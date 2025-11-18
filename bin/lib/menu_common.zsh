#!/usr/bin/env zsh

# ============================================================================
# Shared Menu Functions Library for Dotfiles Menu Systems
# ============================================================================
#
# Common functionality shared between hierarchical and flat menu systems.
# Provides post-install script discovery, description generation, and
# menu item creation helpers.
#
# Usage:
#   source "$(dirname $0)/lib/menu_common.zsh"
#
# Features:
# - Post-install script discovery with filtering (.ignored/.disabled)
# - Friendly description generation based on script name patterns
# - Consistent behavior across both menu systems
# ============================================================================

# Prevent multiple loading
[[ -n "$DOTFILES_MENU_COMMON_LOADED" ]] && return 0
readonly DOTFILES_MENU_COMMON_LOADED=1

# Ensure utils.zsh is loaded (for is_post_install_script_enabled)
if [[ -z "$DOTFILES_UTILS_LOADED" ]]; then
    local lib_dir="$(dirname "${(%):-%N}")"
    source "$lib_dir/utils.zsh" 2>/dev/null || {
        echo "Warning: Could not load utils.zsh library" >&2
        return 1
    }
fi

# ============================================================================
# Post-Install Script Discovery
# ============================================================================

# Get a friendly description for a post-install script based on its name
# Args: script_name (string) - basename of the script without extension
# Returns: Friendly description string
#
# Example:
#   get_pi_script_description "npm-global-packages"
#   # Returns: "Install Node.js packages and tools"
function get_pi_script_description() {
    local script_name="$1"
    local description="Install and configure $script_name"

    # Generate friendly descriptions based on common patterns
    case "$script_name" in
        *package*|*brew*|*apt*)
            description="Install system packages via $script_name"
            ;;
        *npm*|*node*)
            description="Install Node.js packages and tools"
            ;;
        *python*|*pip*)
            description="Install Python packages and tools"
            ;;
        *cargo*|*rust*)
            description="Install Rust packages and tools"
            ;;
        *gem*|*ruby*)
            description="Install Ruby gems and tools"
            ;;
        *language-server*|*lsp*)
            description="Install language servers for IDEs"
            ;;
        *font*)
            description="Install programming fonts"
            ;;
        *toolchain*)
            description="Install $script_name development environment"
            ;;
        *vim*|*neovim*)
            description="Configure Vim/Neovim environment"
            ;;
        *starship*)
            description="Install Starship cross-shell prompt"
            ;;
        *bash-preexec*)
            description="Install bash preexec hook system"
            ;;
        *lombok*)
            description="Install Java Lombok library"
            ;;
        *)
            description="Configure $script_name environment"
            ;;
    esac

    echo "$description"
}

# Discover and filter post-install scripts
# Args: post_install_dir (string) - directory containing scripts
# Returns: Array of enabled script paths (one per line to stdout)
#
# Example:
#   local scripts=($(discover_pi_scripts "$DF_DIR/post-install/scripts"))
function discover_pi_scripts() {
    local post_install_dir="$1"
    local all_scripts=()
    local enabled_scripts=()

    # Validate directory exists
    if [[ ! -d "$post_install_dir" ]]; then
        return 1
    fi

    # Find all .zsh scripts in the directory
    all_scripts=(${(0)"$(find "$post_install_dir" -name "*.zsh" -print0 2>/dev/null)"})

    # Filter to only enabled scripts
    for script in "${all_scripts[@]}"; do
        # Check if executable
        if [[ ! -x "$script" ]]; then
            continue
        fi

        # Check if enabled (not .ignored or .disabled)
        if is_post_install_script_enabled "$script"; then
            enabled_scripts+=("$script")
        fi
    done

    # Output enabled scripts (one per line)
    printf "%s\n" "${enabled_scripts[@]}"
}

# Count total and disabled post-install scripts
# Args: post_install_dir (string) - directory containing scripts
# Returns: Two lines to stdout: total_count\ndisabled_count
#
# Example:
#   local counts=($(count_pi_scripts "$DF_DIR/post-install/scripts"))
#   local total=${counts[1]}
#   local disabled=${counts[2]}
function count_pi_scripts() {
    local post_install_dir="$1"
    local all_scripts=()
    local total_count=0
    local disabled_count=0

    # Validate directory exists
    if [[ ! -d "$post_install_dir" ]]; then
        echo "0"
        echo "0"
        return 1
    fi

    # Find all .zsh scripts
    all_scripts=(${(0)"$(find "$post_install_dir" -name "*.zsh" -print0 2>/dev/null)"})
    total_count=${#all_scripts[@]}

    # Count disabled/ignored
    for script in "${all_scripts[@]}"; do
        if ! is_post_install_script_enabled "$script"; then
            ((disabled_count++))
        fi
    done

    echo "$total_count"
    echo "$disabled_count"
}

# ============================================================================
# Export Functions
# ============================================================================

# Make all menu common functions available for use in sourcing scripts
# Note: Using typeset -f (not -fx) for cross-platform compatibility
{
    typeset -f get_pi_script_description
    typeset -f discover_pi_scripts
    typeset -f count_pi_scripts
} >/dev/null 2>&1 || true
