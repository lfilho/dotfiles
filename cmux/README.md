# cmux Configuration

[cmux](https://cmux.sh/) (`cmuxterm.app`) is a git-worktree-aware terminal/IDE app with an embedded browser and Claude Code/Cursor/Gemini automation integration, used alongside Ghostty/Warp.

## What's tracked

- `cmux.json` - The JSONC config file cmux reads from `~/.config/cmux/`. Per its own header comment: settings here are commented out by default and fall back to whatever's saved in the GUI Settings; uncomment a key to make it file-managed (portable/version-controlled) instead.

## What's intentionally NOT tracked

Everything else cmux writes is runtime/session state, not configuration:

- `~/Library/Preferences/com.cmuxterm.app.plist` - macOS `NSUserDefaults` store: window-frame geometry, notification-dismissal history, an auth project id, Sparkle updater state. This is where GUI Settings actually persist when a key is *not* uncommented in `cmux.json`; it's per-machine state, not portable config.
- `~/.cmuxterm/` - Event/workstream logs and Claude-hook session state (multi-MB `.jsonl` activity logs).
- `~/.local/state/cmux/` - Unix sockets and lock files.
- `~/Library/Application Support/cmux/` - Search index (`search.db`), session/closed-item/notification history.
- `~/Library/Caches/`, `~/Library/Logs/`, `~/Library/HTTPStorages/`, `~/Library/WebKit/` (cmux entries) - Standard macOS app cache/log/webview state.

## Installation

YADR symlinks the whole config directory into place, same pattern as `ghostty/`, `eza/`, `bat/` (nothing else lives in `~/.config/cmux/`, so this is safe):

```
~/.config/cmux -> ~/.yadr/cmux
```

**On a machine where `~/.config/cmux` already exists as a real directory** (i.e. cmux has already been run there), quit cmux and `rm -rf ~/.config/cmux` first — `ln -nfs` will not replace an existing real directory, it will nest a symlink inside it.

Edit `cmux.json` in `~/.yadr/cmux/` (not `~/.config/cmux/`) so changes are picked up by git. Cmux hot-reloads it via `reloadConfiguration` (`cmd+shift+,`) or on relaunch.
