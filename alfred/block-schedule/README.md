# block-schedule (Alfred workflow)

`block [minutes] <content>` books the next free slot on your primary Google Calendar, inside working
hours (Mon-Fri, 9:00-17:00 local). Examples: `block 60 new oncall config`, `block review pr` (30 min).

- The slot starts at the next 5 minutes (rounded up), today if there is room.
- Declined, tentative and unanswered invites, free-time events and working-location markers do not block.
- Success shows a "Block Scheduled" dialog; every failure shows an "Error" dialog.

## Setup from scratch

Do this once per Mac. Alfred runs `block.mjs`, which reads two Keychain items and talks to the Google Calendar API:

| Keychain item (service / account) | Holds | Created by |
|---|---|---|
| `alfred-block-workflow` / `google-oauth-client` | Your Google OAuth client id + secret as JSON | You, in step 2 |
| `note2cal.nvim` / `google-oauth-token` | The signed-in refresh token | note2cal.nvim's login, in step 3 |

Checked on 2026-11-23: Google's and Alfred's docs were read, and the Keychain, Node PATH and dry-run commands below were run on macOS with Node 26 (the Keychain snippet against a throwaway item). Not re-run: the Google Cloud Console clicks from a blank account, the Neovim login, and the Alfred import. Google renames console pages often, so each step links to Google's own guide too.

### Before you start

