// Integration tests: run the real `node block.mjs "<query>"` the way Alfred does, against the fake
// Keychain / Google / osascript / clock from helpers/fake-env.mjs, and assert on what the user would
// see (the alert), what would land on the calendar (the POST) and what we asked Google for.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { describe, it } from "node:test";
import { MIN, allDay, at, formatOffset, norm, runBlock, scenario, timed } from "./helpers/run.mjs";

const MST = -420; // America/Denver in November, the zone these scenarios run in
const day = (d, h, m = 0) => at(MST, 2026, 11, d, h, m);
const NOW = day(23, 15, 37); // Monday 3:37 PM

// A scenario where it is Monday 3:37 PM, with the given fake-Google behavior.
const monday = (google = {}, rest = {}) => scenario({ now: NOW, google, ...rest });

function booking(r) {
  assert.equal(r.code, 0, `exit ${r.code}\n${r.stderr}\n${JSON.stringify(r.alerts)}`);
  assert.equal(r.posts.length, 1, "expected exactly one event to be created");
  const { start, end, ...rest } = r.posts[0].body;
  return { start: Date.parse(start.dateTime), end: Date.parse(end.dateTime), startZone: start.timeZone, ...rest };
}

describe("booking a block", () => {
  it("creates the event in the next free slot, rounded up to 5 minutes, and tells the user", () => {
    const r = runBlock("60 new oncall config", monday());
    const b = booking(r);

    assert.equal(b.start, day(23, 15, 40)); // 3:37 -> 3:40, today
    assert.equal(b.end, day(23, 16, 40));
    assert.equal(b.summary, "new oncall config");
    assert.equal(b.description, "new oncall config");
    assert.equal(b.transparency, "opaque");
    assert.equal(b.startZone, "America/Denver");

    assert.equal(r.alerts.length, 1);
    assert.equal(r.alerts[0].title, "Block Scheduled");
    assert.equal(r.alerts[0].kind, "informational");
    assert.equal(norm(r.alerts[0].message), "Scheduled for Mon, Nov 23, 3:40 PM");
    assert.equal(r.stdout.trim(), "", "success is reported by the dialog, not Alfred's notification text");
  });

  it("defaults to 30 minutes when no duration is given", () => {
    const b = booking(runBlock("review pr", monday()));
    assert.equal(b.end - b.start, 30 * MIN);
    assert.equal(b.summary, "review pr");
  });

  it("with BLOCK_DRY_RUN reports the slot but creates nothing and shows no dialog", () => {
    const r = runBlock("60 anything", monday(), { dryRun: true });
    assert.equal(r.code, 0);
    assert.equal(r.posts.length, 0);
    assert.equal(r.alerts.length, 0);
    assert.equal(norm(r.stdout.trim()), "[dry run] Scheduled for Mon, Nov 23, 3:40 PM");
  });
});

