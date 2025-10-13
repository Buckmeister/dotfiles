#!/usr/bin/env zsh

# ============================================================================
# npm Global Packages Installation
# ============================================================================
#
# Installs npm global packages from a centralized package list.
# Uses shared libraries for package management, validation, and UI.
#
# DEPENDENCY: Requires Node.js and npm to be installed.
#             Install via system package manager (brew install node, apt install nodejs npm)
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
# Main Execution
# ============================================================================

if $UPDATE_MODE; then
    draw_header "npm Global Packages" "Updating Node.js global packages"
else
    draw_header "npm Global Packages" "Installing Node.js global packages"
fi
echo

# Validate prerequisites
if ! validate_command npm "npm (Node.js package manager)"; then
    print_error "npm not found - please install Node.js first"
    exit 1
fi

echo

# Check if package list exists (only needed for installation mode)
if ! $UPDATE_MODE && [[ ! -f "$PACKAGE_LIST" ]]; then
    print_error "Package list not found: $PACKAGE_LIST"
    exit 1
fi

if $UPDATE_MODE; then
    # Update mode: update all installed packages
    print_info "Updating all npm global packages..."
    echo

    if npm update -g 2>&1 | grep -E "(added|removed|updated|changed)" | while IFS= read -r line; do echo "  $line"; done; then
        print_success "npm packages updated"
    else
        print_warning "Some packages may have failed to update"
    fi

    echo
    print_success "npm global packages update complete!"
else
    # Install mode: install from package list
    npm_install_from_list "$PACKAGE_LIST"

    echo
    print_success "npm global packages installation complete!"
fi
echo

# Optional: Print installed packages summary
if command_exists npm; then
    print_info "📦 Installed npm global packages:"
    npm list -g --depth=0 2>/dev/null | grep -v "^├──" | grep -v "^└──" | head -20
fi

echo
print_success "$(get_random_friend_greeting)"
