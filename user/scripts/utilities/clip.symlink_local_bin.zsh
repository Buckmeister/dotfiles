#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# clip - Cross-Platform Clipboard Utility
# ============================================================================
#
# Universal clipboard utility that adapts to your operating system:
# - macOS: Uses pbcopy/pbpaste
# - Linux: Uses xclip or xsel
# - WSL: Uses Windows clip.exe and PowerShell Get-Clipboard
#
# Perfect for copying command output to clipboard and pasting clipboard
# content into terminal commands.
#
# Usage:
#   echo "text" | clip                    # Copy to clipboard
#   clip                                  # Paste from clipboard
#   clip < file.txt                       # Copy file content
#   cat file.txt | clip                   # Copy via pipe
#   clip > output.txt                     # Paste to file
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
clip - Cross-Platform Clipboard Utility

Universal clipboard utility for copying and pasting across all platforms.

USAGE:
    # Copy to clipboard (reads from stdin)
    <command> | clip
    clip < file.txt

    # Paste from clipboard (writes to stdout)
    clip
    clip > output.txt

OPTIONS:
    -h, --help              Show this help message

EXAMPLES:
    # Copy command output to clipboard
    ls -la | clip

    # Copy file content to clipboard
    clip < README.md
    cat ~/.ssh/id_rsa.pub | clip

    # Paste clipboard content
    clip

    # Paste into file
    clip > notes.txt

    # Copy current directory path
    pwd | clip

    # Copy git status
    git status | clip

    # Chain with other commands
    curl -s https://api.github.com/users/octocat | jq '.login' | clip

BEHAVIOR BY PLATFORM:
    - macOS:  Uses pbcopy/pbpaste
    - Linux:  Uses xclip (primary) or xsel (fallback)
    - WSL:    Uses Windows clip.exe and PowerShell Get-Clipboard

INSTALLATION:
    # Linux: Install xclip (recommended)
    sudo apt install xclip      # Ubuntu/Debian
    sudo dnf install xclip      # Fedora
    sudo pacman -S xclip        # Arch

    # Alternative: xsel
    sudo apt install xsel       # Ubuntu/Debian

    # macOS and WSL: Built-in support, no installation needed

INTEGRATION:
    # Quick alias for copying current path
    alias cpwd='pwd | clip'

    # Copy last command output
    alias clast='fc -ln -1 | clip'

    # SSH key to clipboard
    alias pubkey='cat ~/.ssh/id_rsa.pub | clip'

    # Copy git branch name
    alias cbranch='git branch --show-current | clip'

EOF
}

# ============================================================================
# Parse Arguments
# ============================================================================

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# ============================================================================
# Detect Mode: Copy or Paste
# ============================================================================

# If stdin is a terminal (interactive), we're in paste mode
# If stdin has data (pipe or redirect), we're in copy mode
if [[ -t 0 ]]; then
    MODE="paste"
else
    MODE="copy"
fi

# ============================================================================
# Execute Clipboard Operation
# ============================================================================

case "$DF_OS" in
    darwin|macos)
        # macOS: Use pbcopy/pbpaste
        if [[ "$MODE" == "copy" ]]; then
            if command_exists pbcopy; then
                pbcopy
            else
                print_error "pbcopy not found (macOS clipboard utility)"
                exit 1
            fi
        else
            if command_exists pbpaste; then
                pbpaste
            else
                print_error "pbpaste not found (macOS clipboard utility)"
                exit 1
            fi
        fi
        ;;

    wsl)
        # WSL: Use Windows clipboard utilities
        if [[ "$MODE" == "copy" ]]; then
            # Copy to Windows clipboard via clip.exe
            if command_exists clip.exe; then
                # Remove trailing newline that clip.exe adds
                cat | clip.exe
            else
                print_error "clip.exe not found (Windows clipboard utility)"
                print_info "This should be available by default in WSL"
                exit 1
            fi
        else
            # Paste from Windows clipboard via PowerShell
            if command_exists powershell.exe; then
                # Use PowerShell Get-Clipboard to retrieve text
                # Remove Windows line endings (CRLF -> LF)
                powershell.exe -Command "Get-Clipboard" 2>/dev/null | sed 's/\r$//'
            elif command_exists pwsh.exe; then
                # Try PowerShell Core
                pwsh.exe -Command "Get-Clipboard" 2>/dev/null | sed 's/\r$//'
            else
                print_error "PowerShell not found (required for pasting from Windows clipboard)"
                print_info "Install PowerShell or use Windows Terminal"
                exit 1
            fi
        fi
        ;;

    linux)
        # Linux: Use xclip (preferred) or xsel (fallback)
        if [[ "$MODE" == "copy" ]]; then
            if command_exists xclip; then
                # -selection clipboard uses the standard clipboard (Ctrl+C/Ctrl+V)
                # -selection primary uses the X11 primary selection (middle-click paste)
                xclip -selection clipboard
            elif command_exists xsel; then
                # xsel alternative
                xsel --clipboard --input
            else
                print_error "No clipboard utility found"
                print_info "Install xclip: sudo apt install xclip"
                print_info "Or install xsel: sudo apt install xsel"
                exit 1
            fi
        else
            if command_exists xclip; then
                xclip -selection clipboard -o
            elif command_exists xsel; then
                xsel --clipboard --output
            else
                print_error "No clipboard utility found"
                print_info "Install xclip: sudo apt install xclip"
                print_info "Or install xsel: sudo apt install xsel"
                exit 1
            fi
        fi
        ;;

    *)
        print_error "Unsupported operating system: $DF_OS"
        print_info "Supported: macOS, Linux, WSL"
        exit 1
        ;;
esac

exit 0
