#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Interactive TUI Menu System for Dotfiles Management
# ============================================================================
#
# A sophisticated terminal user interface for selecting and executing
# dotfiles operations with keyboard navigation support.
#
# Navigation:
# - ↑/↓ or k/j: Navigate up/down
# - ← /→ or h/l: Navigate left/right (if applicable)
# - Space: Toggle selection
# - Enter: Execute selected items
# - q: Quit
# ============================================================================

# ============================================================================
# Load Shared Libraries (with fallback protection)
# ============================================================================

# Get library directory
LIB_DIR="$(dirname "$(realpath "$0")")/lib"

# Load shared libraries with fallback protection
source "$LIB_DIR/colors.zsh" 2>/dev/null || {
    # Fallback: basic color definitions if library not available
    readonly COLOR_RESET='\033[0m'
    readonly UI_SUCCESS_COLOR='\033[32m'
    readonly UI_WARNING_COLOR='\033[33m'
    readonly UI_ERROR_COLOR='\033[31m'
    readonly UI_INFO_COLOR='\033[90m'
    readonly UI_HEADER_COLOR='\033[32m'
    readonly UI_ACCENT_COLOR='\033[35m'
    readonly UI_PROGRESS_COLOR='\033[36m'
}

source "$LIB_DIR/ui.zsh" 2>/dev/null || {
    # Fallback: basic UI functions if library not available
    function print_success() { echo "✅ $1"; }
    function print_warning() { echo "⚠️ $1"; }
    function print_error() { echo "❌ $1"; }
    function print_info() { echo "ℹ️ $1"; }
    function hide_cursor() { printf '\033[?25l'; }
    function show_cursor() { printf '\033[?25h'; }
    function clear_screen() { printf '\033[2J\033[H'; }
    function print_colored_message() {
        local color="$1"
        local message="$2"
        printf "${color}${message}${COLOR_RESET}"
    }
    function print_status_message() {
        local color="$1"
        local emoji="$2"
        local message="$3"
        print_colored_message "$color" "${emoji} ${message}\n"
    }
}

source "$LIB_DIR/utils.zsh" 2>/dev/null || {
    # Fallback: basic utility functions if library not available
    function get_timestamp() {
        date +"%Y%m%d-%H%M%S"
    }
}

source "$LIB_DIR/greetings.zsh" 2>/dev/null || {
    # Fallback: basic greeting function if library not available
    function get_random_friend_greeting() {
        echo "Happy coding, friend!"
    }
}

# ============================================================================
# Menu-Specific Color Assignments (using shared OneDark theme)
# ============================================================================

# Menu UI semantic colors (conditional assignment to avoid readonly conflicts)
[[ -z "$UI_CURRENT_SELECTION" ]] && UI_CURRENT_SELECTION="$UI_INFO_COLOR$COLOR_BOLD"
[[ -z "$UI_SELECTION_BG" ]] && UI_SELECTION_BG="$ONEDARK_SELECTION"

# Menu item type colors (conditional assignment to avoid readonly conflicts)
[[ -z "$ITEM_LINK_COLOR" ]] && ITEM_LINK_COLOR="$UI_PROGRESS_COLOR"        # Use shared cyan
[[ -z "$ITEM_CONTROL_COLOR" ]] && ITEM_CONTROL_COLOR="$UI_WARNING_COLOR"      # Use shared yellow
[[ -z "$ITEM_ACTION_COLOR" ]] && ITEM_ACTION_COLOR="$UI_SUCCESS_COLOR"       # Use shared green
[[ -z "$ITEM_UPDATE_COLOR" ]] && ITEM_UPDATE_COLOR="$ONEDARK_CYAN"            # Use OneDark cyan
[[ -z "$ITEM_LIBRARIAN_COLOR" ]] && ITEM_LIBRARIAN_COLOR="$UI_ACCENT_COLOR"     # Use shared purple
[[ -z "$ITEM_BACKUP_COLOR" ]] && ITEM_BACKUP_COLOR="$ONEDARK_BLUE"           # Use OneDark blue
[[ -z "$ITEM_QUIT_COLOR" ]] && ITEM_QUIT_COLOR="$UI_ERROR_COLOR"           # Use shared red
[[ -z "$ITEM_SELECTED_COLOR" ]] && ITEM_SELECTED_COLOR="$UI_SUCCESS_COLOR"     # Use shared green
[[ -z "$ITEM_DEFAULT_COLOR" ]] && ITEM_DEFAULT_COLOR="$ONEDARK_FG"            # Use shared foreground


# ============================================================================
# Menu Configuration & Constants
# ============================================================================

