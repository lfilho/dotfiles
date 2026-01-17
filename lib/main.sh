#!/usr/bin/env bash
# YADR Main Installation Orchestrator

set -euo pipefail

# Source all installation functions
# shellcheck source=install.sh
source "${HOME}/.yadr/lib/install.sh"

# Main installation function
yadr_install() {
    log_init
    echo ""
    log_section "Welcome to YADR Installation."
    echo ""

    # Check prerequisites
    check_prerequisites || exit 1

    # Initialize and update submodules
    submodule_init
    update_submodules

    # Install Homebrew and packages
    install_homebrew

    # Install additional packages
    install_python_packages
    install_ruby_packages
    install_npm_packages

    # Install config files (with prompts in ASK mode)
    install_files "git/*" "git configs (color, aliases)"
    install_files "ruby/*" "rubygems config (faster/no docs)"
    install_files "vimify/*" "vimification of command line tools"

    # Install vim and zsh files (always, no prompt)
    shopt -s nullglob
    for file in vim vimrc; do
        [[ -e "$file" ]] && install_single_file "$file" "symlink"
    done
    install_single_file "zsh/zshrc" "symlink"
    shopt -u nullglob

    # Create modern config symlinks
    create_config_symlinks

    # Install Prezto
    install_prezto

    # Install fonts
    install_fonts

    # Bootstrap iTerm2 (macOS only)
    bootstrap_iterm2

    # Success!
    log_success_banner "installed"
}

# Run installation
yadr_install "$@"
