#!/usr/bin/env zsh

# ============================================================================
# Shared Utilities Library for Dotfiles Scripts
# ============================================================================
#
# A comprehensive utilities library providing common functions, error handling,
# file operations, and helper utilities used across dotfiles scripts.
#
# Usage:
#   source "$(dirname $0)/lib/colors.zsh" 2>/dev/null || { ... fallback ... }
#   source "$(dirname $0)/lib/ui.zsh" 2>/dev/null || { ... fallback ... }
#   source "$(dirname $0)/lib/utils.zsh" 2>/dev/null || { ... fallback ... }
#
# Features:
# - Centralized error handling with consistent formatting
# - Common file and directory operations
# - Progress tracking utilities
# - Environment detection and setup
# - Safe execution wrappers
# ============================================================================

# Prevent multiple loading
[[ -n "$DOTFILES_UTILS_LOADED" ]] && return 0
readonly DOTFILES_UTILS_LOADED=1

# Ensure dependencies are loaded
if [[ -z "$DOTFILES_COLORS_LOADED" || -z "$DOTFILES_UI_LOADED" ]]; then
    local lib_dir="$(dirname "${(%):-%N}")"
    [[ -z "$DOTFILES_COLORS_LOADED" ]] && source "$lib_dir/colors.zsh" 2>/dev/null
    [[ -z "$DOTFILES_UI_LOADED" ]] && source "$lib_dir/ui.zsh" 2>/dev/null
fi

# ============================================================================
# Global Utility Variables
# ============================================================================

# Operation tracking (can be used across all scripts)
typeset -g -i TOTAL_OPERATIONS=0
typeset -g -i COMPLETED_OPERATIONS=0
typeset -g -i SUCCESS_COUNT=0
typeset -g -i ERROR_COUNT=0
typeset -g -a OPERATION_RESULTS=()

# ============================================================================
# Error Handling and Exit Functions
# ============================================================================

# Centralized error exit function with consistent formatting
function exit_with_error() {
    local error_message="$1"
    local target_path="${2:-}"
    local exit_code="${3:-1}"

    OPERATION_RESULTS+=("❌ $error_message")

    printf "\n${UI_ERROR_COLOR}❌ Error: $error_message${COLOR_RESET}\n"

    if [[ -n "$target_path" ]]; then
        printf "${UI_INFO_COLOR}Target: $target_path${COLOR_RESET}\n"
    fi

    printf "${UI_INFO_COLOR}Please check the issue and try again.${COLOR_RESET}\n\n"

    ((ERROR_COUNT++))
    ((COMPLETED_OPERATIONS++))

    # Ensure UI is cleaned up
    if typeset -f cleanup_ui >/dev/null; then
        cleanup_ui
    else
        show_cursor 2>/dev/null || true
    fi

    exit $exit_code
}

# Log an error without exiting
function log_error() {
    local error_message="$1"
    local should_increment="${2:-true}"

    OPERATION_RESULTS+=("❌ $error_message")
    print_error "$error_message"

    [[ "$should_increment" == "true" ]] && ((ERROR_COUNT++))
}

# Log a warning
function log_warning() {
    local warning_message="$1"

    OPERATION_RESULTS+=("⚠️ $warning_message")
    print_warning "$warning_message"
}

# ============================================================================
# Progress Tracking Functions
# ============================================================================

# Complete an operation with optional success message
function complete_operation() {
    local success_message="${1:-}"

    if [[ -n "$success_message" ]]; then
        OPERATION_RESULTS+=("✅ $success_message")
        ((SUCCESS_COUNT++))
    fi

    ((COMPLETED_OPERATIONS++))
}

# Initialize operation tracking
function init_operations() {
    local total="${1:-0}"

    TOTAL_OPERATIONS=$total
    COMPLETED_OPERATIONS=0
    SUCCESS_COUNT=0
    ERROR_COUNT=0
    OPERATION_RESULTS=()

    # Set global progress variables if ui.zsh is loaded
    if [[ -n "$DOTFILES_UI_LOADED" ]]; then
        PROGRESS_TOTAL=$total
        PROGRESS_CURRENT=0
    fi
}

# Get current progress percentage
function get_progress_percentage() {
    [[ $TOTAL_OPERATIONS -eq 0 ]] && echo "0" && return
    echo $((COMPLETED_OPERATIONS * 100 / TOTAL_OPERATIONS))
}

