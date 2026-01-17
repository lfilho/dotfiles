#!/usr/bin/env bash
# YADR Installation Functions
# All installation logic in one file for simplicity

set -euo pipefail

#==============================================================================
# LOGGING FUNCTIONS
#==============================================================================

log_init() {
    # Initialize colors if terminal supports it
    if [[ -t 1 ]]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        NC='\033[0m' # No Color
    else
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        NC=''
    fi
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_section() {
    echo ""
    echo "======================================================"
    echo "$*"
    echo "======================================================"
}

log_success_banner() {
    local action="$1"
    echo ""
    echo "   _     _           _         "
    echo "  | |   | |         | |        "
    echo "  | |___| |_____  __| | ____   "
    echo "  |_____  (____ |/ _  |/ ___)  "
    echo "   _____| / ___ ( (_| | |      "
    echo "  (_______\_____|\____|_|      "
    echo ""
    echo "YADR has been ${action}. Please restart your terminal and vim."
}

#==============================================================================
# PLATFORM DETECTION
#==============================================================================

is_macos() {
    local os_type="${OSTYPE:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
    [[ "$os_type" == "darwin"* ]]
}

is_linux() {
    local os_type="${OSTYPE:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
    [[ "$os_type" == "linux-gnu"* ]] || [[ "$os_type" == "linux" ]]
}

detect_linux_distro() {
    if [[ -f /etc/lsb-release ]]; then
        # shellcheck source=/dev/null
        source /etc/lsb-release
        echo "${DISTRIB_ID:-Unknown}"
    elif [[ -f /etc/debian_version ]]; then
        echo "Debian"
    elif [[ -f /etc/centos-release ]]; then
        echo "CentOS"
    elif [[ -f /etc/redhat-release ]]; then
        echo "RedHat"
    else
        echo "Unknown"
    fi
}

get_homebrew_prefix() {
    if is_macos; then
        echo "/opt/homebrew"
    else
        echo "/home/linuxbrew/.linuxbrew"
    fi
}

get_zsh_path() {
    local brew_prefix
    brew_prefix="$(get_homebrew_prefix)"

    if [[ -f "${brew_prefix}/bin/zsh" ]]; then
        echo "${brew_prefix}/bin/zsh"
    elif [[ -f "/usr/local/bin/zsh" ]]; then
        echo "/usr/local/bin/zsh"
    else
        echo "/bin/zsh"
    fi
}

#==============================================================================
# USER PROMPTS
#==============================================================================

ask_yn() {
    local question="$1"
    local default="${2:-y}"

    # Non-interactive mode: always yes
    if [[ "${ASK:-false}" != "true" ]]; then
        return 0
    fi

    local prompt
    if [[ "$default" = "y" ]]; then
        prompt="${question} [y]es, [n]o: "
    else
        prompt="${question} [y]es, [n]o: "
    fi

    read -r -p "$prompt" response
    response="${response:-$default}"

    [[ "$response" =~ ^[Yy] ]]
}

want_to_install() {
    local section="$1"
    ask_yn "Would you like to install configuration files for: ${section}?"
}

ask_choice() {
    local question="$1"
    shift
    local options=("$@")

    echo "$question"
    local i=1
    for option in "${options[@]}"; do
        echo "  $i. $option"
        ((i++))
    done

    while true; do
        read -r -p "Selection (1-${#options[@]}): " selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le "${#options[@]}" ]]; then
            echo "${options[$((selection-1))]}"
            return 0
        else
            log_error "Invalid selection. Please enter a number between 1 and ${#options[@]}."
        fi
    done
}

#==============================================================================
# FILE OPERATIONS
#==============================================================================

backup_file() {
    local path="$1"
    local backup_path="${path}.backup"

    if [[ ! -e "$path" ]]; then
        return 0
    fi

    # If backup already exists, add timestamp
    if [[ -e "$backup_path" ]]; then
        local timestamp
        timestamp="$(date +%Y%m%d_%H%M%S)"
        backup_path="${path}.backup.${timestamp}"
    fi

    echo "[Overwriting] ${path}...leaving original at ${backup_path}..."
    mv "$path" "$backup_path"
}

