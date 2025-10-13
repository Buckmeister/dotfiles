#!/usr/bin/env zsh

# ============================================================================
# Development Toolchains Installation
# ============================================================================
#
# Installs various development toolchains:
# - Haskell (Stack + GHCup)
# - Rust (rustup)
# - Starship prompt (Linux only)
#
# Uses shared libraries for consistent downloading and OS-aware operations.
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
source "$LIB_DIR/installers.zsh"
source "$LIB_DIR/os_operations.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Haskell Toolchain Installation
# ============================================================================

function install_haskell_stack() {
    draw_section_header "Haskell Stack"

    if command_exists stack; then
        print_success "Haskell Stack already installed"
        return 0
    fi

    print_info "Installing Haskell Stack..."
    if curl -sSL https://get.haskellstack.org/ | sh >/dev/null 2>&1; then
        print_success "Haskell Stack installed successfully"
    else
        print_error "Failed to install Haskell Stack"
        return 1
    fi
}

function install_ghcup() {
    draw_section_header "GHCup (Haskell Toolchain Manager)"

    if command_exists ghcup; then
        print_success "GHCup already installed"
        return 0
    fi

    print_info "Installing GHCup..."

    case "${DF_OS:-$(get_os)}" in
        macos)
            # Install GHCup to /usr/local/share/ghcup for consistency
            local ghcup_dir="/usr/local/share/ghcup"
            local ghcup_binary="$ghcup_dir/ghcup"
            local ghcup_url="https://downloads.haskell.org/~ghcup/x86_64-apple-darwin-ghcup"

            print_info "Creating GHCup directory..."
            if [[ -d "$ghcup_dir" ]]; then
                rm -rf "$ghcup_dir"/*
            fi
            mkdir -p "$ghcup_dir"

            if download_file "$ghcup_url" "$ghcup_binary" "GHCup"; then
                chmod 755 "$ghcup_binary"
                ln -sf "$ghcup_binary" "$INSTALL_BIN_DIR/ghcup"
                print_success "GHCup installed successfully"
            else
                print_error "Failed to install GHCup"
                return 1
            fi
            ;;

        linux)
            print_info "Running GHCup installer..."
            if curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh >/dev/null 2>&1; then
                # Fix permissions on .ghci if it exists
                chmod go-w "$HOME/.ghci" 2>/dev/null || true
                print_success "GHCup installed successfully"
            else
                print_error "Failed to install GHCup"
                return 1
            fi
            ;;

        *)
            print_error "Unsupported OS for GHCup: ${DF_OS:-unknown}"
            return 1
            ;;
    esac
}

# ============================================================================
# Rust Toolchain Installation
# ============================================================================

function install_rust() {
    draw_section_header "Rust Toolchain (rustup)"

    if command_exists rustc; then
        print_success "Rust toolchain already installed"
        local rust_version=$(rustc --version | cut -d' ' -f2)
        print_info "Version: $rust_version"
        return 0
    fi

    print_info "Installing Rust toolchain..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1; then
        print_success "Rust toolchain installed successfully"
        print_info "💡 Restart your shell or run: source $HOME/.cargo/env"
    else
        print_error "Failed to install Rust toolchain"
        return 1
    fi
}

# ============================================================================
# Starship Prompt Installation
# ============================================================================

function install_starship() {
    draw_section_header "Starship Prompt"

    if command_exists starship; then
        print_success "Starship already installed"
        return 0
    fi

    case "${DF_OS:-$(get_os)}" in
        linux)
            print_info "Installing Starship prompt..."
            if sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y >/dev/null 2>&1; then
                print_success "Starship installed successfully"
            else
                print_error "Failed to install Starship"
                return 1
            fi
            ;;

        *)
            print_info "Starship should be installed via package manager on ${DF_OS:-unknown}"
            print_info "macOS: brew install starship"
            ;;
    esac
}

# ============================================================================
# Main Installation
# ============================================================================

draw_header "Development Toolchains" "Installing language toolchains"
echo

# Install Haskell toolchain
install_haskell_stack
echo

install_ghcup
echo

# Install Rust toolchain
install_rust
echo

# Install Starship prompt (Linux only)
install_starship
echo

print_success "Development toolchains installation complete!"
print_info "📦 Installed toolchains:"
command_exists stack && echo "   ✅ Haskell Stack"
command_exists ghcup && echo "   ✅ GHCup"
command_exists rustc && echo "   ✅ Rust"
command_exists starship && echo "   ✅ Starship"

echo
print_success "$(get_random_friend_greeting)"