# Update progress and display if ui.zsh is available
function update_operation_progress() {
    local phase_name="$1"
    local operation_name="$2"

    if typeset -f update_status_display >/dev/null; then
        update_status_display "$phase_name" "$operation_name" \
            $COMPLETED_OPERATIONS $TOTAL_OPERATIONS \
            $SUCCESS_COUNT $ERROR_COUNT
    else
        # Fallback: simple text display
        printf "[%d/%d] %s: %s\n" \
            $COMPLETED_OPERATIONS $TOTAL_OPERATIONS \
            "$phase_name" "$operation_name"
    fi
}

# ============================================================================
# File and Directory Operations
# ============================================================================

# Get file size in human readable format
function get_file_size() {
    local file_path="$1"

    if [[ -f "$file_path" ]]; then
        if command -v stat >/dev/null 2>&1; then
            # Try macOS stat first, then GNU stat
            du -h "$file_path" 2>/dev/null | cut -f1 || echo "unknown"
        else
            echo "unknown"
        fi
    else
        echo "not found"
    fi
}

# Check if directory is writable
function is_writable() {
    local path="$1"
    [[ -w "$path" ]]
}

# Create directory with error handling
function create_directory_safe() {
    local dir_path="$1"
    local description="${2:-$dir_path}"

    if [[ ! -d "$dir_path" ]]; then
        if mkdir -p "$dir_path" 2>/dev/null; then
            complete_operation "Created directory: $description"
            return 0
        else
            log_error "Failed to create directory: $description"
            return 1
        fi
    else
        complete_operation "Directory exists: $description"
        return 0
    fi
}

# Expand tilde in path
function expand_path() {
    local path="$1"
    # Use eval for proper tilde expansion
    eval echo "$path"
}

# Check if file or directory exists
function path_exists() {
    local path="$1"
    [[ -e "$(expand_path "$path")" ]]
}

# ============================================================================
# Environment Detection and Setup
# ============================================================================

# Detect operating system
function get_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        CYGWIN*)  echo "windows" ;;
        MINGW*)   echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# Detect and configure package manager
# Sets and exports: DF_OS, DF_PKG_MANAGER, DF_PKG_INSTALL_CMD
# This provides a single source of truth for OS and package manager detection
function detect_package_manager() {
    # Detect operating system
    export DF_OS=$(get_os)

    # Set OS-specific package manager variables
    case "$DF_OS" in
        macos)
            export DF_PKG_MANAGER="brew"
            export DF_PKG_INSTALL_CMD="brew install"
            ;;
        linux)
            # Detect Linux package manager based on what's available
            if command_exists apt; then
                export DF_PKG_MANAGER="apt"
                export DF_PKG_INSTALL_CMD="sudo apt install"
            elif command_exists dnf; then
                export DF_PKG_MANAGER="dnf"
                export DF_PKG_INSTALL_CMD="sudo dnf install"
            elif command_exists pacman; then
                export DF_PKG_MANAGER="pacman"
                export DF_PKG_INSTALL_CMD="sudo pacman -S"
            elif command_exists zypper; then
                export DF_PKG_MANAGER="zypper"
                export DF_PKG_INSTALL_CMD="sudo zypper install"
            else
                export DF_PKG_MANAGER="unknown"
                export DF_PKG_INSTALL_CMD="echo 'No package manager found'"
            fi
            ;;
        windows)
            export DF_PKG_MANAGER="choco"
            export DF_PKG_INSTALL_CMD="choco install"
            ;;
        *)
            export DF_PKG_MANAGER="unknown"
            export DF_PKG_INSTALL_CMD="echo 'Unknown package manager'"
            ;;
    esac
}

# Check if command exists
function command_exists() {
    local command="$1"
    command -v "$command" >/dev/null 2>&1
}

# Validate required commands
function require_commands() {
    local commands=("$@")
    local missing_commands=()

    for cmd in "${commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        local cmd_list=$(printf ", %s" "${missing_commands[@]}")
        cmd_list=${cmd_list:2}  # Remove leading ", "
        exit_with_error "Required commands not found: $cmd_list"
    fi
}

# Get script directory (where the calling script is located)
function get_script_dir() {
    local script_path="${1:-${(%):-%N}}"
    dirname "$(realpath "$script_path")"
}

# Get dotfiles directory (assumes standard structure)
function get_dotfiles_dir() {
    local script_dir="${1:-$(get_script_dir)}"
    realpath "$script_dir/.."
}

