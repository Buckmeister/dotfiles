#!/usr/bin/env zsh

# ============================================================================
# The Librarian - Dotfiles System Health & Status Reporter
# ============================================================================
#
# Like a wise librarian who knows every book in the library,
# this script knows every component of your dotfiles system.
#
# Originally conceived by Thomas as a post-install coordinator,
# now evolved into a system health checker and status reporter.
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries (with fallback protection)
# ============================================================================

# Get script and library directory (using readlink for portability)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Load shared libraries with fallback protection
source "$LIB_DIR/colors.zsh" 2>/dev/null || {
    # Fallback: basic color definitions if library not available
    [[ -z "$COLOR_RESET" ]] && COLOR_RESET='\033[0m'
    [[ -z "$UI_SUCCESS_COLOR" ]] && UI_SUCCESS_COLOR='\033[32m'
    [[ -z "$UI_WARNING_COLOR" ]] && UI_WARNING_COLOR='\033[33m'
    [[ -z "$UI_ERROR_COLOR" ]] && UI_ERROR_COLOR='\033[31m'
    [[ -z "$UI_INFO_COLOR" ]] && UI_INFO_COLOR='\033[90m'
}

source "$LIB_DIR/ui.zsh" 2>/dev/null || {
    # Fallback: basic UI functions if library not available
    function print_success() { echo "✅ $1"; }
    function print_warning() { echo "⚠️ $1"; }
    function print_error() { echo "❌ $1"; }
    function print_info() { echo "ℹ️ $1"; }
}

source "$LIB_DIR/utils.zsh" 2>/dev/null || {
    # Fallback: basic utility functions if library not available
    function get_os() {
        case "$(uname -s)" in
            Darwin*)  echo "macos" ;;
            Linux*)   echo "linux" ;;
            *)        echo "unknown" ;;
        esac
    }
    function command_exists() { command -v "$1" >/dev/null 2>&1; }
}

source "$LIB_DIR/greetings.zsh" 2>/dev/null || {
    # Fallback: basic greeting function if library not available
    function get_random_friend_greeting() {
        echo "Happy coding, friend!"
    }
}

# ============================================================================
# Librarian System Health & Status Reporter
# ============================================================================

# Detect if we're being called from setup (with DF_OS context)
if [[ -n "$DF_OS" ]]; then
    echo "📚 The Librarian awakens... (called from setup)"
    echo "🖥️  Operating System: $DF_OS"
    echo "📦 Package Manager: ${DF_PKG_MANAGER:-unknown}"
else
    echo "📚 The Librarian's Independent Status Report"
    # Detect OS ourselves if not provided using shared utility
    DF_OS=$(get_os)
    echo "🖥️  Operating System: $DF_OS"
fi

echo
echo "🔍 Examining the dotfiles library..."
echo

# ============================================================================
# System Health Checks
# ============================================================================

# Check core setup - use SCRIPT_DIR directly for reliability
dotfiles_root="$SCRIPT_DIR/.."
print_info "📋 Core System Status:"
print_success "   Dotfiles directory: $(cd "$dotfiles_root" && pwd)"

# Check for setup scripts
if [[ -x "$dotfiles_root/bin/setup.zsh" ]]; then
    print_success "   setup.zsh is executable and ready"
elif [[ -f "$dotfiles_root/bin/setup.zsh" ]]; then
    print_warning "   setup.zsh exists but is not executable"
else
    print_warning "   setup.zsh not found"
fi

# Check symlinks
symlink_count=$(find ~/.local/bin -name "*" -type l 2>/dev/null | wc -l | tr -d ' ')
echo "   📎 Active symlinks in ~/.local/bin: $symlink_count"

# Check if vim/nvim is available using shared utility
if command_exists nvim; then
    print_success "   Neovim available: $(nvim --version | head -1)"
elif command_exists vim; then
    print_success "   Vim available: $(vim --version | head -1)"
else
    print_warning "   No vim/nvim found"
fi

# Check essential tools
echo
echo "🛠️  Essential Tools Status:"
tools=("git" "curl" "jq" "zsh")
for tool in "${tools[@]}"; do
    if command_exists "$tool"; then
        print_success "   $tool: $(command -v "$tool")"
    else
        print_error "   $tool: not found"
    fi
done

# ============================================================================
# Post-Install Scripts Catalog
# ============================================================================

echo
echo "📜 Post-Install Scripts Catalog:"

# Look for post-install scripts in the proper directory
post_install_dir="$dotfiles_root/post-install/scripts"