# Menu item types
readonly ITEM_TYPE_ACTION="action"      # Regular selectable items
readonly ITEM_TYPE_BUTTON="button"      # Action buttons (non-selectable)
readonly ITEM_TYPE_CONTROL="control"    # Control buttons (non-selectable)

# Menu item definitions (single source of truth)
readonly MENU_LINK_DOTFILES="Link Dotfiles"
readonly MENU_SELECT_ALL="Select All"
readonly MENU_EXECUTE="Execute Selected"
readonly MENU_UPDATE_ALL="Update All"
readonly MENU_LIBRARIAN="Librarian"
readonly MENU_BACKUP="Backup"
readonly MENU_QUIT="Quit"

# Menu state variables
typeset -a menu_items=()
typeset -a menu_descriptions=()
typeset -a menu_commands=()
typeset -a menu_types=()
typeset -a menu_selected=()
typeset -i current_item=0
typeset -i total_items=0

# ============================================================================
# Menu-Specific Terminal Functions (extending shared UI library)
# ============================================================================

# Move cursor to specific row and column position
# Args: row (int), column (int)
function move_cursor() {
    local row=$1
    local col=$2
    printf "\033[${row};${col}H"
}

# Save current cursor position for later restoration
function save_cursor() {
    printf "\033[s"
}

# Restore cursor to previously saved position
function restore_cursor() {
    printf "\033[u"
}

# ============================================================================
# Menu-Specific Utility Functions (extending shared UI library)
# ============================================================================

# Wait for user to press any key to continue
function wait_for_keypress() {
    print_colored_message "$UI_HEADER_COLOR" "\nPress any key to return to menu..."
    read -k1
}

# Check if a menu item is a control item (non-actionable)
# Args: title (string)
# Returns: 0 if control item, 1 if actionable item
function is_control_menu_item() {
    local title="$1"
    [[ "$title" == "$MENU_SELECT_ALL" || "$title" == "$MENU_EXECUTE" || "$title" == "$MENU_UPDATE_ALL" || "$title" == "$MENU_LIBRARIAN" || "$title" == "$MENU_BACKUP" || "$title" == "$MENU_QUIT" ]]
}

# Validate menu item index
# Args: index (int)
# Returns: 0 if valid, 1 if invalid
function validate_menu_index() {
    local index=$1
    [[ $index -ge 1 && $index -le $total_items ]]
}

# ============================================================================
# Menu Item Management Functions
# ============================================================================

# Add a new menu item to the menu system
# Args: title (string), description (string), command (string)
function add_menu_item() {
    local title="$1"
    local description="$2"
    local command="$3"

    # Input validation
    [[ -z "$title" ]] && { echo "Error: Menu item title cannot be empty" >&2; return 1; }
    [[ -z "$description" ]] && { echo "Error: Menu item description cannot be empty" >&2; return 1; }

    menu_items+=("$title")
    menu_descriptions+=("$description")
    menu_commands+=("$command")
    menu_selected+=(false)

    ((total_items++))
}

# Toggle the selection state of a menu item
# Args: index (int) - 1-based index of the menu item
function toggle_menu_item_selection() {
    local index=$1

    # Input validation
    validate_menu_index "$index" || { echo "Error: Invalid menu index: $index" >&2; return 1; }

    if [[ "${menu_selected[$index]}" == "true" ]]; then
        menu_selected[$index]="false"
    else
        menu_selected[$index]="true"
    fi
}

# Check if all actionable items are currently selected
# Returns: 0 if all selected, 1 if not all selected
function all_actionable_items_selected() {
    local i
    for ((i=1; i<=total_items; i++)); do
        local title="${menu_items[$i]}"
        # Check only actionable items, not control items or buttons
        if ! is_control_menu_item "$title"; then
            [[ "${menu_selected[$i]}" != "true" ]] && return 1
        fi
    done
    return 0
}

# Toggle selection of all actionable menu items (excludes control buttons)
# If all are selected, deselects all. If not all selected, selects all.
function toggle_all_actionable_items() {
    local i
    if all_actionable_items_selected; then
        # All are selected, so deselect all
        for ((i=1; i<=total_items; i++)); do
            local title="${menu_items[$i]}"
            if ! is_control_menu_item "$title"; then
                menu_selected[$i]="false"
            fi
        done
    else
        # Not all are selected, so select all
        for ((i=1; i<=total_items; i++)); do
            local title="${menu_items[$i]}"
            if ! is_control_menu_item "$title"; then
                menu_selected[$i]="true"
            fi
        done
    fi
}

# Clear all menu item selections
function clear_all_menu_selections() {
    local i
    for ((i=1; i<=total_items; i++)); do
        menu_selected[$i]="false"
    done
}

