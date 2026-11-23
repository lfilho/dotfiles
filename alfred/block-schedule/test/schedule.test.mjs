// Unit tests for the pure logic in block.mjs: input parsing, which events block time, slot finding,
// and the timezone pinning decision. No network, Keychain or child processes.
import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  DEFAULT_MINUTES,
  MAX_MINUTES,
  SEARCH_DAYS,
  UserError,
  busyIntervals,
  findSlot,
  formatWhen,
  isBlocking,
  parseInput,
  pinSystemOffset,
  pinnedZone,
} from "../block.mjs";
import { MIN, allDay, norm, timed } from "./helpers/run.mjs";

// A fixed zone with DST, so wall-clock expectations are deterministic wherever the tests run.
process.env.TZ = "America/Denver";

// Local (America/Denver) epoch ms. Nov 2026: Mon 23, Tue 24, ... Sat 28, Sun 29, Mon 30.
const L = (month, day, hour = 0, minute = 0, second = 0, ms = 0) =>
  new Date(2026, month - 1, day, hour, minute, second, ms).getTime();

describe("parseInput", () => {
  it("splits a leading duration from the content", () => {
    assert.deepEqual(parseInput("15 do laundry"), { minutes: 15, content: "do laundry" });
  });

  it("defaults the duration when none is given", () => {
    assert.deepEqual(parseInput("review pr"), { minutes: DEFAULT_MINUTES, content: "review pr" });
  });

  it("only treats a number followed by whitespace as a duration", () => {
    assert.deepEqual(parseInput("2fa rollout"), { minutes: DEFAULT_MINUTES, content: "2fa rollout" });
    assert.deepEqual(parseInput("5 3d printing"), { minutes: 5, content: "3d printing" });
  });

  it("trims whitespace and keeps multi-line content", () => {
    assert.deepEqual(parseInput("  20   padded  "), { minutes: 20, content: "padded" });
    assert.deepEqual(parseInput("10 line one\nline two"), { minutes: 10, content: "line one\nline two" });
  });

  for (const empty of ["", "   ", undefined, null]) {
    it(`rejects empty content (${JSON.stringify(empty)})`, () => {
      assert.throws(() => parseInput(empty), (e) => e instanceof UserError && /No block content/.test(e.message));
    });
  }

  it("enforces the duration bounds (1 minute to one working day)", () => {
    assert.equal(MAX_MINUTES, 480);
    assert.deepEqual(parseInput("1 x"), { minutes: 1, content: "x" });
    assert.deepEqual(parseInput(`${MAX_MINUTES} x`), { minutes: MAX_MINUTES, content: "x" });
    for (const bad of ["0 x", `${MAX_MINUTES + 1} x`]) {
      assert.throws(() => parseInput(bad), (e) => e instanceof UserError && /between 1 and 480/.test(e.message));
    }
  });
});

describe("isBlocking", () => {
  const self = (responseStatus) => ({ attendees: [{ self: true, responseStatus }] });
  const cases = [
    ["an ordinary event", {}, true],
    ["an accepted invite", self("accepted"), true],
    ["an event where you are not an attendee (your own)", { attendees: [{ responseStatus: "accepted" }] }, true],
    ["a declined invite", self("declined"), false],
    ["a tentative invite", self("tentative"), false],
    ["an unanswered invite", self("needsAction"), false],
    ["a cancelled event", { status: "cancelled" }, false],
    ["an event marked free (transparent)", { transparency: "transparent" }, false],
    ["a working-location marker", { eventType: "workingLocation" }, false],
  ];
  for (const [name, event, expected] of cases) {
    it(`${expected ? "blocks" : "does not block"} on ${name}`, () => {
      assert.equal(isBlocking(event), expected);
    });
  }
});

