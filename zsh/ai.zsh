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

# The AI coding harness entry points. Kept in a harness-agnostic file
# (ai.zsh, not omp.zsh) since the underlying harness may change later --
# only this file needs to change, not every callsite of `ai`/`aip`.
#
# The work profile is available wherever the Claude CLI is installed. Terminal
# environments may inject a `claude` shim on every machine, so inspect PATH
# entries directly and ignore shim directories when looking for the real CLI.
claude_path=""
for claude_dir in ${(s.:.)PATH}; do
  [[ -n "$claude_dir" && "$claude_dir" == */cmux-cli-shims/* ]] && continue
  if [[ -x "$claude_dir/claude" ]]; then
    claude_path="$claude_dir/claude"
    break
  fi
done
if [[ -n "$claude_path" ]]; then
  export OMP_PROFILE=work
else
  export OMP_PROFILE=personal
fi
unset claude_dir claude_path

# Everyday entry point: omp under whichever profile this machine defaults
# to.
ai() {
  omp --profile "$OMP_PROFILE" "$@"
}

# Force the personal profile from any machine, regardless of the default.
aip() {
  omp --profile personal "$@"
}

