#!/usr/bin/env zsh

# ============================================================================
# GHCup Packages Installation
# ============================================================================
#
# Installs Haskell Language Server (HLS) and updates GHCup.
# Uses shared libraries for consistent UI and validation.
#
# Dependencies:
#   - ghcup (Haskell toolchain manager) → toolchains.zsh
#
# GHCup is the Haskell toolchain installer.
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
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "ghcup" "Haskell toolchain manager" "toolchains.zsh"

# ============================================================================
# Main Execution
# ============================================================================

draw_header "GHCup Packages" "Haskell toolchain components"
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

echo

# ============================================================================
# Package Installation
# ============================================================================

draw_section_header "Installing Haskell Components"

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
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Installed components:"
echo
echo "   • Haskell Language Server (HLS)"
echo "   • GHCup (updated to latest)"

echo
print_info "💡 Note: Haskell Language Server is now available for your editor"

echo
print_success "$(get_random_friend_greeting)"