# ============================================================================
# Menu Display and Rendering Functions
# ============================================================================

# Draw the main menu header with navigation instructions
function draw_menu_header() {
    draw_header "Dotfiles Management System" "Interactive Menu"

    printf "${UI_INFO_COLOR}Navigation: ↑/↓ or j/k = up/down  Space = select  Enter = run  q = quit${COLOR_RESET}\n"
    printf "${UI_ACCENT_COLOR}Shortcuts:  l = librarian  b = backup  a = (de)select all  x = execute  ? = help${COLOR_RESET}\n"
    printf "\n"
}

# Render a single menu item with appropriate colors and styling
# Args: index (int) - 1-based menu item index, is_current (bool) - whether this item is currently highlighted
function draw_menu_item() {
    local index=$1
    local is_current=$2

    # Input validation
    validate_menu_index "$index" || { echo "Error: Invalid menu index: $index" >&2; return 1; }

    local title="${menu_items[$index]}"
    local description="${menu_descriptions[$index]}"
    local is_selected="${menu_selected[$index]}"

    local prefix="   "
    local checkbox="☐"
    local color="$ITEM_DEFAULT_COLOR"
    local bg=""

    # Special handling for different item types with semantic colors
    case "$title" in
        "$MENU_LINK_DOTFILES")
            if [[ "$is_selected" == "true" ]]; then
                checkbox="🔗✓"
                color="$ITEM_SELECTED_COLOR"
            else
                checkbox="🔗 "
                color="$ITEM_LINK_COLOR"
            fi
            ;;
        "$MENU_SELECT_ALL")
            # Dynamically show "Select All" or "Deselect All" based on current state
            if all_actionable_items_selected; then
                checkbox="📋✓"
                color="$ITEM_SELECTED_COLOR"
                # Override title and description for display
                title="Deselect All"
                description="Deselect all available items"
            else
                checkbox="📋 "
                color="$ITEM_CONTROL_COLOR"
            fi
            ;;
        "$MENU_EXECUTE")
            checkbox="⚡ "
            color="$ITEM_ACTION_COLOR"
            ;;
        "$MENU_UPDATE_ALL")
            checkbox="🔄 "
            color="$ITEM_UPDATE_COLOR"
            ;;
        "$MENU_LIBRARIAN")
            checkbox="📚 "
            color="$ITEM_LIBRARIAN_COLOR"
            ;;
        "$MENU_BACKUP")
            checkbox="💾 "
            color="$ITEM_BACKUP_COLOR"
            ;;
        "$MENU_QUIT")
            checkbox="🚪 "
            color="$ITEM_QUIT_COLOR"
            ;;
        *)
            # Regular post-install script
            if [[ "$is_selected" == "true" ]]; then
                checkbox="☑️ "
                color="$ITEM_SELECTED_COLOR"
            else
                checkbox="☐ "
                color="$ITEM_DEFAULT_COLOR"
            fi
            ;;
    esac

    # Highlight current item with semantic selection colors
    if [[ $is_current -eq 1 ]]; then
        bg="$UI_SELECTION_BG"
        color="$UI_CURRENT_SELECTION"
        prefix=">>>"
    fi

    printf "${bg}${color}%s %s %-22s %s${COLOR_RESET}\n" \
           "$prefix" "$checkbox" "$title" "$description"
}

# Initial complete menu draw (only used once at startup)
function draw_complete_menu() {
    clear_screen
    draw_menu_header

    printf "\n"
    local i
    for ((i=1; i<=total_items; i++)); do
        local is_current=0
        [[ $i -eq $((current_item + 1)) ]] && is_current=1
        draw_menu_item $i $is_current
    done

    printf "\n"
    printf "${UI_INFO_COLOR}Selected items will be executed when you choose 'Execute Selected'${COLOR_RESET}\n"

    # Show selected count (clean display, no debug info)
    local selected_count=0
    for ((i=1; i<=total_items; i++)); do
        [[ "${menu_selected[$i]}" == "true" ]] && ((selected_count++))
    done

    if [[ $selected_count -gt 0 ]]; then
        printf "${UI_SUCCESS_COLOR}📊 $selected_count item(s) selected${COLOR_RESET}\n"
    fi
}

# Global variables to track previous state
typeset -g previous_current_item=-1
typeset -g previous_selected_count=0

