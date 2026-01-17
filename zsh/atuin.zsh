# Defer atuin initialization to improve startup time
# It loads asynchronously in the background after the prompt is ready
if command -v atuin &>/dev/null; then
  {
    eval "$(atuin init zsh)"
  } &!
fi
