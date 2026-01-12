# Load fzf-tab plugin for enhanced tab completion
# Must load after compinit (which prezto already called)
if [[ -f "$HOME/.yadr/zsh/custom-modules/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.yadr/zsh/custom-modules/fzf-tab/fzf-tab.plugin.zsh"
fi
