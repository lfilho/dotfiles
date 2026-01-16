#!/usr/bin/env bash

# ============================================================================
# Alfred Script Filter for Yabai Layouts
# Outputs JSON for Alfred to display available layout commands
# ============================================================================

# Extract available commands from layouts.sh by parsing the case statement
layouts_file="$HOME/.yadr/yabai/layouts.sh"

# Parse the case statement to find all command options
commands=$(grep -A 100 "case \"\$1\" in" "$layouts_file" | grep -E "^[a-z-]+\)" | sed 's/)$//' | grep -v "^\*")

# Build JSON for Alfred
echo '{"items":['

first=true
while IFS= read -r cmd; do
  # Get the description from the help text by finding the line with the command
  description=$(grep "echo \"  $cmd" "$layouts_file" | sed -E 's/.*echo "  [a-z-]+[[:space:]]+-[[:space:]]+//' | tr -d '"')
  
  # If no description found, use a default
  [[ -z "$description" ]] && description="Run $cmd layout"
  
  # Add comma before all items except the first
  [[ "$first" != true ]] && echo ","
  first=false
  
  # Output JSON item
  cat <<EOF
  {
    "title": "$cmd",
    "subtitle": "$description",
    "arg": "$cmd",
    "icon": {
      "path": "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDesktopFolder.icns"
    }
  }
EOF
done <<< "$commands"

echo ']}'
