#!/usr/bin/env zsh

# ============================================================================
# LuaRocks Packages Installation
# ============================================================================
#
# Installs Lua packages via LuaRocks package manager.
# Uses shared libraries for consistent UI and validation.
#
# DEPENDENCY: Requires Lua and LuaRocks to be installed.
#             Install via system package manager (brew install luarocks, apt install luarocks)
#
# Note: Currently no packages configured for installation.
#       Edit this script or create config/packages/luarocks-packages.list to add packages.
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
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Main Installation
# ============================================================================

draw_header "LuaRocks Packages" "Installing Lua packages"
echo

# Validate luarocks is available
if ! validate_command luarocks "luarocks (Lua package manager)"; then
    print_error "luarocks not found - please install LuaRocks first"
    print_info "macOS: brew install luarocks"
    print_info "Linux: apt install luarocks / dnf install luarocks"
    exit 1
fi

echo

# Install packages
print_info "Installing LuaRocks packages..."

# Lua Formatter (currently commented out)
# print_info "Installing luaformatter..."
# luarocks install --server=https://luarocks.org/dev luaformatter

# Add more packages here as needed
# luarocks install <package-name>

print_info "No LuaRocks packages configured for installation"
print_info "Edit this script or config/packages/luarocks-packages.list to add packages"

echo
print_success "LuaRocks packages installation complete!"

echo
print_success "$(get_random_friend_greeting)"
