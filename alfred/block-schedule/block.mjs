#!/usr/bin/env node
// Alfred `block [minutes] <content>`: books the next free slot on the primary
// Google Calendar inside working hours.

import { execFileSync, spawn } from "node:child_process";
import { pathToFileURL } from "node:url";

export const WORK_START_HOUR = 9;
export const WORK_END_HOUR = 17;
export const WORK_DAYS = new Set([1, 2, 3, 4, 5]); // Mon-Fri (Date#getDay)
export const DEFAULT_MINUTES = 30;
export const MAX_MINUTES = (WORK_END_HOUR - WORK_START_HOUR) * 60;
export const SEARCH_DAYS = 30;
const ROUND_MS = 5 * 60_000;

const TOKEN_URL = "https://oauth2.googleapis.com/token";
const EVENTS_URL = "https://www.googleapis.com/calendar/v3/calendars/primary/events";

export class UserError extends Error {}

// "15 do laundry" -> {minutes: 15, content: "do laundry"}; "review pr" -> 30 min.
export function parseInput(query) {
  const text = (query ?? "").trim();
  const m = text.match(/^(\d+)\s+(\S[\s\S]*)$/);
  const minutes = m ? Number(m[1]) : DEFAULT_MINUTES;
  const content = (m ? m[2] : text).trim();
  if (!content) throw new UserError("No block content provided.");
  if (minutes < 1 || minutes > MAX_MINUTES) {
    throw new UserError(`Duration must be between 1 and ${MAX_MINUTES} minutes.`);
  }
  return { minutes, content };
}

// Whether an event should make us treat the time as busy. Declined, tentative
// ("maybe") and unanswered invites are deliberately NOT busy: blocks may go on
// top of them. Free ("transparent") events and working-location markers also
// don't block.
export function isBlocking(event) {
  if (event.status === "cancelled") return false;
  if (event.transparency === "transparent") return false;
  if (event.eventType === "workingLocation") return false;
  const self = (event.attendees ?? []).find((a) => a.self);
  if (self && self.responseStatus !== "accepted") return false;
  return true;
}

// Event start/end -> epoch ms. All-day events use the local calendar day.
function toMs(t) {
  if (t.dateTime) return Date.parse(t.dateTime);
  const [y, mo, d] = t.date.split("-").map(Number);
  return new Date(y, mo - 1, d).getTime();
}

export function busyIntervals(events) {
  return events
    .filter(isBlocking)
    .map((e) => [toMs(e.start), toMs(e.end)])
    .sort((a, b) => a[0] - b[0]);
}

// Earliest [startMs, endMs] of `minutes` that fits inside working hours (local
// time, so DST is handled by Date) and does not overlap any busy interval.
export function findSlot(busy, minutes, now = new Date(), days = SEARCH_DAYS) {
  const need = minutes * 60_000;
  const earliest = Math.ceil(now.getTime() / ROUND_MS) * ROUND_MS;
  for (let i = 0; i <= days; i++) {
    const day = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
    if (!WORK_DAYS.has(day.getDay())) continue;
    const dayEnd = new Date(day.getFullYear(), day.getMonth(), day.getDate(), WORK_END_HOUR).getTime();
    let cursor = Math.max(
      new Date(day.getFullYear(), day.getMonth(), day.getDate(), WORK_START_HOUR).getTime(),
      earliest,
    );
    for (const [bs, be] of busy) {
      if (be <= cursor) continue;
      if (bs >= dayEnd) break;
      if (bs - cursor >= need) break; // gap before this event fits
      cursor = Math.max(cursor, be);
    }
    if (cursor + need <= dayEnd) return [cursor, cursor + need];
  }
  return null;
}

export function formatWhen(ms) {
  return new Date(ms).toLocaleString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  });
}