# Highly efficient menu update - only updates what changed
function update_menu_display() {
    local menu_start_row=9  # First menu item is at row 10 (9 + 0 + 1)

    # Only update if current item actually changed
    if [[ $current_item -ne $previous_current_item ]]; then
        # Clear previous highlight (if valid)
        if [[ $previous_current_item -ge 0 && $previous_current_item -lt $total_items ]]; then
            local prev_row=$((menu_start_row + previous_current_item + 1))
            move_cursor $prev_row 1
            printf "\033[2K"  # Clear entire line
            draw_menu_item $((previous_current_item + 1)) 0
        fi

        # Draw new highlight
        local curr_row=$((menu_start_row + current_item + 1))
        move_cursor $curr_row 1
        printf "\033[2K"  # Clear entire line
        draw_menu_item $((current_item + 1)) 1

        previous_current_item=$current_item
    fi
}

# Update just the selection counter (called separately to avoid unnecessary work)
function update_selection_counter() {
    local menu_start_row=9  # First menu item is at row 10 (9 + 0 + 1)

    # Count current selections
    local selected_count=0
    local i
    for ((i=1; i<=total_items; i++)); do
        [[ "${menu_selected[$i]}" == "true" ]] && ((selected_count++))
    done

    # Only update if count actually changed
    if [[ $selected_count -ne $previous_selected_count ]]; then
        local footer_row=$((menu_start_row + total_items + 3))
        move_cursor $footer_row 1
        printf "\033[2K"  # Clear entire line

        if [[ $selected_count -gt 0 ]]; then
            printf "${UI_SUCCESS_COLOR}📊 $selected_count item(s) selected${COLOR_RESET}"
        fi

        previous_selected_count=$selected_count
    fi
}

# Flicker-free update for all actionable items after select/deselect all
# This updates only the changed items in place, avoiding full screen clear
function update_all_actionable_items_display() {
    local menu_start_row=9  # First menu item is at row 10 (9 + 0 + 1)
    local i

    # Update all actionable items (not control items) in place
    for ((i=1; i<=total_items; i++)); do
        local title="${menu_items[$i]}"

        # Skip control items except Select All button (which needs to change text)
        if is_control_menu_item "$title"; then
            # Only update the Select All button to show state change
            if [[ "$title" == "$MENU_SELECT_ALL" ]]; then
                local row=$((menu_start_row + i))
                move_cursor $row 1
                printf "\033[2K"  # Clear entire line

                # Check if this is the current item for highlighting
                local is_current=0
                [[ $i -eq $((current_item + 1)) ]] && is_current=1
                draw_menu_item $i $is_current
            fi
        else
            # Update actionable items to show selection change
            local row=$((menu_start_row + i))
            move_cursor $row 1
            printf "\033[2K"  # Clear entire line

            # Check if this is the current item for highlighting
            local is_current=0
            [[ $i -eq $((current_item + 1)) ]] && is_current=1
            draw_menu_item $i $is_current
        fi
    done

    # Update the selection counter
    update_selection_counter
}

# ============================================================================
# User Input and Navigation Handling
# ============================================================================

