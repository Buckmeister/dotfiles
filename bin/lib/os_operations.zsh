#!/usr/bin/env zsh

# ============================================================================
# OS Operations Library - OS-Aware File and System Operations
# ============================================================================
#
# This library provides OS-aware operations for file handling, path
# construction, clipboard access, and system-specific operations.
#
# Features:
# - OS-aware file and directory operations
# - XDG Base Directory specification support
# - Cross-platform clipboard operations
# - Path construction and manipulation
# - Desktop environment detection
# - System-specific temporary directories
# - File opening with default applications
# ============================================================================

# Note: emulate -LR zsh removed - this library is sourced by scripts that already have it.
# The caller's emulate directive applies to the entire execution context, making it
# redundant here. Removing it prevents potential array scoping issues in subshells.

# ============================================================================
# Dependency: Load other shared libraries
# ============================================================================

if [[ -z "$COLOR_RESET" ]]; then
    local LIB_DIR="${0:a:h}"
    source "$LIB_DIR/colors.zsh" 2>/dev/null || true
    source "$LIB_DIR/ui.zsh" 2>/dev/null || true
    source "$LIB_DIR/utils.zsh" 2>/dev/null || true
fi

# ============================================================================
# XDG Base Directory Specification
# ============================================================================

# Get XDG config home directory (with fallback)
# Usage: get_xdg_config_home
function get_xdg_config_home() {
    echo "${XDG_CONFIG_HOME:-$HOME/.config}"
}

# Get XDG data home directory (with fallback)
# Usage: get_xdg_data_home
function get_xdg_data_home() {
    echo "${XDG_DATA_HOME:-$HOME/.local/share}"
}

# Get XDG state home directory (with fallback)
# Usage: get_xdg_state_home
function get_xdg_state_home() {
    echo "${XDG_STATE_HOME:-$HOME/.local/state}"
}

# Get XDG cache home directory (with fallback)
# Usage: get_xdg_cache_home
function get_xdg_cache_home() {
    echo "${XDG_CACHE_HOME:-$HOME/.cache}"
}

# Get config directory for a specific application
# Usage: get_app_config_dir <app_name>
function get_app_config_dir() {
    local app_name="$1"
    echo "$(get_xdg_config_home)/$app_name"
}

# Get data directory for a specific application
# Usage: get_app_data_dir <app_name>
function get_app_data_dir() {
    local app_name="$1"
    echo "$(get_xdg_data_home)/$app_name"
}

# Get cache directory for a specific application
# Usage: get_app_cache_dir <app_name>
function get_app_cache_dir() {
    local app_name="$1"
    echo "$(get_xdg_cache_home)/$app_name"
}

# Ensure XDG directories exist
# Usage: ensure_xdg_directories
function ensure_xdg_directories() {
    mkdir -p "$(get_xdg_config_home)"
    mkdir -p "$(get_xdg_data_home)"
    mkdir -p "$(get_xdg_state_home)"
    mkdir -p "$(get_xdg_cache_home)"
    mkdir -p "$HOME/.local/bin"
}

# ============================================================================
# Platform-Specific Paths
# ============================================================================

# Get the user's home directory (portable)
# Usage: get_home_dir
function get_home_dir() {
    echo "$HOME"
}

# Get temporary directory (OS-aware)
# Usage: get_temp_dir
function get_temp_dir() {
    case "${DF_OS:-$(get_os)}" in
        macos)
            echo "${TMPDIR:-/tmp}"
            ;;
        linux|windows)
            echo "${TMPDIR:-/tmp}"
            ;;
        *)
            echo "/tmp"
            ;;
    esac
}

# Create a temporary directory with a specific prefix
# Usage: create_temp_dir <prefix>
function create_temp_dir() {
    local prefix="${1:-dotfiles}"
    mktemp -d "$(get_temp_dir)/${prefix}.XXXXXX"
}

# Get application support directory (OS-aware)
# Usage: get_app_support_dir
function get_app_support_dir() {
    case "${DF_OS:-$(get_os)}" in
        macos)
            echo "$HOME/Library/Application Support"
            ;;
        *)
            get_xdg_data_home
            ;;
    esac
}

# Get user's downloads directory
# Usage: get_downloads_dir
function get_downloads_dir() {
    # Try to find Downloads directory
    if [[ -d "$HOME/Downloads" ]]; then
        echo "$HOME/Downloads"
    elif [[ -d "$HOME/Download" ]]; then
        echo "$HOME/Download"
    else
        # Fallback to home
        echo "$HOME"
    fi
}

# ============================================================================
# Clipboard Operations
# ============================================================================

