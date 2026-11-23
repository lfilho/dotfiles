# block-schedule (Alfred workflow)

`block [minutes] <content>` books the next free slot on your primary Google Calendar, inside working
hours (Mon-Fri, 9:00-17:00 local). Examples: `block 60 new oncall config`, `block review pr` (30 min).

- The slot starts at the next 5 minutes (rounded up), today if there is room.
- Declined, tentative and unanswered invites, free-time events and working-location markers do not block.
- Success shows a "Block Scheduled" dialog; every failure shows an "Error" dialog.

## Layout

| Path | What |
|---|---|
| `block.mjs` | The script Alfred runs. Source of truth. |
| `info.plist` | The Alfred workflow definition. Source of truth. |
| `icon.svg` | Source of the workflow icon. |
| `icon.png` | The 512px icon Alfred shows; rendered from `icon.svg` and committed (see "Changing it"). |
| `../block-schedule.alfredworkflow` | **Build artifact.** Do not edit; produced by `build.sh`. |
| `build.sh` | Tests, then packages the workflow. |
| `test/` | Tests (see below). |

Credentials: the OAuth client lives in the Keychain item `alfred-block-workflow` (or the env vars
`NOTE2CAL_GOOGLE_CLIENT_ID` / `NOTE2CAL_GOOGLE_CLIENT_SECRET`); the refresh token is shared with
`note2cal.nvim` (sign in with `:Note2calGoogleLogin` in Neovim).

## Changing it

1. Edit `block.mjs` / `info.plist` **here**, not inside Alfred and not in a temp copy.
2. `npm test` (or `node --test test/*.test.mjs`) while you work.
3. `./build.sh` to rebuild `../block-schedule.alfredworkflow`, then double-click it to re-import.

Re-importing updates the installed workflow in place (the bundle id is stable). If you change the
workflow in Alfred's UI, copy the result back into `info.plist`, or it will be overwritten.

The icon is plain flat SVG. After editing `icon.svg`, regenerate the committed PNG (needs Inkscape, which
`build.sh` deliberately does not):

```sh
inkscape icon.svg --export-type=png --export-filename=icon.png --export-width=512 --export-height=512
```

## Tests

Plain `node:test`, no dependencies. Node 20+.

| File | Covers |
|---|---|
| `test/schedule.test.mjs` | Unit: input parsing, which events block, slot finding (rounding, working hours, weekends, DST, overlaps) including a differential test against a brute-force oracle, timezone pinning. |
| `test/cli.test.mjs` | Integration: runs the real `node block.mjs "<query>"` against a fake Keychain/Google/osascript/clock and asserts on the event created, the dialog shown, and the requests made. |
| `test/workflow.test.mjs` | The plist graph (keyword is wired to the script), the packaged `.alfredworkflow` matches the source and parses, and the plist's script string runs under Alfred-like conditions (macOS only). |
| `test/helpers/fake-env.mjs` | The fake environment, loaded with `node --import`. Its fake Google is as strict as the real API where it matters: it rejects `orderBy=startTime` without `singleEvents=true`, honors the `fields` mask, and only expands recurring events when asked. |

When you add a feature:

- **New event property** you read (e.g. `location`): add it to the `fields` mask in `listEvents` *and*
  to a fixture. The fake only returns requested fields, so forgetting the mask fails the test instead
  of silently breaking on the real API.
- **New Alfred object**: connect it in `info.plist`; `workflow.test.mjs` fails on orphaned objects.
- **New external call**: add its route to `fake-env.mjs` (unknown routes 404 and are logged).

### Gotchas worth knowing

- **Node's timezone data can lag the OS's.** `block.mjs` pins a fixed offset from `/bin/date` when
  the two disagree (`pinSystemOffset`). Without it, working hours silently shift by an hour.
- **Keep the `fields` mask in sync** with what the code reads, as above.
