# Yabai Window Manager Configuration

Yabai is a tiling window manager for macOS that allows powerful window management through keyboard shortcuts and rules.

## Installation

Yabai is automatically installed and configured when you run:

```bash
cd ~/.yadr
rake install
```

This will:
1. Install yabai via Homebrew
2. Create the `~/.config/yabai/` directory
3. Symlink the configuration file to the correct location

After installation, start yabai:
```bash
yabai --start-service
# Or use the alias:
ystart
```

## Configuration Features

### Global Settings
- **Layout**: Binary Space Partitioning (BSP) tiling by default
- **Padding & Gaps**: 10px padding and gaps for clean appearance
- **Mouse**: Focus does not follow mouse pointer
- **SIP-Safe**: Configuration works without disabling System Integrity Protection

**Note**: Window opacity and borders are commented out as they require disabling SIP. You can uncomment them in `yabairc` if you've disabled SIP and understand the security implications.

### Application Rules

#### Display Pinning
The configuration automatically pins specific apps to your laptop's built-in display:
- **Zoom Workplace** - Always opens on laptop display (display 1)
- **Firefox** - Always opens on laptop display (display 1)

#### Floating Windows
The following apps are set to float (not tile):
- System Settings/Preferences
- Finder
- Alfred
- Calculator
- Activity Monitor
- Archive Utility

## Commands & Aliases

Once zsh integration is loaded, you can use these commands:

### Window Management
- `ymax` - Toggle maximize (fullscreen) for the currently focused window
- `ylayout-zoom` - Set up the Zoom + Ghostty layout (see below)

### Service Management
- `ystart` - Start yabai service
- `ystop` - Stop yabai service
- `yrestart` - Restart yabai service
- `ystatus` - Check yabai service status

## Custom Layouts

### Zoom + Ghostty Layout

The `ylayout-zoom` command creates a specialized layout for video calls with terminal:

**Zoom Window:**
- 25% of screen height
- 50% of screen width
- Positioned at top-center

**Ghostty Window:**
- 75% of screen height
- 80% of screen width
- Positioned at bottom-right

This layout is perfect for:
- Taking notes during calls
- Running commands while in meetings
- Having terminal visible during pair programming sessions

**Usage:**
```bash
# Make sure both Zoom and Ghostty are running
ylayout-zoom
```

## Keyboard Shortcuts

You can add keyboard shortcuts using skhd (not included) or Karabiner-Elements. Example shortcuts:

- `Cmd + Shift + F` → Maximize window: `~/.yadr/yabai/layouts.sh maximize`
- `Cmd + Shift + Z` → Zoom layout: `~/.yadr/yabai/layouts.sh zoom-ghostty`

## Troubleshooting

### Yabai not starting
Check if yabai is running:
```bash
ystatus
```

### Display numbers
To find your display numbers:
```bash
yabai -m query --displays | jq -r '.[] | "Display \(.index): \(.frame)"'
```

The built-in laptop display is typically display 1.

### Windows not positioning correctly
Make sure the app is running before executing layout commands:
```bash
# Check running windows
yabai -m query --windows | jq -r '.[] | "\(.id): \(.app)"'
```

### Permissions

**This configuration is SIP-safe!** All features work without disabling System Integrity Protection.

**Optional Advanced Features** (require disabling SIP):
- Window opacity (showing active/inactive windows with transparency)
- Window borders (visual borders around windows)

These features are commented out in `yabairc` by default. **We do not recommend disabling SIP** as it significantly reduces your system security. The core window management features work perfectly without it.

## Further Customization

Edit the configuration file:
```bash
nvim ~/.yadr/yabai/yabairc
```

After making changes, restart yabai:
```bash
yrestart
```

## Resources

- [Yabai GitHub](https://github.com/koekeishiya/yabai)
- [Yabai Wiki](https://github.com/koekeishiya/yabai/wiki)
- [Configuration Reference](https://github.com/koekeishiya/yabai/blob/master/doc/yabai.asciidoc)