# Process user keyboard input and handle menu navigation
# Args: key (string) - the pressed key or key sequence
# Returns: 0=continue, 1=quit, 2=execute selected, 3=run librarian, 4=run backup, 5=full redraw done, 6=execute current item
function handle_menu_navigation() {
    local keyinput="$1"

    case "$keyinput" in
        # Up arrow or k
        $'\033[A'|k|K)
            ((current_item--))
            [[ $current_item -lt 0 ]] && current_item=$((total_items - 1))
            ;;
        # Down arrow or j
        $'\033[B'|j|J)
            ((current_item++))
            [[ $current_item -ge $total_items ]] && current_item=0
            ;;
        # Space - toggle selection
        ' ')
            local current_title="${menu_items[$((current_item + 1))]}"
            case "$current_title" in
                "$MENU_SELECT_ALL")
                    toggle_all_actionable_items
                    # Flicker-free update of all items (anti-flicker technique)
                    update_all_actionable_items_display
                    return 5  # Signal that update already done
                    ;;
                "$MENU_EXECUTE")
                    return 2  # Signal to execute selected items
                    ;;
                "$MENU_UPDATE_ALL")
                    return 7  # Signal to run update_all
                    ;;
                "$MENU_LIBRARIAN")
                    return 3  # Signal to run librarian
                    ;;
                "$MENU_BACKUP")
                    return 4  # Signal to run backup
                    ;;
                "$MENU_QUIT")
                    return 1  # Signal to quit
                    ;;
                *)
                    toggle_menu_item_selection $((current_item + 1))
                    # Redraw the current item to show selection change
                    local menu_start_row=9  # First menu item is at row 10 (9 + 0 + 1)
                    local curr_row=$((menu_start_row + current_item + 1))
                    move_cursor $curr_row 1
                    printf "\033[2K"  # Clear entire line
                    draw_menu_item $((current_item + 1)) 1
                    # Update counter since selection changed
                    update_selection_counter
                    return 5  # Signal that update already done
                    ;;
            esac
            ;;
        # Enter - execute current item immediately
        $'\n'|$'\r')
            local current_title="${menu_items[$((current_item + 1))]}"
            case "$current_title" in
                "$MENU_EXECUTE")
                    return 2  # Signal to execute selected items
                    ;;
                "$MENU_UPDATE_ALL")
                    return 7  # Signal to run update_all
                    ;;
                "$MENU_LIBRARIAN")
                    return 3  # Signal to run librarian
                    ;;
                "$MENU_BACKUP")
                    return 4  # Signal to run backup
                    ;;
                "$MENU_QUIT")
                    return 1  # Signal to quit
                    ;;
                "$MENU_SELECT_ALL")
                    toggle_all_actionable_items
                    # Flicker-free update of all items (anti-flicker technique)
                    update_all_actionable_items_display
                    return 5  # Signal that update already done
                    ;;
                *)
                    # For regular items, execute immediately
                    return 6  # Signal to execute current item
                    ;;
            esac
            ;;
        # q - quit
        q|Q)
            return 1  # Signal to quit
            ;;
        # u - update all (global shortcut)
        u|U)
            return 7  # Signal to run update_all
            ;;
        # l - launch librarian (global shortcut)
        l|L)
            return 3  # Signal to run librarian
            ;;
        # b - backup (global shortcut)
        b|B)
            return 4  # Signal to run backup
            ;;
        # a - toggle select/deselect all (global shortcut)
        a|A)
            toggle_all_actionable_items
            # Flicker-free update of all items (anti-flicker technique)
            update_all_actionable_items_display
            return 5  # Signal that update already done
            ;;
        # x - execute selected items (global shortcut)
        x|X)
            return 2  # Signal to execute selected items
            ;;
        # ? - show help (global shortcut)
        '?')
            show_menu_help
            draw_complete_menu
            return 5  # Signal that full redraw already done
            ;;
    esac

    return 0  # Continue
}

# ============================================================================
# Menu Action Execution Functions
# ============================================================================

# Show menu help dialog
function show_menu_help() {
    clear_screen
    show_cursor

    draw_header "Menu Help" "Keyboard Shortcuts & Navigation"

    printf "${UI_INFO_COLOR}═══ Navigation ═══${COLOR_RESET}\n"
    printf "  ${UI_ACCENT_COLOR}↑ / k${COLOR_RESET}      Move up\n"
    printf "  ${UI_ACCENT_COLOR}↓ / j${COLOR_RESET}      Move down\n"
    printf "  ${UI_ACCENT_COLOR}Space${COLOR_RESET}      Toggle selection / Activate button\n"
    printf "  ${UI_ACCENT_COLOR}Enter${COLOR_RESET}      Execute current item / Activate button\n"
    printf "  ${UI_ACCENT_COLOR}q${COLOR_RESET}          Quit menu\n\n"

    printf "${UI_INFO_COLOR}═══ Global Shortcuts ═══${COLOR_RESET}\n"
    printf "  ${UI_ACCENT_COLOR}u${COLOR_RESET}          Update all packages and toolchains\n"
    printf "  ${UI_ACCENT_COLOR}l${COLOR_RESET}          Launch Librarian (system health & status)\n"
    printf "  ${UI_ACCENT_COLOR}b${COLOR_RESET}          Backup repository\n"
    printf "  ${UI_ACCENT_COLOR}a${COLOR_RESET}          Toggle Select/Deselect All items\n"
    printf "  ${UI_ACCENT_COLOR}x${COLOR_RESET}          Execute selected items\n"
    printf "  ${UI_ACCENT_COLOR}?${COLOR_RESET}          Show this help screen\n\n"

    printf "${UI_INFO_COLOR}═══ Menu Items ═══${COLOR_RESET}\n"
    printf "  ${ITEM_LINK_COLOR}🔗 Link Dotfiles${COLOR_RESET}    Create symlinks for configuration files\n"
    printf "  ${ITEM_CONTROL_COLOR}📋 Select All${COLOR_RESET}       Select/deselect all post-install scripts\n"
    printf "  ${ITEM_ACTION_COLOR}⚡ Execute Selected${COLOR_RESET}  Run all selected operations\n"
    printf "  ${ITEM_UPDATE_COLOR}🔄 Update All${COLOR_RESET}       Update packages, toolchains, and LSPs\n"
    printf "  ${ITEM_LIBRARIAN_COLOR}📚 Librarian${COLOR_RESET}        System health check and status report\n"
    printf "  ${ITEM_BACKUP_COLOR}💾 Backup${COLOR_RESET}           Create repository backup archive\n"
    printf "  ${ITEM_QUIT_COLOR}🚪 Quit${COLOR_RESET}              Exit the menu system\n\n"

    printf "${UI_SUCCESS_COLOR}💡 Tip: ${COLOR_RESET}${UI_INFO_COLOR}Use global shortcuts for quick access to common operations!${COLOR_RESET}\n\n"

    printf "${UI_HEADER_COLOR}Press any key to return to menu...${COLOR_RESET}"
    read -k1
    hide_cursor
}

