# Ghostty Terminal Configuration

[Ghostty](https://ghostty.org/) is a fast, feature-rich, and GPU-accelerated terminal emulator built with performance and customization in mind.

## Features

### Appearance

- **Theme**: Catppuccin Mocha (`catppuccin-mocha.conf`)
- **Font**: Maple Mono, size 16
  - Alternative fonts available: FiraCode Nerd Font Mono, CommitMono Nerd Font Mono
- **Icon**: Holographic macOS dock icon style
- **Window**: Maximized by default (99999x99999)
- **Cursor**: Inverted foreground/background colors for better visibility
- **Split Focus**: Unfocused splits are dimmed (fill color: 555)

### Quick Terminal

Ghostty includes a quick terminal feature that can be toggled globally:

- **Size**: 60% width, 60% height
- **Position**: Center of screen
- **Keybinding**: `Ctrl+\`` (Ctrl + grave accent) - works from any application

This is perfect for quick command execution without switching to your main terminal.

## Custom Cursor Shaders

Ghostty supports custom GLSL shaders for cursor effects. All shaders are located in the `shaders/` directory.

### Active Shader

**Tesla Coil** (`shaders/tesla_coil.glsl`) - Currently active
- Electric arc effect emanating from the cursor
- Animated, dynamic appearance
- High-energy visual feedback

### Available Shaders

You can switch between different cursor effects by commenting/uncommenting lines in the `config` file:

#### Energy Effects
- **`tesla_coil.glsl`** - Electric arcs around cursor (currently active)
- **`glow.glsl`** - Soft glowing halo effect

#### Fire/Blaze Effects
- **`cursor_blaze.glsl`** - Fiery trail with full effect
- **`cursor_blaze_no_trail.glsl`** - Fire effect without trail
- **`cursor_blaze_tapered.glsl`** - Tapered flame effect

#### Motion Effects
- **`cursor_smear.glsl`** - Motion blur/smear effect
- **`cursor_smear_fade.glsl`** - Smear with gradual fade

#### Special Effects
- **`cursor_frozen.glsl`** - Frozen/crystalline effect
- **`manga_slash.glsl`** - Manga-style action slash

#### Debug Shaders
- **`debug_cursor_animated.glsl`** - Animated debug visualization
- **`debug_cursor_static.glsl`** - Static debug visualization

### How to Change Shaders

Edit the `config` file and comment out the current shader, then uncomment your preferred one:

```conf
# Shaders
custom-shader-animation = true
# custom-shader = "shaders/tesla_coil.glsl"
custom-shader = "shaders/glow.glsl"  # Now using glow effect
```

Ghostty will automatically reload the configuration.

## Keybindings

### Split Navigation (Vim-style)

Navigate between terminal splits using Command key (macOS):

- `Cmd+k` - Go to top split
- `Cmd+j` - Go to bottom split
- `Cmd+h` - Go to left split
- `Cmd+l` - Go to right split

### Split Resizing

Resize splits using Option key + arrow keys:

- `Opt+Left` - Resize split left (10 units)
- `Opt+Right` - Resize split right (10 units)
- `Opt+Up` - Resize split up (10 units)
- `Opt+Down` - Resize split down (10 units)

### Window Management

- `Cmd+Opt+j` - Create new window (global binding)
- `Ctrl+\`` - Toggle quick terminal (global binding)

### Other

- `Shift+Enter` - Insert newline character
- Click cursor to move - Enabled for quick cursor positioning

## Other Settings

- **Auto-update**: Check for updates automatically
- **Mouse**: Hide mouse cursor while typing
- **Cursor Click to Move**: Click anywhere in the terminal to move cursor to that position

## Tips

1. **Quick Terminal**: Use the quick terminal (`Ctrl+\``) for commands while working in other apps. It's perfect for git commands, quick scripts, or checking status without switching windows.

2. **Shader Performance**: If you experience performance issues, try disabling animation or using a simpler shader:
   ```conf
   custom-shader-animation = false
   ```

3. **Split Workflow**: Ghostty's split navigation keybindings match vim's hjkl movement, making it natural for vim users. Combine with tmux for even more power.

4. **Font Customization**: All three font options (Maple Mono, FiraCode Nerd Font, CommitMono Nerd Font) are Nerd Fonts with icon support. Choose based on your preference.

## Integration with YADR

Ghostty is fully integrated with YADR's vim-centric workflow:

- Split navigation matches vim keybindings (hjkl)
- Works seamlessly with tmux configuration
- Supports all Nerd Font icons used in NeoVim and shell prompt
- Catppuccin theme matches available vim colorschemes
- Quick terminal complements the tmux workflow

## Resources

- [Official Ghostty Website](https://ghostty.org/)
- [Ghostty Documentation](https://ghostty.org/docs)
- [Custom Shader Examples](https://github.com/ghostty-org/ghostty/tree/main/shaders)

## Troubleshooting

### Shaders Not Working

If custom shaders aren't displaying:

1. Ensure shader animation is enabled: `custom-shader-animation = true`
2. Check that shader files exist in the `shaders/` directory
3. Verify the shader path is correct (relative to config file)
4. Check GPU acceleration is enabled in your system

### Font Not Displaying

If Maple Mono isn't installed:

1. YADR's installation script copies fonts to `~/Library/Fonts` (macOS)
2. Alternatively, uncomment one of the Nerd Font options
3. Run `rake install` to reinstall fonts if needed

### Quick Terminal Not Appearing

The quick terminal requires a global keybinding:

1. On macOS, you may need to grant accessibility permissions
2. Go to System Preferences → Privacy & Security → Accessibility
3. Add Ghostty to the list of allowed applications
