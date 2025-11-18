#!/usr/bin/env zsh

# ============================================================================
# Hierarchical Menu Engine - Core Rendering & Data Structures
# ============================================================================
#
# A reusable menu engine that supports hierarchical navigation with submenus.
# Provides core data structures and rendering functions for building complex
# menu systems with keyboard navigation and anti-flicker updates.
#
# Dependencies: colors.zsh, ui.zsh, utils.zsh
# ============================================================================

# Note: emulate -LR zsh removed - this library is sourced by scripts that already have it.
# The caller's emulate directive applies to the entire execution context, making it
# redundant here. Removing it prevents potential array scoping issues in subshells.

# ============================================================================
# Menu Data Structure Design
# ============================================================================
#
# Hierarchical menus are defined using nested associative arrays:
#
# typeset -A menu_definition=(
#     [id]="main_menu"                  # Unique identifier
#     [title]="Main Menu"               # Display title
#     [type]="category"                 # Type: category, submenu, action, multi-select
#     [icon]="🏠"                        # Display icon (optional)
#     [description]="Main navigation"   # Description text
# )
#
# Menu items are stored as parallel arrays (compatible with existing approach):
# - menu_items[]        - Item titles
# - menu_descriptions[] - Item descriptions
# - menu_commands[]     - Commands to execute (for action items)
# - menu_types[]        - Item types (submenu, action, button, control, separator)
# - menu_icons[]        - Item icons
# - menu_ids[]          - Item unique IDs (for submenu references)
# - menu_selected[]     - Selection state (for multi-select items)
#
# ============================================================================

# ============================================================================
# Menu Type Constants
# ============================================================================

typeset -gr MENU_TYPE_CATEGORY="category"      # Top-level category (navigable)
typeset -gr MENU_TYPE_SUBMENU="submenu"        # Submenu (navigable)
typeset -gr MENU_TYPE_ACTION="action"          # Executable action item
typeset -gr MENU_TYPE_MULTI_SELECT="multi"     # Multi-selectable action

# ============================================================================
# Debug Logging System
# ============================================================================

# Debug mode can be enabled by setting MENU_DEBUG_MODE=true
# Debug output goes to MENU_DEBUG_LOG (default: /tmp/menu_debug.log)
MENU_DEBUG_MODE="${MENU_DEBUG_MODE:-false}"
MENU_DEBUG_LOG="${MENU_DEBUG_LOG:-/tmp/menu_debug.log}"

# Initialize debug log (clear on first use)
if [[ "$MENU_DEBUG_MODE" == "true" && ! -f "${MENU_DEBUG_LOG}.initialized" ]]; then
    > "$MENU_DEBUG_LOG"
    touch "${MENU_DEBUG_LOG}.initialized"
fi

# Debug logging function
function debug_log() {
    [[ "$MENU_DEBUG_MODE" != "true" ]] && return 0

    local timestamp=$(date '+%H:%M:%S.%3N' 2>/dev/null || date '+%H:%M:%S')
    local func_name="${funcstack[2]:-unknown}"
    local message="$1"

    echo "[$timestamp] ${func_name}: $message" >> "$MENU_DEBUG_LOG"
}
typeset -gr MENU_TYPE_BUTTON="button"          # Action button (non-selectable)
typeset -gr MENU_TYPE_CONTROL="control"        # Control button (non-selectable)
typeset -gr MENU_TYPE_SEPARATOR="separator"    # Visual separator
typeset -gr MENU_TYPE_BACK="back"              # Back/return to parent menu

# ============================================================================
# Menu Item Arrays (Parallel Array Architecture)
# ============================================================================

# Core menu item data (parallel arrays)
typeset -ga MENU_ITEMS=()           # Item titles
typeset -ga MENU_DESCRIPTIONS=()    # Item descriptions
typeset -ga MENU_COMMANDS=()        # Commands to execute
typeset -ga MENU_TYPES=()           # Item types
typeset -ga MENU_ICONS=()           # Item icons
typeset -ga MENU_IDS=()             # Unique IDs (for submenu references)
typeset -ga MENU_SELECTED=()        # Selection state (true/false)

