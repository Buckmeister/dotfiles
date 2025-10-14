#!/usr/bin/env zsh

# ============================================================================
# npm Global Packages Installation
# ============================================================================
#
# Installs npm global packages from a centralized package list.
# Uses shared libraries for package management, validation, and UI.
#
# Dependencies:
#   - npm (Node.js package manager) → system package (brew install node)
#
# Package list: config/packages/npm-packages.list
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
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_LIST="$CONFIG_DIR/packages/npm-packages.list"
UPDATE_MODE=false

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE_MODE=true
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [OPTIONS]"
            echo ""
            echo "OPTIONS:"
            echo "  --update    Update installed packages instead of installing new ones"
            echo "  --help, -h  Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "npm" "Node.js package manager" ""

# ============================================================================
# Main Execution
# ============================================================================

if $UPDATE_MODE; then
    draw_header "npm Global Packages" "Updating Node.js global packages"
else
    draw_header "npm Global Packages" "Installing Node.js global packages"
fi
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show npm version
if command_exists npm; then
    local npm_version=$(npm --version 2>/dev/null)
    print_success "npm available (version: $npm_version)"
fi

echo

if $UPDATE_MODE; then
    # ========================================================================
    # Update Mode: Update all installed npm packages
    # ========================================================================

    draw_section_header "Updating Installed Packages"

    if npm update -g 2>&1 | grep -E "(added|removed|updated|changed)" | while IFS= read -r line; do echo "  $line"; done; then
        echo
        print_success "npm packages updated successfully"
    else
        echo
        print_warning "Some packages may have failed to update"
    fi

else
    # ========================================================================
    # Install Mode: Install packages from list
    # ========================================================================

    draw_section_header "Installing Packages from List"

    # Check if package list exists
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        print_error "Package list not found: $PACKAGE_LIST"
        exit 1
    fi

    # Install packages from list
    npm_install_from_list "$PACKAGE_LIST"

    echo
    print_success "npm global packages installation complete!"
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

# Show installed npm packages
if command_exists npm; then
    print_info "📦 Installed npm global packages:"
    echo
    npm list -g --depth=0 2>/dev/null | tail -n +2 | head -20 | while read -r line; do
        # Extract package name from tree format
        local package=$(echo "$line" | sed -E 's/^[├└─│ ]+//' | cut -d'@' -f1)
        [[ -n "$package" ]] && echo "   • $package"
    done
fi

echo
print_success "$(get_random_friend_greeting)"