# Execute a specific menu item by index
# Args: index (int) - 1-based index of the menu item to execute
function execute_single_menu_item() {
    local index=$1

    # Input validation
    validate_menu_index "$index" || { echo "Error: Invalid menu index: $index" >&2; return 1; }

    local title="${menu_items[$index]}"
    local command="${menu_commands[$index]}"

    # Skip control items that don't have commands
    if is_control_menu_item "$title"; then
        echo "Error: Cannot execute control item: $title" >&2
        return 1
    fi

    # Clear screen before execution to avoid painting over menu
    clear_screen
    show_cursor

    print_status_message "$COLOR_BOLD$UI_SUCCESS_COLOR" "🚀" "Executing: $title"
    printf "   ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫\n\n"

    # Execute the command with proper environment
    if [[ -n "$command" ]]; then
        eval "$command"
        printf "\n"
        print_status_message "$UI_SUCCESS_COLOR" "✅" "Completed: $title"
    else
        print_status_message "$UI_WARNING_COLOR" "⚠️" "No command defined for: $title"
    fi

    wait_for_keypress
    hide_cursor
}

# Execute all currently selected menu items
# Shows progress and results for each executed item
function execute_selected_menu_items() {
    # Clear screen before execution to avoid painting over menu
    clear_screen
    show_cursor

    printf "${COLOR_BOLD}${UI_SUCCESS_COLOR}⚡ Executing selected items...${COLOR_RESET}\n\n"

    local executed_count=0
    local i

    for ((i=1; i<=total_items; i++)); do
        if [[ "${menu_selected[$i]}" == "true" ]]; then
            local title="${menu_items[$i]}"
            local command="${menu_commands[$i]}"

            # Skip control items that don't have commands
            if is_control_menu_item "$title"; then
                continue
            fi

            printf "${UI_HEADER_COLOR}🎵 Executing: $title${COLOR_RESET}\n"
            printf "   ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫\n"

            # Execute the command with proper environment
            if [[ -n "$command" ]]; then
                eval "$command"
                printf "${UI_SUCCESS_COLOR}   ✅ Completed: $title${COLOR_RESET}\n\n"
                ((executed_count++))
            else
                printf "${UI_WARNING_COLOR}   ⚠️  No command defined for: $title${COLOR_RESET}\n\n"
            fi
        fi
    done

    if [[ $executed_count -eq 0 ]]; then
        printf "${UI_WARNING_COLOR}🎼 No items were selected for execution.${COLOR_RESET}\n"
        printf "${UI_INFO_COLOR}Tip: Use Space to select items, then choose 'Execute Selected'${COLOR_RESET}\n"
    else
        printf "${UI_SUCCESS_COLOR}🎭 Successfully executed $executed_count item(s)!${COLOR_RESET}\n"
        # Clear selections after successful execution
        clear_all_menu_selections
    fi

    printf "\n${UI_HEADER_COLOR}Press any key to return to menu...${COLOR_RESET}"
    read -k1
    hide_cursor
}

# Execute the update_all.zsh script
function execute_update_all() {
    # Clear screen before execution to avoid painting over menu
    clear_screen
    show_cursor

    printf "${COLOR_BOLD}${ITEM_UPDATE_COLOR}🔄 Update All${COLOR_RESET}\n\n"
    printf "${UI_INFO_COLOR}Updating system packages, toolchains, and language packages...${COLOR_RESET}\n\n"

    # Execute the update_all script
    "$DF_DIR/bin/update_all.zsh"

    printf "\n${UI_HEADER_COLOR}Press any key to return to menu...${COLOR_RESET}"
    read -k1
    hide_cursor
}

# Execute the librarian status and diagnostics report
function execute_librarian_diagnostics() {
    # Clear screen before execution to avoid painting over menu
    clear_screen
    show_cursor

    # Execute the librarian with --status to show full verbose report
    # The librarian will handle its own output (through pager if interactive)
    # Note: Since librarian uses a pager that requires 'q' to exit,
    # we don't need an additional "press any key" prompt
    local librarian_cmd='DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$DF_DIR/bin/librarian.zsh" --status'
    eval "$librarian_cmd"

    hide_cursor
}

