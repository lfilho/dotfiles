// Shared test helpers: time builders, event builders, and a runner that executes the real block.mjs
// as a child process (the way Alfred does) against the fake environment in fake-env.mjs.
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
export const SOURCE_DIR = join(here, "..", "..");
export const BLOCK_MJS = join(SOURCE_DIR, "block.mjs");
export const PRELOAD_URL = pathToFileURL(join(here, "fake-env.mjs")).href;

export const MIN = 60_000;

// Epoch ms of a wall-clock time in a fixed UTC offset (minutes east of UTC), e.g. at(-420, 2026, 11, 23, 15, 37).
export const at = (offsetMin, year, month, day, hour = 0, minute = 0) =>
  Date.UTC(year, month - 1, day, hour, minute) - offsetMin * MIN;

// "+HHMM" / "-HHMM", the format of `date +%z`.
export const formatOffset = (offsetMin) => {
  const abs = Math.abs(offsetMin);
  const sign = offsetMin < 0 ? "-" : "+";
  return `${sign}${String(Math.floor(abs / 60)).padStart(2, "0")}${String(abs % 60).padStart(2, "0")}`;
};

// Google Calendar event resources.
export const timed = (startMs, endMs, extra = {}) => ({
  start: { dateTime: new Date(startMs).toISOString() },
  end: { dateTime: new Date(endMs).toISOString() },
  ...extra,
});
export const allDay = (startDate, endDate, extra = {}) => ({
  start: { date: startDate },
  end: { date: endDate },
  ...extra,
});

// Collapse every whitespace flavor (ICU uses U+202F before AM/PM) so assertions are stable across Node/ICU versions.
export const norm = (s) => s.replace(/\s/g, " ");

const DEFAULT_KEYCHAIN = {
  "alfred-block-workflow": { client_id: "test-client-id", client_secret: "test-client-secret" },
  "note2cal.nvim": { refresh_token: "test-refresh-token" },
};

// A complete fake environment. Pass `keychain: { "note2cal.nvim": null }` to remove an item.
export function scenario({ now, osOffset, keychain = {}, google = {} } = {}) {
  return {
    now: now === undefined ? undefined : new Date(now).toISOString(),
    osOffset,
    keychain: { ...DEFAULT_KEYCHAIN, ...keychain },
    google,
  };
}

// `display alert "T" message "M" as KIND buttons ...` -> { title, message, kind }
function parseAlert(script) {
  const m = script.match(/^display alert "([^"]*)" message "(.*)" as (\w+) buttons/s);
  if (!m) throw new Error(`unrecognized osascript: ${script}`);
  return { title: m[1], message: m[2].replace(/\\"/g, '"'), kind: m[3] };
}

/**
 * Runs `node block.mjs <query>` with the fake environment.
 * tz: value for TZ in the child ("America/Denver" by default); null leaves it unset.
 * Returns { code, stdout, stderr, log, fetches, posts, alerts }.
 */
export function runBlock(query, sc, { dryRun = false, tz = "America/Denver", env = {} } = {}) {
  const dir = mkdtempSync(join(tmpdir(), "block-test-"));
  const logFile = join(dir, "log.jsonl");
  try {
    const childEnv = { PATH: process.env.PATH, HOME: dir, FAKE_SCENARIO: JSON.stringify(sc), FAKE_LOG: logFile, ...env };
    if (tz) childEnv.TZ = tz;
    if (dryRun) childEnv.BLOCK_DRY_RUN = "1";
    const r = spawnSync(process.execPath, ["--import", PRELOAD_URL, BLOCK_MJS, query], {
      env: childEnv,
      encoding: "utf8",
      timeout: 20_000,
    });
    return summarize(r, logFile);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

export function summarize(r, logFile) {
  const log = existsSync(logFile)
    ? readFileSync(logFile, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l))
    : [];
  const fetches = log.filter((e) => e.type === "fetch");
  return {
    code: r.status,
    stdout: r.stdout,
    stderr: r.stderr,
    log,
    fetches,
    gets: fetches.filter((f) => f.method === "GET"),
    posts: fetches.filter((f) => f.method === "POST" && f.url.endsWith("/events")),
    alerts: log.filter((e) => e.type === "osascript").map((e) => parseAlert(e.script)),
  };
}
