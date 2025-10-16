#!/usr/bin/env zsh

# ============================================================================
# Central Update Script - Update All System Components
# ============================================================================
#
# This script provides a single entry point for updating all development
# tools, packages, and configurations. It respects version pins from
# env/versions.env and provides detailed control over what gets updated.
#
# Usage:
#   ./bin/update_all.zsh                    # Update everything
#   ./bin/update_all.zsh --system           # Update only system packages
#   ./bin/update_all.zsh --toolchains       # Update only development toolchains
#   ./bin/update_all.zsh --packages         # Update only language packages
#   ./bin/update_all.zsh --npm              # Update only npm packages
#   ./bin/update_all.zsh --cargo            # Update only cargo packages
#   ./bin/update_all.zsh --gem              # Update only ruby gems
#   ./bin/update_all.zsh --pipx             # Update only pipx packages
#   ./bin/update_all.zsh --language-servers # Update only language servers
#   ./bin/update_all.zsh --dry-run          # Preview what would be updated
#
# Version Pinning:
#   - Reads env/versions.env for pinned versions
#   - Empty values = "use latest" (will update)
#   - Specific values = pinned (will skip update with message)
#
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
source "$SCRIPT_DIR/../bin/lib/utils.zsh" 2>/dev/null || source "$SCRIPT_DIR/lib/utils.zsh" 2>/dev/null || {
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
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"
source "$LIB_DIR/arguments.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# OS Detection and Context Setup
# ============================================================================

# Detect OS and package manager using shared utility function
detect_package_manager

# ============================================================================
# Configuration
# ============================================================================

DRY_RUN=false
UPDATE_ALL=true
UPDATE_SYSTEM=false
UPDATE_TOOLCHAINS=false
UPDATE_PACKAGES=false
UPDATE_NPM=false
UPDATE_CARGO=false
UPDATE_GEM=false
UPDATE_PIPX=false
UPDATE_LANGUAGE_SERVERS=false

# ============================================================================
# Parse Command Line Arguments
# ============================================================================

function parse_args() {
    # Handle no arguments case
    if [[ $# -eq 0 ]]; then
        UPDATE_ALL=true
        return 0
    fi

    # Parse common flags using shared library
    parse_simple_flags "$@"
    is_help_requested && { show_help; exit 0; }

    # Set dry-run mode from library variable
    [[ "$ARG_DRY_RUN" == "true" ]] && DRY_RUN=true

    # Parse script-specific flags
    UPDATE_ALL=false
    local -a remaining_args=()

    for arg in "$@"; do
        case "$arg" in
            --system)
                UPDATE_SYSTEM=true
                ;;
            --toolchains)
                UPDATE_TOOLCHAINS=true
                ;;
            --packages)
                UPDATE_PACKAGES=true
                UPDATE_NPM=true
                UPDATE_CARGO=true
                UPDATE_GEM=true
                UPDATE_PIPX=true
                ;;
            --npm)
                UPDATE_NPM=true
                ;;
            --cargo)
                UPDATE_CARGO=true
                ;;
            --gem)
                UPDATE_GEM=true
                ;;
            --pipx)
                UPDATE_PIPX=true
                ;;
            --language-servers)
                UPDATE_LANGUAGE_SERVERS=true
                ;;
            # Skip flags already handled by library
            --dry-run|-n|--help|-h)
                ;;
            *)
                remaining_args+=("$arg")
                ;;
        esac
    done

    # Validate no unknown arguments remain
    if [[ ${#remaining_args[@]} -gt 0 ]]; then
        print_error "Unknown option: ${remaining_args[1]}"
        show_help
        exit 1
    fi
}

function show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Update all development tools, packages, and configurations.

OPTIONS:
    (no options)            Update everything
    --system                Update system packages (brew/apt/etc)
    --toolchains            Update development toolchains (rust, haskell, etc)
    --packages              Update all language packages (npm, cargo, gem, pipx)
    --npm                   Update npm global packages only
    --cargo                 Update cargo packages only
    --gem                   Update ruby gems only
    --pipx                  Update pipx packages only
    --language-servers      Update language servers only
    --dry-run               Preview what would be updated without making changes
    --help, -h              Show this help message

EXAMPLES:
    # Update everything
    ./bin/update_all.zsh

    # Update only npm packages
    ./bin/update_all.zsh --npm

    # Update system and toolchains
    ./bin/update_all.zsh --system --toolchains

    # Preview updates without applying them
    ./bin/update_all.zsh --dry-run

VERSION PINNING:
    Version pins are read from env/versions.env:
    - Empty values ("") = use latest (will update)
    - Specific values = pinned (will skip with message)

EOF
}

# ============================================================================
# Update Functions
# ============================================================================

function update_system_packages() {
    echo
    draw_separator
    print_info "📦 System Package Updates"
    draw_separator
    echo

    if $DRY_RUN; then
        print_info "[DRY RUN] Would update system packages via ${DF_PKG_MANAGER:-unknown}"
        return 0
    fi

    case "${DF_PKG_MANAGER:-unknown}" in
        brew)
            print_info "Updating Homebrew..."
            if brew update >/dev/null 2>&1; then
                print_success "Homebrew updated"
            else
                print_error "Failed to update Homebrew"
                return 1
            fi

            echo
            print_info "Upgrading installed packages..."
            if brew upgrade 2>&1 | while IFS= read -r line; do echo "  $line"; done; then
                print_success "Packages upgraded"
            else
                print_warning "Some packages may have failed to upgrade"
            fi

            echo
            print_info "Cleaning up old versions..."
            if brew cleanup >/dev/null 2>&1; then
                print_success "Cleanup complete"
            else
                print_warning "Cleanup encountered issues"
            fi
            ;;

        apt)
            print_info "Updating package lists..."
            if sudo apt update >/dev/null 2>&1; then
                print_success "Package lists updated"
            else
                print_error "Failed to update package lists"
                return 1
            fi

            echo
            print_info "Upgrading installed packages..."
            if sudo apt upgrade -y 2>&1 | grep -E "(Unpacking|Setting up|upgraded)" | while IFS= read -r line; do echo "  $line"; done; then
                print_success "Packages upgraded"
            else
                print_warning "Some packages may have failed to upgrade"
            fi

            echo
            print_info "Cleaning up..."
            if sudo apt autoremove -y >/dev/null 2>&1 && sudo apt autoclean >/dev/null 2>&1; then
                print_success "Cleanup complete"
            else
                print_warning "Cleanup encountered issues"
            fi
            ;;

        dnf)
            print_info "Updating packages..."
            if sudo dnf upgrade -y 2>&1 | grep -E "(Installing|Upgrading)" | while IFS= read -r line; do echo "  $line"; done; then
                print_success "Packages updated"
            else
                print_warning "Some packages may have failed to update"
            fi
            ;;

        pacman)
            print_info "Updating packages..."
            if sudo pacman -Syu --noconfirm 2>&1 | grep -E "(upgrading|installing)" | while IFS= read -r line; do echo "  $line"; done; then
                print_success "Packages updated"
            else
                print_warning "Some packages may have failed to update"
            fi
            ;;

        *)
            print_error "Unknown package manager: ${DF_PKG_MANAGER:-not set}"
            print_info "Supported: brew (macOS), apt (Debian/Ubuntu), dnf (Fedora), pacman (Arch)"
            return 1
            ;;
    esac

    return 0
}

