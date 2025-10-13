#!/usr/bin/env zsh

# ============================================================================
# Ruby Gems Installation
# ============================================================================
#
# Installs Ruby gems from a centralized package list.
# Uses shared libraries for package management, validation, and UI.
#
# DEPENDENCY: Requires Ruby and gem to be installed.
#             Install via system package manager (brew install ruby, apt install ruby-full)
#
# Package list: config/packages/ruby-gems.list
#
# Note: Some gems may require sudo for system-wide installation.
#       Solargraph (Ruby LSP) is installed via system package manager.
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

PACKAGE_LIST="$CONFIG_DIR/packages/ruby-gems.list"
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
            echo "  --update    Update installed gems instead of installing new ones"
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
    draw_header "Ruby Gems" "Updating Ruby gems"
else
    draw_header "Ruby Gems" "Installing Ruby gems"
fi
echo

# Validate prerequisites
if ! validate_command gem "gem (Ruby package manager)"; then
    print_error "gem not found - please install Ruby first"
    exit 1
fi

# Also check for Ruby itself
if ! validate_command ruby "Ruby"; then
    print_error "Ruby not found"
    exit 1
fi

echo

if $UPDATE_MODE; then
    # ========================================================================
    # Update Mode: Update all installed gems
    # ========================================================================

    print_info "Updating all Ruby gems..."
    echo

    gem update 2>&1 | grep -E "(Updating|Successfully)" | while IFS= read -r line; do
        echo "  $line"
    done

    if [[ $? -eq 0 ]]; then
        print_success "Gems updated"
    else
        print_warning "Some gems may have failed to update"
    fi

    echo
    print_info "Cleaning up old versions..."
    gem cleanup >/dev/null 2>&1
    print_success "Cleanup complete"

    echo
    print_success "Ruby gems update complete!"
else
    # ========================================================================
    # Install Mode: Install gems from list
    # ========================================================================

    # Check if package list exists
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        print_error "Package list not found: $PACKAGE_LIST"
        exit 1
    fi

    # Install gems from list
    # Note: gem_install_from_list will handle individual gem installations
    gem_install_from_list "$PACKAGE_LIST"

    echo
    print_success "Ruby gems installation complete!"
fi
echo

# Print note about Solargraph
print_info "📝 Note: Solargraph (Ruby LSP with linting/formatting) is installed via system package manager"

echo

# Optional: Print installed gems
if command_exists gem; then
    print_info "📦 Installed Ruby gems:"
    gem list --local 2>/dev/null | head -20
fi

echo
print_success "$(get_random_friend_greeting)"
