# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
# Commenting the below out so Atuin can use the same keybindings
# source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# fasd & fzf change directory - jump using `fasd` if given argument, filter output of `fasd` using `fzf` else
# Initialize fasd on first use if it's lazy-loaded
z() {
  # Initialize fasd if it's lazy-loaded
  if typeset -f _fasd_lazy_init >/dev/null; then
    _fasd_lazy_init
  fi

  [ $# -gt 0 ] && fasd_cd -d "$*" && return
  local dir
  dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  # Colors below are catpucchin https://github.com/catppuccin/fzf
  export FZF_DEFAULT_OPTS=" \
    -m --height 50% --border \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a \
    --multi"
fi

