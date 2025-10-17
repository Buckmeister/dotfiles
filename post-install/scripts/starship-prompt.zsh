#!/usr/bin/env zsh

# ============================================================================
# Starship Prompt Installation
# ============================================================================
#
# Installs Starship - a fast, customizable shell prompt
#
# Note: This is a SHELL PROMPT utility, not a language toolchain.
#       It was separated from toolchains.zsh for better organization.
#
# Platform Support:
# - macOS: Install via Homebrew (brew install starship)
# - Linux: Install via official install script
#
# Dependencies: NONE
#   This is a standalone utility installation.
#
# Required by: NONE
#   Starship is a shell prompt enhancement, not a build dependency.
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
# Starship Prompt Installation
# ============================================================================

function install_starship() {
    draw_section_header "Starship Prompt"

    if command_exists starship; then
        print_success "Starship already installed"
        local starship_version=$(starship --version 2>/dev/null | cut -d' ' -f2)
        print_info "Version: $starship_version"
        return 0
    fi

    case "${DF_OS:-$(get_os)}" in
        linux)
            print_info "Installing Starship prompt..."
            print_info "Running official install script..."
            echo

            if sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y >/dev/null 2>&1; then
                print_success "Starship installed successfully"

                # Show installed version
                if command_exists starship; then
                    local starship_version=$(starship --version 2>/dev/null | cut -d' ' -f2)
                    print_info "Installed version: $starship_version"
                fi
            else
                print_error "Failed to install Starship"
                return 1
            fi
            ;;

        macos)
            print_info "Starship should be installed via Homebrew on macOS"
            echo
            print_info "Installation command:"
            echo "   ${COLOR_BOLD}brew install starship${COLOR_RESET}"
            echo
            print_info "💡 Tip: Use the package manifest system:"
            echo "   Run ${COLOR_BOLD}install_from_manifest${COLOR_RESET} to install all tools"
            ;;

        *)
            print_error "Starship installation not configured for: ${DF_OS:-unknown}"
            print_info "Visit https://starship.rs/guide/ for manual installation"
            return 1
            ;;
    esac
}

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Starship Prompt" "Installing cross-shell prompt"
echo

# Install Starship
install_starship

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

if command_exists starship; then
    print_success "✨ Starship prompt installed successfully"
    echo
    print_info "💡 Configuration:"
    echo "   Config file: ~/.config/starship.toml"
    echo "   Documentation: https://starship.rs/config/"
    echo
    print_info "💡 Shell Integration:"
    echo "   ${COLOR_BOLD}Bash:${COLOR_RESET} Add to ~/.bashrc:"
    echo "   eval \"\$(starship init bash)\""
    echo
    echo "   ${COLOR_BOLD}Zsh:${COLOR_RESET} Add to ~/.zshrc:"
    echo "   eval \"\$(starship init zsh)\""
    echo
    echo "   ${COLOR_BOLD}Fish:${COLOR_RESET} Add to ~/.config/fish/config.fish:"
    echo "   starship init fish | source"
    echo
    print_info "💡 Note: This dotfiles repository includes a starship.toml config"
    echo "   Location: user/configs/prompts/starship/"
else
    print_info "Starship not installed"
    [[ "${DF_OS:-$(get_os)}" == "macos" ]] && print_info "Run: brew install starship"
fi

echo
print_success "$(get_random_friend_greeting)"
