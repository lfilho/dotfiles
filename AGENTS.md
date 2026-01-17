# AGENTS.md - AI Agent Guide for YADR Dotfiles

> **Purpose**: This document provides AI agents (Claude Code, GitHub Copilot, Cursor, etc.) with comprehensive context about this dotfiles repository to enable accurate code generation, troubleshooting, and maintenance.

**Repository**: YADR (Yet Another Dotfile Repo) - @lfilho's fork
**Primary Maintainer**: @lfilho
**Original Author**: @skwp
**Last Updated**: 2026-01-11
**Repository Path**: `~/.yadr`

---

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Architecture & Philosophy](#architecture--philosophy)
3. [Directory Structure](#directory-structure)
4. [Installation System](#installation-system)
5. [Configuration Files Map](#configuration-files-map)
6. [Customization Points](#customization-points)
7. [Key Technologies & Tools](#key-technologies--tools)
8. [Common Tasks & Workflows](#common-tasks--workflows)
9. [Troubleshooting Guide](#troubleshooting-guide)
10. [Code Modification Guidelines](#code-modification-guidelines)

---

## Repository Overview

### What is YADR?

YADR is an **opinionated, production-ready dotfiles repository** optimized for software development on macOS and Linux. It provides a cohesive, vim-centric workflow across all terminal tools.

### Core Philosophy

1. **Vim-like everywhere**: Shell, text editors, file managers, CLI REPLs all use vim keybindings
2. **Modern tooling**: Prefer modern CLI tools (ripgrep, eza, bat, fzf) over traditional ones (grep, ls, cat, find)
3. **Cross-platform**: Support both macOS and Linux (with platform-specific conditionals)
4. **Non-destructive**: User customizations are separate from core configs
5. **Automated**: One-line installation handles everything (Homebrew, symlinks, submodules, fonts)

### Differences from Upstream (@skwp's YADR)

- **NeoVim terminal** (not GUI MacVim)
- **AstroNvim distribution** with Lua configuration
- **Platform-agnostic keymaps** (no Cmd key dependency)
- **CI/CD testing** on both macOS and Linux
- **Automated iTerm2** configuration with themes
- **Ghostty terminal** support with 13 custom cursor shader effects
- **Enhanced shell** with fzf-tab and fast-syntax-highlighting
- **Brewfile** for package management (well-categorized)
- **Docker support** for testing
- **Gruvbox/Catppuccin themes** (not Solarized)
- **Comprehensive documentation** including this AGENTS.md guide

---

## Architecture & Philosophy

### Installation Model

```
Git Clone → Automated Install → Homebrew Packages → Symlink Configs → Prezto Setup → Font Installation
```

**Key Concepts:**

1. **Central Repository**: Everything lives in `~/.yadr`
2. **Symlink Strategy**: Configs are symlinked to their expected locations
3. **Git Submodules**: External dependencies (Prezto, plugins) are submodules
4. **User Customization Directories**: Separate locations for user overrides

### Symlink Map

| Source | Destination | Purpose |
|--------|-------------|---------|
| `~/.yadr/nvim-user-config` | `~/.config/nvim` | NeoVim configuration |
| `~/.yadr/ranger` | `~/.config/ranger` | Ranger file manager |
| `~/.yadr/ghostty` | `~/.config/ghostty` | Ghostty terminal |
| `~/.yadr/wezterm` | `~/.config/wezterm` | WezTerm terminal |
| `~/.yadr/eza` | `~/.config/eza` | Eza (modern ls) |
| `~/.yadr/bat` | `~/.config/bat` | Bat syntax highlighter |
| `~/.yadr/lazygit` | `~/.config/lazygit` | LazyGit TUI |
| `~/.yadr/yabai/yabairc` | `~/.config/yabai/yabairc` | Yabai window manager (macOS) |
| `~/.yadr/zsh/prezto` | `~/.zprezto` | Prezto framework |
| `~/.yadr/git/*` | `~/.gitconfig`, etc. | Git configuration |

---

## Directory Structure

### Top-Level Overview

```
~/.yadr/
├── nvim-user-config/       # NeoVim (Lua, AstroNvim) [PRIMARY EDITOR]
├── zsh/                    # Zsh shell configuration [PRIMARY SHELL]
├── git/                    # Git configuration
├── tmux/                   # Tmux multiplexer
├── ghostty/                # Ghostty terminal
├── wezterm/                # WezTerm terminal
├── iTerm2/                 # iTerm2 (macOS only)
├── ranger/                 # Ranger file manager
├── bat/                    # Bat syntax themes
├── eza/                    # Eza configuration
├── yabai/                  # Yabai window manager (macOS)
├── vimify/                 # Vim keybindings for CLI tools
├── ctags/                  # CTags for code navigation
├── ruby/                   # Ruby gem config
├── fonts/                  # Patched Powerline fonts
├── bin/                    # Custom scripts
├── doc/                    # Documentation
├── test/                   # CI/CD testing
├── lib/                    # Installation system
│   ├── install.sh          # All installation functions (619 lines)
│   └── main.sh             # Main orchestrator (52 lines)
├── install.sh              # Entry point script
├── Brewfile                # Package dependencies (categorized)
├── migration-todo.md       # Pending NeoVim migration tasks
└── AGENTS.md               # This file
```

### Critical Files for AI Agents

| File | Purpose | When to Modify |
|------|---------|----------------|
| `lib/install.sh` | Installation functions | Adding new installation logic |
| `lib/main.sh` | Installation orchestrator | Changing installation flow/order |
| `Brewfile` | Package dependencies (well-categorized) | Adding new tools/dependencies |
| `zsh/zshrc` | Zsh entry point | Never (use customization hooks) |
| `zsh/aliases.zsh` | Shell aliases | Adding new command aliases |
| `nvim-user-config/init.lua` | NeoVim bootstrap | Rarely (prefer lua/plugins/) |
| `nvim-user-config/lua/plugins/user.lua` | User plugins | Adding new vim plugins (ALWAYS update README) |
| `git/gitconfig` | Git aliases/settings | Adding git customizations |
| `ghostty/config` | Ghostty terminal config | Terminal appearance changes |
| `README.md` | Main documentation | Feature additions, major changes |
| `nvim-user-config/README.md` | NeoVim guide | NeoVim customization changes, plugin list updates |
| `ghostty/README.md` | Ghostty guide | Ghostty shader/config changes |

---

## Installation System

### How Installation Works

YADR uses an automated installation system split into two files for simplicity:

**Architecture:**

1. **`lib/install.sh`** (619 lines) - All installation functions organized by category:
   - Logging functions (colored output, banners)
   - Platform detection (macOS/Linux)
   - User prompts (interactive mode)
   - File operations (backup, symlinks)
   - Git operations (submodules)
   - Homebrew installation (platform-aware)
   - Package installation (pip, gem, npm)
   - Symlink creation (modern configs)
   - Prezto installation (shell switching)
   - Font installation
   - iTerm2 bootstrap (macOS only)
   - Validation (prerequisites, symlinks, packages)

2. **`lib/main.sh`** (52 lines) - Main orchestrator that:
   - Sources all installation functions
   - Calls installers in the correct order
   - Handles overall installation flow

**Installation Flow:**

1. Check prerequisites (git, curl, YADR directory)
2. Initialize and update git submodules
3. Install Homebrew and packages (via Brewfile)
4. Install Python/Ruby/npm packages for NeoVim
5. Create symlinks for config files (git, ruby, vimify, vim, zsh)
6. Create modern config symlinks (nvim, ranger, ghostty, etc.)
7. Install Prezto framework and switch shell to zsh
8. Install fonts
9. Bootstrap iTerm2 (macOS only)
10. Validate installation

**Interactive Mode:**

```bash
sh -c "`curl -fsSL https://raw.githubusercontent.com/lfilho/dotfiles/main/install.sh`" -s ask
```

Or locally:
```bash
cd ~/.yadr
ASK=true ./install.sh
```

This prompts before installing each component.

**Environment Variables:**

- `ASK=true` - Interactive mode (prompts before each section)
- `DEBUG=true` - Dry run (shows what would be done, doesn't execute)
- `SKIP_SUBMODULES=true` - Skip git submodule operations
- `CI=true` - Use minimal Brewfile for CI testing

**Key Features:**

- **Platform-aware**: Automatically handles macOS/Linux differences
- **Strict error handling**: Uses `set -euo pipefail` for immediate error detection
- **Colored logging**: Clear visual feedback with log levels
- **Idempotent**: Safe to run multiple times
- **Shellcheck validated**: Zero warnings, follows best practices

---

## Configuration Files Map

### NeoVim (nvim-user-config/)

**Framework**: AstroNvim v4+ (Lua-based)
**Plugin Manager**: Lazy.nvim
**Structure**:

```
nvim-user-config/
├── init.lua                          # Bootstrap (loads Lazy.nvim)
├── lua/
│   ├── lazy_setup.lua               # Lazy.nvim configuration
│   ├── polish.lua                   # Final polish/tweaks
│   └── plugins/
│       ├── astrocore.lua            # Core options, mappings, autocmds
│       ├── astrolsp.lua             # LSP configuration
│       ├── astroui.lua              # UI components, icons, themes
│       ├── colorschemes.lua         # Color scheme setup
│       ├── treesitter.lua           # Syntax highlighting
│       ├── mason.lua                # LSP/tool installer
│       ├── none-ls.lua              # Linting/formatting
│       ├── snacks.lua               # UI enhancements
│       ├── user.lua                 # Custom plugins [MODIFY THIS]
│       ├── community.lua            # AstroNvim community configs
│       └── todo.lua                 # Todo management
├── spell/                           # Custom dictionaries
├── art/                             # ASCII art
├── lazy-lock.json                   # Pinned plugin versions
└── README.md                        # Comprehensive guide
```

**Documentation**: The README.md in this directory has been completely rewritten to reflect the modern Lua/AstroNvim structure. It covers plugin management with Lazy.nvim, LSP configuration, key mappings, and customization guides.

### Zsh (zsh/)

**Framework**: Prezto
**Structure**:

```
zsh/
├── zshrc                            # Main entry (sources everything)
├── 0000_before.zsh                  # Pre-configuration hook
├── aliases.zsh                      # Shell aliases [MODIFY THIS]
├── fzf.zsh                          # Fuzzy finder config
├── 01_fzf-tab.zsh                   # Tab completion with fzf
├── atuin.zsh                        # History tool
├── bat.zsh                          # Bat syntax highlighter
├── fasd.zsh                         # Quick navigation (z command)
├── vi-mode.zsh                      # Vi keybindings
├── git.zsh                          # Git prompt
├── key-bindings.zsh                 # Custom key bindings
├── projects.zsh                     # Project shortcuts
├── prezto/                          # Prezto submodule
├── prezto-override/
│   └── zpreztorc                    # Prezto configuration
└── custom-modules/
    ├── fzf-tab/                     # Submodule
    └── fast-syntax-highlighting/    # Submodule
```

**Load Order**:
1. Prezto initialization
2. `0000_before.zsh` (user hooks from `~/.zsh.before/`)
3. All other `*.zsh` files (alphabetically)
4. User hooks from `~/.zsh.after/`

### Git (git/)

```
git/
├── gitconfig                        # Main config (aliases, colors)
├── gitignore                        # Global ignore patterns
├── gitattributes                    # Diff settings
├── catppuccin.gitconfig             # Color scheme
└── lazygit/
    └── config.yml                   # LazyGit configuration
```

**Personal Settings**: `~/.gitconfig.user` (not in repo, created by user)

### Terminal Emulators

**Ghostty** (ghostty/):
- GPU-accelerated modern terminal
- Catppuccin Mocha theme
- Maple Mono font, size 16
- 13 custom cursor shaders (Tesla coil, glow, blaze, frozen, manga slash, etc.)
- Split navigation: cmd+k/j/h/l
- Quick toggle: ctrl+grave
- See `ghostty/README.md` for complete shader guide and configuration

**WezTerm** (wezterm/wezterm.lua):
- Lua-based configuration
- Workspace management

**iTerm2** (iTerm2/):
- `com.googlecode.iterm2.plist` - Full settings
- 15+ color schemes (Catppuccin variants, Gruvbox, GitHub Dark, etc.)
- `bootstrap-iterm2.sh` - Auto-configuration script

### Window Management

**Yabai** (yabai/) - macOS only:
- Binary Space Partitioning (BSP) tiling window manager
- Configuration: `yabai/yabairc` - main config with window rules and appearance
- Helper scripts: `yabai/layouts.sh` - custom layout functions
- Zsh integration: `zsh/yabai.zsh` - aliases for common operations
- Features:
  - Display pinning rules (Zoom, Firefox → laptop display)
  - Custom layouts (e.g., Zoom + Ghostty split layout)
  - Window maximize toggle
  - Service management aliases (`ystart`, `ystop`, `yrestart`, `ystatus`)
- See `yabai/README.md` for complete setup and usage guide

---

## Customization Points

### User Customization Directories (IMPORTANT!)

**NEVER modify core config files directly**. Use these hooks:

| Hook Directory | Purpose | Load Time |
|----------------|---------|-----------|
| `~/.zsh.before/` | Zsh customizations (before YADR) | Early in zshrc |
| `~/.zsh.after/` | Zsh customizations (after YADR) | Late in zshrc |
| `~/.zsh.prompts/` | Custom zsh prompts (`prompt_name_setup`) | When prompt loads |
| `~/.gitconfig.user` | Personal git settings (user, email) | Git config include |
| `~/.tmux.conf.user` | Personal tmux overrides | Tmux config source |

### How to Customize

**Add a shell alias:**
```bash
echo "alias myalias='my command'" > ~/.zsh.after/myalias.zsh
```

**Change zsh prompt:**
```bash
echo "prompt mytheme" > ~/.zsh.after/prompt.zsh
```

**Add git user config:**
```bash
cat > ~/.gitconfig.user << 'EOF'
[user]
  name = Your Name
  email = your.email@example.com
EOF
```

**Add NeoVim plugin:**
Edit `nvim-user-config/lua/plugins/user.lua` and add to the return array.

---

## Key Technologies & Tools

### Shell & Terminal

| Tool | Purpose | Config Location | Notes |
|------|---------|----------------|-------|
| **zsh** | Shell | `zsh/zshrc` | Via Prezto framework |
| **Prezto** | Zsh framework | `zsh/prezto/` | Git submodule |
| **fzf** | Fuzzy finder | `zsh/fzf.zsh` | Integrated in shell, vim |
| **fzf-tab** | Tab completion | `zsh/01_fzf-tab.zsh` | Custom module |
| **fast-syntax-highlighting** | Shell syntax | `zsh/custom-modules/` | Custom module |
| **atuin** | History tool | `zsh/atuin.zsh` | Enhanced Ctrl-R |
| **fasd** | Quick navigation | `zsh/fasd.zsh` | z command |
| **Ghostty** | Terminal emulator | `ghostty/config` | GPU-accelerated |
| **WezTerm** | Terminal emulator | `wezterm/wezterm.lua` | Alternative terminal |
| **iTerm2** | Terminal (macOS) | `iTerm2/` | Automated setup |
| **yabai** | Window manager (macOS) | `yabai/yabairc` | Tiling window manager |

### Editor & Development

| Tool | Purpose | Config Location | Notes |
|------|---------|----------------|-------|
| **NeoVim** | Text editor | `nvim-user-config/` | AstroNvim distribution |
| **AstroNvim** | NeoVim distro | Via Lazy.nvim | Lua-based, v4+ |
| **Lazy.nvim** | Plugin manager | `lua/lazy_setup.lua` | Fast, lazy-loading |
| **Mason** | LSP installer | `lua/plugins/mason.lua` | Auto-installs language servers |
| **Treesitter** | Syntax parsing | `lua/plugins/treesitter.lua` | Better highlighting |
| **None-ls** | Linting/formatting | `lua/plugins/none-ls.lua` | Null-ls successor |

### File & Code Tools

| Tool | Purpose | Config Location | Notes |
|------|---------|----------------|-------|
| **ranger** | File manager | `ranger/` | Vim-like navigation |
| **eza** | Modern ls | `eza/` | Replaces ls command |
| **bat** | Syntax viewer | `bat/themes/` | Replaces cat |
| **ripgrep** | Code search | Via fzf.zsh | Replaces grep |
| **fd** | File finder | Via fzf.zsh | Replaces find |
| **git-delta** | Diff viewer | Via gitconfig | Better git diffs |

### Multiplexer & Utilities

| Tool | Purpose | Config Location | Notes |
|------|---------|----------------|-------|
| **tmux** | Terminal multiplexer | `tmux/tmux.conf` | Powerline status |
| **ctags** | Code navigation | `ctags/` | Function jumping |
| **lazygit** | Git TUI | `lazygit/` | Terminal UI for git |

---

## Common Tasks & Workflows

### For AI Agents: Task Guidelines

#### Adding a New Tool/Package

**The YADR Tool Configuration Pattern:**

1. **Create config directory** in `~/.yadr/[tool-name]/` with config files
2. **Make scripts executable** before committing: `chmod +x ~/.yadr/[tool-name]/script.sh`
3. **Add to Brewfile** (if it needs installation) - place in appropriate category
4. **Update `lib/install.sh`** to create symlink in `create_config_symlinks()` function
5. **Add zsh integration** (optional) in `~/.yadr/zsh/[tool-name].zsh` for aliases/environment
6. **Document** in README.md and this AGENTS.md file

**Key Insight**: Executable permissions are stored in git and should be set before committing, NOT during installation.

**Example**: Adding tool "yabai"

```bash
# 1. Create config directory with files
mkdir ~/.yadr/yabai
# Create yabai/yabairc, yabai/scripts.sh, etc.

# 2. Make scripts executable (commit these permissions to repo)
chmod +x ~/.yadr/yabai/yabairc
chmod +x ~/.yadr/yabai/scripts.sh
```

```ruby
# 3. In Brewfile - add under appropriate category section
if OS.mac?
    brew 'koekeishiya/formulae/yabai'  # Window manager
end
```

```bash
# 4. In lib/install.sh, in create_config_symlinks() function
# Add after other symlinks, use platform guards if needed
if is_macos; then
    echo "mkdir -p ${HOME}/.config/yabai"
    mkdir -p "${HOME}/.config/yabai"

    echo "ln -nfs ${HOME}/.yadr/yabai/yabairc ${HOME}/.config/yabai/yabairc"
    ln -nfs "${HOME}/.yadr/yabai/yabairc" "${HOME}/.config/yabai/yabairc"
fi

# 5. Optional: Create zsh integration
# In zsh/yabai.zsh
alias ystart="yabai --start-service"
alias ystop="yabai --stop-service"
```

#### Adding a Zsh Alias

**NEVER modify `zsh/aliases.zsh` directly** if it's personal. Use hooks instead.

For YADR-wide aliases, modify `zsh/aliases.zsh`:

```bash
# In zsh/aliases.zsh
alias myalias='my command'
```

#### Adding a NeoVim Plugin

**IMPORTANT**: When adding, removing, or modifying plugins in `user.lua`, ALWAYS update the plugin list in `nvim-user-config/README.md` under "Custom User Plugins" section.

Edit `nvim-user-config/lua/plugins/user.lua`:

```lua
return {
  -- Add new plugin spec
  {
    "author/plugin-name",
    lazy = false, -- or true with events
    config = function()
      -- Plugin setup
    end,
  },
}
```

Then update `nvim-user-config/README.md` to document the plugin:

```markdown
### Custom User Plugins (lua/plugins/user.lua)

- **plugin-name** - Brief description
  - Key mappings if any
```

#### Modifying Git Configuration

**For personal settings**: Use `~/.gitconfig.user`

**For YADR-wide settings**: Edit `git/gitconfig`:

```gitconfig
[alias]
  myalias = "!git command here"
```

#### Updating Submodules

```bash
cd ~/.yadr
git submodule update --init --recursive
git submodule update --remote --merge  # Update to latest
```

#### Creating a Custom Zsh Prompt

```bash
# Create prompt file
cat > ~/.zsh.prompts/prompt_mytheme_setup << 'EOF'
function prompt_mytheme_setup {
  PROMPT='%~ %# '
}

prompt_mytheme_setup "$@"
EOF

# Activate it
echo "prompt mytheme" > ~/.zsh.after/prompt.zsh
```

---

## Troubleshooting Guide

### Common Issues

#### Symlinks Not Working

**Problem**: Config files not loading
**Solution**: Run the installer to recreate symlinks

```bash
cd ~/.yadr
./install.sh
```

#### Prezto Not Loading

**Problem**: Zsh doesn't have custom features
**Solution**: Check if `.zprezto` symlink exists

```bash
ls -la ~/.zprezto
# Should point to ~/.yadr/zsh/prezto
```

#### NeoVim Plugins Not Working

**Problem**: Plugins not loaded
**Solution**: Open nvim and run `:Lazy sync`

```vim
:Lazy sync
:checkhealth  " Check for issues
```

#### Homebrew Packages Missing

**Problem**: Commands not found
**Solution**: Run brew bundle install

```bash
cd ~/.yadr
brew bundle install
```

#### Fonts Not Displaying Icons

**Problem**: Square boxes instead of icons
**Solution**: Install patched fonts

```bash
# macOS
cp -f ~/.yadr/fonts/* ~/Library/Fonts/

# Linux
mkdir -p ~/.fonts && cp ~/.yadr/fonts/* ~/.fonts && fc-cache -vf ~/.fonts
```

#### Git Submodules Out of Date

**Problem**: Prezto or plugins not working
**Solution**: Update submodules

```bash
cd ~/.yadr
git submodule update --init --recursive
```

---

## Code Modification Guidelines

### For AI Agents: Best Practices

#### 1. Understand the Load Order

- **Zsh**: Prezto → `0000_before.zsh` → other zsh files → user hooks
- **NeoVim**: `init.lua` → `lazy_setup.lua` → plugins → `polish.lua`
- **Git**: `gitconfig` → `~/.gitconfig.user` (includes)

#### 2. Prefer User Customization Points

- **DON'T**: Modify `zsh/zshrc` or `nvim-user-config/init.lua` directly
- **DO**: Use `~/.zsh.after/`, `~/.zsh.before/`, `lua/plugins/user.lua`

#### 3. Maintain Cross-Platform Compatibility

Use platform detection:

```bash
# Installation scripts (lib/install.sh)
if is_macos; then
  # macOS-specific
else
  # Linux-specific
fi
```

```lua
-- NeoVim Lua
if vim.fn.has("mac") == 1 then
  -- macOS-specific
elseif vim.fn.has("unix") == 1 then
  -- Linux-specific
end
```

```bash
# Shell scripts
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
else
  # Linux
fi
```

#### 4. Document Changes

When modifying configs, update:
1. Inline comments in the file
2. Relevant README.md files
3. This AGENTS.md file
4. Main README.md (if user-facing)
5. **CRITICAL**: When adding/removing/modifying NeoVim plugins in `lua/plugins/user.lua`, ALWAYS update the plugin list in `nvim-user-config/README.md` under "Custom User Plugins" section

#### 5. Follow Existing Patterns

- **Naming**: Use descriptive, lowercase names with hyphens (e.g., `git-extras`)
- **File organization**: Group by tool/category
- **Comments**: Explain WHY, not just WHAT

#### 6. Test on Both Platforms

YADR supports macOS and Linux. Consider:
- Homebrew paths differ (`/opt/homebrew` vs `/home/linuxbrew/.linuxbrew`)
- Shell paths differ (`/usr/local/bin/zsh` vs `/home/linuxbrew/.linuxbrew/bin/zsh`)
- Font installation differs

#### 7. Handle Git Submodules Carefully

When adding/modifying submodules:

```bash
# Adding a new submodule
git submodule add <url> <path>
git submodule update --init --recursive

# Updating submodule URL
git config --file=.gitmodules submodule.<path>.url <new-url>
git submodule sync
git submodule update --init --recursive
```

#### 8. Preserve User Configurations

**NEVER** overwrite these files:
- `~/.zsh.after/`
- `~/.zsh.before/`
- `~/.zsh.prompts/`
- `~/.gitconfig.user`
- `~/.tmux.conf.user`

The installer already handles this with backup logic.

#### 9. Version Pinning

- NeoVim plugins: `lazy-lock.json` pins versions
- Homebrew: Brewfile doesn't pin versions (uses latest)
- Git submodules: Pinned to specific commits

When updating, consider impact on users.

#### 10. Lua Configuration (NeoVim)

**Structure**: Return plugin specs, not side effects

```lua
-- GOOD
return {
  {
    "plugin/name",
    config = function()
      require("plugin").setup({})
    end,
  },
}

-- BAD
require("plugin").setup({})
return {}
```

**Keymaps**: Define in `astrocore.lua` mappings section

```lua
-- In lua/plugins/astrocore.lua
mappings = {
  n = {
    ["<Leader>x"] = { "<cmd>Command<CR>", desc = "Description" },
  },
}
```

---

## Migration Notes

### Active Migration Tasks (migration-todo.md)

The repository has pending NeoVim migration tasks:

1. **Window/split closing keymap**: Previous `Q` mapping needs replacement
2. **Debugger setup**: nvim-dap integration needed
3. **Community plugin evaluation**:
   - nvim-spectre (search/replace)
   - trouble.nvim (diagnostics)
   - sibling-swap.nvim (swap function args)
   - package-info.nvim (package version info)
   - tabout.nvim (tab out of brackets)
4. **Keymap normalization**: Unify split opening across neotree, snacks picker

**AI Agent Note**: When working on these, check if AstroNvim community pack exists first.

---

## Quick Reference Card

### Essential Paths

```
~/.yadr                          # Main repo
~/.config/nvim                   # NeoVim config (symlink)
~/.zprezto                       # Prezto framework (symlink)
~/.zsh.after/                    # User zsh customizations
~/.gitconfig.user                # User git config
~/.tmux.conf.user                # User tmux config
```

### Essential Commands

```bash
# Installation/Update
cd ~/.yadr && ./install.sh

# Interactive installation
cd ~/.yadr && ASK=true ./install.sh

# Dry run (see what would be done)
cd ~/.yadr && DEBUG=true ./install.sh

# Update submodules
cd ~/.yadr && git submodule update --init --recursive

# Reinstall Homebrew packages
cd ~/.yadr && brew bundle install

# Reload zsh
source ~/.zshrc

# Update NeoVim plugins
nvim +Lazy sync +qa
```

### Key Keybindings

**Shell (vi-mode)**:
- `Ctrl-R` - Reverse history search (Atuin)
- `Ctrl-T` - Fuzzy file finder (fzf)
- `Ctrl-R` - Fuzzy history (fzf)
- `z <partial>` - Jump to recent directory (fasd)

**Tmux**:
- `Ctrl-h/j/k/l` - Navigate panes (works with vim splits)

**NeoVim**:
- `<Leader>` = `,`
- `,f` - Find definition
- `,gg` or `,rg` - Ripgrep search
- `Ctrl-p` - File picker
- `Space-e` - File explorer

**Ghostty**:
- `Cmd+k/j/h/l` - Navigate splits (macOS)
- `Ctrl+grave` - Quick terminal toggle

---

## Version Information

**YADR Version**: @lfilho's fork
**NeoVim**: AstroNvim v4+ (Lua-based)
**Zsh Framework**: Prezto
**Plugin Manager**: Lazy.nvim
**Supported OS**: macOS (primary), Linux (community-supported)

---

## Additional Resources

**Documentation Files:**
- `README.md` - Main installation guide
- `AGENTS.md` - This file - comprehensive AI agent guide
- `zsh/README.md` - Zsh customization and hooks
- `nvim-user-config/README.md` - NeoVim guide (completely rewritten for AstroNvim)
- `ghostty/README.md` - Ghostty terminal with shader guide
- `git/README.md` - Git aliases/config
- `tmux/README.md` - Tmux config
- `vimify/README.md` - CLI vim keybindings
- `doc/credits.md` - Attribution
- `doc/osx_tools.md` - Recommended macOS tools

**External Links:**
- [Prezto](https://github.com/sorin-ionescu/prezto) - Zsh framework
- [AstroNvim](https://astronvim.com) - NeoVim distribution
- [Lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [Original YADR](https://github.com/skwp/dotfiles) - Upstream repo

---

## For AI Agents: Summary Checklist

When assisting with this repository:

- [ ] Check if modification should go in core config or user customization hook
- [ ] Maintain cross-platform compatibility (macOS and Linux)
- [ ] Follow existing naming conventions and patterns
- [ ] Update relevant documentation
- [ ] Consider git submodule implications
- [ ] Preserve user customization directories
- [ ] Test commands before suggesting (or note they're untested)
- [ ] Reference this AGENTS.md for context

**Remember**: This is a mature, production dotfiles repo. Changes should be conservative, well-documented, and backward-compatible.

---

**Last Updated**: 2026-01-16
**Maintained By**: @lfilho
**AI Agent Guide Version**: 1.2
