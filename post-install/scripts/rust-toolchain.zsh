#!/usr/bin/env zsh

# ============================================================================
# Rust Toolchain Installation
# ============================================================================
#
# Installs Rust development toolchain:
# - rustup (Rust toolchain installer and version manager)
# - rustc (Rust compiler)
# - cargo (Rust package manager and build tool)
#
# Dependencies: NONE
#   This is a base toolchain provider script.
#
# Required by:
#   - cargo-packages.zsh (Rust package installation)
#
# Uses shared libraries for consistent downloading and OS-aware operations.
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
CONFIG_DIR="$DOTFILES_ROOT/env"

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
# Rust Toolchain Installation
# ============================================================================

function install_rust() {
    draw_section_header "Rust Toolchain (rustup)"

    if command_exists rustc; then
        print_success "Rust toolchain already installed"
        local rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
        local cargo_version=$(cargo --version 2>/dev/null | cut -d' ' -f2)
        print_info "Rust version: $rust_version"
        print_info "Cargo version: $cargo_version"

        # Check for rustup
        if command_exists rustup; then
            local rustup_version=$(rustup --version 2>/dev/null | head -1)
            print_info "Rustup version: $rustup_version"
        fi

        return 0
    fi

    print_info "Installing Rust toolchain via rustup..."
    print_info "This will install: rustup, rustc, and cargo"
    echo

    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1; then
        print_success "Rust toolchain installed successfully"

        # Show installed versions
        if [[ -f "$HOME/.cargo/env" ]]; then
            source "$HOME/.cargo/env"
            local rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
            local cargo_version=$(cargo --version 2>/dev/null | cut -d' ' -f2)
            print_info "Installed Rust version: $rust_version"
            print_info "Installed Cargo version: $cargo_version"
        fi
    else
        print_error "Failed to install Rust toolchain"
        return 1
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Rust Toolchain" "Installing Rust development tools"
echo

# Install Rust toolchain
install_rust

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Installed Rust toolchain components:"
echo
command_exists rustup && echo "   • rustup (Rust toolchain installer & version manager)"
command_exists rustc && echo "   • rustc (Rust compiler)"
command_exists cargo && echo "   • cargo (Rust package manager & build tool)"

echo
print_info "💡 Important: Restart your shell or run:"
echo "   ${COLOR_BOLD}source \$HOME/.cargo/env${COLOR_RESET}"
echo
print_info "💡 Next steps:"
echo "   - Update Rust: 'rustup update'"
echo "   - Install nightly: 'rustup install nightly'"
echo "   - Add components: 'rustup component add rust-analyzer'"
echo
print_info "💡 Note: cargo-packages.zsh depends on this script"
echo "   Run it next to install Rust packages and tools"

echo
print_success "$(get_random_friend_greeting)"
