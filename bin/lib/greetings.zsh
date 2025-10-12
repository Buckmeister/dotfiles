#!/usr/bin/env zsh

# ============================================================================
# International Friend Greetings Library for Dotfiles Scripts
# ============================================================================
#
# A delightful library providing warm, international greetings to make
# dotfiles scripts welcoming to developers from around the world.
#
# Usage:
#   source "$(dirname $0)/lib/greetings.zsh" 2>/dev/null || { ... fallback ... }
#
#   # Get a random greeting
#   greeting=$(get_random_friend_greeting)
#   echo "$greeting"
#
# Features:
# - 20+ languages with beautiful flag emojis
# - Consistent warm, friendly tone across all languages
# - Random selection for variety
# - Fallback greetings for maximum compatibility
# ============================================================================

# Prevent multiple loading
[[ -n "$DOTFILES_GREETINGS_LOADED" ]] && return 0
readonly DOTFILES_GREETINGS_LOADED=1

# ============================================================================
# International Friend Greetings Collection 🌍✨
# ============================================================================

# Comprehensive collection of warm coding greetings from around the world
readonly -a FRIEND_GREETINGS=(
    "🇺🇸 Happy coding, friend!"
    "🇩🇪 Frohes Programmieren, Freund!"
    "🇫🇷 Bon codage, ami!"
    "🇪🇸 ¡Feliz codificación, amigo!"
    "🇮🇹 Buona programmazione, amico!"
    "🇯🇵 ハッピーコーディング、友達！"
    "🇰🇷 즐거운 코딩, 친구!"
    "🇳🇱 Vrolijk coderen, vriend!"
    "🇵🇹 Boa codificação, amigo!"
    "🇷🇺 Счастливого кодирования, друг!"
    "🇨🇳 快乐编程，朋友！"
    "🇮🇳 खुश कोडिंग, दोस्त!"
    "🇧🇷 Boa codificação, amigo!"
    "🇸🇪 Glad kodning, vän!"
    "🇳🇴 Glad koding, venn!"
    "🇩🇰 Glad kodning, ven!"
    "🇫🇮 Iloista koodausta, ystävä!"
    "🇵🇱 Szczęśliwego kodowania, przyjacielu!"
    "🇹🇷 Mutlu kodlama, arkadaş!"
    "🇬🇷 Καλή κωδικοποίηση, φίλε!"
    "🇦🇺 G'day mate, happy coding!"
    "🇨🇦 Happy coding, eh friend!"
    "🇮🇱 קידוד שמח, חבר!"
    "🇦🇷 ¡Feliz codificación, amigo!"
    "🇲🇽 ¡Que tengas buen código, amigo!"
)

# Fallback greetings (ASCII-only, for maximum compatibility)
readonly -a FALLBACK_GREETINGS=(
    "Happy coding, friend!"
    "Great coding, friend!"
    "Wonderful coding, friend!"
    "Excellent coding, friend!"
    "Amazing coding, friend!"
    "Fantastic coding, friend!"
    "Brilliant coding, friend!"
    "Superb coding, friend!"
    "Outstanding coding, friend!"
    "Marvelous coding, friend!"
)

# ============================================================================
# Greeting Generation Functions
# ============================================================================