# Show fancy backup location dialog
function prompt_backup_location() {
    # Redirect all output to /dev/tty to ensure immediate display
    {
        clear_screen
        show_cursor

        draw_header "Repository Backup" "Choose Backup Location"

        printf "${UI_INFO_COLOR}The backup will create a timestamped ZIP archive of your dotfiles repository.${COLOR_RESET}\n\n"

        printf "${UI_ACCENT_COLOR}═══ Backup Location Options ═══${COLOR_RESET}\n\n"
        printf "  ${UI_SUCCESS_COLOR}[1]${COLOR_RESET} ${UI_INFO_COLOR}Default location${COLOR_RESET}\n"
        printf "      ${ONEDARK_COMMENT}~/Downloads/dotfiles_repo_backups/${COLOR_RESET}\n\n"
        printf "  ${UI_SUCCESS_COLOR}[2]${COLOR_RESET} ${UI_INFO_COLOR}Custom location${COLOR_RESET}\n"
        printf "      ${ONEDARK_COMMENT}Specify your own backup directory${COLOR_RESET}\n\n"
        printf "  ${UI_ERROR_COLOR}[c]${COLOR_RESET} ${UI_INFO_COLOR}Cancel${COLOR_RESET}\n\n"

        printf "${UI_ACCENT_COLOR}Choose an option [1/2/c]: ${COLOR_RESET}"
    } > /dev/tty

    # Force terminal to sync and give user time to see the prompt
    sleep 0.3

    local choice
    read -t 0.01 > /dev/null 2>&1  # Flush any stale input
    read -k1 -s choice < /dev/tty
    printf "\n\n" > /dev/tty

    case "$choice" in
        1)
            # Use default location - return special marker
            printf "DEFAULT"
            ;;
        2)
            # Prompt for custom location
            {
                printf "${UI_ACCENT_COLOR}Enter custom backup directory path:${COLOR_RESET}\n"
                printf "${ONEDARK_COMMENT}(Tip: Use ~ for home directory, e.g., ~/Desktop)${COLOR_RESET}\n"
                printf "${UI_SUCCESS_COLOR}➜ ${COLOR_RESET}"
            } > /dev/tty

            local custom_path
            read custom_path < /dev/tty

            # Validate path is not empty
            if [[ -z "$custom_path" ]]; then
                printf "\n${UI_ERROR_COLOR}❌ Error: Path cannot be empty. Using default location.${COLOR_RESET}\n" > /dev/tty
                sleep 2
                printf "DEFAULT"
            else
                printf "%s" "$custom_path"
            fi
            ;;
        c|C)
            # User cancelled - return to stdout
            printf "CANCELLED"
            ;;
        *)
            # Invalid choice, use default
            printf "\n${UI_WARNING_COLOR}⚠️  Invalid choice. Using default location.${COLOR_RESET}\n" > /dev/tty
            sleep 1
            printf "DEFAULT"
            ;;
    esac

    hide_cursor
}

# Execute the backup repository operation
function execute_backup_repo() {
    # Clear screen before execution to avoid painting over menu
    clear_screen
    show_cursor

    printf "${COLOR_BOLD}${ITEM_BACKUP_COLOR}💾 Repository Backup${COLOR_RESET}\n\n"
    printf "${UI_INFO_COLOR}📁 Using default location: ${COLOR_BOLD}~/Downloads/dotfiles_repo_backups/${COLOR_RESET}\n\n"

    # Execute the backup script with default location (no -t flag)
    "$DF_DIR/bin/backup_dotfiles_repo.zsh"

    printf "\n${UI_HEADER_COLOR}Press any key to return to menu...${COLOR_RESET}"
    read -k1
    hide_cursor
}

# ============================================================================
# Main Menu Loop
# ============================================================================