function update_toolchains() {
    echo
    draw_separator
    print_info "🔧 Development Toolchain Updates"
    draw_separator
    echo

    local updated_any=false

    # Update Rust toolchain
    if command_exists rustup; then
        if $DRY_RUN; then
            print_info "[DRY RUN] Would update Rust toolchain via rustup"
        else
            print_info "Updating Rust toolchain..."
            if rustup update 2>&1 | grep -v "^info:" | while IFS= read -r line; do [[ -n "$line" ]] && echo "  $line"; done; then
                print_success "Rust toolchain updated"
                updated_any=true
            else
                print_warning "Rust update encountered issues"
            fi
        fi
        echo
    fi

    # Update GHCup (Haskell)
    if command_exists ghcup; then
        if $DRY_RUN; then
            print_info "[DRY RUN] Would update GHCup and Haskell Language Server"
        else
            print_info "Updating GHCup..."
            if ghcup upgrade >/dev/null 2>&1; then
                print_success "GHCup updated"
                updated_any=true
            else
                print_warning "GHCup update encountered issues"
            fi

            echo
            print_info "Updating Haskell Language Server..."
            if ghcup install hls --set >/dev/null 2>&1; then
                print_success "HLS updated"
            else
                print_warning "HLS update encountered issues"
            fi
        fi
        echo
    fi

    # Update Go (if installed via system package manager, will be handled there)
    if command_exists go; then
        local go_version=$(go version 2>/dev/null | cut -d' ' -f3)
        print_success "Go toolchain available: $go_version"
        print_info "💡 Update Go via system package manager (--system flag)"
        echo
    fi

    # Update Node.js (if managed by nvm)
    if [[ -n "${NVM_DIR:-}" ]] && [[ -f "$NVM_DIR/nvm.sh" ]]; then
        if $DRY_RUN; then
            print_info "[DRY RUN] Would update nvm"
        else
            print_info "Updating nvm..."
            source "$NVM_DIR/nvm.sh"
            if nvm install node --reinstall-packages-from=node >/dev/null 2>&1; then
                print_success "Node.js updated to latest"
                updated_any=true
            else
                print_warning "Node.js update encountered issues"
            fi
        fi
        echo
    fi

    if ! $updated_any && ! $DRY_RUN; then
        print_info "No updatable toolchains found"
        print_info "💡 Most toolchains are updated via --system"
    fi
}