function keychain(service, account) {
  try {
    return execFileSync("/usr/bin/security", ["find-generic-password", "-a", account, "-s", service, "-w"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return null;
  }
}

function clientCredentials() {
  const id = process.env.NOTE2CAL_GOOGLE_CLIENT_ID;
  const secret = process.env.NOTE2CAL_GOOGLE_CLIENT_SECRET;
  if (id && secret) return { client_id: id, client_secret: secret };
  const raw = keychain("alfred-block-workflow", "google-oauth-client");
  if (!raw) {
    throw new UserError(
      "Google OAuth client id/secret not found (env vars or Keychain item alfred-block-workflow).",
    );
  }
  return JSON.parse(raw);
}

async function accessToken() {
  const raw = keychain("note2cal.nvim", "google-oauth-token");
  if (!raw) throw new UserError("Not signed in to Google. Run :Note2calGoogleLogin in Neovim.");
  const { refresh_token } = JSON.parse(raw);
  if (!refresh_token) throw new UserError("Stored Google token has no refresh token. Run :Note2calGoogleLogin.");
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({ ...clientCredentials(), refresh_token, grant_type: "refresh_token" }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok || !body.access_token) {
    throw new UserError(`Google token refresh failed (${res.status} ${body.error ?? ""}). Run :Note2calGoogleLogin.`);
  }
  return body.access_token;
}

async function api(token, url, init = {}) {
  const res = await fetch(url, {
    ...init,
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json", ...init.headers },
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new UserError(`Google Calendar API ${res.status}: ${body.error?.message ?? "request failed"}`);
  return body;
}

async function listEvents(token, from, to) {
  const items = [];
  let pageToken;
  do {
    const q = new URLSearchParams({
      timeMin: from.toISOString(),
      timeMax: to.toISOString(),
      singleEvents: "true",
      orderBy: "startTime",
      maxResults: "2500",
      fields: "nextPageToken,items(status,transparency,eventType,start,end,attendees(self,responseStatus))",
    });
    if (pageToken) q.set("pageToken", pageToken);
    const page = await api(token, `${EVENTS_URL}?${q}`);
    items.push(...(page.items ?? []));
    pageToken = page.nextPageToken;
  } while (pageToken);
  return items;
}

// Show blocking modal dialog (success)
export function showBlockingAlert(msg) {
  if (process.env.BLOCK_DRY_RUN) {
    console.log(msg);
    return;
  }
  spawn("osascript", [
    "-e",
    `display alert "Block Scheduled" message "${msg.replace(/"/g, '\\"')}" as informational buttons {"OK"} default button "OK"`,
  ], { stdio: "ignore" });
}

// Show blocking modal dialog (error)
export function showErrorAlert(msg) {
  spawn("osascript", [
    "-e",
    `display alert "Error" message "${msg.replace(/"/g, '\\"')}" as critical buttons {"OK"} default button "OK"`,
  ], { stdio: "ignore" });
}

// Node ships its own tzdata, which can lag the OS's: after a zone's rules change, Node and the
// system clock report different UTC offsets for the same zone name. Working hours must follow
// the clock the user sees, so when the two disagree pin a fixed-offset zone taken from the OS.
// Offsets are minutes east of UTC. Etc/GMT zones only exist for whole hours, and their sign is
// inverted (UTC-7 is Etc/GMT+7).
export function pinnedZone(osOffsetMin, nodeOffsetMin) {
  if (osOffsetMin === nodeOffsetMin || osOffsetMin % 60 !== 0) return null;
  return `Etc/GMT${osOffsetMin <= 0 ? "+" : "-"}${Math.abs(osOffsetMin) / 60}`;
}

// env and exec are injectable so tests never touch the real process environment.
export function pinSystemOffset({ now = new Date(), env = process.env, exec = execFileSync } = {}) {
  if (env.TZ) return false; // an explicit TZ wins
  let out;
  try {
    out = exec("/bin/date", ["+%z"], { encoding: "utf8" }).trim();
  } catch {
    return false;
  }
  const m = out.match(/^([+-])(\d{2})(\d{2})$/);
  if (!m) return false;
  const osOffset = (m[1] === "-" ? -1 : 1) * (Number(m[2]) * 60 + Number(m[3]));
  const zone = pinnedZone(osOffset, -now.getTimezoneOffset());
  if (!zone) return false;
  env.TZ = zone;
  return true;
}

export async function main(query) {
  const { minutes, content } = parseInput(query);
  const pinned = pinSystemOffset();
  const now = new Date();
  const token = await accessToken();
  const to = new Date(now.getFullYear(), now.getMonth(), now.getDate() + SEARCH_DAYS + 1);
  const slot = findSlot(busyIntervals(await listEvents(token, now, to)), minutes, now);
  if (!slot) throw new UserError(`No free ${minutes} minute slot in the next ${SEARCH_DAYS} days.`);
  const [start, end] = slot;
  if (!process.env.BLOCK_DRY_RUN) {
    // Etc/GMT+N is a made-up label to Google; the ISO instants below are what matter.
    const timeZone = pinned ? undefined : Intl.DateTimeFormat().resolvedOptions().timeZone;
    await api(token, EVENTS_URL, {
      method: "POST",
      body: JSON.stringify({
        summary: content,
        description: content,
        transparency: "opaque",
        start: { dateTime: new Date(start).toISOString(), timeZone },
        end: { dateTime: new Date(end).toISOString(), timeZone },
      }),
    });
  }
  const result = `${process.env.BLOCK_DRY_RUN ? "[dry run] " : ""}Scheduled for ${formatWhen(start)}`;
  showBlockingAlert(result);
  return ""; // Empty output to Alfred—modal is the notification
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main(process.argv.slice(2).join(" ")).then(
    (msg) => {
      if (msg) console.log(msg);
      process.exit(0);
    },
    (err) => {
      const msg = err instanceof UserError ? err.message : `Unexpected error: ${err.message}`;
      showErrorAlert(msg);
      process.exit(1);
    },
  );
}
