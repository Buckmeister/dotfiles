#!/usr/bin/env zsh

# ============================================================================
# Shared UI Components Library for Dotfiles Scripts
# ============================================================================
#
# A comprehensive UI library providing progress bars, status displays,
# headers, and terminal control functions for consistent user experience.
#
# Usage:
#   source "$(dirname $0)/lib/colors.zsh" 2>/dev/null || { ... fallback ... }
#   source "$(dirname $0)/lib/ui.zsh" 2>/dev/null || { ... fallback ... }
#
# Features:
# - Beautiful progress bars with customizable width and styling
# - Professional status displays with phase tracking
# - Elegant headers and box drawing
# - Terminal control and cursor management
# - Message printing with automatic color handling
# ============================================================================

# Prevent multiple loading
[[ -n "$DOTFILES_UI_LOADED" ]] && return 0
readonly DOTFILES_UI_LOADED=1

# Ensure colors are loaded (dependency)
if [[ -z "$DOTFILES_COLORS_LOADED" ]]; then
    local lib_dir="$(dirname "${(%):-%N}")"
    source "$lib_dir/colors.zsh" 2>/dev/null || {
        echo "Warning: Could not load colors.zsh library" >&2
        return 1
    }
fi

# ============================================================================
# Terminal Control Functions
# ============================================================================

# Hide terminal cursor
function hide_cursor() {
    printf "$CURSOR_HIDE"
}

# Show terminal cursor
function show_cursor() {
    printf "$CURSOR_SHOW"
}

# Clear entire screen and move to home
function clear_screen() {
    printf "$CLEAR_SCREEN$CURSOR_HOME"
}

# Clear current line
function clear_line() {
    printf "$CLEAR_LINE"
}

# Move cursor to specific line
function move_cursor_to_line() {
    local line=$1
    printf "\033[${line};1H"
}

# Move cursor to specific position
function move_cursor_to() {
    local line=$1
    local column=$2
    printf "\033[${line};${column}H"
}

# Save current cursor position
function save_cursor() {
    printf "$SAVE_CURSOR"
}

# Restore saved cursor position
function restore_cursor() {
    printf "$RESTORE_CURSOR"
}

# ============================================================================
# Message Display Functions
# ============================================================================

# Display a colored message with automatic color reset
function print_colored_message() {
    local color="$1"
    local message="$2"
    printf "${color}${message}${COLOR_RESET}"
}

# Display a status message with emoji and color
function print_status_message() {
    local color="$1"
    local emoji="$2"
    local message="$3"
    print_colored_message "$color" "${emoji} ${message}\n"
}

# Print message with semantic color
function print_success() {
    local message="$1"
    print_status_message "$UI_SUCCESS_COLOR" "✅" "$message"
}

function print_warning() {
    local message="$1"
    print_status_message "$UI_WARNING_COLOR" "⚠️" "$message"
}

function print_error() {
    local message="$1"
    print_status_message "$UI_ERROR_COLOR" "❌" "$message"
}

function print_info() {
    local message="$1"
    print_status_message "$UI_INFO_COLOR" "ℹ️" "$message"
}

# ============================================================================
# Text Width Calculation Functions
# ============================================================================

