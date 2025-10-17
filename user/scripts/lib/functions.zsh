#!/usr/bin/env zsh

# ============================================================================
# Bootstrap Functions for User Scripts
# ============================================================================
#
# Shared bootstrap library for user-facing scripts in user/scripts/*.
# Provides path detection and library loading with graceful fallbacks.
#
# This library is intentionally minimal and has no external dependencies,
# allowing it to be sourced before the main shared libraries are loaded.
#
# Usage in user scripts:
#   SCRIPT_PATH="${0:A}"
#   BOOTSTRAP_LIB="${SCRIPT_PATH%/user/scripts/*}/user/scripts/lib/functions.zsh"
#   source "$BOOTSTRAP_LIB"
#   DF_DIR=$(detect_df_dir)
#   load_shared_libs "$DF_DIR"
#
# ============================================================================

# ============================================================================
# Path Detection
# ============================================================================

# Detect dotfiles directory from script location using pattern matching
# This approach is robust to arbitrary directory depth and future reorganization
#
# Args: None (uses $0 from calling script)
# Returns: Dotfiles root directory path
# Outputs: Directory path to stdout
detect_df_dir() {
    local script_path="${0:A}"

    # Try user/scripts pattern (most common for user-facing scripts)
    if [[ "$script_path" == */user/scripts/* ]]; then
        echo "${script_path%%/user/scripts/*}"
        return 0
    fi

    # Try bin pattern (for core scripts)
    if [[ "$script_path" == */bin/* ]]; then
        echo "${script_path%%/bin/*}"
        return 0
    fi

    # Try post-install pattern
    if [[ "$script_path" == */post-install/* ]]; then
        echo "${script_path%%/post-install/*}"
        return 0
    fi

    # Try tests pattern
    if [[ "$script_path" == */tests/* ]]; then
        echo "${script_path%%/tests/*}"
        return 0
    fi

    # Fallback: assume HOME/.config/dotfiles (last resort)
    echo "${HOME}/.config/dotfiles"
    return 1
}

# ============================================================================
# Library Loading
# ============================================================================

# Load shared libraries with graceful fallback
# Attempts to load the full shared library suite from bin/lib/
# If unavailable, defines minimal fallback functions to prevent script failure
#
# Args:
#   $1 - Dotfiles root directory
# Returns:
#   0 if libraries loaded successfully
#   1 if fallback functions were defined
load_shared_libs() {
    local df_dir="$1"

    if [[ -f "$df_dir/bin/lib/colors.zsh" ]]; then
        source "$df_dir/bin/lib/colors.zsh" 2>/dev/null
        source "$df_dir/bin/lib/ui.zsh" 2>/dev/null
        source "$df_dir/bin/lib/utils.zsh" 2>/dev/null
        return 0
    else
        # Define minimal fallback functions (all redirect to stderr)
        print_error() { echo "Error: $1" >&2; }
        print_success() { echo "$1" >&2; }
        print_info() { echo "$1" >&2; }
        print_warning() { echo "Warning: $1" >&2; }
        command_exists() { command -v "$1" >/dev/null 2>&1; }
        draw_header() { echo "$1" >&2; }
        draw_section_header() { echo "$1" >&2; }

        # Basic color definitions for fallback
        readonly UI_SUCCESS_COLOR='\033[32m'
        readonly UI_INFO_COLOR='\033[34m'
        readonly UI_ERROR_COLOR='\033[31m'
        readonly UI_WARNING_COLOR='\033[33m'
        readonly UI_ACCENT_COLOR='\033[35m'
        readonly COLOR_RESET='\033[0m'
        readonly COLOR_BOLD='\033[1m'
        readonly COLOR_DIM='\033[2m'

        return 1
    fi
}

# ============================================================================
# OS Detection (Minimal Fallback)
# ============================================================================

# Get operating system (minimal version for bootstrap)
# This is a simplified version of get_os() from utils.zsh
# Used only when full libraries cannot be loaded
#
# Returns: OS identifier (darwin, linux, windows, unknown)
# Outputs: OS name to stdout
get_os_minimal() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$os" in
        darwin*)
            echo "darwin"
            ;;
        linux*)
            echo "linux"
            ;;
        mingw*|msys*|cygwin*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}
