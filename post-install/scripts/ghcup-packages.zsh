#!/usr/bin/env zsh

# ============================================================================
# GHCup Packages Installation
# ============================================================================
#
# Installs Haskell Language Server (HLS) and updates GHCup.
# Uses shared libraries for consistent UI and validation.
#
# DEPENDENCY: Requires GHCup to be installed.
#             Run toolchains.zsh first if GHCup is not installed.
#
# GHCup is the Haskell toolchain installer.
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

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Main Installation
# ============================================================================

draw_header "GHCup Packages" "Haskell toolchain components"
echo

# Validate ghcup is available
if ! validate_command ghcup "ghcup (Haskell toolchain installer)"; then
    print_error "ghcup not found - please run toolchains.zsh first"
    print_info "Or install manually: https://www.haskell.org/ghcup/"
    exit 1
fi

echo

# Install Haskell Language Server
print_info "Installing Haskell Language Server (HLS)..."
if ghcup install hls 2>/dev/null; then
    print_success "HLS installed successfully"
else
    print_warning "HLS installation encountered issues (may already be installed)"
fi

echo

# Upgrade GHCup itself
print_info "Upgrading GHCup..."
if ghcup upgrade 2>/dev/null; then
    print_success "GHCup upgraded successfully"
else
    print_warning "GHCup upgrade encountered issues (may already be latest)"
fi

echo

# Clean up legacy symlink if it exists
if [[ -f "$HOME/.local/bin/ghcup" ]]; then
    print_info "Removing legacy ghcup symlink..."
    rm "$HOME/.local/bin/ghcup"
    print_success "Legacy symlink removed"
    echo
fi

print_success "GHCup packages installation complete!"
print_info "💡 Haskell Language Server is now available for your editor"

echo
print_success "$(get_random_friend_greeting)"
