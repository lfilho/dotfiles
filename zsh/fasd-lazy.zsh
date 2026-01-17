# ============================================================================
# Lazy-loading for fasd - the 'z' command and directory jumping
# Only loads when you actually use fasd commands
# ============================================================================

if command -v fasd &>/dev/null; then
  # Initialize fasd on first use
  # This is called by wrapper functions and fzf.zsh
  _fasd_lazy_init() {
    # Only initialize once
    [[ -n $_fasd_initialized ]] && return
    _fasd_initialized=1

    # Initialize fasd properly
    fasd_cache="$HOME/.fasd-init-bash"
    if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
      eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)" >| "$fasd_cache"
    fi
    source "$fasd_cache"
    unset fasd_cache
  }

  # Create wrapper functions for a, s, f only
  # Note: 'd' conflicts with Prezto's directory alias
  # Note: 'z' is handled by fzf.zsh

  a() {
    _fasd_lazy_init
    fasd -a "$@"
  }

  s() {
    _fasd_lazy_init
    fasd -si "$@"
  }

  f() {
    _fasd_lazy_init
    fasd -f "$@"
  }
fi