function update_npm_packages() {
    echo
    draw_separator
    print_info "📦 npm Global Package Updates"
    draw_separator
    echo

    if ! command_exists npm; then
        print_warning "npm not found - skipping npm updates"
        return 0
    fi

    if $DRY_RUN; then
        print_info "[DRY RUN] Would update npm global packages:"
        npm outdated -g 2>/dev/null | while IFS= read -r line; do echo "  $line"; done
        return 0
    fi

    print_info "Updating npm global packages..."
    local npm_output=$(npm update -g 2>&1)

    if [[ $? -eq 0 ]]; then
        # Show meaningful output
        echo "$npm_output" | grep -E "(added|removed|updated|changed)" | while IFS= read -r line; do
            echo "  $line"
        done
        print_success "npm packages updated"
    else
        print_warning "Some npm packages may have failed to update"
    fi

    echo
    print_info "📦 Current global packages:"
    npm list -g --depth=0 2>/dev/null | head -10 | while IFS= read -r line; do echo "  $line"; done
}

function update_cargo_packages() {
    echo
    draw_separator
    print_info "🦀 Cargo Package Updates"
    draw_separator
    echo

    if ! command_exists cargo; then
        print_warning "cargo not found - skipping cargo updates"
        return 0
    fi

    # Check if cargo-install-update is available
    if ! command_exists cargo-install-update-config; then
        print_info "Installing cargo-update for package management..."
        if $DRY_RUN; then
            print_info "[DRY RUN] Would install cargo-update"
            return 0
        fi

        if cargo install cargo-update >/dev/null 2>&1; then
            print_success "cargo-update installed"
        else
            print_error "Failed to install cargo-update"
            print_info "💡 Manual update: cargo install <package> --force"
            return 1
        fi
    fi

    echo

    if $DRY_RUN; then
        print_info "[DRY RUN] Would check for cargo package updates"
        cargo install-update -l 2>/dev/null | while IFS= read -r line; do echo "  $line"; done
        return 0
    fi

    print_info "Checking for updates..."
    cargo install-update -a 2>&1 | while IFS= read -r line; do
        [[ -n "$line" ]] && echo "  $line"
    done

    if [[ $? -eq 0 ]]; then
        print_success "Cargo packages updated"
    else
        print_warning "Some cargo packages may have failed to update"
    fi
}

function update_gem_packages() {
    echo
    draw_separator
    print_info "💎 Ruby Gem Updates"
    draw_separator
    echo

    if ! command_exists gem; then
        print_warning "gem not found - skipping gem updates"
        return 0
    fi

    if $DRY_RUN; then
        print_info "[DRY RUN] Would update Ruby gems:"
        gem outdated 2>/dev/null | while IFS= read -r line; do echo "  $line"; done
        return 0
    fi

    print_info "Updating Ruby gems..."
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
}