install_single_file() {
    local source_path="$1"
    local method="${2:-symlink}"

    local filename
    filename="$(basename "$source_path")"

    local source="${HOME}/.yadr/${source_path}"
    local target="${HOME}/.${filename}"

    echo "======================${filename}=============================="
    echo "Source: ${source}"
    echo "Target: ${target}"

    # Backup existing file if needed
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_link
            current_link="$(readlink "$target")"
            if [[ "$current_link" = "$source" ]]; then
                echo "Symlink already correct: ${target} -> ${source}"
                echo "=========================================================="
                echo ""
                return 0
            fi
        fi

        backup_file "$target"
    fi

    # Create symlink or copy
    if [[ "$method" = "symlink" ]]; then
        ln -nfs "$source" "$target"
    else
        cp -f "$source" "$target"
    fi

    echo "=========================================================="
    echo ""
}

install_files() {
    local pattern="$1"
    local description="$2"
    local method="${3:-symlink}"

    if ! want_to_install "$description"; then
        log_info "Skipping ${description}"
        return 0
    fi

    # Use bash globbing - word splitting is intentional here
    shopt -s nullglob
    # shellcheck disable=SC2206
    local files=($pattern)
    shopt -u nullglob

    if [[ ${#files[@]} -eq 0 ]]; then
        log_warn "No files found matching: ${pattern}"
        return 0
    fi

    for file_path in "${files[@]}"; do
        install_single_file "$file_path" "$method"
    done
}

#==============================================================================
# GIT OPERATIONS
#==============================================================================

submodule_init() {
    if [[ "${SKIP_SUBMODULES:-false}" = "true" ]]; then
        log_info "Skipping submodule initialization (SKIP_SUBMODULES=true)"
        return 0
    fi

    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would initialize git submodules"
        return 0
    fi

    echo "git submodule update --init --recursive"
    git submodule update --init --recursive
}

update_submodules() {
    if [[ "${SKIP_SUBMODULES:-false}" = "true" ]]; then
        log_info "Skipping submodule updates (SKIP_SUBMODULES=true)"
        return 0
    fi

    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would update git submodules"
        return 0
    fi

    log_section "Downloading YADR submodules...please wait"

    echo "cd ${HOME}/.yadr"
    cd "${HOME}/.yadr"

    echo "git submodule update --recursive"
    git submodule update --recursive

    echo "git clean -df"
    git clean -df

    echo ""
}

#==============================================================================
# HOMEBREW INSTALLATION
#==============================================================================

has_homebrew() {
    command -v brew &>/dev/null
}

install_homebrew_linux() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install Homebrew for Linux"
        return 0
    fi

    echo "Running Homebrew 'install.sh' on Linux..."

    # Create directory if needed
    if [[ ! -d /home/linuxbrew ]]; then
        echo "sudo mkdir -p /home/linuxbrew"
        sudo mkdir -p /home/linuxbrew

        echo "sudo chmod 777 /home/linuxbrew"
        sudo chmod 777 /home/linuxbrew
    fi

    # Install Homebrew
    echo "yes | bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    yes | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true

    # Configure environment
    echo "Configuring 'brew shellenv' on Linux..."
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
    export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
    export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
    export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}"
    export INFOPATH="/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}"

    # Verify installation
    if ! has_homebrew; then
        log_error "'brew' is NOT in the path!"
        exit 1
    fi

    # Install build dependencies based on distro
    local distro
    distro="$(detect_linux_distro)"

    if [[ "$distro" = "Ubuntu" ]] || [[ "$distro" = "Debian" ]]; then
        echo "sudo apt-get install -y build-essential"
        sudo apt-get install -y build-essential
    elif [[ "$distro" = "CentOS" ]] || [[ "$distro" = "RedHat" ]]; then
        echo "sudo yum groupinstall -y 'Development Tools'"
        sudo yum groupinstall -y 'Development Tools'
    fi
}

install_homebrew() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install Homebrew"
        return 0
    fi

    # Check if already installed
    echo "which brew"
    if which brew &>/dev/null; then
        log_info "Homebrew is already installed"
    else
        log_section "Installing Homebrew, the OSX package manager...If it's"
        echo "already installed, this will do nothing."

        if is_macos; then
            echo "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\""
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            install_homebrew_linux
        fi
    fi

    echo ""
    echo ""
    log_section "Updating Homebrew."
    echo "brew update"
    brew update

    echo ""
    echo ""
    log_section "Installing Homebrew and other packages..."

    local brewfile="Brewfile"
    if [[ "${CI:-false}" = "true" ]]; then
        brewfile="test/Brewfile_ci"
    fi

    echo "brew bundle install --file=${brewfile}"
    brew bundle install --file="${brewfile}"

    echo ""
    echo ""
}

