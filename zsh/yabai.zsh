# ============================================================================
# Yabai Window Manager Integration
# ============================================================================

# Set yabai config location
export YABAI_CONFIG_DIR="${HOME}/.yadr/yabai"

# Aliases for common yabai operations
alias ymax="${YABAI_CONFIG_DIR}/layouts.sh maximize"
alias ylayout-zoom="${YABAI_CONFIG_DIR}/layouts.sh zoom-ghostty"

# Window floating aliases (for manual resizing)
alias yfloat="yabai -m window --toggle float"
alias yfloat-center="yabai -m window --toggle float --grid 4:4:1:1:2:2"

# Restart yabai service
alias yrestart="yabai --restart-service"

# Stop yabai service
alias ystop="yabai --stop-service"

# Start yabai service
alias ystart="yabai --start-service"

# Show yabai status
alias ystatus="yabai --check-service"