# Get a random international greeting with flag emoji
function get_random_friend_greeting() {
    local random_index=$(( RANDOM % ${#FRIEND_GREETINGS[@]} + 1 ))
    echo "${FRIEND_GREETINGS[$random_index]}"
}

# Get a random fallback greeting (ASCII-only)
function get_random_fallback_greeting() {
    local random_index=$(( RANDOM % ${#FALLBACK_GREETINGS[@]} + 1 ))
    echo "${FALLBACK_GREETINGS[$random_index]}"
}

# Get an appropriate greeting based on terminal capabilities
function get_smart_greeting() {
    # Check if terminal likely supports Unicode/emojis
    if [[ -n "$LANG" ]] && [[ "$LANG" =~ UTF-8 ]] && [[ "$TERM" != "dumb" ]]; then
        get_random_friend_greeting
    else
        get_random_fallback_greeting
    fi
}

# ============================================================================
# Themed Greeting Collections
# ============================================================================

# Get greeting by language family (for cultural themes)
function get_greeting_by_region() {
    local region="$1"

    case "$region" in
        "europe"|"european")
            local european_greetings=(
                "🇩🇪 Frohes Programmieren, Freund!"
                "🇫🇷 Bon codage, ami!"
                "🇪🇸 ¡Feliz codificación, amigo!"
                "🇮🇹 Buona programmazione, amico!"
                "🇳🇱 Vrolijk coderen, vriend!"
                "🇸🇪 Glad kodning, vän!"
                "🇳🇴 Glad koding, venn!"
                "🇩🇰 Glad kodning, ven!"
                "🇫🇮 Iloista koodausta, ystävä!"
                "🇵🇱 Szczęśliwego kodowania, przyjacielu!"
                "🇬🇷 Καλή κωδικοποίηση, φίλε!"
            )
            local random_index=$(( RANDOM % ${#european_greetings[@]} + 1 ))
            echo "${european_greetings[$random_index]}"
            ;;
        "asia"|"asian")
            local asian_greetings=(
                "🇯🇵 ハッピーコーディング、友達！"
                "🇰🇷 즐거운 코딩, 친구!"
                "🇨🇳 快乐编程，朋友！"
                "🇮🇳 खुश कोडिंग, दोस्त!"
                "🇹🇷 Mutlu kodlama, arkadaş!"
            )
            local random_index=$(( RANDOM % ${#asian_greetings[@]} + 1 ))
            echo "${asian_greetings[$random_index]}"
            ;;
        "americas"|"american")
            local american_greetings=(
                "🇺🇸 Happy coding, friend!"
                "🇧🇷 Boa codificação, amigo!"
                "🇦🇷 ¡Feliz codificación, amigo!"
                "🇲🇽 ¡Que tengas buen código, amigo!"
                "🇨🇦 Happy coding, eh friend!"
            )
            local random_index=$(( RANDOM % ${#american_greetings[@]} + 1 ))
            echo "${american_greetings[$random_index]}"
            ;;
        *)
            get_random_friend_greeting
            ;;
    esac
}

# ============================================================================
# Special Occasion Greetings
# ============================================================================

# Get time-appropriate greeting
function get_time_greeting() {
    local hour=$(date +%H)
    local base_greeting=$(get_random_friend_greeting)

    # Modify greeting based on time of day
    if [[ $hour -ge 5 && $hour -lt 12 ]]; then
        echo "🌅 Good morning! $base_greeting"
    elif [[ $hour -ge 12 && $hour -lt 17 ]]; then
        echo "☀️ Good afternoon! $base_greeting"
    elif [[ $hour -ge 17 && $hour -lt 22 ]]; then
        echo "🌆 Good evening! $base_greeting"
    else
        echo "🌙 Good night! $base_greeting"
    fi
}

# Get seasonal greeting (basic implementation)
function get_seasonal_greeting() {
    local month=$(date +%m)
    local base_greeting=$(get_random_friend_greeting)

    case "$month" in
        12|01|02) echo "❄️ Winter coding vibes! $base_greeting" ;;
        03|04|05) echo "🌸 Spring coding energy! $base_greeting" ;;
        06|07|08) echo "☀️ Summer coding fun! $base_greeting" ;;
        09|10|11) echo "🍂 Autumn coding spirit! $base_greeting" ;;
        *) echo "$base_greeting" ;;
    esac
}

# ============================================================================
# Greeting Display Functions
# ============================================================================

# Display greeting with color if colors library is available
function display_greeting() {
    local greeting="${1:-$(get_smart_greeting)}"

    # Check if colors are available
    if [[ -n "$DOTFILES_COLORS_LOADED" ]] && [[ -n "$UI_ACCENT_COLOR" ]]; then
        printf "${UI_ACCENT_COLOR}${greeting}${COLOR_RESET}\n"
    else
        echo "$greeting"
    fi
}

# Display greeting with a decorative border
function display_greeting_with_border() {
    local greeting="${1:-$(get_smart_greeting)}"
    local width=$((${#greeting} + 4))

    # Top border
    printf "┌"
    printf "%*s" $((width - 2)) | tr ' ' '─'
    printf "┐\n"

    # Greeting line
    printf "│ %s │\n" "$greeting"

    # Bottom border
    printf "└"
    printf "%*s" $((width - 2)) | tr ' ' '─'
    printf "┘\n"
}

# ============================================================================
# Utility Functions
# ============================================================================

# Get total number of available greetings
function get_greeting_count() {
    echo ${#FRIEND_GREETINGS[@]}
}

# List all available greetings (for testing/debugging)
function list_all_greetings() {
    local include_numbers="${1:-false}"

    if [[ "$include_numbers" == "true" ]]; then
        for ((i=1; i<=${#FRIEND_GREETINGS[@]}; i++)); do
            printf "%2d. %s\n" $i "${FRIEND_GREETINGS[$i]}"
        done
    else
        printf "%s\n" "${FRIEND_GREETINGS[@]}"
    fi
}

# Test greeting display (shows 5 random greetings)
function test_greetings() {
    echo "Testing international greetings system:"
    echo "======================================"
    echo

    for ((i=1; i<=5; i++)); do
        printf "%d. " $i
        display_greeting
    done

    echo
    echo "Total greetings available: $(get_greeting_count)"
}

# ============================================================================
# Export Functions
# ============================================================================

# Export all greeting functions for use in sourcing scripts (suppress output)
{
    typeset -fx get_random_friend_greeting get_random_fallback_greeting get_smart_greeting
    typeset -fx get_greeting_by_region get_time_greeting get_seasonal_greeting
    typeset -fx display_greeting display_greeting_with_border
    typeset -fx get_greeting_count list_all_greetings test_greetings
} >/dev/null 2>&1