describe("what counts as busy", () => {
  it("books right after a meeting that overlaps the start of the search", () => {
    const b = booking(runBlock("30 x", monday({ events: [timed(day(23, 15, 40), day(23, 16, 15))] })));
    assert.equal(b.start, day(23, 16, 15));
  });

  it("moves to tomorrow 9:00 when the rest of today is too small", () => {
    const b = booking(runBlock("60 x", monday({ events: [timed(day(23, 15, 40), day(23, 16, 15))] })));
    assert.equal(b.start, day(24, 9)); // only 45 minutes left after the meeting
  });

  it("expands recurring meetings, so a weekly series blocks its instance (not just its first date)", () => {
    const events = [
      timed(day(23, 15, 30), day(23, 17)), // today is full
      { ...timed(day(24, 9), day(24, 10)), _only: "singleEvents" }, // this week's instance of the weekly meeting
      { ...timed(at(MST, 2025, 1, 6, 9), at(MST, 2025, 1, 6, 10)), _only: "unexpanded" }, // the series master
    ];
    const r = runBlock("60 x", monday({ events }));
    assert.equal(booking(r).start, day(24, 10));
    assert.equal(r.gets[0].query.singleEvents, "true");
    assert.equal(r.gets[0].query.orderBy, "startTime");
  });

  for (const status of ["declined", "tentative", "needsAction"]) {
    it(`does not treat a ${status} invite as busy`, () => {
      const events = [timed(day(23, 15, 40), day(23, 17), { attendees: [{ self: true, responseStatus: status }] })];
      assert.equal(booking(runBlock("60 x", monday({ events }))).start, day(23, 15, 40));
    });
  }

  it("treats an accepted invite as busy", () => {
    const events = [timed(day(23, 15, 40), day(23, 17), { attendees: [{ self: true, responseStatus: "accepted" }] })];
    assert.equal(booking(runBlock("60 x", monday({ events }))).start, day(24, 9));
  });

  for (const [name, extra] of [
    ["free (transparent)", { transparency: "transparent" }],
    ["a working-location marker", { eventType: "workingLocation" }],
    ["cancelled", { status: "cancelled" }],
  ]) {
    it(`does not treat an event that is ${name} as busy`, () => {
      const events = [timed(day(23, 15, 40), day(23, 17), extra)];
      assert.equal(booking(runBlock("60 x", monday({ events }))).start, day(23, 15, 40));
    });
  }

  it("treats an all-day event as busy for the whole day, unless it is marked free", () => {
    const blocked = runBlock("30 x", monday({ events: [allDay("2026-11-23", "2026-11-24")] }));
    assert.equal(booking(blocked).start, day(24, 9));

    const free = runBlock("30 x", monday({ events: [allDay("2026-11-23", "2026-11-24", { transparency: "transparent" })] }));
    assert.equal(booking(free).start, day(23, 15, 40));
  });

  it("reads every page of results", () => {
    const events = [timed(day(23, 15, 40), day(23, 16)), timed(day(23, 16), day(23, 16, 20))];
    const r = runBlock("30 x", monday({ events, pageSize: 1 }));
    assert.equal(booking(r).start, day(23, 16, 20)); // the second meeting is on page two
    assert.equal(r.gets.length, 2);
    assert.equal(r.gets[1].query.pageToken, "1");
  });
});

describe("talking to Google", () => {
  it("refreshes the access token from the Keychain credentials and uses it for every call", () => {
    const r = runBlock("30 x", monday());
    const token = r.fetches.find((f) => f.url === "https://oauth2.googleapis.com/token");
    assert.deepEqual(token.body, {
      client_id: "test-client-id",
      client_secret: "test-client-secret",
      refresh_token: "test-refresh-token",
      grant_type: "refresh_token",
    });
    const calendarCalls = r.fetches.filter((f) => f.url.includes("/calendar/"));
    assert.ok(calendarCalls.length >= 2);
    for (const call of calendarCalls) assert.equal(call.authorization, "Bearer fake-access-token");
    assert.deepEqual(
      r.log.filter((e) => e.type === "keychain").map((e) => e.service).sort(),
      ["alfred-block-workflow", "note2cal.nvim"],
    );
  });

  it("searches the calendar from now on, one month ahead", () => {
    const { query } = runBlock("30 x", monday()).gets[0];
    assert.equal(Date.parse(query.timeMin), NOW);
    assert.equal(Date.parse(query.timeMax), at(MST, 2026, 12, 24)); // midnight after day 30
  });

  it("prefers client credentials from the environment over the Keychain", () => {
    const r = runBlock("30 x", monday({}, { keychain: { "alfred-block-workflow": null } }), {
      env: { NOTE2CAL_GOOGLE_CLIENT_ID: "env-id", NOTE2CAL_GOOGLE_CLIENT_SECRET: "env-secret" },
    });
    assert.equal(booking(r).summary, "x");
    const token = r.fetches.find((f) => f.url.includes("oauth2"));
    assert.equal(token.body.client_id, "env-id");
    assert.equal(token.body.client_secret, "env-secret");
    assert.ok(!r.log.some((e) => e.type === "keychain" && e.service === "alfred-block-workflow"));
  });
});