# ============================================================================
# Timestamp and Filename Utilities
# ============================================================================

# Generate timestamp in standard format
function get_timestamp() {
    local format="${1:-"%Y%m%d-%H%M%S"}"
    date +"$format"
}

# Generate unique filename with timestamp
function generate_timestamped_filename() {
    local prefix="$1"
    local extension="${2:-}"
    local timestamp=$(get_timestamp)

    if [[ -n "$extension" ]]; then
        echo "${prefix}_${timestamp}.${extension}"
    else
        echo "${prefix}_${timestamp}"
    fi
}

# ============================================================================
# Safe Execution Wrappers
# ============================================================================

# Execute command with error handling
function safe_exec() {
    local description="$1"
    shift
    local command=("$@")

    update_operation_progress "Executing" "$description"

    if "${command[@]}" >/dev/null 2>&1; then
        complete_operation "$description completed successfully"
        return 0
    else
        log_error "$description failed"
        return 1
    fi
}

# Execute command with output capture
function exec_with_output() {
    local description="$1"
    shift
    local command=("$@")

    update_operation_progress "Executing" "$description"

    local output
    if output=$("${command[@]}" 2>&1); then
        complete_operation "$description completed successfully"
        echo "$output"
        return 0
    else
        log_error "$description failed: $output"
        return 1
    fi
}

# ============================================================================
# Archive and File Operations
# ============================================================================

# Test archive integrity
function test_archive_integrity() {
    local archive_path="$1"
    local archive_type="${2:-zip}"

    case "$archive_type" in
        "zip")
            if command_exists zip; then
                zip -T "$archive_path" >/dev/null 2>&1
            else
                log_error "zip command not available for integrity test"
                return 1
            fi
            ;;
        "tar")
            if command_exists tar; then
                tar -tf "$archive_path" >/dev/null 2>&1
            else
                log_error "tar command not available for integrity test"
                return 1
            fi
            ;;
        *)
            log_error "Unsupported archive type: $archive_type"
            return 1
            ;;
    esac
}

# Get archive file count
function get_archive_file_count() {
    local archive_path="$1"
    local archive_type="${2:-zip}"

    case "$archive_type" in
        "zip")
            if command_exists unzip; then
                unzip -l "$archive_path" 2>/dev/null | grep -c "^[[:space:]]*[0-9]" || echo "0"
            else
                echo "0"
            fi
            ;;
        "tar")
            if command_exists tar; then
                tar -tf "$archive_path" 2>/dev/null | wc -l | tr -d ' ' || echo "0"
            else
                echo "0"
            fi
            ;;
        *)
            echo "0"
            ;;
    esac
}

# ============================================================================
# String and Array Utilities
# ============================================================================

# Join array elements with delimiter
function join_array() {
    local delimiter="$1"
    shift
    local elements=("$@")

    local result=""
    for ((i=0; i<${#elements[@]}; i++)); do
        [[ $i -gt 0 ]] && result+="$delimiter"
        result+="${elements[$i]}"
    done

    echo "$result"
}

# Trim whitespace from string
function trim() {
    local string="$1"
    # Remove leading whitespace
    string="${string#"${string%%[![:space:]]*}"}"
    # Remove trailing whitespace
    string="${string%"${string##*[![:space:]]}"}"
    echo "$string"
}

# ============================================================================
# Configuration and Settings
# ============================================================================

# Load configuration from file if it exists
function load_config() {
    local config_file="$1"
    local required="${2:-false}"

    if [[ -f "$config_file" ]]; then
        source "$config_file"
        return 0
    elif [[ "$required" == "true" ]]; then
        exit_with_error "Required configuration file not found: $config_file"
    else
        return 1
    fi
}

# ============================================================================
# Export Functions
# ============================================================================

# Export all utility functions for use in sourcing scripts (suppress output)
{
    typeset -fx exit_with_error log_error log_warning
    typeset -fx complete_operation init_operations get_progress_percentage update_operation_progress
    typeset -fx get_file_size is_writable create_directory_safe expand_path path_exists
    typeset -fx get_os detect_package_manager command_exists require_commands get_script_dir get_dotfiles_dir
    typeset -fx get_timestamp generate_timestamped_filename
    typeset -fx safe_exec exec_with_output
    typeset -fx test_archive_integrity get_archive_file_count
    typeset -fx join_array trim load_config
} >/dev/null 2>&1