| Need | Why / how to check |
|---|---|
| Alfred with the **Powerpack** | Workflows are a [Powerpack feature](https://www.alfredapp.com/help/workflows/). |
| **Node.js 20+** in `/opt/homebrew/bin` or `/usr/local/bin` (`brew install node`) | The workflow runs `export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; node block.mjs "{query}"`, so a Node from nvm, fnm, mise or asdf is not found. Check: `zsh -c 'export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin; command -v node && node --version'`. Developed on Node 26; 20 is only what `package.json` declares. |
| **Neovim with note2cal.nvim** | It does the Google login and stores the refresh token; this workflow has no login of its own. It is already in this repo's Neovim config (`nvim-user-config/lua/plugins/user.lua`, `provider = "google"`, `security = "os-key-store"`). |
| A **Google account** | The one whose primary calendar gets the blocks. |

### 1. Create the Google OAuth client

Google's guides: [Manage OAuth clients](https://support.google.com/cloud/answer/15549257), [Personal mode](https://support.google.com/cloud/answer/15544987#personal-mode-onboarding).

Choose the audience first; it decides whether the token silently dies later:

| Audience | Use when | Catch |
|---|---|---|
| **Personal** (recommended) | It is only for you. | Only the account that created the app can authorize it (anyone else gets `client_user_mismatch`). It cannot be switched to External or Internal later; make a new project if you ever share it. No app verification, no "unverified app" screen, no 7-day token expiry ([Google](https://support.google.com/cloud/answer/15549945#user-type-personal)). |
| External, **In production** | Personal mode is not available to you. | Sign-in shows Google's "unverified app" warning (expected for your own app). This is what [note2cal's guide](https://github.com/lfilho/note2cal.nvim/blob/main/docs/google-calendar-setup.md) uses. |
| External, **Testing** | Avoid. | Google expires the refresh token after 7 days, so the workflow would break weekly ([Google](https://support.google.com/cloud/answer/15549945#publishing-status)). |
| Internal | Workspace accounts that have a Google Cloud organization. | Not available to free accounts; org members only. |

Personal mode steps:

1. Open the [Personal mode onboarding page](https://console.cloud.google.com/auth/overview/personal) signed in as the Google account whose calendar you want to book on.
2. Continue with the default project (`personal-mode-app`), choose application type **Desktop app**, accept the Terms of Service, click **Continue**.
3. In the "OAuth client created" dialog copy the **Client ID** and **Client secret** (or **Download JSON**). **The secret is shown only once.** If you lose it, open the client under Google Auth platform > Clients and add a new secret. Never commit either value.
4. Enable the **Google Calendar API** in the same project: [Enable it here](https://console.cloud.google.com/marketplace/product/google/calendar-json.googleapis.com) (check the project picker at the top). Personal mode does not enable it for you. Wait a minute or two; trying immediately can fail with "Google Calendar API has not been used in project ... or it is disabled" ([note2cal docs](https://github.com/lfilho/note2cal.nvim/blob/main/docs/google-calendar-setup.md)).
5. The scope needed is `https://www.googleapis.com/auth/calendar.events`. Google lists it as sufficient for listing events ([events.list](https://developers.google.com/workspace/calendar/api/v3/reference/events/list)), and it is what note2cal requests. Optionally declare it under Google Auth platform > Data Access (Google's [consent guide](https://developers.google.com/workspace/guides/configure-oauth-consent) recommends listing scopes); I have not verified whether Personal mode needs that.

If you use External instead, follow note2cal's guide and **publish the app**, or the 7-day expiry applies.

### 2. Store the client in two places

The refresh token only works with the client that issued it (Google answers `invalid_grant`, "issued to another client", per [RFC 6749 section 5.2](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2)). So Neovim and Alfred must use the **same** client id and secret.

**a) For Neovim.** note2cal.nvim reads both from the environment, so export them from a file that git does not track. This repo already sources two such files when they exist: any `~/.zsh.before/*.zsh` (via `zsh/0000_before.zsh`) and `~/.secrets` (via `zsh/secrets.zsh`). Put these two lines in one of them, then open a new terminal:

```sh
export NOTE2CAL_GOOGLE_CLIENT_ID="<id>.apps.googleusercontent.com"
export NOTE2CAL_GOOGLE_CLIENT_SECRET="<secret>"
```

**b) For Alfred.** Put the same pair in the Keychain as JSON (run in zsh; the secret is not echoed and not stored in shell history):

```sh
printf 'Client ID: '; read -r CID
printf 'Client secret (hidden): '; read -rs CSECRET; echo
security add-generic-password -U -a google-oauth-client -s alfred-block-workflow \
  -w "$(printf '{"client_id":"%s","client_secret":"%s"}' "$CID" "$CSECRET")"
unset CID CSECRET
```

`-U` updates the item if it already exists, so the same command also rotates the secret. While it runs the value is briefly visible in the process list, because `security` takes it as an argument (note2cal's own login has the same caveat). The alternative is ending the command with a bare `-w`, which prompts, but then you type the JSON by hand.

Do not put the client in Alfred's workflow Environment Variables: they are saved in the workflow's `info.plist`, which is committed to this public repo and exported into the `.alfredworkflow`. `block.mjs` also accepts `NOTE2CAL_GOOGLE_CLIENT_ID` / `NOTE2CAL_GOOGLE_CLIENT_SECRET` from the environment, but that is for terminal runs and tests.

Check it without printing the secret (expect `client_id: present | client_secret: present`):

```sh
security find-generic-password -a google-oauth-client -s alfred-block-workflow -w \
  | node -e 'const j = JSON.parse(require("fs").readFileSync(0, "utf8")); console.log("client_id:", j.client_id ? "present" : "MISSING", "| client_secret:", j.client_secret ? "present" : "MISSING")'
```

### 3. Sign in (creates the refresh token)

1. In the terminal from step 2a, open any markdown file (this config loads note2cal only for markdown): `nvim /tmp/login.md`.
2. Run `:Note2calGoogleLogin`. Your browser opens; choose **the same Google account**, then allow access.
3. The browser tab says "note2cal: authentication complete, you can close this tab." If Neovim instead reports that Google did not return a refresh_token, revoke the app at [your Google account permissions](https://myaccount.google.com/permissions) and run the login again.

Check it (expect `refresh_token: present` and the `calendar.events` scope):

```sh
security find-generic-password -a google-oauth-token -s note2cal.nvim -w \
  | node -e 'const j = JSON.parse(require("fs").readFileSync(0, "utf8")); console.log("refresh_token:", j.refresh_token ? "present" : "MISSING"); console.log("scope:", j.scope)'
```

The workflow only reads the macOS Keychain. If you ever set note2cal's `security` option to `plain-file`, the workflow cannot see the token.

### 4. Try it from the terminal

```sh
cd ~/.yadr/alfred/block-schedule
BLOCK_DRY_RUN=1 node block.mjs "20 setup check"
```

It reads your calendar, prints `[dry run] Scheduled for <day and time>`, and creates nothing. Any problem prints as the same message Alfred would show; see Troubleshooting.

### 5. Import into Alfred

Double-click `~/.yadr/alfred/block-schedule.alfredworkflow` and click **Import**. Then type `block 20 setup check` in Alfred: a "Block Scheduled" dialog appears and a **real** 20 minute event lands on your calendar, so delete it afterwards. If macOS asks to allow Keychain access, choose **Always Allow**.

### Troubleshooting

Every failure shows an "Error" dialog with one of these messages (also printed by step 4):

| Message | Cause and fix |
|---|---|
| `No block content provided.` / `Duration must be between 1 and 480 minutes.` | Input problem: `block [minutes] <content>`, 1 to 480 minutes. |
| `Google OAuth client id/secret not found ...` | The `alfred-block-workflow` item is missing or unreadable. Redo step 2b and run its check. |
| `Not signed in to Google. Run :Note2calGoogleLogin in Neovim.` | The `note2cal.nvim` item is missing. Do step 3. |
| `Stored Google token has no refresh token.` | Revoke the app at [account permissions](https://myaccount.google.com/permissions), then do step 3 again. |
| `Google token refresh failed (... invalid_grant)` | The refresh token was revoked, not used for six months, expired (External + Testing), or was issued to a different client than the one in step 2b. Make sure both use the same client, then do step 3 again. See [Google's list](https://developers.google.com/identity/protocols/oauth2#expiration). |
| `Google token refresh failed (... invalid_client)` | The client id or secret in the Keychain is wrong, or the client was deleted (Google deletes OAuth clients unused for six months, [source](https://support.google.com/cloud/answer/15549257#unused-client-deletion)). Redo step 2b; recreate the client if needed. |
| `Google Calendar API 403: ... has not been used in project ... or it is disabled` | Step 1.4: enable the Calendar API in the project that owns your client, wait a few minutes. |
| Other `Google Calendar API <status>: ...` | Google's own message is shown as is. Run the step 3 check to confirm the scope. A 403 or 429 `usageLimits` means quota ([Google](https://developers.google.com/workspace/calendar/api/guides/quota)). |
| `No free N minute slot in the next 30 days.` | Working hours (Mon to Fri, 9:00 to 17:00) are full; use a shorter duration. |
| `Unexpected error: ...` | Network or a bug. Reproduce with step 4. |
| Nothing happens at all | Alfred never started the script. Open the workflow in Alfred Preferences, click the **bug icon** at the top right of the editor, trigger `block ...`, and see which step fails ([Alfred debugger](https://www.alfredapp.com/help/workflows/advanced/debugger/)). Check the Node PATH test in "Before you start". |

Housekeeping: to remove everything, run `:Note2calGoogleLogout` in Neovim, `security delete-generic-password -a google-oauth-client -s alfred-block-workflow`, delete the Cloud project, and delete the workflow in Alfred.

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

Credentials and first-time setup: see [Setup from scratch](#setup-from-scratch).

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
