#!/usr/bin/env zsh

# ============================================================================
# Shared OneDark Color Theme Library for Dotfiles Scripts
# ============================================================================
#
# A centralized color theme system providing consistent OneDark theming
# across all dotfiles management scripts.
#
# Usage:
#   source "$(dirname $0)/lib/colors.zsh" 2>/dev/null || {
#       # Fallback: define basic colors inline if library not available
#       readonly COLOR_RESET='\033[0m'
#       # ... other fallback definitions
#   }
#
# Features:
# - Complete OneDark color palette with true color RGB support
# - Semantic color assignments for consistent UI
# - Fallback ANSI colors for older terminals
# - Terminal formatting and cursor control
# ============================================================================

# Prevent multiple loading
[[ -n "$DOTFILES_COLORS_LOADED" ]] && return 0
readonly DOTFILES_COLORS_LOADED=1

# ============================================================================
# Terminal Text Formatting
# ============================================================================

readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_DIM='\033[2m'
readonly COLOR_ITALIC='\033[3m'
readonly COLOR_UNDERLINE='\033[4m'

# ============================================================================
# OneDark Color Palette 🎨
# ============================================================================

# Core OneDark colors (true color RGB support)
readonly ONEDARK_BG='\033[48;2;40;44;52m'           # #282c34 - main background
readonly ONEDARK_FG='\033[38;2;171;178;191m'        # #abb2bf - default text
readonly ONEDARK_BLUE='\033[38;2;97;175;239m'       # #61afef - bright blue
readonly ONEDARK_CYAN='\033[38;2;86;182;194m'       # #56b6c2 - cyan
readonly ONEDARK_GREEN='\033[38;2;152;195;121m'     # #98c379 - green
readonly ONEDARK_PURPLE='\033[38;2;198;120;221m'    # #c678dd - purple/magenta
readonly ONEDARK_RED='\033[38;2;224;108;117m'       # #e06c75 - red
readonly ONEDARK_YELLOW='\033[38;2;229;192;123m'    # #e5c07b - yellow
readonly ONEDARK_ORANGE='\033[38;2;209;154;102m'    # #d19a66 - orange
readonly ONEDARK_GRAY='\033[38;2;92;99;112m'        # #5c6370 - comments/subtle

# Interactive UI backgrounds
readonly ONEDARK_SELECTION='\033[48;2;60;70;85m'    # #3c4653 - selection highlight
readonly ONEDARK_ACCENT='\033[48;2;35;40;50m'       # #232832 - subtle accent

# ============================================================================
# Semantic Color Assignments
# ============================================================================

# Universal UI colors for consistent theming across all scripts
readonly UI_SUCCESS_COLOR="$ONEDARK_GREEN"
readonly UI_WARNING_COLOR="$ONEDARK_YELLOW"
readonly UI_ERROR_COLOR="$ONEDARK_RED"
readonly UI_INFO_COLOR="$ONEDARK_GRAY"
readonly UI_HEADER_COLOR="$ONEDARK_GREEN"
readonly UI_ACCENT_COLOR="$ONEDARK_PURPLE"
readonly UI_PROGRESS_COLOR="$ONEDARK_CYAN"

# Menu-specific colors
readonly UI_CURRENT_SELECTION="$ONEDARK_BLUE$COLOR_BOLD"
readonly UI_SELECTION_BG="$ONEDARK_SELECTION"

# Item type colors (for menus and lists)
readonly ITEM_LINK_COLOR="$ONEDARK_CYAN"
readonly ITEM_CONTROL_COLOR="$ONEDARK_YELLOW"
readonly ITEM_ACTION_COLOR="$ONEDARK_GREEN"
readonly ITEM_LIBRARIAN_COLOR="$ONEDARK_PURPLE"
readonly ITEM_QUIT_COLOR="$ONEDARK_RED"
readonly ITEM_SELECTED_COLOR="$ONEDARK_GREEN"
readonly ITEM_DEFAULT_COLOR="$ONEDARK_FG"

# ============================================================================
# Fallback ANSI Colors (for terminals without true color support)
# ============================================================================

# Basic ANSI foreground colors
readonly COLOR_RED='\033[31m'
readonly COLOR_GREEN='\033[32m'
readonly COLOR_YELLOW='\033[33m'
readonly COLOR_BLUE='\033[34m'
readonly COLOR_MAGENTA='\033[35m'
readonly COLOR_CYAN='\033[36m'
readonly COLOR_WHITE='\033[37m'
readonly COLOR_GRAY='\033[90m'