function update_pipx_packages() {
    echo
    draw_separator
    print_info "🐍 pipx Package Updates"
    draw_separator
    echo

    if ! command_exists pipx; then
        print_warning "pipx not found - skipping pipx updates"
        return 0
    fi

    if $DRY_RUN; then
        print_info "[DRY RUN] Would update pipx packages:"
        pipx list --short 2>/dev/null | while IFS= read -r line; do echo "  $line"; done
        return 0
    fi

    print_info "Updating all pipx packages..."
    pipx upgrade-all 2>&1 | grep -E "(upgraded|already)" | while IFS= read -r line; do
        echo "  $line"
    done

    if [[ $? -eq 0 ]]; then
        print_success "pipx packages updated"
    else
        print_warning "Some pipx packages may have failed to update"
    fi
}

function update_language_servers() {
    echo
    draw_separator
    print_info "🔧 Language Server Updates"
    draw_separator
    echo

    if $DRY_RUN; then
        print_info "[DRY RUN] Would update language servers via their respective package managers"
        return 0
    fi

    print_info "Language servers are updated via their package managers:"
    echo "  • npm packages (typescript-language-server, etc.) → --npm"
    echo "  • cargo packages (rust-analyzer) → --cargo"
    echo "  • pipx packages (pyright) → --pipx"
    echo "  • GHCup (haskell-language-server) → --toolchains"
    echo ""
    print_info "💡 Run with --packages to update all at once"
}

# ============================================================================
# Main Execution
# ============================================================================

function main() {
    parse_args "$@"

    # Show header
    if $DRY_RUN; then
        draw_header "Update All (Dry Run)" "Preview mode - no changes will be made"
    else
        draw_header "Update All" "Updating development environment"
    fi
    echo

    # Show what will be updated
    if $UPDATE_ALL; then
        print_info "🔄 Updating: System, Toolchains, and All Packages"
    else
        local components=()
        $UPDATE_SYSTEM && components+=("System")
        $UPDATE_TOOLCHAINS && components+=("Toolchains")
        $UPDATE_NPM && components+=("npm")
        $UPDATE_CARGO && components+=("cargo")
        $UPDATE_GEM && components+=("gem")
        $UPDATE_PIPX && components+=("pipx")
        $UPDATE_LANGUAGE_SERVERS && components+=("Language Servers")

        print_info "🔄 Updating: ${(j:, :)components}"
    fi
    echo

    # Execute updates based on flags
    local success=true

    if $UPDATE_ALL || $UPDATE_SYSTEM; then
        update_system_packages || success=false
        echo
    fi

    if $UPDATE_ALL || $UPDATE_TOOLCHAINS; then
        update_toolchains || success=false
        echo
    fi

    if $UPDATE_ALL || $UPDATE_PACKAGES || $UPDATE_NPM; then
        update_npm_packages || success=false
        echo
    fi

    if $UPDATE_ALL || $UPDATE_PACKAGES || $UPDATE_CARGO; then
        update_cargo_packages || success=false
        echo
    fi

    if $UPDATE_ALL || $UPDATE_PACKAGES || $UPDATE_GEM; then
        update_gem_packages || success=false
        echo
    fi

    if $UPDATE_ALL || $UPDATE_PACKAGES || $UPDATE_PIPX; then
        update_pipx_packages || success=false
        echo
    fi

    if $UPDATE_LANGUAGE_SERVERS; then
        update_language_servers || success=false
        echo
    fi

    # Final summary
    if $DRY_RUN; then
        print_success "Dry run complete - no changes were made"
        print_info "💡 Run without --dry-run to apply updates"
    elif $success; then
        print_success "All updates completed successfully!"
        print_info "✨ Your development environment is up to date"
    else
        print_warning "Updates completed with some warnings"
        print_info "💡 Check output above for details"
    fi

    echo
    print_success "$(get_random_friend_greeting)"
}

# Run main function
main "$@"
