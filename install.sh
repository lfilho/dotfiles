#!/usr/bin/env bash

set -euo pipefail

# Clone YADR if not present
if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing lfilho's YADR for the first time"
    git clone --depth=1 https://github.com/lfilho/dotfiles.git "$HOME/.yadr"
fi

cd "$HOME/.yadr"

# Handle 'ask' parameter for interactive mode
[ "${1:-}" = "ask" ] && export ASK="true"

# Use bash installer
# shellcheck source=lib/main.sh
source lib/main.sh
