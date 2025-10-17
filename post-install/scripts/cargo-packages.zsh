#!/usr/bin/env zsh

# ============================================================================
# Cargo (Rust) Packages Installation
# ============================================================================
#
# Installs Rust packages from a centralized list using cargo.
# Uses shared libraries for package management, validation, and UI.
#
# Dependencies:
#   - cargo (Rust package manager) → provided by rust-toolchain.zsh
#   - rustc (Rust compiler) → provided by rust-toolchain.zsh
#
# Package list: env/packages/cargo-packages.list
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
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"
source "$LIB_DIR/arguments.zsh"

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
# Help Function
# ============================================================================

function show_help() {
    standard_help_header "cargo-packages.zsh" \
        "Installs Rust packages from centralized list using cargo"
    echo "  --update        Update installed packages instead of installing new ones"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "${COLOR_BOLD}EXAMPLES:${COLOR_RESET}"
    echo "  # Install packages from list"
    echo "  ./cargo-packages.zsh"
    echo ""
    echo "  # Update all installed cargo packages"
    echo "  ./cargo-packages.zsh --update"
    exit 0
}

# ============================================================================
# Argument Parsing
# ============================================================================

# Parse arguments using shared library
parse_simple_flags "$@"
is_help_requested && show_help

# Set modes based on parsed flags
[[ "$ARG_UPDATE" == "true" ]] && UPDATE_MODE=true

# Validate no unknown arguments remain
validate_no_unknown_args "$@" || exit 1

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "cargo" "Rust package manager" "rust-toolchain.zsh"
declare_dependency_command "rustc" "Rust compiler" "rust-toolchain.zsh"

# ============================================================================
# Main Execution
# ============================================================================

if $UPDATE_MODE; then
    draw_header "Cargo Packages" "Updating Rust packages"
else
    draw_header "Cargo Packages" "Installing Rust packages"
fi
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

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

    draw_section_header "Preparing Package Updater"

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

    draw_section_header "Updating Installed Packages"

    cargo install-update -a 2>&1 | while IFS= read -r line; do
        [[ -n "$line" ]] && echo "  $line"
    done

    if [[ $? -eq 0 ]]; then
        echo
        print_success "Cargo packages updated successfully"
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
    cargo_install_from_list "$PACKAGE_LIST"

    echo
    print_success "Cargo packages installation complete!"
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

# Show installed cargo packages
if command_exists cargo; then
    print_info "📦 Installed cargo binaries:"
    echo
    ls -1 "$HOME/.cargo/bin" 2>/dev/null | head -20 | while read -r binary; do
        echo "   • $binary"
    done
fi

echo
print_success "$(get_random_friend_greeting)"
