# OMP (Oh My Pi) Configuration

[OMP](https://ompcode.com/) is the AI coding harness/agent used from the terminal. This directory tracks the parts of `~/.omp` that are actual user configuration, so preferences stay in sync between machines.

## What's tracked

- `agent/config.yml` - Shared/common agent config: personality, composer, display, tool approval mode, `webSearchOrder`, model roles. Same on every machine.
- `plugins/package.json`, `plugins/omp-plugins.lock.json`, `plugins/bun.lock` - Installed OMP plugins (e.g. `omp-vim`) and their pinned versions.

## What's intentionally NOT tracked

`~/.omp` is mostly runtime state, not configuration, so the rest of the directory is left untouched by YADR:

- `agent/*.db*` - SQLite session/history/model databases.
- `agent/config.yml.lock`, `agent/last-changelog-version` - Runtime lock/state files.
- `agent/.env` - Provider secrets. Never commit these.
- `cache/`, `logs/`, `run/`, `natives/`, `plugins/node_modules/` - Caches, logs, sockets, downloaded native binaries, installed plugin code.
- `gpu_cache.json`, `install-id` - Machine-specific runtime/identity files.

## Installation

YADR symlinks the tracked files into place:

```
~/.omp/agent/config.yml            -> ~/.yadr/omp/agent/config.yml
~/.omp/plugins/package.json        -> ~/.yadr/omp/plugins/package.json
~/.omp/plugins/omp-plugins.lock.json -> ~/.yadr/omp/plugins/omp-plugins.lock.json
~/.omp/plugins/bun.lock            -> ~/.yadr/omp/plugins/bun.lock
```

Edit the files in `~/.yadr/omp/` (not `~/.omp/`) so changes are picked up by git.