# Menu display state
typeset -gi MENU_CURRENT_ITEM=0     # Current cursor position (0-indexed)
typeset -gi MENU_TOTAL_ITEMS=0      # Total number of items

# ============================================================================
# Menu Engine Functions - Item Management
# ============================================================================

# Add a menu item to the current menu
# Args: title, description, type, [command], [icon], [id]
# Returns: 0 on success, 1 on error
function menu_engine_add_item() {
    local title="$1"
    local description="$2"
    local type="$3"
    local command="${4:-}"
    local icon="${5:-}"
    local id="${6:-}"

    # Input validation (separators are exempt from title/description requirements)
    if [[ "$type" != "$MENU_TYPE_SEPARATOR" ]]; then
        if [[ -z "$title" ]]; then
            print_error "menu_engine_add_item: title cannot be empty"
            return 1
        fi
        if [[ -z "$description" ]]; then
            print_error "menu_engine_add_item: description cannot be empty"
            return 1
        fi
    fi
    if [[ -z "$type" ]]; then
        print_error "menu_engine_add_item: type cannot be empty"
        return 1
    fi

    # Add to parallel arrays
    MENU_ITEMS+=("$title")
    MENU_DESCRIPTIONS+=("$description")
    MENU_COMMANDS+=("$command")
    MENU_TYPES+=("$type")
    MENU_ICONS+=("$icon")
    MENU_IDS+=("$id")
    MENU_SELECTED+=(false)

    ((MENU_TOTAL_ITEMS++))
    return 0
}

# Clear all menu items (reset for new menu)
function menu_engine_clear_items() {
    MENU_ITEMS=()
    MENU_DESCRIPTIONS=()
    MENU_COMMANDS=()
    MENU_TYPES=()
    MENU_ICONS=()
    MENU_IDS=()
    MENU_SELECTED=()
    MENU_CURRENT_ITEM=0
    MENU_TOTAL_ITEMS=0
}

# Initialize cursor to first non-separator item
# Call this after building a menu to ensure cursor starts on a valid item
function menu_engine_init_cursor() {
    debug_log "START total_items=$MENU_TOTAL_ITEMS"
    MENU_CURRENT_ITEM=0

    # Find first non-separator item
    local i
    for ((i=0; i<MENU_TOTAL_ITEMS; i++)); do
        local index=$((i + 1))
        local type="${MENU_TYPES[$index]}"

        if [[ "$type" != "$MENU_TYPE_SEPARATOR" ]]; then
            MENU_CURRENT_ITEM=$i
            local item_title="${MENU_ITEMS[$index]}"
            debug_log "END cursor=$MENU_CURRENT_ITEM item='$item_title'"
            return 0
        fi
    done

    # Fallback: if all items are separators (shouldn't happen), stay at 0
    MENU_CURRENT_ITEM=0
    debug_log "END cursor=0 (all items are separators - shouldn't happen)"
    return 1
}

# Validate menu item index
# Args: index (int) - 1-based index
# Returns: 0 if valid, 1 if invalid
function menu_engine_validate_index() {
    local index=$1
    [[ $index -ge 1 && $index -le $MENU_TOTAL_ITEMS ]]
}

# Get menu item property by index
# Args: index (int), property (string) - title, description, command, type, icon, id, selected
# Returns: property value on stdout
function menu_engine_get_item_property() {
    local index=$1
    local property="$2"

    if ! menu_engine_validate_index "$index"; then
        return 1
    fi

    case "$property" in
        title)       echo "${MENU_ITEMS[$index]}" ;;
        description) echo "${MENU_DESCRIPTIONS[$index]}" ;;
        command)     echo "${MENU_COMMANDS[$index]}" ;;
        type)        echo "${MENU_TYPES[$index]}" ;;
        icon)        echo "${MENU_ICONS[$index]}" ;;
        id)          echo "${MENU_IDS[$index]}" ;;
        selected)    echo "${MENU_SELECTED[$index]}" ;;
        *)           return 1 ;;
    esac
}

# Toggle selection state of a menu item
# Args: index (int) - 1-based index
function menu_engine_toggle_selection() {
    local index=$1

    if ! menu_engine_validate_index "$index"; then
        return 1
    fi

    if [[ "${MENU_SELECTED[$index]}" == "true" ]]; then
        MENU_SELECTED[$index]="false"
    else
        MENU_SELECTED[$index]="true"
    fi
}

