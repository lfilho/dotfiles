p() {
  setopt aliases
  local projects=(
    "Dotfiles"
    "Gantt"
    "Iniatitive Tracker"
    "Notes"
    "Scoreboard"
    "Pipipitchu"
    "Work"
  )


  if [[ $# -eq 0 ]]; then
    # No arguments: show fzf selection
    local selected=$(printf "%s\n" "${projects[@]}" | fzf --height 40% --reverse)
  else
    # Argument provided: use fzf with query
    local search="$1"
    local selected=$(printf "%s\n" "${projects[@]}" | fzf -f "$search" | head -n1)
  fi

  # Check if a project was selected
  if [[ -n "$selected" ]]; then
    # Change directory based on the selected project
    case $selected in
      "Dotfiles")
        cd $HOME/.yadr &&
          v
        ;;
      "Notes")
          n
        ;;
      "Gantt")
        cd $HOME/work/standalone/emscripts/gsheet-gantt &&
          v
        ;;
      "Iniatitive Tracker")
        cd $HOME/work/standalone/emscripts/initiative-tracker &&
          v
        ;;
      "Scoreboard")
        cd $HOME/work/nas/rpi/scoreboard &&
          v
        ;;
      "Pipipitchu")
        cd $HOME/work/nas/pipipitchu &&
          v
        ;;
    esac
  fi
}