install_python_packages() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install Python packages"
        return 0
    fi

    if ! command -v pip3 &>/dev/null; then
        log_warn "pip3 not found, skipping Python packages"
        return 0
    fi

    echo "pip3 install --user neovim --break-system-packages"
    pip3 install --user neovim --break-system-packages || log_warn "Failed to install neovim Python package"

    echo "pip3 install --user pynvim --break-system-packages"
    pip3 install --user pynvim --break-system-packages || log_warn "Failed to install pynvim Python package"
}

install_ruby_packages() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install Ruby packages"
        return 0
    fi

    if ! command -v gem &>/dev/null; then
        log_warn "gem not found, skipping Ruby packages"
        return 0
    fi

    echo "gem install neovim"
    gem install neovim || log_warn "Failed to install neovim Ruby gem"
}

install_npm_packages() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install npm packages"
        return 0
    fi

    if ! command -v npm &>/dev/null; then
        log_warn "npm not found, skipping npm packages"
        return 0
    fi

    echo "npm install -g tree-sitter-cli"
    npm install -g tree-sitter-cli || log_warn "Failed to install tree-sitter-cli"
}

#==============================================================================
# SYMLINK CREATION
#==============================================================================

create_config_symlinks() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would create config symlinks"
        return 0
    fi

    echo "mkdir -p ${HOME}/.config"
    mkdir -p "${HOME}/.config"

    echo "ln -nfs ${HOME}/.yadr/nvim-user-config ${HOME}/.config/nvim"
    ln -nfs "${HOME}/.yadr/nvim-user-config" "${HOME}/.config/nvim"

    echo "mkdir -p ${HOME}/.config/ranger"
    mkdir -p "${HOME}/.config/ranger"

    echo "mkdir -p ${HOME}/.config/lazygit"
    mkdir -p "${HOME}/.config/lazygit"

    echo "ln -nfs ${HOME}/.yadr/ranger ${HOME}/.config/ranger"
    ln -nfs "${HOME}/.yadr/ranger" "${HOME}/.config/ranger"

    echo "ln -nfs ${HOME}/.yadr/ghostty ${HOME}/.config/ghostty"
    ln -nfs "${HOME}/.yadr/ghostty" "${HOME}/.config/ghostty"

    echo "ln -nfs ${HOME}/.yadr/wezterm ${HOME}/.config/"
    ln -nfs "${HOME}/.yadr/wezterm" "${HOME}/.config/"

    echo "ln -nfs ${HOME}/.yadr/lazygit ${HOME}/.config/lazygit"
    ln -nfs "${HOME}/.yadr/lazygit" "${HOME}/.config/lazygit"

    echo "ln -nfs ${HOME}/.yadr/eza ${HOME}/.config/eza"
    ln -nfs "${HOME}/.yadr/eza" "${HOME}/.config/eza"

    echo "ln -nfs ${HOME}/.yadr/bat ${HOME}/.config/bat"
    ln -nfs "${HOME}/.yadr/bat" "${HOME}/.config/bat"

    echo "touch ${HOME}/.hushlogin"
    touch "${HOME}/.hushlogin"

    if is_macos; then
        echo "mkdir -p ${HOME}/.config/yabai"
        mkdir -p "${HOME}/.config/yabai"

        echo "ln -nfs ${HOME}/.yadr/yabai/yabairc ${HOME}/.config/yabai/yabairc"
        ln -nfs "${HOME}/.yadr/yabai/yabairc" "${HOME}/.config/yabai/yabairc"
    fi
}

#==============================================================================
# PREZTO INSTALLATION
#==============================================================================

install_prezto_runcoms() {
    local runcoms=(
        "zlogin"
        "zlogout"
        "zpreztorc"
        "zprofile"
        "zshenv"
    )

    for runcom in "${runcoms[@]}"; do
        local source="${HOME}/.yadr/zsh/prezto/runcoms/${runcom}"
        local target="${HOME}/.${runcom}"

        # Only install if doesn't exist
        if [[ ! -e "$target" ]]; then
            install_single_file "zsh/prezto/runcoms/${runcom}" "symlink"
        fi
    done
}

create_customization_dirs() {
    echo "Creating directories for your customizations"

    echo "mkdir -p ${HOME}/.zsh.before"
    mkdir -p "${HOME}/.zsh.before"

    echo "mkdir -p ${HOME}/.zsh.after"
    mkdir -p "${HOME}/.zsh.after"

    echo "mkdir -p ${HOME}/.zsh.prompts"
    mkdir -p "${HOME}/.zsh.prompts"
}