# ============================================================================
# Menu Engine Functions - Rendering
# ============================================================================

# Get the color for a menu item based on its type and state
# Args: type (string), is_selected (bool)
# Returns: color code on stdout
function menu_engine_get_item_color() {
    local type="$1"
    local is_selected="${2:-false}"

    # Use selected color if item is selected
    if [[ "$is_selected" == "true" ]]; then
        echo "$ITEM_SELECTED_COLOR"
        return
    fi

    # Otherwise, use type-specific colors
    case "$type" in
        "$MENU_TYPE_CATEGORY")
            echo "$UI_ACCENT_COLOR"
            ;;
        "$MENU_TYPE_SUBMENU")
            echo "$UI_PROGRESS_COLOR"
            ;;
        "$MENU_TYPE_ACTION"|"$MENU_TYPE_MULTI_SELECT")
            echo "$ITEM_DEFAULT_COLOR"
            ;;
        "$MENU_TYPE_BUTTON")
            echo "$ITEM_ACTION_COLOR"
            ;;
        "$MENU_TYPE_CONTROL")
            echo "$ITEM_CONTROL_COLOR"
            ;;
        "$MENU_TYPE_BACK")
            echo "$UI_WARNING_COLOR"
            ;;
        "$MENU_TYPE_SEPARATOR")
            echo "$UI_INFO_COLOR"
            ;;
        *)
            echo "$ITEM_DEFAULT_COLOR"
            ;;
    esac
}

# Get the checkbox/icon for a menu item based on its type and selection
# Args: type (string), is_selected (bool), custom_icon (string)
# Returns: checkbox/icon on stdout
function menu_engine_get_item_checkbox() {
    local type="$1"
    local is_selected="${2:-false}"
    local custom_icon="${3:-}"

    # Use custom icon if provided
    if [[ -n "$custom_icon" ]]; then
        if [[ "$is_selected" == "true" ]]; then
            echo "${custom_icon}✓"
        else
            echo "${custom_icon} "
        fi
        return
    fi

    # Otherwise, use type-specific icons
    case "$type" in
        "$MENU_TYPE_CATEGORY")
            echo "📂 "
            ;;
        "$MENU_TYPE_SUBMENU")
            echo "📁 "
            ;;
        "$MENU_TYPE_MULTI_SELECT")
            if [[ "$is_selected" == "true" ]]; then
                echo "☑️ "
            else
                echo "☐ "
            fi
            ;;
        "$MENU_TYPE_ACTION")
            echo "▸ "
            ;;
        "$MENU_TYPE_BUTTON")
            echo "⚡ "
            ;;
        "$MENU_TYPE_CONTROL")
            echo "🎛️ "
            ;;
        "$MENU_TYPE_BACK")
            echo "◂ "
            ;;
        "$MENU_TYPE_SEPARATOR")
            echo "───"
            ;;
        *)
            echo "  "
            ;;
    esac
}

# Draw a single menu item with appropriate styling
# Args: index (int) - 1-based index, is_current (bool)
# Returns: 0 on success, 1 on error
function menu_engine_draw_item() {
    local index=$1
    local is_current=${2:-0}

    if ! menu_engine_validate_index "$index"; then
        print_error "menu_engine_draw_item: invalid index $index"
        return 1
    fi

    local title="${MENU_ITEMS[$index]}"
    local description="${MENU_DESCRIPTIONS[$index]}"
    local type="${MENU_TYPES[$index]}"
    local icon="${MENU_ICONS[$index]}"
    local is_selected="${MENU_SELECTED[$index]}"

    # Handle separator specially
    if [[ "$type" == "$MENU_TYPE_SEPARATOR" ]]; then
        printf "${UI_INFO_COLOR}   ────────────────────────────────────────────────${COLOR_RESET}\n"
        return 0
    fi

    # Determine display elements
    local prefix="   "
    local checkbox=$(menu_engine_get_item_checkbox "$type" "$is_selected" "$icon")
    local color=$(menu_engine_get_item_color "$type" "$is_selected")
    local bg=""

    # Highlight current item
    if [[ $is_current -eq 1 ]]; then
        bg="$UI_SELECTION_BG"
        color="$UI_CURRENT_SELECTION"
        prefix=">>>"
    fi

    # Render the menu item
    printf "${bg}${color}%s %s %-30s %s${COLOR_RESET}\n" \
           "$prefix" "$checkbox" "$title" "$description"

    return 0
}

