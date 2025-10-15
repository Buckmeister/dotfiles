#!/usr/bin/env zsh

# ============================================================================
# Vim Environment Setup
# ============================================================================
#
# Sets up vim-plug plugin manager and installs configured plugins.
# Uses shared libraries for consistent downloading and validation.
#
# Dependencies:
#   - vim or nvim (optional) → system package
#
# vim-plug: https://github.com/junegunn/vim-plug
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================


# ============================================================================
# Path Detection and Library Loading
# ============================================================================

# Initialize paths using shared utility
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../bin/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)
init_dotfiles_paths

LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/installers.zsh"
source "$LIB_DIR/os_operations.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_DIR="$HOME/.vim/autoload"
VIM_PLUG_FILE="$VIM_PLUG_DIR/plug.vim"
VIM_PLUG_CONFIG_DIR="$HOME/.config/vim-plug"

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Vim Environment Setup" "vim-plug and plugin installation"
echo

# ============================================================================
# Checking Dependencies
# ============================================================================

draw_section_header "Checking Dependencies"

# Check if vim or nvim is available
if ! command_exists vim && ! command_exists nvim; then
    print_warning "Neither vim nor nvim found"
    print_info "Install vim or neovim before running this script"
    exit 0
fi

if command_exists vim; then
    print_success "vim is available"
fi
if command_exists nvim; then
    print_success "nvim is available"
fi

echo

# ============================================================================
# Installation
# ============================================================================

draw_section_header "Installing vim-plug"

# Create vim-plug config directory
print_info "Creating vim-plug config directory..."
ensure_directory "$VIM_PLUG_CONFIG_DIR"
print_success "Directory created: $VIM_PLUG_CONFIG_DIR"

echo

# Download vim-plug if not already installed
if [[ -f "$VIM_PLUG_FILE" ]]; then
    print_success "vim-plug already installed"
else
    print_info "Downloading vim-plug..."
    if download_file "$VIM_PLUG_URL" "$VIM_PLUG_FILE" "vim-plug"; then
        print_success "vim-plug installed successfully"
    else
        print_error "Failed to download vim-plug"
        exit 1
    fi
fi

echo

draw_section_header "Installing Vim Plugins"

# Install vim plugins
if command_exists vim; then
    print_info "Installing vim plugins..."
    if vim +'PlugInstall --sync' +qa! &>/dev/null; then
        print_success "Vim plugins installed successfully"
    else
        print_warning "Vim plugin installation encountered issues"
    fi
else
    print_info "Vim not found - skipping plugin installation"
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Installed components:"
echo
echo "   • vim-plug (plugin manager)"
if command_exists vim; then
    echo "   • Vim plugins (via PlugInstall)"
fi

echo
print_info "📍 Location: $VIM_PLUG_FILE"

echo
print_success "$(get_random_friend_greeting)"
