#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Battery Status Utility for macOS
# ============================================================================
#
# A beautiful battery monitoring utility that provides battery level,
# charging status, and remaining time with support for multiple output
# formats (ANSI, Kitty, tmux).
#
# Features:
#   - Multiple output formats (ANSI, Kitty, tmux)
#   - Battery icons with charging indicators
#   - Customizable danger threshold
#   - OneDark color scheme integration
#   - Time remaining estimates
#
# Usage:
#   battery [options]
#
# Options:
#   --numeric          Show battery percentage only (no formatting)
#   --ansi             Show battery with ANSI color formatting
#   --kitty            Show battery with Kitty terminal icon
#   --tmux             Show battery with tmux formatting
#   -r, --remain       Show time remaining estimate
#   -h, --help         Show this help message
#
# Examples:
#   battery            # Show raw percentage
#   battery --ansi     # Colored percentage for terminal
#   battery --kitty    # Icon + percentage for Kitty
#   battery --tmux     # Formatted for tmux status bar
#   battery --remain   # Show time remaining
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
    else
        LIBRARIES_LOADED=false
    fi
else
    # Ultra-minimal fallback if bootstrap library missing
    LIBRARIES_LOADED=false
    DF_DIR="${HOME}/.config/dotfiles"
    print_error() { echo "Error: $1" >&2; }
    print_success() { echo "$1" >&2; }
    print_info() { echo "$1" >&2; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }

    # Basic color definitions
    readonly UI_SUCCESS_COLOR='\033[32m'
    readonly UI_INFO_COLOR='\033[34m'
    readonly UI_ERROR_COLOR='\033[31m'
    readonly UI_WARNING_COLOR='\033[33m'
    readonly COLOR_RESET='\033[0m'
fi

# ============================================================================
# Configuration
# ============================================================================

BATTERY_DANGER=20

# ============================================================================
# Battery Functions
# ============================================================================

# Get current battery load percentage
get_current_load() {
    local current_bat percentage

    if command_exists pmset; then
        current_bat="$(pmset -g ps | grep -o '[0-9]\+%' | tr -d '%')"
    elif command_exists ioreg; then
        local _battery_info _max_cap _cur_cap
        _battery_info="$(ioreg -n AppleSmartBattery)"
        _max_cap="$(echo "$_battery_info" | awk '/MaxCapacity/{print $5}')"
        _cur_cap="$(echo "$_battery_info" | awk '/CurrentCapacity/{print $5}')"
        current_bat="$(awk -v cur="$_cur_cap" -v max="$_max_cap" 'BEGIN{ printf("%.2f\n", cur/max*100) }')"
    fi

    echo "$current_bat"
}

# Get battery percentage (rounded)
get_percentage() {
    local current_load="${1:-$(get_current_load)}"
    local percentage="$(echo "$current_load" | awk '{print int($1+0.5)}')"

    if [[ -n "$percentage" ]]; then
        echo "$percentage"
    fi
}

# Get battery icon based on charge level and charging status
get_icon() {
    local load="${1:-$(get_current_load)}"

    # Battery icons (0-100% in 10% increments)
    local icons=(
        "󰂑"  # 0-10%
        "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑"  # Not charging icons
        "󰂑"  # Charging base
        "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑"  # Charging icons
    )

    local icon_index="$(echo "$load" | awk '{print int($1/10+0.5)}')"

    if is_charging; then
        icon_index=$(($icon_index + 10))
    fi

    echo -e "${icons[$icon_index]}"
}