# Calculate the display width of text (handles emojis and Unicode)
# This function accounts for emoji characters that may display as 2 columns
function get_display_width() {
    local text="$1"

    # Try using wc -m for better Unicode support if available
    if command -v wc >/dev/null 2>&1; then
        # Use printf to avoid newline, then count display columns
        # This is a heuristic approach since perfect emoji width detection
        # requires complex Unicode databases
        local char_count=$(printf "%s" "$text" | wc -m 2>/dev/null | tr -d ' ')

        # Estimate emoji count (very basic heuristic)
        # Count common emoji ranges (this is simplified but covers most cases)
        local emoji_pattern='[🀀-🫿]'
        local emoji_count=0

        # Use grep to count emoji-like characters if available
        if command -v grep >/dev/null 2>&1; then
            emoji_count=$(printf "%s" "$text" | grep -o "$emoji_pattern" 2>/dev/null | wc -l 2>/dev/null | tr -d ' ' || echo "0")
        fi

        # Rough estimate: each emoji takes 2 columns, regular chars take 1
        # This is approximate but works for most common cases
        echo $((char_count + emoji_count))
    else
        # Fallback to simple character count
        echo ${#text}
    fi
}

# Safe display width calculation with fallback
function get_safe_display_width() {
    local text="$1"
    local calculated_width

    # Try the advanced calculation
    calculated_width=$(get_display_width "$text" 2>/dev/null)

    # Fallback to character count if calculation fails
    if [[ -z "$calculated_width" ]] || [[ "$calculated_width" -eq 0 ]]; then
        calculated_width=${#text}
    fi

    echo "$calculated_width"
}

# ============================================================================
# Header and Box Drawing Functions
# ============================================================================

# Draw a beautiful header with box drawing characters
function draw_header() {
    local title="$1"
    local subtitle="${2:-}"
    local width="${3:-78}"

    printf "${COLOR_BOLD}${UI_HEADER_COLOR}"

    # Top border
    printf "╔"
    printf "%*s" $((width - 2)) | tr ' ' '═'
    printf "╗\n"

    # Title line (using display width for proper emoji alignment)
    local title_display_width=$(get_safe_display_width "$title")
    local title_padding=$(( (width - title_display_width - 2) / 2 ))
    printf "║%*s%s%*s║\n" $title_padding "" "$title" $title_padding ""

    # Subtitle line (if provided)
    if [[ -n "$subtitle" ]]; then
        local subtitle_display_width=$(get_safe_display_width "$subtitle")
        local subtitle_padding=$(( (width - subtitle_display_width - 2) / 2 ))
        printf "║%*s%s%*s║\n" $subtitle_padding "" "$subtitle" $subtitle_padding ""
    fi

    # Bottom border
    printf "╚"
    printf "%*s" $((width - 2)) | tr ' ' '═'
    printf "╝\n"

    printf "${COLOR_RESET}\n"
}

# Draw a simple separator line
function draw_separator() {
    local width="${1:-78}"
    local char="${2:-─}"

    printf "${UI_INFO_COLOR}"
    printf "%*s" $width | tr ' ' "$char"
    printf "${COLOR_RESET}\n"
}

# ============================================================================
# Progress Bar System (Optimized for minimal repaints)
# ============================================================================

# Global progress tracking variables (can be overridden by scripts)
typeset -g -i PROGRESS_TOTAL=100
typeset -g -i PROGRESS_CURRENT=0

# Cache for last drawn state (avoid redundant redraws)
typeset -g -i _PROGRESS_LAST_PERCENTAGE=-1
typeset -g -i _PROGRESS_LAST_FILLED=-1
typeset -g -i _PROGRESS_LAST_CURRENT=-1
typeset -g -i _PROGRESS_LAST_TOTAL=-1

# Pre-build character strings for performance (avoid tr subprocess overhead)
typeset -g _PROGRESS_FILLED_CACHE=""
typeset -g _PROGRESS_EMPTY_CACHE=""
typeset -g -i _PROGRESS_CACHE_WIDTH=0

# Build filled/empty character strings (called once per width)
function _build_progress_chars() {
    local width=$1
    local filled_char="${2:-█}"
    local empty_char="${3:-░}"

    # Only rebuild if width changed
    if [[ $width -ne $_PROGRESS_CACHE_WIDTH ]]; then
        _PROGRESS_FILLED_CACHE=""
        _PROGRESS_EMPTY_CACHE=""

        # Build strings directly without subprocess
        for ((i=0; i<width; i++)); do
            _PROGRESS_FILLED_CACHE="${_PROGRESS_FILLED_CACHE}${filled_char}"
            _PROGRESS_EMPTY_CACHE="${_PROGRESS_EMPTY_CACHE}${empty_char}"
        done

        _PROGRESS_CACHE_WIDTH=$width
    fi
}

# Draw a beautiful progress bar (optimized version)
function draw_progress_bar() {
    local current="${1:-$PROGRESS_CURRENT}"
    local total="${2:-$PROGRESS_TOTAL}"
    local width="${3:-50}"
    local filled_char="${4:-█}"
    local empty_char="${5:-░}"

    # Safety checks
    [[ $current -lt 0 ]] && current=0
    [[ $total -le 0 ]] && total=1
    [[ $current -gt $total ]] && current=$total

    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    # Additional safety check for width
    [[ $filled -gt $width ]] && { filled=$width; empty=0; }
    [[ $filled -lt 0 ]] && { filled=0; empty=$width; }

    # Build character cache if needed
    _build_progress_chars $width "$filled_char" "$empty_char"

    # Use substring operations instead of tr (much faster - no subprocess)
    local filled_str="${_PROGRESS_FILLED_CACHE:0:$filled}"
    local empty_str="${_PROGRESS_EMPTY_CACHE:0:$empty}"

    # Single printf call for entire bar (reduces overhead)
    printf "${UI_PROGRESS_COLOR}[%s%s] %3d%% (%d/%d)${COLOR_RESET}" \
        "$filled_str" "$empty_str" $percentage $current $total
}

# Update progress bar with current values (optimized repaint)
function update_progress() {
    local current="$1"
    local total="${2:-$PROGRESS_TOTAL}"
    local width="${3:-50}"

    PROGRESS_CURRENT=$current
    PROGRESS_TOTAL=$total

    # Calculate what changed
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))

    # Skip redraw if nothing visually changed
    if [[ $percentage -eq $_PROGRESS_LAST_PERCENTAGE ]] && \
       [[ $filled -eq $_PROGRESS_LAST_FILLED ]] && \
       [[ $current -eq $_PROGRESS_LAST_CURRENT ]] && \
       [[ $total -eq $_PROGRESS_LAST_TOTAL ]]; then
        return 0
    fi

    # Update cache
    _PROGRESS_LAST_PERCENTAGE=$percentage
    _PROGRESS_LAST_FILLED=$filled
    _PROGRESS_LAST_CURRENT=$current
    _PROGRESS_LAST_TOTAL=$total

    # Efficient redraw: carriage return + overwrite (no clear needed)
    printf "\rProgress: "
    draw_progress_bar $current $total
}

