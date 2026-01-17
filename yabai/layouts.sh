#!/usr/bin/env bash

# ============================================================================
# Yabai Layout Helper Scripts
# ============================================================================

# Function to maximize the currently focused window
maximize_window() {
  yabai -m window --toggle zoom-fullscreen
}

# Function to setup Zoom call + Ghostty layout
# - Zoom: Moved to external display (if available), 25% height (top), 50% width (centered)
# - Ghostty: 75% height (bottom), 80% width (right-aligned) on external display (if available)
# If no external display exists, both stay on laptop display
zoom_ghostty_layout() {
  # Query all displays and windows once
  local displays
  local windows
  displays=$(yabai -m query --displays)
  windows=$(yabai -m query --windows)
  
  # Parse display info efficiently
  local external_display_index
  local laptop_display_index
  external_display_index=$(jq -r '.[] | select(.index == 1) | .index' <<< "$displays")
  laptop_display_index=$(jq -r '.[] | select(.index == 2) | .index' <<< "$displays")

  # Determine target display
  local target_display_index
  if [[ -n "$external_display_index" ]]; then
    target_display_index="$external_display_index"
  else
    target_display_index="$laptop_display_index"
  fi

  # Get target display dimensions in one jq call, convert to integers
  local target_info
  target_info=$(jq -r ".[] | select(.index == $target_display_index) | .frame | \"\(.x | floor) \(.y | floor) \(.w | floor) \(.h | floor)\"" <<< "$displays")
  read -r target_x target_y target_width target_height <<< "$target_info"

  # Calculate all dimensions using bash arithmetic (faster than bc)
  local zoom_width=$((target_width * 50 / 100))
  local zoom_height=$((target_height * 25 / 100))
  local zoom_x=$((target_x + (target_width - zoom_width) / 2))
  local zoom_y=$target_y

  local ghostty_width=$((target_width * 80 / 100))
  local ghostty_height=$((target_height * 75 / 100))
  local ghostty_x=$((target_x + target_width - ghostty_width))
  local ghostty_y=$((target_y + target_height - ghostty_height))

  # Find window IDs - only Zoom Meeting window (not other Zoom windows)
  local zoom_id
  local ghostty_id
  zoom_id=$(jq -r '.[] | select(.title == "Zoom Meeting") | .id' <<< "$windows" | head -n 1)
  ghostty_id=$(jq -r '.[] | select(.app == "Ghostty") | .id' <<< "$windows" | head -n 1)

  # Get floating status for both windows at once
  local zoom_floating
  local ghostty_floating
  zoom_floating=$(jq -r ".[] | select(.id == $zoom_id) | .\"is-floating\"" <<< "$windows")
  ghostty_floating=$(jq -r ".[] | select(.id == $ghostty_id) | .\"is-floating\"" <<< "$windows")

  # Position Zoom window
  if [[ -n "$zoom_id" ]]; then
    # Ensure window is floating (unmanaged) - only toggle if NOT already floating
    if [[ "$zoom_floating" != "true" ]]; then
      yabai -m window "$zoom_id" --toggle float
    fi
    # Move to target display first
    yabai -m window "$zoom_id" --display "$target_display_index"
    # Small delay to let the display move complete
    sleep 0.05
    # Now position and resize - must be separate commands
    yabai -m window "$zoom_id" --move "abs:${zoom_x}:${zoom_y}"
    yabai -m window "$zoom_id" --resize "abs:${zoom_width}:${zoom_height}"
  fi

  # Position Ghostty window
  if [[ -n "$ghostty_id" ]]; then
    # Ensure window is floating (unmanaged) - only toggle if NOT already floating
    if [[ "$ghostty_floating" != "true" ]]; then
      yabai -m window "$ghostty_id" --toggle float
    fi
    # Move to target display first
    yabai -m window "$ghostty_id" --display "$target_display_index"
    # Small delay to let the display move complete
    sleep 0.05
    # Now position and resize - must be separate commands
    yabai -m window "$ghostty_id" --move "abs:${ghostty_x}:${ghostty_y}"
    yabai -m window "$ghostty_id" --resize "abs:${ghostty_width}:${ghostty_height}"
  fi
}

# Function to toggle floating mode for the focused window
toggle_float() {
  yabai -m window --toggle float
}

# Function to toggle floating mode and center the window at 50% size
float_centered() {
  yabai -m window --toggle float --grid 4:4:1:1:2:2
}

# Parse command line arguments
case "$1" in
maximize)
  maximize_window
  ;;
zoom-ghostty)
  zoom_ghostty_layout
  ;;
float)
  toggle_float
  ;;
float-center)
  float_centered
  ;;
*)
  echo "Usage: $0 {maximize|zoom-ghostty|float|float-center}"
  echo ""
  echo "Commands:"
  echo "  maximize      - Toggle fullscreen for the focused window"
  echo "  zoom-ghostty  - Layout Zoom (25% top) and Ghostty (75% bottom)"
  echo "  float         - Toggle floating mode for focused window"
  echo "  float-center  - Toggle float and center window at 50% size"
  exit 1
  ;;
esac