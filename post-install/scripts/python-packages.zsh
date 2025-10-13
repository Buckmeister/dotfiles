#!/usr/bin/env zsh

# ============================================================================
# Python Package Management
# ============================================================================
#
# Manages Python packages using pipx for CLI tools and virtual environments
# for application-specific dependencies (like Neovim).
#
# Uses shared libraries for consistent UI and validation.
#
# DEPENDENCY: Requires Python 3 and pipx to be installed.
#             Install via system package manager (brew install pipx, apt install pipx)
#
# Components:
# - pipx CLI tools (powerline-status)
# - HTTPie with JWT plugin
# - Neovim Python support (dedicated venv)
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/os_operations.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

NVIM_VENV="${PYTHON_VENV_DIR:-$HOME/.local/lib/venvs}/nvim-venv"
NVIM_PYTHON_LINK="$INSTALL_BIN_DIR/nvim-python3"

# ============================================================================
# Powerline Status (CLI tool via pipx)
# ============================================================================

function install_powerline() {
    draw_section_header "Powerline Status"

    if ! command_exists pipx; then
        print_error "pipx not found - please install pipx first"
        return 1
    fi

    print_info "Upgrading/installing powerline-status..."
    if pipx upgrade powerline-status 2>/dev/null || pipx install powerline-status 2>/dev/null; then
        print_success "Powerline status installed/upgraded"
    else
        print_warning "Powerline status encountered issues"
    fi
}

# ============================================================================
# HTTPie with JWT Plugin
# ============================================================================

function install_httpie_with_jwt() {
    draw_section_header "HTTPie with JWT Plugin"

    if ! command_exists pipx; then
        print_error "pipx not found - please install pipx first"
        return 1
    fi

    # Check if HTTPie is already installed
    if pipx list 2>/dev/null | grep -q "httpie"; then
        print_success "HTTPie already installed via pipx"
    else
        print_info "Installing HTTPie via pipx..."
        if pipx install httpie --include-deps >/dev/null 2>&1; then
            print_success "HTTPie installed successfully"
        else
            print_error "Failed to install HTTPie"
            return 1
        fi
    fi

    echo

    # Check if JWT plugin is installed
    if pipx list 2>/dev/null | grep -A 10 "httpie" | grep -q "httpie-jwt-auth"; then
        print_success "HTTPie JWT plugin already installed"
    else
        print_info "Adding JWT authentication plugin..."
        if pipx inject httpie httpie-jwt-auth >/dev/null 2>&1; then
            print_success "JWT plugin added successfully"
        else
            print_error "Failed to add JWT plugin"
            return 1
        fi
    fi

    echo
    print_info "💡 Usage: http --auth-type=jwt ..."
}

# ============================================================================
# Neovim Python Support
# ============================================================================

function setup_neovim_python() {
    draw_section_header "Neovim Python Support"

    if ! command_exists python3; then
        print_error "python3 not found - please install Python first"
        return 1
    fi

    # Create dedicated virtual environment for Neovim
    if [[ ! -d "$NVIM_VENV" ]]; then
        print_info "Creating dedicated Neovim Python environment..."
        if python3 -m venv "$NVIM_VENV" >/dev/null 2>&1; then
            print_success "Virtual environment created"
        else
            print_error "Failed to create virtual environment"
            return 1
        fi
    else
        print_success "Neovim virtual environment already exists"
    fi

    echo

    # Upgrade pip in the venv
    print_info "Upgrading pip in Neovim venv..."
    "$NVIM_VENV/bin/pip" install --upgrade pip >/dev/null 2>&1

    # Install pynvim
    print_info "Installing pynvim in dedicated environment..."
    if "$NVIM_VENV/bin/pip" install pynvim >/dev/null 2>&1; then
        print_success "pynvim installed successfully"
    else
        print_error "Failed to install pynvim"
        return 1
    fi

    echo

    # Create symlink for Neovim to find
    print_info "Creating symlink for Neovim..."
    ensure_directory "$INSTALL_BIN_DIR"
    ln -sf "$NVIM_VENV/bin/python" "$NVIM_PYTHON_LINK"
    print_success "Symlink created: $NVIM_PYTHON_LINK"
}

# ============================================================================
# Old User Packages Cleanup
# ============================================================================

function check_old_user_packages() {
    draw_section_header "Old User Packages Check"

    if ! command_exists pip; then
        print_info "pip not found - skipping cleanup check"
        return 0
    fi

    # List current user packages that could be moved
    local old_packages=($(pip list --user --format=freeze 2>/dev/null | grep -E "^(httpie|httpie-jwt-auth)" | cut -d= -f1))

    if [[ ${#old_packages[@]} -gt 0 ]]; then
        print_warning "Found old user packages that can be replaced:"
        for pkg in "${old_packages[@]}"; do
            echo "  - $pkg (consider removing with: pip uninstall --user $pkg)"
        done
        echo ""
        print_info "After installing alternatives, you can clean these up with:"
        print_info "  pip uninstall --user ${old_packages[*]}"
    else
        print_success "No old user packages found"
    fi
}

# ============================================================================
# Main Installation
# ============================================================================

draw_header "Python Package Management" "pipx, HTTPie, and Neovim support"
echo

# Validate prerequisites
if ! validate_command python3 "python3"; then
    print_error "python3 not found - please install Python first"
    exit 1
fi

if ! validate_command pipx "pipx"; then
    print_error "pipx not found - please install pipx first"
    print_info "macOS: brew install pipx"
    print_info "Linux: apt install pipx / dnf install python3-pipx"
    exit 1
fi

echo

# Install Powerline
install_powerline
echo

# Install HTTPie with JWT plugin
install_httpie_with_jwt
echo

# Setup Neovim Python support
setup_neovim_python
echo

# Check for old user packages
check_old_user_packages
echo

print_success "Python package management setup complete!"
print_info "📦 Summary:"
echo "   ✅ CLI tools: pipx (isolated environments)"
echo "   ✅ HTTPie: with JWT authentication"
echo "   ✅ Neovim: dedicated virtual environment at $NVIM_VENV"
echo "   🚫 No more --break-system-packages needed!"

echo
print_success "$(get_random_friend_greeting)"
