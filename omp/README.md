# OMP (Oh My Pi) Configuration

[OMP](https://ompcode.com/) is the AI coding harness/agent used from the terminal. This directory tracks the parts of `~/.omp` that are actual user configuration, so preferences stay in sync between machines.

There is deliberately **no "global"/default-profile config**. Every machine uses one of two OMP-native [named profiles](https://ompcode.com/docs/config-usage#profiles): `work` (Anthropic) or `personal` (OpenCode Go). A profile fully relocates `~/.omp/agent/...` to `~/.omp/profiles/<name>/agent/...` — settings, sessions, and **credential store** are all separate per profile. That isolation is the actual fix for a real bug we hit with a shared-config + `PI_CONFIG_FILES`-overlay approach: model-role writes always land on the global file regardless of any overlay, so switching models under a "personal" session leaked into the "work" default. Profiles don't have that problem because there's no shared file to leak into — verified live (see below).

## What's tracked

- `profiles/work/agent/config.yml` and `profiles/personal/agent/config.yml` — two **fully duplicated** config files (personality, composer, display, tool approval, `webSearchOrder`, model roles, `enabledModels`). Deliberate duplication, not a shared base: edit both by hand when changing something both profiles should have (e.g. `personality`).
- `plugins/package.json`, `plugins/omp-plugins.lock.json`, `plugins/bun.lock` — Installed OMP plugins (e.g. `omp-vim`) and their pinned versions. Plugins live under `~/.omp/plugins/` (a sibling of `agent/`, not inside it), so they are **not** profile-scoped — one shared install for both profiles.

## What's intentionally NOT tracked

`~/.omp` is mostly runtime state, not configuration, so the rest of the directory is left untouched by YADR:

- `profiles/*/agent/*.db*` — SQLite session/history/model databases, **including the credential store** — separate per profile, see "Credentials" below.
- `profiles/*/agent/config.yml.lock`, `profiles/*/agent/last-changelog-version` — Runtime lock/state files.
- `profiles/*/agent/.env` — Provider secrets (e.g. `OPENCODE_API_KEY`). Never commit these.
- `cache/`, `logs/`, `run/`, `natives/`, `plugins/node_modules/` — Caches, logs, sockets, downloaded native binaries, installed plugin code.
- `gpu_cache.json`, `install-id` — Machine-specific runtime/identity files.

## Installation

YADR symlinks the tracked files into place:

```
~/.omp/profiles/work/agent/config.yml     -> ~/.yadr/omp/profiles/work/agent/config.yml
~/.omp/profiles/personal/agent/config.yml -> ~/.yadr/omp/profiles/personal/agent/config.yml
~/.omp/plugins/package.json               -> ~/.yadr/omp/plugins/package.json
~/.omp/plugins/omp-plugins.lock.json      -> ~/.yadr/omp/plugins/omp-plugins.lock.json
~/.omp/plugins/bun.lock                   -> ~/.yadr/omp/plugins/bun.lock
```

Edit the files in `~/.yadr/omp/` (not `~/.omp/`) so changes are picked up by git.

## Activation: `zsh/ai.zsh`

Tracked, identical on every machine (appended to the existing `zsh/ai.zsh`, which also has `ai_cmd_helper` — a Cursor Cmd+K-style helper, unrelated). Named `ai.zsh`, not `omp.zsh`, deliberately: the harness behind `ai`/`aip` may change later, and only this file would need to change, not every callsite. Exports `OMP_PROFILE` (`work` or `personal`) based on `$HOST_KIND`, which comes from an **untracked** `~/.zsh.before/` hook that hardcodes each machine's own hostname — never hardcode a real hostname in the tracked file:

```bash
# ~/.zsh.before/<any-name>.zsh (untracked; content is machine-specific)
if [[ "$(hostname)" == "<this-machine's-actual-hostname>" ]]; then
  export HOST_KIND=work
else
  export HOST_KIND=personal
fi
```

A machine with no hook at all leaves `$HOST_KIND` unset, which resolves to `work` — same fail-safe default as before.

Two functions, also in `zsh/ai.zsh`:

```bash
ai()  { … omp --profile work "$@" or --profile personal "$@", based on $HOST_KIND … }
aip() { omp --profile personal "$@" }
```

- `ai` — the everyday entry point. Use this instead of bare `omp`.
- `aip` — force the personal profile from any machine (e.g. from work), regardless of `$HOST_KIND`.
- Bare `omp` (no `--profile`) uses OMP's actual default profile, which this repo does not configure at all — intentionally bare/unconfigured, since `ai`/`aip` are the real entry points.

## Credentials (do this once per profile, per machine)

**Profiles do not share credentials.** I verified this live: a fresh `~/.omp/profiles/work/agent/agent.db` has zero Anthropic credentials even though the default profile was already logged in — `omp --profile work` fell back to a local `lm-studio` model instead of Anthropic until logged in under that profile specifically.

- Work machine: `ai` once, then `/login anthropic` inside the session (or `omp --profile work` then `/login anthropic`).
- Personal machine: set `OPENCODE_API_KEY` as a real exported environment variable (always wins regardless of profile), or in `~/.omp/profiles/personal/agent/.env`.
- Personal profile also needs real model ids: replace the `REPLACE_WITH_MODEL_ID` placeholders in `omp/profiles/personal/agent/config.yml` — run `omp --profile personal models find opencode` once credentials are in place.

Verify either profile independently:

```bash
omp --profile work config get modelRoles --json
omp --profile personal config get modelRoles --json
ai --print "reply with exactly: OK"
aip --print "reply with exactly: OK"
```

## Verified isolation

Confirmed live: setting `modelRoles` under `--profile personal` (simulating a `/model` switch mid-session) left `--profile work`'s `config.yml` byte-for-byte unchanged. No snapshot/restore wrapper needed — the profile boundary itself is the fix.
