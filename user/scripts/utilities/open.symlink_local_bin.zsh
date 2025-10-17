#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# open - Cross-Platform File/URL Opener
# ============================================================================
#
# Universal file and URL opener that adapts to your operating system:
# - macOS: Uses native `open` command
# - Linux: Uses `xdg-open`
# - WSL: Uses Windows default applications via cmd.exe
#
# Perfect for opening files in default apps, URLs in browsers, and
# seamlessly integrating WSL with Windows applications.
#
# Usage:
#   open file.pdf
#   open https://github.com
#   open .
#   open ~/Documents
#
# ============================================================================

# ============================================================================
# Bootstrap: Load Shared Libraries
# ============================================================================

# Resolve script path and load bootstrap library
SCRIPT_PATH="${0:A}"
BOOTSTRAP_LIB="${SCRIPT_PATH%/user/scripts/*}/user/scripts/lib/functions.zsh"

if [[ -f "$BOOTSTRAP_LIB" ]]; then
    source "$BOOTSTRAP_LIB"
    DF_DIR=$(detect_df_dir)
    if load_shared_libs "$DF_DIR"; then
        LIBRARIES_LOADED=true
        # Get OS from shared library
        DF_OS=$(get_os 2>/dev/null || echo "linux")
    else
        LIBRARIES_LOADED=false
        # Use minimal OS detection
        DF_OS=$(get_os_minimal)
    fi
else
    # Ultra-minimal fallback if bootstrap library missing
    LIBRARIES_LOADED=false
    DF_DIR="${HOME}/.config/dotfiles"
    print_error() { echo "Error: $1" >&2; }
    print_success() { echo "$1"; }
    print_info() { echo "$1"; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }
    # Detect OS manually in fallback mode
    if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
        DF_OS="wsl"
    else
        DF_OS="$(uname | tr '[:upper:]' '[:lower:]')"
    fi
fi

# ============================================================================
# Helper Functions
# ============================================================================

# Show help message
show_help() {
    cat <<'EOF'
open - Cross-Platform File/URL Opener

Universal file and URL opener that adapts to your operating system.

USAGE:
    open [options] <file|directory|url>

OPTIONS:
    -h, --help              Show this help message

EXAMPLES:
    # Open a PDF file in default PDF viewer
    open document.pdf

    # Open URL in default browser
    open https://github.com

    # Open current directory in file manager
    open .

    # Open a directory
    open ~/Documents

    # Open multiple files
    open file1.txt file2.txt file3.txt

BEHAVIOR BY PLATFORM:
    - macOS:  Uses native 'open' command
    - Linux:  Uses 'xdg-open' (freedesktop standard)
    - WSL:    Uses Windows default applications via cmd.exe

WSL FEATURES:
    - Automatically translates Linux paths to Windows paths
    - Opens files in Windows default applications
    - Launches URLs in Windows default browser
    - Opens directories in Windows Explorer

INTEGRATION:
    # Open project in default text editor
    open README.md

    # Open GitHub repo in browser
    open https://github.com/$(git config user.name)/dotfiles

    # Open current directory in file manager
    open .

    # Quick project access
    alias proj='open ~/Projects'

EOF
}

# Convert WSL path to Windows path
# Args: $1 = Linux path
# Returns: Windows path
wsl_to_windows_path() {
    local linux_path="$1"

    # Use wslpath if available (WSL 2)
    if command_exists wslpath; then
        wslpath -w "$linux_path" 2>/dev/null || echo "$linux_path"
    else
        # Fallback: manual conversion
        # /mnt/c/... -> C:\...
        # /home/... -> \\wsl$\distro\home\...
        if [[ "$linux_path" =~ ^/mnt/([a-z])(/.*)?$ ]]; then
            local drive="${match[1]}"
            local path="${match[2]}"
            echo "${(U)drive}:${path//\//\\}"
        else
            # WSL paths need to use \\wsl$ UNC path
            local distro=$(cat /etc/os-release | grep ^ID= | cut -d= -f2 | tr -d '"')
            echo "\\\\wsl\$\\${distro}${linux_path//\//\\}"
        fi
    fi
}

# ============================================================================
# Parse Arguments
# ============================================================================

if [[ $# -eq 0 ]]; then
    print_error "No file, directory, or URL specified"
    print_info "Usage: open <file|directory|url>"
    print_info "Use 'open --help' for more information"
    exit 1
fi

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# ============================================================================
# Open Files/URLs/Directories
# ============================================================================

# Process all arguments
for target in "$@"; do
    case "$DF_OS" in
        darwin|macos)
            # macOS: Use native open command
            if command_exists /usr/bin/open; then
                /usr/bin/open "$target"
            else
                print_error "macOS 'open' command not found"
                exit 1
            fi
            ;;

        wsl)
            # WSL: Use Windows default applications

            # Check if it's a URL (starts with http:// or https://)
            if [[ "$target" =~ ^https?:// ]]; then
                # Open URL in Windows default browser
                cmd.exe /c start "$target" 2>/dev/null
            elif [[ -e "$target" ]]; then
                # File or directory exists - convert path and open
                local windows_path=$(wsl_to_windows_path "$(realpath "$target")")

                if [[ -d "$target" ]]; then
                    # Directory - open in Explorer
                    explorer.exe "$windows_path" 2>/dev/null
                else
                    # File - open with default application
                    cmd.exe /c start "" "$windows_path" 2>/dev/null
                fi
            else
                # Path doesn't exist - try as URL or Windows path
                cmd.exe /c start "$target" 2>/dev/null
            fi
            ;;

        linux)
            # Linux: Use xdg-open (freedesktop standard)
            if command_exists xdg-open; then
                xdg-open "$target" &>/dev/null &
            elif command_exists gnome-open; then
                # Fallback for older GNOME
                gnome-open "$target" &>/dev/null &
            elif command_exists kde-open; then
                # Fallback for KDE
                kde-open "$target" &>/dev/null &
            else
                print_error "No file opener found"
                print_info "Install xdg-utils: sudo apt install xdg-utils"
                exit 1
            fi
            ;;

        *)
            print_error "Unsupported operating system: $DF_OS"
            print_info "Supported: macOS, Linux, WSL"
            exit 1
            ;;
    esac
done

exit 0
