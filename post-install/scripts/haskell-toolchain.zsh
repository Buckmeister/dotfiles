#!/usr/bin/env zsh

# ============================================================================
# Haskell Toolchain Installation
# ============================================================================
#
# Installs Haskell development toolchain:
# - Haskell Stack (build tool and package manager)
# - GHCup (Haskell toolchain manager for GHC, cabal, HLS)
#
# Dependencies: NONE
#   This is a base toolchain provider script.
#
# Required by:
#   - ghcup-packages.zsh (Haskell package installation)
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
# Haskell Stack Installation
# ============================================================================

function install_haskell_stack() {
    draw_section_header "Haskell Stack"

    if command_exists stack; then
        print_success "Haskell Stack already installed"
        local stack_version=$(stack --version 2>/dev/null | head -1)
        print_info "Version: $stack_version"
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

# ============================================================================
# GHCup Installation
# ============================================================================

function install_ghcup() {
    draw_section_header "GHCup (Haskell Toolchain Manager)"

    if command_exists ghcup; then
        print_success "GHCup already installed"
        local ghcup_version=$(ghcup --version 2>/dev/null | head -1)
        print_info "Version: $ghcup_version"
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

        linux|wsl)
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
# Main Execution
# ============================================================================

draw_header "Haskell Toolchain" "Installing Haskell development tools"
echo

# Install Haskell Stack
install_haskell_stack
echo

# Install GHCup
install_ghcup

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Installed Haskell toolchain components:"
echo
command_exists stack && echo "   • Haskell Stack (build tool & package manager)"
command_exists ghcup && echo "   • GHCup (toolchain manager for GHC, cabal, HLS)"

echo
print_info "💡 Next steps:"
echo "   - Run 'ghcup tui' for interactive toolchain management"
echo "   - Install GHC: 'ghcup install ghc'"
echo "   - Install Cabal: 'ghcup install cabal'"
echo "   - Install HLS: 'ghcup install hls'"
echo
print_info "💡 Note: ghcup-packages.zsh depends on this script"
echo "   Run it next to install Haskell packages and tools"

echo
print_success "$(get_random_friend_greeting)"
