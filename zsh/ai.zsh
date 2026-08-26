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
# No "global" default-profile config -- every machine uses one of two
# named OMP profiles (~/.omp/profiles/work/agent/config.yml or
# .../personal/agent/config.yml), each fully isolated by OMP itself
# (separate settings, sessions, and credential store per profile; see
# omp/README.md). $HOST_KIND is set by an untracked ~/.zsh.before/ hook
# that hardcodes this machine's own hostname check -- never hardcode a
# real hostname in this tracked file. Unset/unrecognized -> "work" (the
# same fail-safe default as before).
if [[ "$HOST_KIND" == "personal" ]]; then
  export OMP_PROFILE=personal
else
  export OMP_PROFILE=work
fi

# Everyday entry point: omp under whichever profile this machine defaults
# to.
ai() {
  if [[ "$HOST_KIND" == "personal" ]]; then
    omp --profile personal "$@"
  else
    omp --profile work "$@"
  fi
}

# Force the personal profile from any machine, regardless of host.
aip() {
  omp --profile personal "$@"
}