# Increment progress by one step (optimized)
function increment_progress() {
    local increment="${1:-1}"
    PROGRESS_CURRENT=$((PROGRESS_CURRENT + increment))

    # Use optimized update
    update_progress $PROGRESS_CURRENT $PROGRESS_TOTAL
}

# Reset progress bar cache (call when starting new progress sequence)
function reset_progress_cache() {
    _PROGRESS_LAST_PERCENTAGE=-1
    _PROGRESS_LAST_FILLED=-1
    _PROGRESS_LAST_CURRENT=-1
    _PROGRESS_LAST_TOTAL=-1
}

# ============================================================================
# Advanced Status Display System
# ============================================================================

# Display comprehensive status with phase tracking
function update_status_display() {
    local phase_name="$1"
    local operation_name="$2"
    local current="${3:-$PROGRESS_CURRENT}"
    local total="${4:-$PROGRESS_TOTAL}"
    local success_count="${5:-0}"
    local error_count="${6:-0}"
    local line_offset="${7:-7}"

    # Clear the status area and redraw with proper line clearing
    move_cursor_to_line $line_offset

    # Clear each line by overwriting with spaces, then rewrite content
    printf "%-80s\r${COLOR_BOLD}${UI_ACCENT_COLOR}Phase: %-20s${COLOR_RESET}\n" \
        "" "$phase_name"
    printf "%-80s\r${UI_INFO_COLOR}Current: %-40s${COLOR_RESET}\n\n" \
        "" "$operation_name"

    # Draw progress bar with proper clearing
    printf "%-80s\r" ""
    print_colored_message "$UI_PROGRESS_COLOR" "Progress: "
    draw_progress_bar $current $total
    printf "\n\n"

    # Show statistics with proper clearing
    printf "%-80s\r" ""
    printf "${UI_SUCCESS_COLOR}✅ Success: %d${COLOR_RESET}  " $success_count
    printf "${UI_ERROR_COLOR}❌ Errors: %d${COLOR_RESET}\n" $error_count
}

