set -o vi
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

# Defer zsh-vi-mode loading to improve startup time
# Loads asynchronously in the background after the prompt is ready
if command -v brew &>/dev/null; then
  zvm_plugin_path="$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  if [[ -f "$zvm_plugin_path" ]]; then
    {
      source "$zvm_plugin_path"
    } &!
  fi
  unset zvm_plugin_path
fi
