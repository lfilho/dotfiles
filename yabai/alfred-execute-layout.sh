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
left-50)
  # Ensure window is floating first
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 1:2:0:0:1:1
  ;;
right-50)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 1:2:1:0:1:1
  ;;
left-30)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:0:0:3:10
  ;;
right-30)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:7:0:3:10
  ;;
left-70)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:0:0:7:10
  ;;
right-70)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:3:0:7:10
  ;;
top-50)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 2:1:0:0:1:1
  ;;
bottom-50)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 2:1:0:1:1:1
  ;;
top-30)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:0:0:10:3
  ;;
bottom-30)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:0:7:10:3
  ;;
top-70)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:0:0:10:7
  ;;
bottom-70)
  is_floating=$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')
  [[ "$is_floating" != "true" ]] && yabai -m window "$window_id" --toggle float
  yabai -m window "$window_id" --grid 10:10:0:3:10:7
  ;;
*)
  # Fall back to original script
  ~/.yadr/yabai/layouts.sh "$command"
  ;;
esac