# Copy text to clipboard (OS-aware)
# Usage: copy_to_clipboard <text>
# Or pipe: echo "text" | copy_to_clipboard
function copy_to_clipboard() {
    local text="${1:-}"

    # If no argument provided, read from stdin
    if [[ -z "$text" ]]; then
        text=$(cat)
    fi

    case "${DF_OS:-$(get_os)}" in
        macos)
            if command_exists pbcopy; then
                echo "$text" | pbcopy
                return 0
            fi
            ;;
        linux)
            if command_exists xclip; then
                echo "$text" | xclip -selection clipboard
                return 0
            elif command_exists xsel; then
                echo "$text" | xsel --clipboard
                return 0
            fi
            ;;
        windows)
            if command_exists clip.exe; then
                echo "$text" | clip.exe
                return 0
            fi
            ;;
    esac

    return 1
}

# Paste text from clipboard (OS-aware)
# Usage: paste_from_clipboard
function paste_from_clipboard() {
    case "${DF_OS:-$(get_os)}" in
        macos)
            if command_exists pbpaste; then
                pbpaste
                return 0
            fi
            ;;
        linux)
            if command_exists xclip; then
                xclip -selection clipboard -o
                return 0
            elif command_exists xsel; then
                xsel --clipboard
                return 0
            fi
            ;;
        windows)
            if command_exists powershell.exe; then
                powershell.exe -command "Get-Clipboard"
                return 0
            fi
            ;;
    esac

    return 1
}

# Check if clipboard operations are available
# Usage: has_clipboard_support
function has_clipboard_support() {
    case "${DF_OS:-$(get_os)}" in
        macos)
            command_exists pbcopy && command_exists pbpaste
            ;;
        linux)
            command_exists xclip || command_exists xsel
            ;;
        windows)
            command_exists clip.exe
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================================
# File Opening Operations
# ============================================================================

# Open a file or URL with the default application (OS-aware)
# Usage: open_with_default <file_or_url>
function open_with_default() {
    local target="$1"

    case "${DF_OS:-$(get_os)}" in
        macos)
            if command_exists open; then
                open "$target"
                return 0
            fi
            ;;
        linux)
            if command_exists xdg-open; then
                xdg-open "$target" >/dev/null 2>&1
                return 0
            elif command_exists gnome-open; then
                gnome-open "$target" >/dev/null 2>&1
                return 0
            fi
            ;;
        windows)
            if command_exists cmd.exe; then
                cmd.exe /c start "" "$target"
                return 0
            fi
            ;;
    esac

    return 1
}

# Open a URL in the default browser
# Usage: open_url <url>
function open_url() {
    local url="$1"
    open_with_default "$url"
}

# Open a file in the default editor
# Usage: open_in_editor <file>
function open_in_editor() {
    local file="$1"

    # Try to use $EDITOR or $VISUAL
    if [[ -n "$EDITOR" ]]; then
        "$EDITOR" "$file"
        return 0
    elif [[ -n "$VISUAL" ]]; then
        "$VISUAL" "$file"
        return 0
    fi

    # Fallback to common editors
    for editor in nvim vim vi nano; do
        if command_exists "$editor"; then
            "$editor" "$file"
            return 0
        fi
    done

    # Last resort: try default file opener
    open_with_default "$file"
}

# ============================================================================
# Path Manipulation
# ============================================================================

# Normalize a path (resolve . and .., remove duplicate slashes)
# Usage: normalize_path <path>
function normalize_path() {
    local path="$1"
    # Use realpath if available, otherwise readlink
    if command_exists realpath; then
        realpath -m "$path" 2>/dev/null || echo "$path"
    elif command_exists readlink; then
        readlink -f "$path" 2>/dev/null || echo "$path"
    else
        # Basic normalization
        echo "$path" | sed -e 's|/\./|/|g' -e 's|//|/|g'
    fi
}

