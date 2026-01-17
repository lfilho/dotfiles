# Lazy-load nvm - only initialize when actually used
export NVM_DIR="$HOME/.config/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Create wrapper functions for common node commands
  function nvm() {
    unfunction nvm node npm npx 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    nvm "$@"
  }

  function node() {
    unfunction nvm node npm npx 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    node "$@"
  }

  function npm() {
    unfunction nvm node npm npx 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    npm "$@"
  }

  function npx() {
    unfunction nvm node npm npx 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    npx "$@"
  }
fi
