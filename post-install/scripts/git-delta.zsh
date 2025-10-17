#!/usr/bin/env zsh

# ============================================================================
# Git Delta Installation
# ============================================================================
#
# Installs git-delta (modern syntax highlighting for diffs).
# Delta is a syntax-highlighting pager for git, diff, and grep output.
#
# Dependencies:
#   - git → system package
#
# Uses shared libraries for consistent UI and OS-aware installation.
#
# Repository: https://github.com/dandavison/delta
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

declare_dependency_command "git" "Git version control" ""

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Git Delta" "Installing syntax-highlighting pager"
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show git version
if command_exists git; then
    local git_version=$(git --version | awk '{print $3}')
    print_success "git available (version: $git_version)"
fi

echo

# Check if delta is already installed
if command_exists delta; then
    local delta_version=$(delta --version | head -1)
    print_success "delta already installed: $delta_version"
    echo
    print_info "💡 To reconfigure delta, run: git-delta-config.zsh"
    echo
    print_success "$(get_random_friend_greeting)"
    exit 0
fi

# ============================================================================
# Installation
# ============================================================================

draw_section_header "Installing Delta"

case "$DF_OS" in
    macos)
        print_info "Installing delta via Homebrew..."
        if os_aware_command install git-delta; then
            print_success "Delta installed successfully"
        else
            print_error "Failed to install delta"
            print_info "💡 Manual install: brew install git-delta"
            exit 1
        fi
        ;;

    linux|wsl)
        print_info "Installing delta via package manager..."

        # Detect package manager and install
        case "$DF_PKG_MANAGER" in
            apt)
                # For Ubuntu/Debian, delta is available in newer releases
                # For older releases, we'll download the .deb package
                print_info "Attempting to install from apt repository..."

                if os_aware_command update >/dev/null 2>&1; then
                    if os_aware_command install git-delta 2>/dev/null; then
                        print_success "Delta installed from apt repository"
                    else
                        print_info "Delta not in apt repository, installing from GitHub release..."

                        # Determine architecture
                        local arch=$(uname -m)
                        local delta_arch
                        case "$arch" in
                            x86_64) delta_arch="amd64" ;;
                            aarch64|arm64) delta_arch="arm64" ;;
                            *)
                                print_error "Unsupported architecture: $arch"
                                exit 1
                                ;;
                        esac

                        # Download latest .deb package
                        local tmp_dir=$(mktemp -d)
                        local deb_url="https://github.com/dandavison/delta/releases/latest/download/git-delta_${delta_arch}.deb"

                        print_info "Downloading delta package..."
                        if curl -fsSL -o "$tmp_dir/git-delta.deb" "$deb_url"; then
                            print_success "Downloaded delta package"

                            print_info "Installing delta package..."
                            if os_aware_command install "$tmp_dir/git-delta.deb" >/dev/null 2>&1; then
                                print_success "Delta installed from GitHub release"
                            else
                                print_error "Failed to install delta package"
                                rm -rf "$tmp_dir"
                                exit 1
                            fi
                        else
                            print_error "Failed to download delta package"
                            rm -rf "$tmp_dir"
                            exit 1
                        fi

                        rm -rf "$tmp_dir"
                    fi
                else
                    print_error "Failed to update package manager"
                    exit 1
                fi
                ;;

            dnf|yum)
                print_info "Installing delta via $DF_PKG_MANAGER..."
                if os_aware_command install git-delta; then
                    print_success "Delta installed successfully"
                else
                    print_error "Failed to install delta"
                    print_info "💡 Manual install: $DF_PKG_INSTALL_CMD install git-delta"
                    exit 1
                fi
                ;;

            pacman)
                print_info "Installing delta via pacman..."
                if os_aware_command install git-delta; then
                    print_success "Delta installed successfully"
                else
                    print_error "Failed to install delta"
                    print_info "💡 Manual install: sudo pacman -S git-delta"
                    exit 1
                fi
                ;;

            *)
                print_error "Unsupported package manager: $DF_PKG_MANAGER"
                print_info "💡 See https://github.com/dandavison/delta#installation"
                exit 1
                ;;
        esac
        ;;

    *)
        print_error "Unsupported OS: $DF_OS"
        print_info "💡 See https://github.com/dandavison/delta#installation"
        exit 1
        ;;
esac

echo

# Verify installation
if command_exists delta; then
    local delta_version=$(delta --version | head -1)
    print_success "Delta installed successfully: $delta_version"
else
    print_error "Delta installation failed"
    exit 1
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Installed components:"
echo
echo "   • git-delta (syntax-highlighting pager)"

echo
print_info "💡 Next steps:"
echo "   • Run git-delta-config.zsh to configure Git to use delta"
echo "   • Or manually configure: git config --global core.pager delta"

echo
print_success "$(get_random_friend_greeting)"