# Draw complete menu (header + all items)
# Args: menu_title (string), menu_subtitle (string)
function menu_engine_draw_complete_menu() {
    local menu_title="${1:-Dotfiles Management System}"
    local menu_subtitle="${2:-Interactive Menu}"

    clear_screen
    draw_header "$menu_title" "$menu_subtitle"

    printf "${UI_INFO_COLOR}Navigation: ↑/↓ or j/k = up/down  Space = select  Enter = execute  ESC/h/← = back  q = quit${COLOR_RESET}\n"
    printf "${UI_ACCENT_COLOR}Shortcuts:  l = librarian  b = backup  a = (de)select all  x = execute  ? = help${COLOR_RESET}\n"
    printf "\n"

    # Draw all menu items
    local i
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local is_current=0
        [[ $i -eq $((MENU_CURRENT_ITEM + 1)) ]] && is_current=1
        menu_engine_draw_item $i $is_current
    done

    printf "\n"

    # Show selected count for multi-select menus
    local selected_count=0
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        [[ "${MENU_SELECTED[$i]}" == "true" ]] && ((selected_count++))
    done

    if [[ $selected_count -gt 0 ]]; then
        printf "${UI_SUCCESS_COLOR}📊 $selected_count item(s) selected${COLOR_RESET}\n"
    fi
}

# ============================================================================
# Menu Engine Functions - Navigation Helpers
# ============================================================================

# Move cursor up in menu (skipping separators)
function menu_engine_move_up() {
    local start_cursor=$MENU_CURRENT_ITEM
    local attempts=0
    local max_attempts=$MENU_TOTAL_ITEMS

    debug_log "START cursor=$start_cursor total=$MENU_TOTAL_ITEMS"

    while [[ $attempts -lt $max_attempts ]]; do
        ((MENU_CURRENT_ITEM--))
        [[ $MENU_CURRENT_ITEM -lt 0 ]] && MENU_CURRENT_ITEM=$((MENU_TOTAL_ITEMS - 1))

        # Check if current item is a separator
        local index=$((MENU_CURRENT_ITEM + 1))
        local type="${MENU_TYPES[$index]}"

        # If not a separator, we're done
        if [[ "$type" != "$MENU_TYPE_SEPARATOR" ]]; then
            local item_title="${MENU_ITEMS[$index]}"
            debug_log "END cursor=$MENU_CURRENT_ITEM (moved from $start_cursor) item='$item_title' attempts=$attempts"
            break
        fi

        debug_log "SKIP cursor=$MENU_CURRENT_ITEM (separator) attempt=$attempts"
        ((attempts++))
    done
}

# Move cursor down in menu (skipping separators)
function menu_engine_move_down() {
    local start_cursor=$MENU_CURRENT_ITEM
    local attempts=0
    local max_attempts=$MENU_TOTAL_ITEMS

    debug_log "START cursor=$start_cursor total=$MENU_TOTAL_ITEMS"

    while [[ $attempts -lt $max_attempts ]]; do
        ((MENU_CURRENT_ITEM++))
        [[ $MENU_CURRENT_ITEM -ge $MENU_TOTAL_ITEMS ]] && MENU_CURRENT_ITEM=0

        # Check if current item is a separator
        local index=$((MENU_CURRENT_ITEM + 1))
        local type="${MENU_TYPES[$index]}"

        # If not a separator, we're done
        if [[ "$type" != "$MENU_TYPE_SEPARATOR" ]]; then
            local item_title="${MENU_ITEMS[$index]}"
            debug_log "END cursor=$MENU_CURRENT_ITEM (moved from $start_cursor) item='$item_title' attempts=$attempts"
            break
        fi

        debug_log "SKIP cursor=$MENU_CURRENT_ITEM (separator) attempt=$attempts"
        ((attempts++))
    done
}