function run_interactive_menu() {
    # Setup terminal
    hide_cursor

    # Cleanup on exit
    trap 'show_cursor; exit 0' INT TERM EXIT

    # Draw the menu once at startup
    draw_complete_menu

    # Initialize previous state to match current state (prevents first keystroke issues)
    previous_current_item=$current_item

    while true; do
        # Read single keypress (silently, no echo)
        local key
        read -k1 -s key

        # Handle special keys (arrow keys are multi-character sequences)
        if [[ "$key" == $'\033' ]]; then
            read -k2 -s key
            key=$'\033'"$key"
        fi

        # Process navigation
        handle_menu_navigation "$key"
        result=$?

        unset key

        case $result in
            1)  # Quit
                break
                ;;
            2)  # Execute selected items
                execute_selected_menu_items
                # Redraw complete menu after execution
                draw_complete_menu
                # Reset tracking state after full redraw
                previous_current_item=$current_item
                ;;
            3)  # Run librarian
                execute_librarian_diagnostics
                # Redraw complete menu after execution
                draw_complete_menu
                # Reset tracking state after full redraw
                previous_current_item=$current_item
                ;;
            4)  # Run backup
                execute_backup_repo
                # Redraw complete menu after execution
                draw_complete_menu
                # Reset tracking state after full redraw
                previous_current_item=$current_item
                ;;
            5)  # Already updated - no further action needed
                # Do nothing, the handler already updated what was needed
                ;;
            7)  # Run update_all
                execute_update_all
                # Redraw complete menu after execution
                draw_complete_menu
                # Reset tracking state after full redraw
                previous_current_item=$current_item
                ;;
            6)  # Execute current item
                execute_single_menu_item $((current_item + 1))
                # Redraw complete menu after execution
                draw_complete_menu
                # Reset tracking state after full redraw
                previous_current_item=$current_item
                ;;
            0)  # Continue - just update the display efficiently
                update_menu_display
                ;;
        esac
    done

    show_cursor
    clear_screen
    printf "${UI_SUCCESS_COLOR}📚 The work is complete. $(get_random_friend_greeting) 💙${COLOR_RESET}\n\n"
}

# ============================================================================
# Menu Initialization
# ============================================================================

function initialize_menu() {
    # Clear all arrays first to prevent duplicates
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_types=()
    menu_selected=()
    current_item=0
    total_items=0

    # Add link dotfiles option
    add_menu_item "$MENU_LINK_DOTFILES" "Create symlinks for all dotfiles" \
                  'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$DF_DIR/bin/link_dotfiles.zsh"'

    # Find and add post-install scripts from the post-install/scripts directory
    local post_install_dir="$DF_DIR/post-install/scripts"
    local all_scripts=()

    if [[ -d "$post_install_dir" ]]; then
        # Find all post-install scripts
        all_scripts=(${(0)"$(find "$post_install_dir" -name "*.zsh" -print0 2>/dev/null)"})

        # Filter out disabled/ignored scripts and add enabled ones to menu
        for script in "${all_scripts[@]}"; do
            # Check if script is enabled (not disabled/ignored)
            if ! is_post_install_script_enabled "$script"; then
                continue  # Skip disabled/ignored scripts
            fi

            if [[ -x "$script" ]]; then
                local script_name="$(basename "$script" .zsh)"
                local script_desc="Install and configure $script_name"

                # Make script descriptions more user-friendly
                case "$script_name" in
                    *package*|*brew*|*apt*)
                        script_desc="Install system packages via $script_name"
                        ;;
                    *npm*|*node*)
                        script_desc="Install Node.js packages and tools"
                        ;;
                    *python*|*pip*)
                        script_desc="Install Python packages and tools"
                        ;;
                    *cargo*|*rust*)
                        script_desc="Install Rust packages and tools"
                        ;;
                    *gem*|*ruby*)
                        script_desc="Install Ruby gems and tools"
                        ;;
                    *)
                        script_desc="Configure $script_name environment"
                        ;;
                esac

                add_menu_item "$script_name" "$script_desc" \
                              'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "'$script'"'
            fi
        done
    else
        echo "Note: No post-install scripts directory found at $post_install_dir"
    fi

    # Add control items
    add_menu_item "$MENU_SELECT_ALL" "Select all available items" ""
    add_menu_item "$MENU_EXECUTE" "Run all selected operations" ""

    # Add update all system components
    add_menu_item "$MENU_UPDATE_ALL" "Update packages, toolchains, and language servers" ""

    # Add librarian status and diagnostics (below execute button)
    add_menu_item "$MENU_LIBRARIAN" "Run system health check and status report" \
                  'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$DF_DIR/bin/librarian.zsh" --status'

    # Add backup repository option (below librarian)
    add_menu_item "$MENU_BACKUP" "Create repository backup archive" \
                  '"$DF_DIR/bin/backup_dotfiles_repo.zsh"'

    add_menu_item "$MENU_QUIT" "Exit the menu system" ""
}

# ============================================================================
# Main Execution
# ============================================================================

# If script is run directly (not sourced) and not in test mode, run the interactive menu
if [[ -z "$MENU_TEST_MODE" && ( "${BASH_SOURCE[0]}" == "${0}" || "${(%):-%N}" == "$0" ) ]]; then
    # Ensure we have the required environment
    if [[ -z "$DF_DIR" ]]; then
        export DF_DIR=$(realpath "$(dirname $0)/..")
    fi

    initialize_menu
    run_interactive_menu
fi