# Simple status display for basic operations
function show_status() {
    local message="$1"
    local type="${2:-info}"

    case "$type" in
        "success") print_success "$message" ;;
        "warning") print_warning "$message" ;;
        "error")   print_error "$message" ;;
        "info"|*) print_info "$message" ;;
    esac
}

# ============================================================================
# Loading and Spinner Functions
# ============================================================================

# Simple spinner animation
function show_spinner() {
    local message="$1"
    local duration="${2:-3}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

    hide_cursor

    for ((i=0; i<duration*10; i++)); do
        local frame=${frames[$((i % ${#frames[@]}))]}
        printf "\r${UI_ACCENT_COLOR}${frame}${COLOR_RESET} ${message}"
        sleep 0.1
    done

    printf "\r${UI_SUCCESS_COLOR}✓${COLOR_RESET} ${message}\n"
    show_cursor
}

# ============================================================================
# Input and Confirmation Functions
# ============================================================================

# Ask for user confirmation with colored prompt
function ask_confirmation() {
    local message="$1"
    local default="${2:-n}"

    local prompt_color="$UI_ACCENT_COLOR"
    local default_display="y/N"
    [[ "$default" == "y" ]] && default_display="Y/n"

    printf "${prompt_color}${message} [${default_display}]: ${COLOR_RESET}"
    read -r response

    case "${response:-$default}" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# ============================================================================
# Layout and Formatting Helpers
# ============================================================================

# Print a centered line of text
function print_centered() {
    local text="$1"
    local width="${2:-80}"
    local color="${3:-$UI_INFO_COLOR}"

    local padding=$(( (width - ${#text}) / 2 ))
    printf "${color}%*s%s%*s${COLOR_RESET}\n" $padding "" "$text" $padding ""
}

# Print text in a box
function print_box() {
    local text="$1"
    local padding="${2:-2}"
    local color="${3:-$UI_INFO_COLOR}"

    local text_width=${#text}
    local box_width=$((text_width + padding * 2 + 2))

    printf "${color}"
    printf "┌%*s┐\n" $((box_width - 2)) | tr ' ' '─'
    printf "│%*s%s%*s│\n" $padding "" "$text" $padding ""
    printf "└%*s┘\n" $((box_width - 2)) | tr ' ' '─'
    printf "${COLOR_RESET}"
}

# ============================================================================
# Cleanup and Safety Functions
# ============================================================================

# Ensure cursor is shown and screen state is clean on exit
function cleanup_ui() {
    show_cursor
    printf "\n${COLOR_RESET}"
}

# Set up proper cleanup on script exit
function setup_ui_cleanup() {
    trap cleanup_ui EXIT INT TERM
}

# ============================================================================
# Export Functions
# ============================================================================

# Export all UI functions for use in sourcing scripts (suppress output)
{
    typeset -fx hide_cursor show_cursor clear_screen clear_line
    typeset -fx move_cursor_to_line move_cursor_to save_cursor restore_cursor
    typeset -fx print_colored_message print_status_message
    typeset -fx print_success print_warning print_error print_info
    typeset -fx get_display_width get_safe_display_width
    typeset -fx draw_header draw_separator draw_progress_bar
    typeset -fx update_progress increment_progress reset_progress_cache update_status_display show_status
    typeset -fx show_spinner ask_confirmation print_centered print_box
    typeset -fx cleanup_ui setup_ui_cleanup
} >/dev/null 2>&1