# Get current item's type
# Returns: current item type on stdout
function menu_engine_get_current_type() {
    local index=$((MENU_CURRENT_ITEM + 1))
    if menu_engine_validate_index "$index"; then
        echo "${MENU_TYPES[$index]}"
    fi
}

# Get current item's ID
# Returns: current item ID on stdout
function menu_engine_get_current_id() {
    local index=$((MENU_CURRENT_ITEM + 1))
    if menu_engine_validate_index "$index"; then
        echo "${MENU_IDS[$index]}"
    fi
}

# Get current item's command
# Returns: current item command on stdout
function menu_engine_get_current_command() {
    local index=$((MENU_CURRENT_ITEM + 1))
    if menu_engine_validate_index "$index"; then
        echo "${MENU_COMMANDS[$index]}"
    fi
}

# Check if item is navigable (submenu or category)
# Args: type (string)
# Returns: 0 if navigable, 1 if not
function menu_engine_is_navigable() {
    local type="$1"
    [[ "$type" == "$MENU_TYPE_CATEGORY" || "$type" == "$MENU_TYPE_SUBMENU" ]]
}

# Check if item is selectable (multi-select)
# Args: type (string)
# Returns: 0 if selectable, 1 if not
function menu_engine_is_selectable() {
    local type="$1"
    [[ "$type" == "$MENU_TYPE_MULTI_SELECT" ]]
}

# Check if item is executable (action or button)
# Args: type (string)
# Returns: 0 if executable, 1 if not
function menu_engine_is_executable() {
    local type="$1"
    [[ "$type" == "$MENU_TYPE_ACTION" || "$type" == "$MENU_TYPE_BUTTON" ]]
}

# ============================================================================
# Menu Engine Functions - Utility
# ============================================================================

# Count selected items in current menu
# Returns: count of selected items
function menu_engine_count_selected() {
    local count=0
    local i
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        [[ "${MENU_SELECTED[$i]}" == "true" ]] && ((count++))
    done
    echo $count
}

# Select all multi-selectable items
function menu_engine_select_all() {
    local i
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local type="${MENU_TYPES[$i]}"
        if menu_engine_is_selectable "$type"; then
            MENU_SELECTED[$i]="true"
        fi
    done
}

# Deselect all items
function menu_engine_deselect_all() {
    local i
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        MENU_SELECTED[$i]="false"
    done
}

# Toggle all selectable items (select if any unselected, deselect if all selected)
function menu_engine_toggle_all() {
    local all_selected=true
    local i

    # Check if all selectable items are selected
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local type="${MENU_TYPES[$i]}"
        if menu_engine_is_selectable "$type" && [[ "${MENU_SELECTED[$i]}" != "true" ]]; then
            all_selected=false
            break
        fi
    done

    # Toggle based on current state
    if [[ "$all_selected" == "true" ]]; then
        menu_engine_deselect_all
    else
        menu_engine_select_all
    fi
}

# Get list of selected item indices
# Returns: space-separated list of 1-based indices
function menu_engine_get_selected_indices() {
    local indices=()
    local i
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        if [[ "${MENU_SELECTED[$i]}" == "true" ]]; then
            indices+=($i)
        fi
    done
    echo "${indices[@]}"
}

# Export functions for use in other scripts
autoload -U menu_engine_add_item
autoload -U menu_engine_clear_items
autoload -U menu_engine_validate_index
autoload -U menu_engine_get_item_property
autoload -U menu_engine_toggle_selection
autoload -U menu_engine_get_item_color
autoload -U menu_engine_get_item_checkbox
autoload -U menu_engine_draw_item
autoload -U menu_engine_draw_complete_menu
autoload -U menu_engine_move_up
autoload -U menu_engine_move_down
autoload -U menu_engine_get_current_type
autoload -U menu_engine_get_current_id
autoload -U menu_engine_get_current_command
autoload -U menu_engine_is_navigable
autoload -U menu_engine_is_selectable
autoload -U menu_engine_is_executable
autoload -U menu_engine_count_selected
autoload -U menu_engine_select_all
autoload -U menu_engine_deselect_all
autoload -U menu_engine_toggle_all
autoload -U menu_engine_get_selected_indices