describe("busyIntervals", () => {
  it("returns only blocking events, as [start, end] ms sorted by start", () => {
    const events = [
      timed(L(11, 23, 14), L(11, 23, 15)),
      timed(L(11, 23, 9), L(11, 23, 10)),
      timed(L(11, 23, 11), L(11, 23, 12), { status: "cancelled" }),
      timed(L(11, 23, 12), L(11, 23, 13), { attendees: [{ self: true, responseStatus: "declined" }] }),
    ];
    assert.deepEqual(busyIntervals(events), [
      [L(11, 23, 9), L(11, 23, 10)],
      [L(11, 23, 14), L(11, 23, 15)],
    ]);
  });

  it("turns all-day events into the local calendar day(s), end date exclusive", () => {
    assert.deepEqual(busyIntervals([allDay("2026-11-23", "2026-11-25")]), [[L(11, 23), L(11, 25)]]);
  });
});

describe("findSlot", () => {
  const slot = (busy, minutes, now, days) => findSlot(busy, minutes, new Date(now), days);

  describe("starting point", () => {
    it("rounds now UP to the next 5 minutes, never down and never to the next hour", () => {
      assert.deepEqual(slot([], 60, L(11, 23, 15, 26)), [L(11, 23, 15, 30), L(11, 23, 16, 30)]);
      assert.deepEqual(slot([], 30, L(11, 23, 15, 31)), [L(11, 23, 15, 35), L(11, 23, 16, 5)]);
    });

    it("keeps an exact 5-minute mark, but rounds up past it by even one millisecond", () => {
      assert.equal(slot([], 30, L(11, 23, 15, 30))[0], L(11, 23, 15, 30));
      assert.equal(slot([], 30, L(11, 23, 15, 30, 0, 1))[0], L(11, 23, 15, 35));
    });

    it("uses the rest of today when there is room (never skips ahead to tomorrow)", () => {
      assert.equal(slot([], 60, L(11, 23, 14, 3))[0], L(11, 23, 14, 5));
    });

    it("waits for 9:00 when now is before working hours", () => {
      assert.equal(slot([], 30, L(11, 23, 7, 12))[0], L(11, 23, 9));
    });
  });

  describe("working hours", () => {
    it("rolls to the next workday at 9:00 after 17:00", () => {
      assert.equal(slot([], 30, L(11, 23, 17, 1))[0], L(11, 24, 9));
    });

    it("skips weekends", () => {
      assert.equal(slot([], 30, L(11, 27, 17, 30))[0], L(11, 30, 9)); // Fri evening
      assert.equal(slot([], 30, L(11, 28, 10))[0], L(11, 30, 9)); // Saturday
      assert.equal(slot([], 30, L(11, 29, 10))[0], L(11, 30, 9)); // Sunday
    });

    it("allows a block that ends exactly at 17:00 but not one minute later", () => {
      assert.deepEqual(slot([], 60, L(11, 23, 16)), [L(11, 23, 16), L(11, 23, 17)]);
      assert.equal(slot([], 61, L(11, 23, 16))[0], L(11, 24, 9));
    });

    it("follows local wall-clock time across DST changes", () => {
      // Fri 6 Mar 2026 (MST, UTC-7) -> Mon 9 Mar (MDT, UTC-6): DST began on Sunday.
      assert.equal(slot([], 30, L(3, 6, 17, 30))[0], Date.UTC(2026, 2, 9, 15, 0));
      // Fri 30 Oct 2026 (MDT, UTC-6) -> Mon 2 Nov (MST, UTC-7): DST ended on Sunday.
      assert.equal(slot([], 30, L(10, 30, 18))[0], Date.UTC(2026, 10, 2, 16, 0));
    });
  });

  describe("around busy time", () => {
    it("ignores meetings that already ended", () => {
      assert.equal(slot([[L(11, 23, 14), L(11, 23, 15)]], 60, L(11, 23, 15, 26))[0], L(11, 23, 15, 30));
    });

    it("starts right after a meeting that is in progress", () => {
      assert.equal(slot([[L(11, 23, 14), L(11, 23, 16)]], 60, L(11, 23, 15, 26))[0], L(11, 23, 16));
    });

    it("uses a gap that exactly fits, and skips one that is a minute short", () => {
      const busy = [[L(11, 23, 9), L(11, 23, 10)], [L(11, 23, 11), L(11, 23, 12)]];
      assert.equal(slot(busy, 60, L(11, 23, 8))[0], L(11, 23, 10));
      assert.equal(slot(busy, 61, L(11, 23, 8))[0], L(11, 23, 12));
    });

    it("steps over back-to-back meetings", () => {
      const busy = [[L(11, 23, 9), L(11, 23, 10)], [L(11, 23, 10), L(11, 23, 11)]];
      assert.equal(slot(busy, 30, L(11, 23, 8))[0], L(11, 23, 11));
    });

    it("never lands inside overlapping meetings", () => {
      const busy = [[L(11, 23, 9), L(11, 23, 10, 30)], [L(11, 23, 10), L(11, 23, 11)]];
      assert.equal(slot(busy, 30, L(11, 23, 8))[0], L(11, 23, 11));
    });

    it("never lands inside a meeting nested in a longer one", () => {
      const busy = [[L(11, 23, 9), L(11, 23, 12)], [L(11, 23, 10), L(11, 23, 11)]];
      assert.equal(slot(busy, 30, L(11, 23, 8))[0], L(11, 23, 12));
    });

    it("respects a meeting that started before working hours", () => {
      assert.equal(slot([[L(11, 23, 8), L(11, 23, 9, 30)]], 30, L(11, 23, 7))[0], L(11, 23, 9, 30));
    });

    it("moves to tomorrow when the remaining gap today is too small", () => {
      assert.equal(slot([[L(11, 23, 16, 15), L(11, 23, 18)]], 30, L(11, 23, 16))[0], L(11, 24, 9));
    });

    it("steps over a multi-day event (out of office)", () => {
      const busy = [[L(11, 23, 9), L(11, 26, 9)]];
      assert.equal(slot(busy, 30, L(11, 23, 12))[0], L(11, 26, 9));
    });
  });

  describe("when nothing fits", () => {
    it("returns null if the search window is fully booked", () => {
      assert.equal(slot([[L(11, 1), L(12, 31)]], 30, L(11, 23, 12)), null);
    });

    it("only looks as many days ahead as asked", () => {
      const busy = [[L(11, 23, 9), L(11, 25, 9)]];
      assert.equal(slot(busy, 30, L(11, 23, 12), 1), null); // Mon+Tue booked, Wed is day 2
      assert.equal(slot(busy, 30, L(11, 23, 12), 2)[0], L(11, 25, 9));
      assert.equal(SEARCH_DAYS, 30);
    });
  });

  // An independent, deliberately naive oracle: walk every 5-minute candidate from `now` and take the
  // first one that is a weekday, inside 9-17 local, and overlaps nothing. If findSlot ever disagrees
  // (a rewrite that books inside a meeting, rounds the wrong way, skips today...), this fails.
  function bruteForce(busy, minutes, now, days = SEARCH_DAYS) {
    const need = minutes * MIN;
    const step = 5 * MIN;
    const horizon = new Date(now.getFullYear(), now.getMonth(), now.getDate() + days + 1).getTime();
    for (let c = Math.ceil(now.getTime() / step) * step; c < horizon; c += step) {
      const d = new Date(c);
      if (d.getDay() === 0 || d.getDay() === 6) continue;
      const dayStart = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 9).getTime();
      const dayEnd = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 17).getTime();
      if (c < dayStart || c + need > dayEnd) continue;
      if (busy.some(([s, e]) => s < c + need && e > c)) continue;
      return [c, c + need];
    }
    return null;
  }

  it("agrees with a brute-force oracle across a week of 'now' values, durations and a messy calendar", () => {
    const busy = [
      [L(11, 23, 9), L(11, 23, 10)],
      [L(11, 23, 10, 30), L(11, 23, 11, 30)],
      [L(11, 23, 13), L(11, 23, 14)],
      [L(11, 23, 15, 30), L(11, 23, 16, 15)],
      [L(11, 24, 9), L(11, 24, 12)],
      [L(11, 24, 10), L(11, 24, 11)], // nested
      [L(11, 24, 14), L(11, 24, 17)],
      [L(11, 25, 8), L(11, 25, 18)], // all day
      [L(11, 26, 9), L(11, 26, 9, 30)],
      [L(11, 26, 9, 30), L(11, 26, 10)], // back to back
      [L(11, 26, 12), L(11, 26, 13)],
      [L(11, 27, 16), L(11, 27, 16, 40)],
      [L(11, 30, 9), L(12, 2, 17)], // out of office
    ].sort((a, b) => a[0] - b[0]);

    let checked = 0;
    for (let now = L(11, 23); now <= L(11, 28, 23, 59); now += 13 * MIN) {
      for (const minutes of [5, 30, 60, 120, 480]) {
        assert.deepEqual(
          slot(busy, minutes, now),
          bruteForce(busy, minutes, new Date(now)),
          `${new Date(now).toString()} / ${minutes} min`,
        );
        checked++;
      }
    }
    assert.ok(checked > 3000);
  });
});

