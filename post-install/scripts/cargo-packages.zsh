#!/usr/bin/env zsh

# ============================================================================
# Cargo (Rust) Packages Installation
# ============================================================================
#
# Installs Rust packages from a centralized list using cargo.
# Uses shared libraries for package management, validation, and UI.
#
# DEPENDENCY: Requires Rust toolchain (cargo/rustup) to be installed.
#             Run toolchains.zsh first if Rust is not installed.
#
# Package list: config/packages/cargo-packages.list
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

PACKAGE_LIST="$CONFIG_DIR/packages/cargo-packages.list"
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
    draw_header "Cargo Packages" "Updating Rust packages"
else
    draw_header "Cargo Packages" "Installing Rust packages"
fi
echo

# Validate prerequisites
if ! validate_command cargo "cargo (Rust package manager)"; then
    print_error "Rust toolchain not found"
    print_info "Please install Rust first by running: ./post-install/scripts/toolchains.zsh"
    print_info "Or visit: https://rustup.rs/"
    exit 1
fi

# Show current Rust version
if command_exists rustc; then
    local rust_version=$(rustc --version | cut -d' ' -f2)
    print_success "Rust toolchain available (version: $rust_version)"
fi

echo

if $UPDATE_MODE; then
    # ========================================================================
    # Update Mode: Update all installed cargo packages
    # ========================================================================

    print_info "Checking for cargo-update tool..."

    if ! command_exists cargo-install-update-config; then
        print_info "Installing cargo-update for package management..."
        if cargo install cargo-update >/dev/null 2>&1; then
            print_success "cargo-update installed"
        else
            print_error "Failed to install cargo-update"
            print_info "💡 Manual update: cargo install <package> --force"
            exit 1
        fi
    else
        print_success "cargo-update already available"
    fi

    echo
    print_info "Updating all cargo packages..."
    echo

    cargo install-update -a 2>&1 | while IFS= read -r line; do
        [[ -n "$line" ]] && echo "  $line"
    done

    if [[ $? -eq 0 ]]; then
        print_success "Cargo packages updated"
    else
        print_warning "Some packages may have failed to update"
    fi

    echo
    print_success "Cargo packages update complete!"
else
    # ========================================================================
    # Install Mode: Install packages from list
    # ========================================================================

    # Check if package list exists
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        print_error "Package list not found: $PACKAGE_LIST"
        exit 1
    fi

    # Install packages from list
    cargo_install_from_list "$PACKAGE_LIST"

    echo
    print_success "Cargo packages installation complete!"
fi
echo

# Optional: Print installed cargo packages
if command_exists cargo; then
    print_info "📦 Installed cargo binaries:"
    ls -1 "$HOME/.cargo/bin" 2>/dev/null | head -20
fi

echo
print_success "$(get_random_friend_greeting)"
