# NeoVim Configuration (AstroNvim)

This is a modern NeoVim configuration based on [AstroNvim](https://astronvim.com/) v4+, using Lua and the Lazy.nvim plugin manager.

## Table of Contents

- [Structure](#structure)
- [How to Customize](#how-to-customize)
- [Plugin Management](#plugin-management)
- [Key Mappings](#key-mappings)
- [LSP & Language Support](#lsp--language-support)
- [Useful Commands](#useful-commands)

---

## Structure

### Directory Layout

```
nvim-user-config/
├── init.lua                    # Bootstrap entry point
├── lua/
│   ├── lazy_setup.lua         # Lazy.nvim plugin manager setup
│   ├── polish.lua             # Final configuration polish
│   ├── community.lua          # AstroNvim community plugin configs
│   └── plugins/
│       ├── astrocore.lua      # Core options, mappings, autocmds
│       ├── astrolsp.lua       # LSP configuration
│       ├── astroui.lua        # UI components, icons, themes
│       ├── colorschemes.lua   # Color scheme setup
│       ├── treesitter.lua     # Syntax highlighting
│       ├── mason.lua          # LSP/tool auto-installer
│       ├── none-ls.lua        # Linting & formatting
│       ├── snacks.lua         # UI enhancements (notifications, picker)
│       └── user.lua           # YOUR custom plugins go here
├── spell/                      # Custom spell dictionaries
├── art/                        # ASCII art
└── lazy-lock.json             # Plugin version lockfile
```

### Key Files

| File | Purpose |
|------|---------|
| `init.lua` | Bootstraps Lazy.nvim and loads configuration |
| `lua/plugins/astrocore.lua` | **Main configuration** - options, keymaps, commands |
| `lua/plugins/astrolsp.lua` | LSP settings (servers, formatting, diagnostics) |
| `lua/plugins/user.lua` | **Add your custom plugins here** |
| `lua/polish.lua` | Final tweaks after all plugins load |
| `lazy-lock.json` | Locks plugin versions for reproducibility |

---

## How to Customize

### Adding Custom Options

Edit `lua/plugins/astrocore.lua` in the `options` section:

```lua
options = {
  opt = {
    relativenumber = true,  -- Show relative line numbers
    wrap = false,           -- Don't wrap lines
    tabstop = 4,           -- Tab width
    -- Add your options here
  },
}
```

### Adding Custom Keymaps

Edit `lua/plugins/astrocore.lua` in the `mappings` section:

```lua
mappings = {
  n = {  -- Normal mode
    ["<Leader>w"] = { ":w<CR>", desc = "Save file" },
    -- Add your mappings here
  },
  i = {  -- Insert mode
    -- ...
  },
  v = {  -- Visual mode
    -- ...
  },
}
```

**Note**: `<Leader>` is set to `,` (comma)

### Adding Custom Commands

Edit `lua/plugins/astrocore.lua` in the `commands` section:

```lua
commands = {
  MyCommand = {
    function()
      -- Your command logic here
      vim.notify("Hello from MyCommand!")
    end,
  },
}
```

---

## Plugin Management

### Lazy.nvim Plugin Manager

This configuration uses [Lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. It's fast, lazy-loads plugins, and has a great UI.

### Adding a Plugin

Edit `lua/plugins/user.lua` and add a plugin spec:

```lua
return {
  -- Example: Add a new plugin
  {
    "author/plugin-name",
    lazy = false,  -- Load immediately (or true to lazy-load)
    config = function()
      require("plugin-name").setup({
        -- Plugin configuration here
      })
    end,
  },

  -- Example: Plugin with dependencies
  {
    "another/plugin",
    dependencies = {
      "dependency/plugin",
    },
    event = "VeryLazy",  -- Lazy-load on VeryLazy event
  },
}
```

### Plugin Commands

Open NeoVim and use these commands:

- `:Lazy` - Open Lazy.nvim UI
- `:Lazy sync` - Update all plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy restore` - Restore plugins from lazy-lock.json
- `:Lazy profile` - View plugin loading times

### Updating Plugins

```vim
:Lazy sync
```

This will update all plugins to their latest versions and update `lazy-lock.json`.

---

## Key Mappings

**Leader key**: `,` (comma)

### Navigation & Movement

| Keymap | Mode | Description |
|--------|------|-------------|
| `H` | Normal | Previous buffer |
| `L` | Normal | Next buffer |
| `[b` / `]b` | Normal | Previous/Next buffer (alternative) |
| `Ctrl-h/j/k/l` | Normal | Navigate splits (also works with tmux) |
| `vv` | Normal | Split vertically |
| `ss` | Normal | Split horizontally |
| `'` | Normal | Jump to mark (line and column) |
| `` ` `` | Normal | Jump to mark (line only) |
| `0` | Normal | Go to first character (not whitespace) |
| `^` | Normal | Go to beginning of line (with whitespace) |
| `g;` | Normal | Jump to previous position (centered) |
| `g,` | Normal | Jump to next position (centered) |

### Buffer Management

| Keymap | Mode | Description |
|--------|------|-------------|
| `<Leader>bd` | Normal | Close buffer (interactive picker) |
| `<Leader>c` | Normal | Close current buffer |

### Search & Replace

| Keymap | Mode | Description |
|--------|------|-------------|
| `/` | Normal | Search forward (with regex mode `\v`) |
| `?` | Normal | Search backward (with regex mode `\v`) |

**Note**: Searches use Perl/Python style regex by default (`\v` mode)

### File Operations

| Keymap | Mode | Description |
|--------|------|-------------|
| `<Leader>yf` | Normal | Copy full file path to clipboard |

### Window Resizing

| Keymap | Mode | Description |
|--------|------|-------------|
| `Shift-Up` | Normal | Increase window height |
| `Shift-Down` | Normal | Decrease window height |
| `Shift-Left` | Normal | Decrease window width |
| `Shift-Right` | Normal | Increase window width |

### AstroNvim Default Mappings

AstroNvim provides many built-in keymaps. Some important ones:

| Keymap | Description |
|--------|-------------|
| `<Leader>f` | Find (Telescope file picker) |
| `<Leader>fo` | Find old files (recent files) |
| `<Leader>fw` | Find word (grep) |
| `<Leader>fb` | Find buffers |
| `<Leader>e` | Toggle file explorer (Neo-tree) |
| `<Leader>o` | Toggle outline (symbols) |
| `<Leader>u` | Toggle UI elements |
| `<Leader>l` | LSP actions |
| `<Leader>g` | Git actions |
| `<Space>` | Open command palette |

For a complete list, run `:Telescope keymaps` or press `<Leader>fk`

---

## LSP & Language Support

### Mason - Automatic Language Server Installation

This configuration uses [Mason](https://github.com/williamboman/mason.nvim) to automatically install language servers, formatters, and linters.

### Installing Language Servers

Open NeoVim and run:

```vim
:Mason
```

This opens the Mason UI where you can:
- Browse available tools
- Install/uninstall language servers
- View installed tools

Common language servers:
- `lua_ls` - Lua (recommended for editing this config)
- `ts_ls` - TypeScript/JavaScript
- `pyright` - Python
- `rust_analyzer` - Rust
- `gopls` - Go
- `clangd` - C/C++

### Auto-Installation

Edit `lua/plugins/mason.lua` to configure which servers to install automatically:

```lua
ensure_installed = {
  "lua_ls",
  "ts_ls",
  -- Add more servers here
}
```

### LSP Keymaps

When in a file with an active LSP server:

| Keymap | Description |
|--------|-------------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Show references |
| `gI` | Go to implementation |
| `K` | Show hover documentation |
| `<Leader>lh` | Signature help |
| `<Leader>lr` | Rename symbol |
| `<Leader>la` | Code actions |
| `<Leader>lf` | Format buffer |
| `<Leader>ld` | Show diagnostics |
| `]d` / `[d` | Next/previous diagnostic |

### Formatting

Formatting is configured in `lua/plugins/none-ls.lua` using [none-ls](https://github.com/nvimtools/none-ls.nvim) (successor to null-ls).

To format the current buffer:
```vim
:Format
" or
<Leader>lf
```

---

## Useful Commands

### Built-in Commands

| Command | Description |
|---------|-------------|
| `:AstroUpdate` | Update AstroNvim core |
| `:AstroUpdatePackages` | Update Mason packages |
| `:Lazy` | Open plugin manager UI |
| `:Mason` | Open LSP installer UI |
| `:Telescope` | Open Telescope fuzzy finder |
| `:checkhealth` | Check NeoVim configuration health |

### Custom Commands (from astrocore.lua)

| Command | Description |
|---------|-------------|
| `:DiffOrig` | Show diff between current buffer and saved file |
| `:OpenChangedFiles` | Open all git-changed files in splits |
| `:TeamMembers` | Insert team member checklist (custom) |

### Treesitter Commands

Treesitter provides better syntax highlighting:

| Command | Description |
|---------|-------------|
| `:TSInstall <language>` | Install language parser |
| `:TSUpdate` | Update all parsers |
| `:TSModuleInfo` | Show installed modules |

---

## Plugins Overview

### Core AstroNvim Plugins

- **astrocore** - Core configuration (options, mappings, commands)
- **astrolsp** - LSP integration
- **astroui** - UI components and icons
- **astrotheme** - Default color schemes

### Essential Plugins (Included)

- **Lazy.nvim** - Plugin manager
- **Mason** - LSP/tool installer
- **Treesitter** - Better syntax highlighting
- **Telescope** - Fuzzy finder for files, buffers, grep, etc.
- **Neo-tree** - File explorer
- **none-ls** - Formatting and linting
- **snacks.nvim** - UI enhancements (notifications, picker, dashboard)
- **gitsigns** - Git integration in sign column
- **which-key** - Show keybindings as you type
- **Comment.nvim** - Easy commenting
- **nvim-autopairs** - Auto-close brackets/quotes

### Custom User Plugins (lua/plugins/user.lua)

These are custom plugins configured in this dotfiles repo:

- **claude-code.nvim** - Claude Code integration for AI-assisted development in vertical split
- **agentic.nvim** - AI agent sidebar with context management
  - `<Leader>at` - Toggle agent sidebar
  - `<Leader>aa` - Add selection/file to agent context
  - `<Leader>an` - New agent chat session
  - `<Leader>as` - Stop agent generation
- **printer.nvim** - Debug print helper with `gcl` keymap
- **render-markdown.nvim** - Beautiful markdown rendering with custom heading styles and code blocks
- **note2cal.nvim** - Create calendar events from markdown notes
- **indent-blankline.nvim** - Rainbow indent guides
- **mini.nvim** - Collection of mini modules:
  - `mini.surround` - Surround text objects (ys/ds/cs mappings)
  - `mini.move` - Move lines and blocks
  - `mini.bracketed` - Navigate with brackets
  - `mini.ai` - Extended text objects (functions, classes, comments, etc.)
- **emmet-vim** - HTML/CSS abbreviation expansion with `,` leader
- **hop.nvim** - Jump to any word with `,s`
- **yanky.nvim** - Yank ring with `<Ctrl-p>/<Ctrl-n>` to cycle through yanks
- **vim-wordmotion** - CamelCase word motion with `,` prefix
- **vim-copy-as-rtf** - Copy code as rich text format
- **vim-abolish** - Case conversion (crs, crc, cru, etc.) and smart search/replace
- **treesj** - Split/join code blocks with `J`
- **tabular** - Align text in tabular format
- **cosco.vim** - Smart comma/semicolon insertion with `,;`
- **img-clip.nvim** - Paste images from clipboard with `<Leader>up`
- **bullets.vim** - Auto-format markdown lists and checkboxes

### Adding More Plugins

You have two options for adding plugins:

**Option 1: Add custom plugins to `lua/plugins/user.lua`** (recommended for personal plugins):

```lua
return {
  -- Add new plugin spec
  {
    "author/plugin-name",
    lazy = false,  -- Load immediately (or true to lazy-load)
    config = function()
      require("plugin-name").setup({
        -- Plugin configuration here
      })
    end,
  },
}
```

**Option 2: Use AstroNvim Community Plugins** (recommended for common plugins):

Check [AstroNvim Community Plugins](https://github.com/AstroNvim/astrocommunity) for pre-configured plugin specs.

To use a community plugin, edit `lua/community.lua`:

```lua
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.typescript" },  -- TypeScript pack
  { import = "astrocommunity.colorscheme.catppuccin" },  -- Catppuccin theme
}
```

---

## Troubleshooting

### Health Check

Run NeoVim's health check to diagnose issues:

```vim
:checkhealth
```

This will check:
- NeoVim version
- Python/Ruby provider setup
- Clipboard support
- LSP servers
- Plugin health

### Common Issues

#### Plugins Not Loading

1. Run `:Lazy sync` to update plugins
2. Check `:Lazy` UI for errors
3. Restart NeoVim

#### LSP Not Working

1. Install language server via `:Mason`
2. Check `:LspInfo` to see if server is attached
3. Run `:checkhealth lsp`

#### Slow Startup

1. Run `:Lazy profile` to see plugin loading times
2. Consider lazy-loading more plugins
3. Check for slow autocmds in `astrocore.lua`

#### Syntax Highlighting Issues

1. Install Treesitter parser: `:TSInstall <language>`
2. Update parsers: `:TSUpdate`
3. Check `:TSModuleInfo`

---

## Tips & Tricks

1. **Explore Keymaps**: Press `<Leader>fk` to search all keybindings with Telescope

2. **Learn Lua**: Install the Lua language server for better editing:
   ```vim
   :LspInstall lua_ls
   ```

3. **Use Which-Key**: Start typing a keymap (like `<Leader>`) and wait - Which-Key will show available options

4. **Check Plugin Docs**: Most plugins have `:help <plugin-name>` documentation

5. **Telescope Everything**: Telescope can search files, buffers, help tags, commands, keymaps, and more. Press `<Leader>f` and explore!

6. **Git Integration**: Use `<Leader>g` for git commands, or use `:LazyGit` (if installed) for a full git TUI

---

## Resources

- [AstroNvim Documentation](https://docs.astronvim.com/)
- [Lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [Telescope Documentation](https://github.com/nvim-telescope/telescope.nvim)
- [Mason Documentation](https://github.com/williamboman/mason.nvim)
- [NeoVim Documentation](https://neovim.io/doc/)
- [Learn Lua in Y Minutes](https://learnxinyminutes.com/docs/lua/)

---

## Quick Start Checklist

After installation:

1. [ ] Install Lua language server: `:LspInstall lua_ls`
2. [ ] Run health check: `:checkhealth`
3. [ ] Update plugins: `:Lazy sync`
4. [ ] Install language servers for your languages: `:Mason`
5. [ ] Explore keymaps: `<Leader>fk`
6. [ ] Read `:help astronvim`
7. [ ] Customize `lua/plugins/user.lua` with your plugins
8. [ ] Customize `lua/plugins/astrocore.lua` with your keymaps

Happy editing! 🚀