describe("formatWhen", () => {
  it("renders weekday, date and 12-hour time in en-US", () => {
    assert.equal(norm(formatWhen(L(11, 23, 15, 40))), "Mon, Nov 23, 3:40 PM");
    assert.equal(norm(formatWhen(L(11, 24, 9))), "Tue, Nov 24, 9:00 AM");
  });
});

describe("pinnedZone", () => {
  it("pins a fixed-offset zone only when the OS and Node disagree on whole hours", () => {
    assert.equal(pinnedZone(-420, -480), "Etc/GMT+7"); // OS -07:00, Node's stale data says -08:00
    assert.equal(pinnedZone(60, 0), "Etc/GMT-1"); // east of UTC: the Etc sign is inverted
    assert.equal(pinnedZone(0, 60), "Etc/GMT+0");
    assert.equal(pinnedZone(-420, -420), null); // agree: leave Node (and its DST handling) alone
    assert.equal(pinnedZone(330, 300), null); // +05:30 has no Etc zone: do not guess
  });
});

describe("pinSystemOffset", () => {
  const now = new Date(L(11, 23, 12)); // Node (TZ=America/Denver) says -07:00 here
  function run(osOutput, env = {}) {
    const calls = [];
    const pinned = pinSystemOffset({
      now,
      env,
      exec: (...args) => {
        calls.push(args);
        if (osOutput instanceof Error) throw osOutput;
        return `${osOutput}\n`;
      },
    });
    return { pinned, env, calls };
  }

  it("pins the OS offset into TZ when Node's timezone data disagrees with the OS", () => {
    const { pinned, env, calls } = run("-0800");
    assert.equal(pinned, true);
    assert.equal(env.TZ, "Etc/GMT+8");
    assert.deepEqual(calls[0].slice(0, 2), ["/bin/date", ["+%z"]]);
  });

  it("does nothing when they agree", () => {
    const { pinned, env } = run("-0700");
    assert.equal(pinned, false);
    assert.equal(env.TZ, undefined);
  });

  it("never overrides an explicit TZ, and does not even ask the OS", () => {
    const { pinned, env, calls } = run("-0800", { TZ: "Asia/Tokyo" });
    assert.equal(pinned, false);
    assert.equal(env.TZ, "Asia/Tokyo");
    assert.equal(calls.length, 0);
  });

  it("leaves things alone when the OS offset cannot be expressed or read", () => {
    for (const output of ["+0530", "banana", "", "-07:00", new Error("date not found")]) {
      const { pinned, env } = run(output);
      assert.equal(pinned, false, String(output));
      assert.equal(env.TZ, undefined, String(output));
    }
  });
});
