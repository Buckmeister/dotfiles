#!/usr/bin/env zsh

# ============================================================================
# LuaRocks Packages Installation
# ============================================================================
#
# Installs Lua packages via LuaRocks package manager.
# Uses shared libraries for consistent UI and validation.
#
# Dependencies:
#   - luarocks (Lua package manager) → system package
#
# Note: Currently no packages configured for installation.
#       Edit this script or create config/packages/luarocks-packages.list to add packages.
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

declare_dependency_command "luarocks" "Lua package manager" ""

# ============================================================================
# Main Execution
# ============================================================================

draw_header "LuaRocks Packages" "Installing Lua packages"
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show luarocks version
if command_exists luarocks; then
    local luarocks_version=$(luarocks --version 2>/dev/null | head -1 | awk '{print $2}')
    print_success "luarocks available (version: $luarocks_version)"
fi

echo

# ============================================================================
# Package Installation
# ============================================================================

draw_section_header "Installing LuaRocks Packages"

# Lua Formatter (currently commented out)
# print_info "Installing luaformatter..."
# luarocks install --server=https://luarocks.org/dev luaformatter

# Add more packages here as needed
# luarocks install <package-name>

print_info "No LuaRocks packages configured for installation"
print_info "Edit this script or config/packages/luarocks-packages.list to add packages"

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 LuaRocks status:"
echo
echo "   • No packages currently configured"
echo "   • Edit this script to add packages"

echo
print_info "💡 Note: Add package installations above or create config/packages/luarocks-packages.list"

echo
print_success "$(get_random_friend_greeting)"