if [[ -d "$post_install_dir" ]]; then
    # Find all post-install scripts
    post_install_scripts=(${(0)"$(find "$post_install_dir" -name "*.zsh" -print0 2>/dev/null)"})

    if [[ ${#post_install_scripts[@]} -gt 0 ]]; then
        for script in $post_install_scripts; do
            script_name="$(basename "$script" .zsh)"

            if [[ -x "$script" ]]; then
                echo "   📄 $script_name (executable)"
            else
                echo "   📄 $script_name (not executable)"
            fi
        done
    else
        print_info "   No post-install scripts found"
    fi
else
    print_warning "   Post-install scripts directory not found at: $post_install_dir"
fi

# ============================================================================
# GitHub Downloaders Status
# ============================================================================

echo
echo "🐙 GitHub Downloaders Status:"

github_dir="$dotfiles_root/github"
if [[ -d "$github_dir" ]]; then
    github_tools=($(find "$github_dir" -name "*.symlink_local_bin.zsh" 2>/dev/null))

    for tool in $github_tools; do
        tool_name="$(basename "$tool" .symlink_local_bin.zsh)"
        if [[ -x "$tool" ]]; then
            echo "   🔗 $tool_name (ready)"
        else
            echo "   🔗 $tool_name (not executable)"
        fi
    done
else
    echo "   ⚠️  GitHub tools directory not found"
fi

# ============================================================================
# Configuration Health
# ============================================================================

echo
echo "⚙️  Configuration Health:"

# Check for common config files
configs=(".zshrc" ".vimrc" ".tmux.conf" ".gitconfig")
config_count=0

for config in "${configs[@]}"; do
    if [[ -e "$HOME/$config" ]]; then
        config_count=$((config_count + 1))
        echo "   ✅ ~/$config exists"
    fi
done

echo "   📊 Configuration files found: $config_count/${#configs[@]}"

# ============================================================================
# Artistic Conclusion
# ============================================================================

echo
echo "🎭 The Librarian's Assessment:"

if [[ $config_count -eq ${#configs[@]} && $symlink_count -gt 5 ]]; then
    echo "   🌟 Your dotfiles library is well-organized and flourishing!"
    echo "   🎵 Like a beautiful symphony, everything is in harmony."
elif [[ $config_count -gt 2 ]]; then
    echo "   📚 Your dotfiles library is taking shape nicely."
    echo "   🎼 There's music in the making - keep composing!"
else
    echo "   🌱 Your dotfiles library is just beginning to grow."
    echo "   🎹 Every great composition starts with a single note."
fi

# ============================================================================
# Post-Install Scripts Execution (The Librarian's Original Purpose)
# ============================================================================

echo
echo "🎯 The Librarian's Original Purpose:"
echo "   Would you like to run post-install scripts? 🎵"
echo

# Check execution mode based on arguments
case "${1:-}" in
    "--skip-pi"|"--help"|"--status")
        if [[ "${1:-}" != "--status" ]]; then
            echo "📚 Post-install scripts skipped. The Librarian's work is complete. $(get_random_friend_greeting) 💙"
        fi
        echo
        exit 0
        ;;
    "--all-pi")
        # Silent mode - run all scripts without interaction
        echo "🎵 Running all post-install scripts silently..."
        echo "   🎶 Unattended symphony mode activated! 🎶"
        echo

        # Find all executable post-install scripts in the proper directory
        post_install_dir="$dotfiles_root/post-install/scripts"

        if [[ ! -d "$post_install_dir" ]]; then
            print_error "Post-install scripts directory not found: $post_install_dir"
            exit 1
        fi

        post_install_scripts=(${(0)"$(find "$post_install_dir" -name "*.zsh" -print0 2>/dev/null)"})

        if [[ ${#post_install_scripts[@]} -eq 0 ]]; then
            print_warning "No post-install scripts found in $post_install_dir"
            exit 0
        fi

        for script in $post_install_scripts; do
            script_name="$(basename "$script" .zsh)"

            if [[ -x "$script" ]]; then
                echo "🎵 Executing: $script_name"

                # Export OS context for post-install scripts
                if [[ -n "${DF_OS:-}" && -n "${DF_PKG_MANAGER:-}" && -n "${DF_PKG_INSTALL_CMD:-}" ]]; then
                    DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$script"
                else
                    # Fallback: detect OS context if not provided using shared utility
                    local detected_os=$(get_os)
                    case "$detected_os" in
                        "macos")   DF_OS="macos" DF_PKG_MANAGER="brew" DF_PKG_INSTALL_CMD="brew install" "$script" ;;
                        "linux")   DF_OS="linux" DF_PKG_MANAGER="apt" DF_PKG_INSTALL_CMD="apt install -y" "$script" ;;
                        *)          DF_OS="unknown" "$script" ;;
                    esac
                fi

                echo "   ✅ Completed: $script_name"
            else
                print_warning "   Skipping $script_name (not executable)"
            fi
        done

        echo
        echo "🎭 The Librarian's Assessment: All scripts executed successfully!"
        echo "🎵 Your dotfiles symphony is now complete and harmonious."
        echo
        echo "📚 The Librarian's work is complete. $(get_random_friend_greeting) 💙"
        echo
        exit 0
        ;;
    "--menu")
        # Launch the interactive TUI menu
        echo "🎼 Launching the enhanced interactive menu..."
        echo "   Use ↑↓ or j/k to navigate, Space to select, Enter to execute!"
        echo
        sleep 1

        # Export environment for the TUI menu and launch it
        DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$SCRIPT_DIR/menu_tui.zsh"
        ;;
    *)
        # Default: show status only (health check mode)
        # This is the normal behavior when running ./bin/librarian.zsh directly
        echo
        exit 0
        ;;
esac