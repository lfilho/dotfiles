// Preload for integration tests (`node --import <this file> block.mjs ...`).
//
// Replaces every external boundary of block.mjs with a scenario-driven fake so the real, unmodified
// script runs end to end without touching Keychain, the network, the user's calendar, osascript or
// the wall clock:
//
//   Date          frozen at scenario.now
//   Keychain      scenario.keychain[service] (null/missing = item not found)
//   /bin/date     scenario.osOffset (e.g. "-0700"), else the real binary
//   osascript     recorded, never shown
//   fetch         a fake Google (token + Calendar events) driven by scenario.google
//
// Everything that crosses a boundary is appended as JSONL to $FAKE_LOG for the test to assert on.
// The fake Google is deliberately as strict as the real API where it matters for regressions:
//   - orderBy=startTime without singleEvents=true is a 400 (as in the real API)
//   - the `fields` mask is honored, so a property the script forgets to request comes back missing
//   - recurring series are only expanded into instances when singleEvents=true is requested
import childProcess from "node:child_process";
import { EventEmitter } from "node:events";
import fs from "node:fs";
import { syncBuiltinESMExports } from "node:module";

const scenario = JSON.parse(process.env.FAKE_SCENARIO ?? "{}");
const google = scenario.google ?? {};
const log = (entry) => fs.appendFileSync(process.env.FAKE_LOG, `${JSON.stringify(entry)}\n`);

// --- clock -----------------------------------------------------------------------------------
if (scenario.now) {
  const RealDate = Date;
  const fixed = RealDate.parse(scenario.now);
  globalThis.Date = class extends RealDate {
    constructor(...args) {
      if (args.length) super(...args);
      else super(fixed);
    }
    static now() {
      return fixed;
    }
  };
}

// --- Keychain, /bin/date, osascript ----------------------------------------------------------
const realExecFileSync = childProcess.execFileSync;
const realSpawn = childProcess.spawn;

childProcess.execFileSync = (file, args = [], opts) => {
  if (file === "/usr/bin/security") {
    const service = args[args.indexOf("-s") + 1];
    log({ type: "keychain", service }); // never log the secret itself
    const item = scenario.keychain?.[service];
    if (item == null) throw Object.assign(new Error("The specified item could not be found in the keychain."), { status: 44 });
    return `${typeof item === "string" ? item : JSON.stringify(item)}\n`;
  }
  if (file === "/bin/date" && scenario.osOffset !== undefined) return `${scenario.osOffset}\n`;
  return realExecFileSync(file, args, opts);
};

childProcess.spawn = (file, args, opts) => {
  if (file === "osascript") {
    log({ type: "osascript", script: args[1] });
    return new EventEmitter();
  }
  return realSpawn(file, args, opts);
};
syncBuiltinESMExports(); // block.mjs imports these by name, so refresh the ESM bindings

// --- fake Google -----------------------------------------------------------------------------
const json = (status, body) =>
  new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

// Applies a Google-style `fields` mask ("a,b(c,d(e))") to a response body.
function parseMask(mask) {
  const tree = {};
  let depth = 0;
  let cur = "";
  const flush = () => {
    if (!cur) return;
    const open = cur.indexOf("(");
    if (open < 0) tree[cur] = true;
    else tree[cur.slice(0, open)] = parseMask(cur.slice(open + 1, -1));
    cur = "";
  };
  for (const ch of mask) {
    if (ch === "(") depth++;
    if (ch === ")") depth--;
    if (ch === "," && depth === 0) flush();
    else cur += ch;
  }
  flush();
  return tree;
}

function pick(value, tree) {
  if (Array.isArray(value)) return value.map((v) => pick(v, tree));
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(tree)
      .filter(([key]) => key in value)
      .map(([key, sub]) => [key, sub === true ? value[key] : pick(value[key], sub)]),
  );
}

// Event start/end -> epoch ms (all-day events are local midnights, like the real calendar's day).
function toMs(t) {
  if (t.dateTime) return Date.parse(t.dateTime);
  const [y, m, d] = t.date.split("-").map(Number);
  return new Date(y, m - 1, d).getTime();
}

const TOKEN = "POST https://oauth2.googleapis.com/token";
const LIST = "GET https://www.googleapis.com/calendar/v3/calendars/primary/events";
const INSERT = "POST https://www.googleapis.com/calendar/v3/calendars/primary/events";

globalThis.fetch = async (input, init = {}) => {
  const url = new URL(String(input));
  const method = init.method ?? "GET";
  const headers = Object.fromEntries(Object.entries(init.headers ?? {}).map(([k, v]) => [k.toLowerCase(), v]));
  const body =
    init.body instanceof URLSearchParams ? Object.fromEntries(init.body) : init.body ? JSON.parse(init.body) : undefined;
  const query = Object.fromEntries(url.searchParams);
  const route = `${method} ${url.origin}${url.pathname}`;
  log({ type: "fetch", method, url: url.origin + url.pathname, query, authorization: headers.authorization, body });

  if (google.networkError) throw new TypeError("fetch failed");

  if (route === TOKEN) {
    const token = google.token ?? { status: 200, body: { access_token: "fake-access-token" } };
    return json(token.status, token.body);
  }

  if (route === LIST) {
    if (google.eventsError) return json(google.eventsError.status, google.eventsError.body);
    const expanded = query.singleEvents === "true";
    if (query.orderBy === "startTime" && !expanded) {
      return json(400, { error: { message: "The requested ordering is not available for the particular query." } });
    }
    const min = Date.parse(query.timeMin);
    const max = Date.parse(query.timeMax);
    // `_only` marks test events that stand in for recurring series: "singleEvents" entries are the
    // expanded instances, "unexpanded" is the series master (old start date) that Google returns
    // instead when the request does not expand recurrences.
    const items = (google.events ?? [])
      .filter((e) => !e._only || (e._only === "singleEvents") === expanded)
      .filter((e) => e._only === "unexpanded" || (toMs(e.end) > min && toMs(e.start) < max))
      .map(({ _only, ...e }) => e)
      .sort((a, b) => toMs(a.start) - toMs(b.start));
    const offset = Number(query.pageToken ?? 0);
    const size = google.pageSize ?? items.length;
    const page = {
      items: items.slice(offset, offset + size),
      nextPageToken: offset + size < items.length ? String(offset + size) : undefined,
    };
    return json(200, query.fields ? pick(page, parseMask(query.fields)) : page);
  }

  if (route === INSERT) {
    const insert = google.insert ?? { status: 200, body: { id: "fake-event" } };
    return json(insert.status, insert.body);
  }

  log({ type: "unexpected-fetch", route });
  return json(404, { error: { message: `unexpected request: ${route}` } });
};
