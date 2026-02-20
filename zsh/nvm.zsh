# Lazy-load nvm - only initialize when actually used
export NVM_DIR="$HOME/.config/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Define commands that should trigger nvm initialization
  _nvm_commands=(nvm node npm npx yarn claude-code-acp clasp)

  # Initialize nvm once when any node-related command is first used
  _load_nvm() {
    # Hardcoded list (not the array) so this works even when _nvm_commands is
    # unavailable in the calling context (e.g. non-interactive subshells)
    unset -f nvm node npm npx yarn clasp claude-code-acp clasp _load_nvm 2>/dev/null
    # Stub compdef to silence "invalid subscript range" errors when nvm.sh is
    # sourced after prezto has already run compinit. Unsetting restores the real
    # autoloaded compdef for subsequent calls.
    compdef() {; }
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    unset -f compdef
  }

  # Create wrapper functions that trigger nvm initialization
  for cmd in "${_nvm_commands[@]}"; do
    eval "${cmd}() { _load_nvm && ${cmd} \"\$@\"; }"
  done
fi
