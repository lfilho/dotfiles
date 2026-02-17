# Lazy-load nvm - only initialize when actually used
export NVM_DIR="$HOME/.config/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Define commands that should trigger nvm initialization
  local nvm_commands=(nvm node npm npx yarn claude-code-acp)

  # Initialize nvm once when any node-related command is first used
  _load_nvm() {
    # Unset all wrapper functions
    unset -f "${nvm_commands[@]}"
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  }

  # Create wrapper functions that trigger nvm initialization
  for cmd in "${nvm_commands[@]}"; do
    eval "${cmd}() { _load_nvm && ${cmd} \"\$@\"; }"
  done
fi