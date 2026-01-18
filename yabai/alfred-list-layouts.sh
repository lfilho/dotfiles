#!/usr/bin/env bash

# ============================================================================
# Alfred Script Filter for Yabai Layouts
# Outputs JSON for Alfred to display available layout commands
# ============================================================================

# Extract available commands from layouts.sh by parsing the case statement
layouts_file="$HOME/.yadr/yabai/layouts.sh"

# Get the previously focused window (non-Alfred window with the most recent focus)
previous_window=$(yabai -m query --windows | jq -r '[.[] | select(.app != "Alfred") | select(.app != "Alfred Preferences")] | sort_by(.["has-focus"], .["focus-history"]) | reverse | .[0].id')

# Parse the case statement to find all command options
commands=$(grep -A 100 "case \"\$1\" in" "$layouts_file" | grep -E "^[a-z0-9-]+\)" | sed 's/)$//' | grep -v "^\*")

# Build JSON for Alfred
echo '{"items":['

first=true
while IFS= read -r cmd; do
  # Get the description from the help text by finding the line with the command
  # Use word boundaries to match exact command name, extract from help text only
  # The pattern matches: echo "  command      - description"
  description=$(sed -n '/echo "Commands:"/,/exit 1/p' "$layouts_file" | grep "echo \"  $cmd[[:space:]]" | head -1 | sed -E 's/.*echo "  [a-z0-9-]+[[:space:]]+-[[:space:]]+//' | tr -d '"')
  
  # If no description found, use a default
  [[ -z "$description" ]] && description="Run $cmd layout"
  
  # Add comma before all items except the first
  [[ "$first" != true ]] && echo ","
  first=false
  
  # Output JSON item with window ID embedded in arg
  cat <<EOF
  {
    "title": "$cmd",
    "subtitle": "$description",
    "arg": "$previous_window $cmd",
    "icon": {
      "path": "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDesktopFolder.icns"
    }
  }
EOF
done <<< "$commands"

echo ']}'