# Get absolute path of a file or directory
# Usage: get_absolute_path <path>
function get_absolute_path() {
    local path="$1"

    # If path is already absolute, return it
    if [[ "$path" = /* ]]; then
        normalize_path "$path"
        return 0
    fi

    # Make it absolute by prepending current directory
    normalize_path "$(pwd)/$path"
}

# Join path components
# Usage: join_path <component1> <component2> ...
function join_path() {
    local result="$1"
    shift

    for component in "$@"; do
        # Remove trailing slash from result
        result="${result%/}"
        # Remove leading slash from component
        component="${component#/}"
        # Join with single slash
        result="$result/$component"
    done

    echo "$result"
}

# Get the directory part of a path
# Usage: get_dir_path <path>
function get_dir_path() {
    local path="$1"
    dirname "$path"
}

# Get the filename part of a path
# Usage: get_file_name <path>
function get_file_name() {
    local path="$1"
    basename "$path"
}

# Get file extension
# Usage: get_file_extension <filename>
function get_file_extension() {
    local filename="$1"
    echo "${filename##*.}"
}

# Get filename without extension
# Usage: get_file_basename <filename>
function get_file_basename() {
    local filename="$1"
    echo "${filename%.*}"
}

# ============================================================================
# File and Directory Operations
# ============================================================================

# Create directory if it doesn't exist (recursive)
# Usage: ensure_directory <path>
function ensure_directory() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        mkdir -p "$path"
    fi
}

# Safely copy a file, creating parent directories if needed
# Usage: safe_copy <source> <destination>
function safe_copy() {
    local source="$1"
    local destination="$2"

    ensure_directory "$(get_dir_path "$destination")"
    cp "$source" "$destination"
}

# Safely move a file, creating parent directories if needed
# Usage: safe_move <source> <destination>
function safe_move() {
    local source="$1"
    local destination="$2"

    ensure_directory "$(get_dir_path "$destination")"
    mv "$source" "$destination"
}

# Backup a file before modifying it
# Usage: backup_file <file> [backup_suffix]
function backup_file() {
    local file="$1"
    local backup_suffix="${2:-.backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_file="${file}${backup_suffix}"

    if [[ -f "$file" ]]; then
        cp "$file" "$backup_file"
        echo "$backup_file"
        return 0
    fi

    return 1
}

# Create a symbolic link, backing up existing target if necessary
# Usage: safe_symlink <source> <target> [backup]
function safe_symlink() {
    local source="$1"
    local target="$2"
    local do_backup="${3:-true}"

    # Create parent directory if needed
    ensure_directory "$(get_dir_path "$target")"

    # Backup existing target if requested
    if [[ "$do_backup" == "true" ]] && [[ -e "$target" || -L "$target" ]]; then
        backup_file "$target"
    fi

    # Remove existing target (file, directory, or symlink)
    if [[ -e "$target" || -L "$target" ]]; then
        rm -rf "$target"
    fi

    # Create symlink
    ln -s "$source" "$target"
}

# ============================================================================
# System Detection and Information
# ============================================================================

# Detect desktop environment (Linux only)
# Usage: get_desktop_environment
function get_desktop_environment() {
    if [[ "${DF_OS:-$(get_os)}" != "linux" ]]; then
        echo "none"
        return 1
    fi

    # Check XDG_CURRENT_DESKTOP first
    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]'
        return 0
    fi

    # Check DESKTOP_SESSION
    if [[ -n "$DESKTOP_SESSION" ]]; then
        echo "$DESKTOP_SESSION" | tr '[:upper:]' '[:lower:]'
        return 0
    fi

    # Try to detect by running processes
    if pgrep -x "gnome-shell" >/dev/null; then
        echo "gnome"
    elif pgrep -x "kwin" >/dev/null; then
        echo "kde"
    elif pgrep -x "xfce4-session" >/dev/null; then
        echo "xfce"
    elif pgrep -x "mate-session" >/dev/null; then
        echo "mate"
    elif pgrep -x "cinnamon" >/dev/null; then
        echo "cinnamon"
    else
        echo "unknown"
    fi
}

# Check if running in a graphical environment
# Usage: is_graphical_session
function is_graphical_session() {
    [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]
}

# Get the current shell name
# Usage: get_current_shell
function get_current_shell() {
    basename "$SHELL"
}

# Get system architecture
# Usage: get_architecture
function get_architecture() {
    uname -m
}

# Get number of CPU cores
# Usage: get_cpu_count
function get_cpu_count() {
    case "${DF_OS:-$(get_os)}" in
        macos)
            sysctl -n hw.ncpu 2>/dev/null || echo "1"
            ;;
        linux)
            nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "1"
            ;;
        *)
            echo "1"
            ;;
    esac
}

# ============================================================================
# Permission and Ownership Operations
# ============================================================================

# Make a file executable
# Usage: make_executable <file>
function make_executable() {
    local file="$1"
    if [[ -f "$file" ]]; then
        chmod +x "$file"
        return 0
    fi
    return 1
}

# Make a file readonly
# Usage: make_readonly <file>
function make_readonly() {
    local file="$1"
    if [[ -f "$file" ]]; then
        chmod 444 "$file"
        return 0
    fi
    return 1
}

# Check if file is owned by current user
# Usage: is_owned_by_user <file>
function is_owned_by_user() {
    local file="$1"
    [[ -O "$file" ]]
}

# ============================================================================
# Utility Functions
# ============================================================================

# Print a summary of OS-specific paths
# Usage: print_os_paths
function print_os_paths() {
    print_info "📁 OS-Specific Paths:"
    echo "   OS:              ${DF_OS:-$(get_os)}"
    echo "   Home:            $(get_home_dir)"
    echo "   Config:          $(get_xdg_config_home)"
    echo "   Data:            $(get_xdg_data_home)"
    echo "   Cache:           $(get_xdg_cache_home)"
    echo "   Temp:            $(get_temp_dir)"
    echo "   Downloads:       $(get_downloads_dir)"
    echo "   Architecture:    $(get_architecture)"
    echo "   CPU Cores:       $(get_cpu_count)"
    echo "   Shell:           $(get_current_shell)"

    if is_graphical_session; then
        echo "   Desktop:         $(get_desktop_environment)"
    else
        echo "   Desktop:         none (terminal session)"
    fi

    echo
}
