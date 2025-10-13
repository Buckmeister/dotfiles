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
# Pager Selection (bat with fallback to less/cat)
# ============================================================================

function select_pager() {
    # Check if stdout is a terminal
    if [[ ! -t 1 ]]; then
        echo "cat"
        return
    fi

    # Skip bat for now, use less or cat
    if command_exists less; then
        echo "less -R"
    else
        echo "cat"
    fi
}

function use_pager() {
    # When called in a pipeline, we need to ensure less has access to the terminal
    # Check if we're actually in an interactive terminal (check stderr)
    if [[ -t 2 ]] && command_exists less; then
        # Read from stdin (the piped content), write to /dev/tty (the terminal)
        less -R > /dev/tty
    else
        cat
    fi
}

# ============================================================================
# Librarian System Health & Status Reporter
# ============================================================================

# Function to generate the full report (so we can pipe it through a pager)
function generate_report() {

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
dotfiles_root="$(cd "$SCRIPT_DIR/.." && pwd)"
print_info "📋 Core System Status:"
print_success "   Dotfiles directory: $dotfiles_root"

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

# Check git status of dotfiles repo
if [[ -d "$dotfiles_root/.git" ]]; then
    cd "$dotfiles_root"
    git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    # Count uncommitted changes (modified, staged, deleted files)
    git_changes=$(git status --porcelain 2>/dev/null | grep -v '^??' | wc -l | tr -d ' ')

    # Count untracked files
    git_untracked=$(git status --porcelain 2>/dev/null | grep '^??' | wc -l | tr -d ' ')

    if [[ $git_changes -eq 0 && $git_untracked -eq 0 ]]; then
        print_success "   Git repository: clean (branch: $git_branch)"
    else
        # Build status message based on what we found
        local status_parts=()
        [[ $git_changes -gt 0 ]] && status_parts+=("$git_changes uncommitted change(s)")
        [[ $git_untracked -gt 0 ]] && status_parts+=("$git_untracked untracked file(s)")

        local status_msg="${(j:, :)status_parts}"
        print_warning "   Git repository: $status_msg (branch: $git_branch)"
    fi
fi

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
# Development Toolchains Status
# ============================================================================

echo
echo "🔧 Development Toolchains:"

# Rust
if command_exists rustc; then
    rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
    print_success "   Rust: $rust_version"
    if command_exists cargo; then
        cargo_version=$(cargo --version 2>/dev/null | cut -d' ' -f2)
        echo "      └─ cargo: $cargo_version"
    fi
    if command_exists rustup; then
        echo "      └─ rustup: available"
    fi
else
    print_info "   Rust: not installed"
fi

# Node.js
if command_exists node; then
    node_version=$(node --version 2>/dev/null)
    print_success "   Node.js: $node_version"
    if command_exists npm; then
        npm_version=$(npm --version 2>/dev/null)
        echo "      └─ npm: $npm_version"
    fi
    if command_exists nvm; then
        echo "      └─ nvm: available"
    fi
else
    print_info "   Node.js: not installed"
fi

# Python
if command_exists python3; then
    python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
    print_success "   Python: $python_version"
    if command_exists pip3; then
        pip_version=$(pip3 --version 2>/dev/null | cut -d' ' -f2)
        echo "      └─ pip: $pip_version"
    fi
    if command_exists pipx; then
        pipx_version=$(pipx --version 2>/dev/null)
        echo "      └─ pipx: $pipx_version"
    fi
else
    print_info "   Python: not installed"
fi

# Ruby
if command_exists ruby; then
    ruby_version=$(ruby --version 2>/dev/null | cut -d' ' -f2)
    print_success "   Ruby: $ruby_version"
    if command_exists gem; then
        gem_version=$(gem --version 2>/dev/null)
        echo "      └─ gem: $gem_version"
    fi
else
    print_info "   Ruby: not installed"
fi

# Go
if command_exists go; then
    go_version=$(go version 2>/dev/null | cut -d' ' -f3 | sed 's/go//')
    print_success "   Go: $go_version"
else
    print_info "   Go: not installed"
fi

# Haskell
if command_exists ghc; then
    ghc_version=$(ghc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    print_success "   Haskell (GHC): $ghc_version"
    if command_exists ghcup; then
        echo "      └─ ghcup: available"
    fi
    if command_exists stack; then
        stack_version=$(stack --version 2>/dev/null | head -1 | cut -d' ' -f2)
        echo "      └─ stack: $stack_version"
    fi
else
    print_info "   Haskell: not installed"
fi

# Java
if command_exists java; then
    java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    print_success "   Java: $java_version"
    if command_exists mvn; then
        mvn_version=$(mvn --version 2>/dev/null | head -1 | cut -d' ' -f3)
        echo "      └─ Maven: $mvn_version"
    fi
else
    print_info "   Java: not installed"
fi

# ============================================================================
# Language Servers Status
# ============================================================================

echo
echo "🔌 Language Servers:"

# Check for common language servers
lsp_servers=(
    "rust-analyzer:Rust"
    "typescript-language-server:TypeScript"
    "pyright:Python"
    "lua-language-server:Lua"
    "gopls:Go"
    "haskell-language-server-wrapper:Haskell"
    "solargraph:Ruby"
)

lsp_found=0
for lsp_entry in "${lsp_servers[@]}"; do
    lsp_cmd="${lsp_entry%%:*}"
    lsp_lang="${lsp_entry##*:}"
    if command_exists "$lsp_cmd"; then
        print_success "   $lsp_lang LSP ($lsp_cmd): installed"
        lsp_found=$((lsp_found + 1))
    fi
done

if [[ $lsp_found -eq 0 ]]; then
    print_info "   No language servers detected"
    echo "      💡 Install with: ./post-install/scripts/language-servers.zsh"
else
    echo "   📊 Language servers found: $lsp_found/${#lsp_servers[@]}"
fi

# ============================================================================
# Test Suite Status
# ============================================================================

echo
echo "🧪 Test Suite:"

test_runner="$dotfiles_root/tests/run_tests.zsh"
if [[ -x "$test_runner" ]]; then
    print_success "   Test runner available"

    # Count test files
    unit_test_count=$(find "$dotfiles_root/tests/unit" -name "test_*.zsh" -type f 2>/dev/null | wc -l | tr -d ' ')
    integration_test_count=$(find "$dotfiles_root/tests/integration" -name "test_*.zsh" -type f 2>/dev/null | wc -l | tr -d ' ')
    total_tests=$((unit_test_count + integration_test_count))

    echo "      ├─ Unit tests: $unit_test_count"
    echo "      ├─ Integration tests: $integration_test_count"
    echo "      └─ Total test suites: $total_tests"

    # Check if we should run tests
    if [[ "$1" == "--with-tests" ]] || [[ "$1" == "--run-tests" ]]; then
        echo
        echo "   🔬 Running test suite..."
        echo
        "$test_runner"
        local test_exit_code=$?
        echo
        if [[ $test_exit_code -eq 0 ]]; then
            print_success "   Test suite completed successfully!"
        else
            print_error "   Some tests failed. See output above for details."
        fi
    else
        echo "      💡 Run with --with-tests to execute the test suite"
        echo "      💡 Or run directly: ./tests/run_tests.zsh"
    fi
elif [[ -f "$test_runner" ]]; then
    print_warning "   Test runner exists but is not executable"
    echo "      💡 Fix with: chmod +x $test_runner"
else
    print_info "   Test suite not found"
    echo "      💡 Test infrastructure may not be installed yet"
fi

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
# Detailed Symlink Inventory
# ============================================================================

echo
echo "🔗 Detailed Symlink Inventory:"
echo

# Local bin symlinks
print_info "📂 ~/.local/bin/ symlinks:"
if [[ -d ~/.local/bin ]]; then
    local_bin_links=($(find ~/.local/bin -type l 2>/dev/null | sort))
    if [[ ${#local_bin_links[@]} -gt 0 ]]; then
        for link in $local_bin_links; do
            link_name=$(basename "$link")
            link_target=$(readlink "$link")
            if [[ -e "$link" ]]; then
                echo "   ✅ $link_name → $link_target"
            else
                echo "   ❌ $link_name → $link_target (broken)"
            fi
        done
    else
        print_info "   No symlinks found"
    fi
else
    print_warning "   ~/.local/bin not found"
fi

echo

# Config directory symlinks
print_info "📂 ~/.config/ symlinks:"
if [[ -d ~/.config ]]; then
    config_links=($(find ~/.config -maxdepth 1 -type l 2>/dev/null | sort))
    if [[ ${#config_links[@]} -gt 0 ]]; then
        for link in $config_links; do
            link_name=$(basename "$link")
            link_target=$(readlink "$link")
            if [[ -e "$link" ]]; then
                echo "   ✅ $link_name → $link_target"
            else
                echo "   ❌ $link_name → $link_target (broken)"
            fi
        done
    else
        print_info "   No symlinks found"
    fi
else
    print_warning "   ~/.config not found"
fi

echo

# Home directory dotfiles
print_info "📂 ~/ dotfile symlinks:"
home_dotfiles=($(find ~ -maxdepth 1 -name ".*" -type l 2>/dev/null | sort))
if [[ ${#home_dotfiles[@]} -gt 0 ]]; then
    for link in $home_dotfiles; do
        link_name=$(basename "$link")
        link_target=$(readlink "$link")
        if [[ -e "$link" ]]; then
            echo "   ✅ $link_name → $link_target"
        else
            echo "   ❌ $link_name → $link_target (broken)"
        fi
    done
else
    print_info "   No dotfile symlinks found in ~/"
fi

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

} # End of generate_report function

# ============================================================================
# Help Function
# ============================================================================

function show_help() {
    cat << EOF
${COLOR_BOLD}📚 The Librarian - Dotfiles System Health & Status Reporter${COLOR_RESET}

${UI_ACCENT_COLOR}DESCRIPTION:${COLOR_RESET}
    Like a wise librarian who knows every book in the library, this script
    knows every component of your dotfiles system and provides comprehensive
    health reporting and diagnostics.

${UI_ACCENT_COLOR}USAGE:${COLOR_RESET}
    $0 [OPTIONS]

${UI_ACCENT_COLOR}OPTIONS:${COLOR_RESET}
    (no options)        Show comprehensive system health report
    --status            Same as no options (explicit status check)
    --with-tests        Run system health check with test suite execution
    --run-tests         Alias for --with-tests
    --all-pi            Run all post-install scripts silently
    --menu              Launch interactive TUI menu
    --skip-pi           Skip post-install scripts (used by setup)
    --help, -h          Show this help message

${UI_ACCENT_COLOR}HEALTH REPORT INCLUDES:${COLOR_RESET}
    📋 Core System Status     - Dotfiles location, setup scripts, git status
    🛠️  Essential Tools       - git, curl, jq, zsh detection
    🔧 Development Toolchains - Rust, Node.js, Python, Ruby, Go, Haskell, Java
    🔌 Language Servers       - LSP server detection and status
    🧪 Test Suite             - Test availability and optional execution
    📜 Post-Install Scripts   - Available scripts catalog
    🐙 GitHub Downloaders     - Custom GitHub tool status
    ⚙️  Configuration Health  - Config file existence checks
    🔗 Symlink Inventory      - Complete symlink listing with broken link detection

${UI_ACCENT_COLOR}EXAMPLES:${COLOR_RESET}
    $0                  # Full system health report
    $0 --with-tests     # Health report + run test suite
    $0 --all-pi         # Run all post-install scripts
    $0 --menu           # Launch interactive menu

${UI_ACCENT_COLOR}INTEGRATION:${COLOR_RESET}
    The Librarian is typically called by ./setup after symlinking completes,
    but can also be run independently for system diagnostics and health checks.

EOF
}

# ============================================================================
# Main Execution Logic
# ============================================================================

# Check execution mode based on arguments
case "${1:-}" in
    "--help"|"-h")
        # Show help message
        show_help
        exit 0
        ;;
    "--status")
        # Explicit status check - show verbose report through pager
        generate_report | use_pager
        exit 0
        ;;
    "--with-tests"|"--run-tests")
        # Status check with test suite execution
        generate_report "$1" | use_pager
        exit 0
        ;;
    "--skip-pi")
        # Show friendly exit message for this flag
        echo "📚 Post-install scripts skipped. The Librarian's work is complete. $(get_random_friend_greeting) 💙"
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
        # Default: show verbose status through pager (health check mode)
        # This is the normal behavior when running ./bin/librarian.zsh directly
        generate_report | use_pager
        exit 0
        ;;
esac