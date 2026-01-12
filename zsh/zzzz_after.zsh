# Load any custom after code
if [ -d $HOME/.zsh.after/ ]; then
  if [ "$(ls -A $HOME/.zsh.after/)" ]; then
    for config_file ($HOME/.zsh.after/*.zsh) source $config_file
  fi
fi

# Load fast-syntax-highlighting (must be loaded at the end)
if [[ -f "$HOME/.yadr/zsh/custom-modules/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.yadr/zsh/custom-modules/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  # eval "$(oh-my-posh init zsh)"
  eval "$(oh-my-posh init zsh --config ~/.yadr/zsh/oh-my-posh-theme.json)"
fi
