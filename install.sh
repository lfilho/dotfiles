#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing daxgames's YADR for the first time"
    git clone --depth=1 https://github.com/daxgames/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"
    rake install
else
    echo "YADR is already installed"
fi
