# Alfred Workflow for Yabai Layouts

This workflow allows you to quickly trigger yabai layouts by typing `y` in Alfred.

## Setup Instructions

1. Double-click `~/.yadr/alfred/Yabai-Layouts.alfredworkflow`
2. Alfred will prompt to import - click "Import"
3. Done!

## Usage

1. Press ⌘Space (or your Alfred hotkey)
2. Type `y` 
3. Start typing layout name (e.g., "zoom", "max")
4. Press Enter to execute

## Adding New Layouts

When you add new layouts to `layouts.sh`:

1. Add the function
2. Add a case statement entry
3. Add a description in the help text like:
   ```bash
   echo "  my-layout  - Description of what it does"
   ```

The Alfred workflow will automatically pick it up! No need to modify anything else.

## Files

- `~/.yadr/yabai/layouts.sh` - Main layout script
- `~/.yadr/yabai/alfred-list-layouts.sh` - Alfred script filter (auto-discovers layouts)
- `~/.yadr/alfred/Yabai-Layouts.alfredworkflow` - Importable Alfred workflow
- This file - Setup instructions