# Check if battery is currently charging
# Returns: 0 if charging, 1 if not charging
is_charging() {
    if command_exists pmset; then
        pmset -g ps | grep -E "Battery Power|charged" >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            return 1
        else
            return 0
        fi
    elif command_exists ioreg; then
        ioreg -c AppleSmartBattery | grep "IsCharging" | grep "Yes" >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# Format battery for ANSI terminal output with OneDark colors
battery_color_ansi() {
    local percentage="${1:-$(get_percentage)}"

    if is_charging; then
        # Charging: Green (OneDark success color)
        echo -e "${UI_SUCCESS_COLOR}${percentage}%${COLOR_RESET}"
    else
        if [[ "${percentage%%%*}" -ge "$BATTERY_DANGER" ]]; then
            # Normal: Blue (OneDark info color)
            echo -e "${UI_INFO_COLOR}${percentage}%${COLOR_RESET}"
        else
            # Low battery: Red (OneDark error color)
            echo -e "${UI_ERROR_COLOR}${percentage}%${COLOR_RESET}"
        fi
    fi
}

# Format battery for Kitty terminal with icon
battery_color_kitty() {
    local load="${1:-$(get_current_load)}"
    local percentage="$(get_percentage "$load")"

    echo -e "$(get_icon "$load") ${percentage}%"
}

# Format battery for tmux status bar
battery_color_tmux() {
    local percentage="${1:-$(get_percentage)}"

    if is_charging; then
        # Charging: Green
        echo -e "#[fg=green]$(get_icon) ${percentage}%#[default]"
    else
        if [[ "${percentage%%%*}" -ge "$BATTERY_DANGER" ]]; then
            # Normal: Blue
            echo -e "#[fg=blue]$(get_icon) ${percentage}%#[default]"
        else
            # Low battery: Red
            echo -e "#[fg=red]$(get_icon) ${percentage}%#[default]"
        fi
    fi
}

# Get time remaining estimate
get_remain() {
    local time_remain

    if command_exists pmset; then
        time_remain="$(pmset -g ps | grep -o '[0-9]\+:[0-9]\+')"
        if [[ -z "$time_remain" ]]; then
            time_remain="no estimate"
        fi
    elif command_exists ioreg; then
        local itte
        itte="$(ioreg -n AppleSmartBattery | awk '/InstantTimeToEmpty/{print $5}')"
        time_remain="$(awk -v remain="$itte" 'BEGIN{ printf("%dh%dm\n", remain/60, remain%60) }')"
        if [[ -z "$time_remain" ]] || [[ "${time_remain%%h*}" -gt 10 ]]; then
            time_remain="no estimate"
        fi
    else
        time_remain="no estimate"
    fi

    echo "$time_remain"
    if [[ "$time_remain" = "no estimate" ]]; then
        return 1
    fi
}

# ============================================================================
# Help Function
# ============================================================================

show_help() {
    cat <<EOF
${COLOR_BOLD}${UI_ACCENT_COLOR}Battery Status Utility for macOS${COLOR_RESET}

A beautiful battery monitoring utility with multiple output formats,
charging indicators, and OneDark color scheme integration.

${COLOR_BOLD}${UI_ACCENT_COLOR}USAGE${COLOR_RESET}
    battery [options]

${COLOR_BOLD}${UI_ACCENT_COLOR}OPTIONS${COLOR_RESET}
    --numeric           Show battery percentage only (no formatting)
    --ansi              Show battery with ANSI color formatting
    --kitty             Show battery with Kitty terminal icon
    --tmux              Show battery with tmux status bar formatting
    -r, --remain        Show time remaining estimate
    -h, --help          Show this help message

${COLOR_BOLD}${UI_ACCENT_COLOR}EXAMPLES${COLOR_RESET}
    ${COLOR_DIM}# Show raw percentage${COLOR_RESET}
    battery

    ${COLOR_DIM}# Colored percentage for terminal${COLOR_RESET}
    battery --ansi

    ${COLOR_DIM}# Icon + percentage for Kitty terminal${COLOR_RESET}
    battery --kitty

    ${COLOR_DIM}# Formatted for tmux status bar${COLOR_RESET}
    battery --tmux

    ${COLOR_DIM}# Show time remaining${COLOR_RESET}
    battery --remain

${COLOR_BOLD}${UI_ACCENT_COLOR}TMUX INTEGRATION${COLOR_RESET}
    Add to your tmux.conf status line:
    ${COLOR_DIM}set -g status-right "#(battery --tmux) | %H:%M"${COLOR_RESET}

${COLOR_BOLD}${UI_ACCENT_COLOR}COLOR SCHEME${COLOR_RESET}
    ${UI_SUCCESS_COLOR}Green${COLOR_RESET}   Charging
    ${UI_INFO_COLOR}Blue${COLOR_RESET}    Normal battery level (>${BATTERY_DANGER}%)
    ${UI_ERROR_COLOR}Red${COLOR_RESET}     Low battery (<${BATTERY_DANGER}%)

${COLOR_BOLD}${UI_ACCENT_COLOR}REQUIREMENTS${COLOR_RESET}
    macOS with pmset or ioreg command

${COLOR_BOLD}${UI_ACCENT_COLOR}CONFIGURATION${COLOR_RESET}
    Battery danger threshold: ${BATTERY_DANGER}%
    Edit BATTERY_DANGER variable in script to customize

EOF
}

# ============================================================================
# Argument Parsing
# ============================================================================

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        --numeric)
            get_percentage
            exit $?
            ;;
        --ansi)
            battery_color_ansi "$(get_percentage)"
            exit $?
            ;;
        --kitty)
            battery_color_kitty "$(get_current_load)"
            exit $?
            ;;
        --tmux)
            battery_color_tmux "$(get_percentage)"
            exit $?
            ;;
        -r|--remain)
            get_remain
            exit $?
            ;;
        -*|--*)
            print_error "Unknown option: $arg"
            print_info "Use 'battery --help' for usage information"
            exit 1
            ;;
    esac
done

# Default: show raw percentage
get_current_load