# Basic ANSI background colors
readonly BG_BLACK='\033[40m'
readonly BG_RED='\033[41m'
readonly BG_GREEN='\033[42m'
readonly BG_YELLOW='\033[43m'
readonly BG_BLUE='\033[44m'
readonly BG_MAGENTA='\033[45m'
readonly BG_CYAN='\033[46m'
readonly BG_WHITE='\033[47m'

# ============================================================================
# Cursor and Terminal Control
# ============================================================================

readonly CURSOR_HIDE='\033[?25l'
readonly CURSOR_SHOW='\033[?25h'
readonly CLEAR_SCREEN='\033[2J'
readonly CURSOR_HOME='\033[H'
readonly CLEAR_LINE='\033[2K'
readonly SAVE_CURSOR='\033[s'
readonly RESTORE_CURSOR='\033[u'

# ============================================================================
# Color Testing and Validation Functions
# ============================================================================

# Test if terminal supports true color (24-bit)
function supports_true_color() {
    [[ -n "$COLORTERM" ]] && [[ "$COLORTERM" =~ (truecolor|24bit) ]] && return 0
    [[ "$TERM" =~ (xterm-256color|screen-256color) ]] && return 0
    [[ -n "$TERM_PROGRAM" ]] && [[ "$TERM_PROGRAM" =~ (iTerm|Terminal) ]] && return 0
    return 1
}

# Get appropriate color for current terminal capabilities
function get_color() {
    local color_name="$1"
    local fallback_color="$2"

    if supports_true_color; then
        case "$color_name" in
            "success")   echo "$UI_SUCCESS_COLOR" ;;
            "warning")   echo "$UI_WARNING_COLOR" ;;
            "error")     echo "$UI_ERROR_COLOR" ;;
            "info")      echo "$UI_INFO_COLOR" ;;
            "header")    echo "$UI_HEADER_COLOR" ;;
            "accent")    echo "$UI_ACCENT_COLOR" ;;
            "progress")  echo "$UI_PROGRESS_COLOR" ;;
            *)           echo "${fallback_color:-$ONEDARK_FG}" ;;
        esac
    else
        # Fallback to ANSI colors
        case "$color_name" in
            "success")   echo "$COLOR_GREEN" ;;
            "warning")   echo "$COLOR_YELLOW" ;;
            "error")     echo "$COLOR_RED" ;;
            "info")      echo "$COLOR_GRAY" ;;
            "header")    echo "$COLOR_GREEN$COLOR_BOLD" ;;
            "accent")    echo "$COLOR_MAGENTA" ;;
            "progress")  echo "$COLOR_CYAN" ;;
            *)           echo "${fallback_color:-$COLOR_WHITE}" ;;
        esac
    fi
}

# ============================================================================
# Color Utility Functions
# ============================================================================

# Apply color to text with automatic reset
function colorize() {
    local color="$1"
    local text="$2"
    printf "${color}${text}${COLOR_RESET}"
}

# Print colored text with newline
function print_color() {
    local color="$1"
    local text="$2"
    printf "${color}${text}${COLOR_RESET}\n"
}

# ============================================================================
# Color Scheme Information
# ============================================================================

# Display color scheme information (for debugging/testing)
function show_color_info() {
    echo "Dotfiles OneDark Color Theme Library"
    echo "====================================="
    echo

    if supports_true_color; then
        echo "✅ True color (24-bit) support detected"
    else
        echo "⚠️  Fallback to ANSI colors (true color not supported)"
    fi

    echo
    echo "Color samples:"
    print_color "$UI_SUCCESS_COLOR" "✅ Success message"
    print_color "$UI_WARNING_COLOR" "⚠️  Warning message"
    print_color "$UI_ERROR_COLOR" "❌ Error message"
    print_color "$UI_INFO_COLOR" "ℹ️  Info message"
    print_color "$UI_HEADER_COLOR" "📦 Header text"
    print_color "$UI_ACCENT_COLOR" "🎨 Accent color"
    print_color "$UI_PROGRESS_COLOR" "📊 Progress indicator"
}

# Export functions for use in sourcing scripts
# Export all color functions for use in sourcing scripts (suppress output)
{
    typeset -fx supports_true_color get_color colorize print_color show_color_info
} >/dev/null 2>&1