describe("failures are never silent", () => {
  // Every failure must end as exactly one critical dialog with a useful message and a non-zero exit.
  // A script that dies without telling the user is what made this workflow look "broken for no reason".
  const failures = [
    ["empty content", "", monday(), /No block content provided/, { fetches: 0 }],
    ["duration of zero", "0 x", monday(), /Duration must be between 1 and 480 minutes/, { fetches: 0 }],
    ["duration over a working day", "481 x", monday(), /Duration must be between 1 and 480 minutes/, { fetches: 0 }],
    ["not signed in to Google", "30 x", monday({}, { keychain: { "note2cal.nvim": null } }), /Not signed in to Google.*Note2calGoogleLogin/],
    ["stored token without a refresh token", "30 x", monday({}, { keychain: { "note2cal.nvim": {} } }), /no refresh token/],
    ["missing OAuth client", "30 x", monday({}, { keychain: { "alfred-block-workflow": null } }), /OAuth client id\/secret not found/],
    [
      "token refresh rejected",
      "30 x",
      monday({ token: { status: 400, body: { error: "invalid_grant" } } }),
      /Google token refresh failed \(400 invalid_grant\)/,
    ],
    ["token response without an access token", "30 x", monday({ token: { status: 200, body: {} } }), /Google token refresh failed/],
    [
      "calendar API error",
      "30 x",
      monday({ eventsError: { status: 403, body: { error: { message: "Insufficient Permission" } } } }),
      /Google Calendar API 403: Insufficient Permission/,
    ],
    [
      "event creation rejected",
      "30 x",
      monday({ insert: { status: 500, body: { error: { message: "Backend Error" } } } }),
      /Google Calendar API 500: Backend Error/,
      { posts: 1 },
    ],
    ["network failure", "30 x", monday({ networkError: true }), /Unexpected error: fetch failed/],
    [
      "no free slot within 30 days",
      "60 x",
      monday({ events: [allDay("2026-11-23", "2027-01-31")] }),
      /No free 60 minute slot in the next 30 days/,
    ],
  ];

  for (const [name, query, sc, message, expect = {}] of failures) {
    it(`${name}: one critical dialog, exit 1, nothing reported as scheduled`, () => {
      const r = runBlock(query, sc);
      assert.equal(r.code, 1, r.stderr);
      assert.equal(r.alerts.length, 1, JSON.stringify(r.alerts));
      assert.equal(r.alerts[0].title, "Error");
      assert.equal(r.alerts[0].kind, "critical");
      assert.match(r.alerts[0].message, message);
      assert.equal(r.stdout.trim(), "");
      if (expect.fetches !== undefined) assert.equal(r.fetches.length, expect.fetches);
      if (expect.posts !== undefined) assert.equal(r.posts.length, expect.posts);
      else assert.equal(r.posts.length, 0);
    });
  }
});

describe("timezone: working hours follow the OS clock, not Node's possibly stale tzdata", () => {
  // What Node thinks the host offset is at `ms` (TZ unset, so this is the host/ICU data).
  function hostOffset(ms) {
    const env = { ...process.env };
    delete env.TZ;
    // Not "-new Date(...)": a leading "-" makes node parse the expression as a CLI flag.
    const out = spawnSync(process.execPath, ["-p", `0 - new Date(${ms}).getTimezoneOffset()`], { env, encoding: "utf8" });
    const offset = Number(out.stdout);
    assert.ok(Number.isFinite(offset), `could not read the host offset: ${out.stderr}`);
    return offset;
  }

  it("pins to the OS offset when Node disagrees with it", (t) => {
    const host = hostOffset(NOW);
    if (host % 60 !== 0) return t.skip("host offset is not a whole number of hours");
    const os = host - 60; // pretend the OS says an hour behind what Node's data says
    const now = at(os, 2026, 11, 23, 16, 50); // Monday 16:50 by the OS clock

    const r = runBlock("30 x", scenario({ now, osOffset: formatOffset(os) }), { tz: null });
    const b = booking(r);

    // 16:50 + 30 min does not fit before 17:00 OS time, so: tomorrow 9:00 OS time. Using Node's zone
    // would instead have given 9:00 an hour earlier by the OS clock.
    assert.equal(b.start, at(os, 2026, 11, 24, 9));
    assert.equal(b.startZone, undefined, "a made-up Etc/GMT zone must not be sent to Google as the event's zone");
  });

  it("leaves Node's own zone (and label) alone when the OS agrees", () => {
    const host = hostOffset(NOW);
    const now = at(host, 2026, 11, 23, 11, 3);
    const r = runBlock("30 x", scenario({ now, osOffset: formatOffset(host) }), { tz: null });
    const b = booking(r);
    assert.equal(b.start, at(host, 2026, 11, 23, 11, 5));
    assert.equal(typeof b.startZone, "string");
  });

  it("never overrides an explicit TZ", () => {
    const now = day(23, 16, 50);
    const r = runBlock("30 x", scenario({ now, osOffset: "-0800" }), { tz: "America/Denver" });
    const b = booking(r);
    assert.equal(b.start, day(24, 9)); // by Denver's clock, not the pretend -08:00 OS
    assert.equal(b.startZone, "America/Denver");
  });
});
