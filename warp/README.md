# Warp Terminal Configuration

[Warp](https://www.warp.dev/) is used as an alternative terminal to Ghostty. This directory tracks the user-editable settings under `~/.warp`.

## What's tracked

- `settings.toml` - App preferences: vim mode, compact spacing, vertical tabs, secret redaction rules, agent execution profile (`always_ask` for commands/writes, denylist for shells/network tools), notifications, font (FiraCode Nerd Font Mono).
- `keybindings.yaml` - Custom pane navigation keybindings (`alt-cmd-hjkl`), completion suggestions, and autosuggestion insert.
- `tab_configs/startup_config.toml` - Default new-tab layout (single agent pane in `$HOME`).
- `themes/catppuccin_mocha.yaml` - Custom Catppuccin Mocha theme with the Pip-Boy background.
- `themes/pipboy.jpg` - Background image referenced by the custom theme (kept alongside it since the theme uses a path relative to the `themes/` directory).

## What's intentionally NOT tracked

Warp is a closed-source app that can write other state directly under `~/.warp` at any time (crash logs, local storage, etc.) without notice. Since the whole directory is symlinked (see below), anything not listed above simply won't exist under `~/.warp` after installing — nothing to separately ignore.

## Installation

Unlike `omp/` (which mixes config with databases/caches that must stay out of git), nothing under `~/.warp` is runtime state that Warp needs to write outside of what's tracked here, so YADR symlinks the whole directory like it does for `ghostty/`, `yazi/`, etc.:

```
~/.warp -> ~/.yadr/warp
```

`rake install` creates this with `ln -nfs ~/.yadr/warp ~/.warp`. **On a machine where `~/.warp` already exists as a real directory** (i.e. Warp has already been run there), quit Warp and `rm -rf ~/.warp` first — `ln -nfs` will not replace an existing real directory, it will nest a symlink inside it.

Edit the files in `~/.yadr/warp/` (not `~/.warp/`) so changes are picked up by git.
