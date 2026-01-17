#!/usr/bin/env bash

# ============================================================================
# Alfred Wrapper for Yabai Layouts
# Receives "window_id command" as a single argument from Alfred
# Executes layout commands on the previously focused window
# ============================================================================

# Parse the argument: "window_id command"
window_id=$(echo "$1" | awk '{print $1}')
command=$(echo "$1" | awk '{print $2}')

# If window ID is empty/null, fall back to current focused window
if [[ -z "$window_id" ]] || [[ "$window_id" == "null" ]]; then
  window_id=$(yabai -m query --windows --window | jq -r '.id')
fi

# Execute the command on the specific window
case "$command" in
maximize)
  # Maximize window to fill the screen (not macOS fullscreen)
  # First ensure it's not floating
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  if [[ "$is_floating" == "true" ]]; then
    yabai -m window "$window_id" --toggle float
  fi
  
  # Toggle zoom-fullscreen which maximizes without entering fullscreen mode
  yabai -m window "$window_id" --toggle zoom-fullscreen
  ;;
zoom-ghostty)
  ~/.yadr/yabai/layouts.sh zoom-ghostty
  ;;
float)
  yabai -m window "$window_id" --toggle float
  ;;
float-center)
  yabai -m window "$window_id" --toggle float --grid 4:4:1:1:2:2
  ;;
*)
  # Fall back to original script
  ~/.yadr/yabai/layouts.sh "$command"
  ;;
esac
