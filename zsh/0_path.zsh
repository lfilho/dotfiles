# path, the 0 in the filename causes this to load first
#
# If you have duplicate entries on your PATH, run this command to fix it:
# PATH=$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')

pathAppend() {
  # Only adds to the path if it's not already there
  if ! echo "$PATH" | egrep -q "(^|:)$1($|:)"; then
    PATH=$PATH:$1
  fi
}

[[ "$OSTYPE" == linux* ]] && [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

pathAppend "$HOME/.yadr/bin"
pathAppend "$HOME/.lmstudio/bin"
pathAppend "$HOME/.claude/local"

export XDG_CONFIG_HOME="$HOME/.config"