switch_to_zsh() {
    local current_shell
    current_shell="$(basename "${SHELL:-/bin/bash}")"

    if [[ "$current_shell" = "zsh" ]]; then
        echo "Zsh is already configured as your shell of choice. Restart your session to load the new settings"
        return 0
    fi

    echo "Setting zsh as your default shell"

    local zsh_path
    zsh_path="$(get_zsh_path)"

    # Add zsh to /etc/shells if not present
    local shells_file
    if is_macos; then
        shells_file="/private/etc/shells"
    else
        shells_file="/etc/shells"
    fi

    if ! grep -q "^${zsh_path}$" "$shells_file" 2>/dev/null; then
        echo "Adding zsh to standard shell list"
        echo "echo \"${zsh_path}\" | sudo tee -a ${shells_file}"
        echo "${zsh_path}" | sudo tee -a "${shells_file}"
    fi

    # Change shell
    local current_user
    current_user="${USER:-$(whoami)}"

    if [[ -f "$zsh_path" ]]; then
        echo "sudo chsh -s ${zsh_path} ${current_user}"
        sudo chsh -s "$zsh_path" "$current_user"
    else
        echo "Falling back to default/system zsh"
        echo "chsh -s /bin/zsh"
        chsh -s /bin/zsh
    fi
}

install_prezto() {
    if ! want_to_install "zsh enhancements & prezto"; then
        log_info "Skipping Prezto installation"
        return 0
    fi

    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install Prezto"
        return 0
    fi

    echo ""
    echo "Installing Prezto (ZSH Enhancements)..."

    echo "ln -nfs ${HOME}/.yadr/zsh/prezto \${ZDOTDIR:-${HOME}}/.zprezto"
    ln -nfs "${HOME}/.yadr/zsh/prezto" "${ZDOTDIR:-$HOME}/.zprezto"

    # Install Prezto runcoms (only if not already present)
    install_prezto_runcoms

    echo ""
    echo "Overriding prezto ~/.zpreztorc with YADR's zpreztorc to enable additional modules..."
    echo "ln -nfs ${HOME}/.yadr/zsh/prezto-override/zpreztorc \${ZDOTDIR:-${HOME}}/.zpreztorc"
    ln -nfs "${HOME}/.yadr/zsh/prezto-override/zpreztorc" "${ZDOTDIR:-$HOME}/.zpreztorc"

    echo ""
    create_customization_dirs

    echo ""
    switch_to_zsh
}

#==============================================================================
# FONT INSTALLATION
#==============================================================================

install_fonts() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would install fonts"
        return 0
    fi

    log_section "Installing patched fonts for Powerline/Lightline."

    if is_macos; then
        echo "cp -f ${HOME}/.yadr/fonts/* ${HOME}/Library/Fonts"
        cp -f "${HOME}/.yadr/fonts/"* "${HOME}/Library/Fonts"
    else
        echo "mkdir -p ${HOME}/.fonts && cp ${HOME}/.yadr/fonts/* ${HOME}/.fonts && fc-cache -vf ${HOME}/.fonts"
        mkdir -p "${HOME}/.fonts"
        cp "${HOME}/.yadr/fonts/"* "${HOME}/.fonts"
        fc-cache -vf "${HOME}/.fonts"
    fi

    echo ""
}

#==============================================================================
# ITERM2 BOOTSTRAP
#==============================================================================

bootstrap_iterm2() {
    if ! is_macos; then
        return 0
    fi

    if [[ "${DEBUG:-false}" = "true" ]]; then
        log_info "[DRY RUN] Would bootstrap iTerm2"
        return 0
    fi

    local bootstrap_script="${HOME}/.yadr/iTerm2/bootstrap-iterm2.sh"

    if [[ ! -f "$bootstrap_script" ]]; then
        log_warn "iTerm2 bootstrap script not found: ${bootstrap_script}"
        return 0
    fi

    echo "${bootstrap_script}"
    "${bootstrap_script}"
}

#==============================================================================
# VALIDATION
#==============================================================================

check_prerequisites() {
    log_section "Checking Prerequisites"

    local failed=0

    # Check git
    if ! command -v git &>/dev/null; then
        log_error "git is not installed"
        ((failed++))
    else
        log_success "git found: $(git --version)"
    fi

    # Check curl
    if ! command -v curl &>/dev/null; then
        log_error "curl is not installed"
        ((failed++))
    else
        log_success "curl found"
    fi

    # Check if YADR directory exists
    if [[ ! -d "${HOME}/.yadr" ]]; then
        log_error "YADR directory not found: ${HOME}/.yadr"
        ((failed++))
    else
        log_success "YADR directory found"
    fi

    if [[ $failed -gt 0 ]]; then
        log_error "Prerequisites check failed"
        return 1
    fi

    log_success "All prerequisites satisfied"
    return 0
}
