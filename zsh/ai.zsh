ai_cmd_helper() {
  local prompt="${*}"
  # If no args, use fzf modal
  if [ -z "$prompt" ]; then
    prompt=$(echo "" | fzf \
      --print-query \
      --preview-window=hidden \
      --height=3 \
      --header="Type your prompt..." \
      --info=hidden)
    [ -z "$prompt" ] && return
  fi

  echo "Calling Claude..."
  local cmd=$(claude -p "Return ONLY the equivalent zsh command, remove code fences, comments, etc. It should be ready to paste and execute in a shell prompt: $prompt" 2>/dev/null | head -1)
  print -z "$cmd"
}
