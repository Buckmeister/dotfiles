#!/usr/bin/env zsh

# ============================================================================
# Menu Navigation Logic - Keyboard Input & Display Updates
# ============================================================================
#
# Handles keyboard navigation, integrates menu_engine and menu_state modules,
# and provides anti-flicker display updates for hierarchical menus.
#
# Dependencies: menu_engine.zsh, menu_state.zsh, colors.zsh, ui.zsh
# ============================================================================

# Note: emulate -LR zsh removed - this library is sourced by scripts that already have it.
# The caller's emulate directive applies to the entire execution context, making it
# redundant here. Removing it prevents potential array scoping issues in subshells.

# ============================================================================
# Navigation Return Codes
# ============================================================================

readonly NAV_CONTINUE=0           # Continue menu loop
readonly NAV_QUIT=1               # Quit menu system
readonly NAV_EXECUTE_SELECTED=2   # Execute all selected items
readonly NAV_EXECUTE_CURRENT=3    # Execute current item only
readonly NAV_NAVIGATE_SUBMENU=4   # Navigate into submenu
readonly NAV_NAVIGATE_BACK=5      # Navigate back to parent menu
readonly NAV_UPDATE_DONE=6        # Update already done (no further action needed)
readonly NAV_FULL_REDRAW=7        # Full screen redraw needed
readonly NAV_SHOW_HELP=8          # Show help screen
readonly NAV_RUN_LIBRARIAN=9      # Run librarian diagnostics
readonly NAV_RUN_BACKUP=10        # Run backup operation
readonly NAV_RUN_UPDATE_ALL=11    # Run update all

# ============================================================================
# Display Update State (Anti-Flicker)
# ============================================================================

typeset -gi NAV_PREVIOUS_ITEM=-1           # Previous cursor position
typeset -gi NAV_PREVIOUS_SELECTED_COUNT=0  # Previous selection count

# ============================================================================
# Display Update Functions (uses terminal control from ui.zsh)
# ============================================================================
# Terminal control functions (move_cursor_to, save_cursor, restore_cursor,
# clear_line, wait_for_keypress) are provided by ui.zsh.
#
# This module focuses on anti-flicker display updates for menu navigation.
# ============================================================================

# Update only the changed menu items (anti-flicker technique)
# This is called after cursor movement to update only what changed
function nav_update_display() {
    local menu_start_row=9  # First menu item starts at row 10 (header is 8 lines)

    # Only update if current item actually changed
    if [[ $MENU_CURRENT_ITEM -ne $NAV_PREVIOUS_ITEM ]]; then
        # Clear and redraw previous item (unhighlight)
        if [[ $NAV_PREVIOUS_ITEM -ge 0 && $NAV_PREVIOUS_ITEM -lt $MENU_TOTAL_ITEMS ]]; then
            local prev_row=$((menu_start_row + NAV_PREVIOUS_ITEM + 1))
            move_cursor_to $prev_row 1
            clear_line
            menu_engine_draw_item $((NAV_PREVIOUS_ITEM + 1)) 0
        fi

        # Clear and redraw current item (highlight)
        local curr_row=$((menu_start_row + MENU_CURRENT_ITEM + 1))
        move_cursor_to $curr_row 1
        clear_line
        menu_engine_draw_item $((MENU_CURRENT_ITEM + 1)) 1

        NAV_PREVIOUS_ITEM=$MENU_CURRENT_ITEM
    fi
}

# Update the selection counter display
function nav_update_selection_counter() {
    local menu_start_row=9

    # Count current selections
    local selected_count=$(menu_engine_count_selected)

    # Only update if count changed
    if [[ $selected_count -ne $NAV_PREVIOUS_SELECTED_COUNT ]]; then
        local footer_row=$((menu_start_row + MENU_TOTAL_ITEMS + 3))
        move_cursor_to $footer_row 1
        clear_line

        if [[ $selected_count -gt 0 ]]; then
            printf "${UI_SUCCESS_COLOR}📊 $selected_count item(s) selected${COLOR_RESET}"
        fi

        NAV_PREVIOUS_SELECTED_COUNT=$selected_count
    fi
}

# Update all selectable items after toggle-all operation
function nav_update_all_items_display() {
    local menu_start_row=9
    local i

    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local type=$(menu_engine_get_item_property $i "type")

        # Update selectable items
        if menu_engine_is_selectable "$type"; then
            local row=$((menu_start_row + i))
            move_cursor_to $row 1
            clear_line

            local is_current=0
            [[ $i -eq $((MENU_CURRENT_ITEM + 1)) ]] && is_current=1
            menu_engine_draw_item $i $is_current
        fi
    done

    # Update selection counter
    nav_update_selection_counter
}

# Update breadcrumb display
# Args: breadcrumb_text (string)
function nav_update_breadcrumb() {
    local breadcrumb="$1"
    local breadcrumb_row=5  # Row where breadcrumb is displayed

    move_cursor_to $breadcrumb_row 1
    clear_line
    printf "${UI_INFO_COLOR}📍 Location: ${UI_ACCENT_COLOR}${breadcrumb}${COLOR_RESET}\n"
}

# Reset display state tracking (call after full screen redraw)
function nav_reset_display_state() {
    NAV_PREVIOUS_ITEM=$MENU_CURRENT_ITEM
    NAV_PREVIOUS_SELECTED_COUNT=$(menu_engine_count_selected)
}

# ============================================================================
# Keyboard Input Handling
# ============================================================================

# Handle keyboard input and return appropriate navigation action
# Args: key (string) - the key input from user
# Returns: navigation return code (see constants above)
function nav_handle_keypress() {
    local key="$1"

    case "$key" in
        # ═══ Cursor Movement ═══
        $'\033[A'|k|K)  # Up arrow or k
            menu_engine_move_up
            return $NAV_CONTINUE
            ;;
        $'\033[B'|j|J)  # Down arrow or j
            menu_engine_move_down
            return $NAV_CONTINUE
            ;;

        # ═══ Navigation ═══
        $'\n'|$'\r')  # Enter - execute or drill down
            local current_type=$(menu_engine_get_current_type)

            if menu_engine_is_navigable "$current_type"; then
                # Navigate into submenu
                return $NAV_NAVIGATE_SUBMENU
            elif menu_engine_is_executable "$current_type"; then
                # Execute current item
                return $NAV_EXECUTE_CURRENT
            elif [[ "$current_type" == "$MENU_TYPE_CONTROL" ]]; then
                # Handle control items (like select all, execute, etc.)
                nav_handle_control_item
                return $?
            fi
            return $NAV_CONTINUE
            ;;

        $'\033'|h|H)  # Escape or h - navigate back
            # Only navigate back if not at root
            if ! menu_state_is_root; then
                return $NAV_NAVIGATE_BACK
            fi
            return $NAV_CONTINUE
            ;;

        # ═══ Selection ═══
        ' ')  # Space - toggle selection
            local current_type=$(menu_engine_get_current_type)

            if menu_engine_is_selectable "$current_type"; then
                # Toggle current item selection
                menu_engine_toggle_selection $((MENU_CURRENT_ITEM + 1))

                # Redraw current item to show selection change
                local menu_start_row=9
                local curr_row=$((menu_start_row + MENU_CURRENT_ITEM + 1))
                move_cursor_to $curr_row 1
                clear_line
                menu_engine_draw_item $((MENU_CURRENT_ITEM + 1)) 1

                # Update selection counter
                nav_update_selection_counter
                return $NAV_UPDATE_DONE
            elif [[ "$current_type" == "$MENU_TYPE_CONTROL" ]]; then
                # Handle control items
                nav_handle_control_item
                return $?
            fi
            return $NAV_CONTINUE
            ;;

        # ═══ Global Shortcuts ═══
        q|Q)  # Quit
            return $NAV_QUIT
            ;;

        a|A)  # Toggle select/deselect all
            menu_engine_toggle_all
            nav_update_all_items_display
            return $NAV_UPDATE_DONE
            ;;

        x|X)  # Execute selected items
            return $NAV_EXECUTE_SELECTED
            ;;

        l|L)  # Launch librarian
            return $NAV_RUN_LIBRARIAN
            ;;

        b|B)  # Backup
            return $NAV_RUN_BACKUP
            ;;

        u|U)  # Update all
            return $NAV_RUN_UPDATE_ALL
            ;;

        '?')  # Show help
            return $NAV_SHOW_HELP
            ;;

        # ═══ Debug (hidden) ═══
        d|D)  # Debug - print state
            if [[ -n "$MENU_DEBUG" ]]; then
                menu_state_debug_print_stack
                return $NAV_FULL_REDRAW
            fi
            return $NAV_CONTINUE
            ;;
    esac

    return $NAV_CONTINUE
}

# Handle control item activation (select all, execute, etc.)
# Returns: navigation return code
function nav_handle_control_item() {
    local current_index=$((MENU_CURRENT_ITEM + 1))
    local title=$(menu_engine_get_item_property $current_index "title")

    case "$title" in
        "Select All"|"Deselect All")
            menu_engine_toggle_all
            nav_update_all_items_display
            return $NAV_UPDATE_DONE
            ;;
        "Execute Selected")
            return $NAV_EXECUTE_SELECTED
            ;;
        "Update All")
            return $NAV_RUN_UPDATE_ALL
            ;;
        "Librarian")
            return $NAV_RUN_LIBRARIAN
            ;;
        "Backup")
            return $NAV_RUN_BACKUP
            ;;
        "Quit")
            return $NAV_QUIT
            ;;
        "Back")
            return $NAV_NAVIGATE_BACK
            ;;
        *)
            return $NAV_CONTINUE
            ;;
    esac
}

# ============================================================================
# Navigation Actions
# ============================================================================

# Navigate into a submenu
# Returns: 0 on success, 1 on error
function nav_enter_submenu() {
    local current_index=$((MENU_CURRENT_ITEM + 1))
    local submenu_id=$(menu_engine_get_item_property $current_index "id")
    local submenu_title=$(menu_engine_get_item_property $current_index "title")

    if [[ -z "$submenu_id" ]]; then
        return 1
    fi

    # Save current cursor position
    menu_state_save_cursor $MENU_CURRENT_ITEM

    # Push new menu onto stack
    menu_state_push "$submenu_id" "$submenu_title"

    return 0
}

# Navigate back to parent menu
# Returns: 0 on success, 1 on error (already at root)
function nav_return_to_parent() {
    # Attempt to pop the stack
    local parent_id=$(menu_state_pop)

    if [[ $? -ne 0 ]]; then
        # Already at root, can't go back
        return 1
    fi

    # Restore cursor position for parent menu
    local restored_pos=$(menu_state_restore_cursor "$parent_id")
    MENU_CURRENT_ITEM=$restored_pos

    return 0
}

# ============================================================================
# Wait for User Input
# ============================================================================

# Wait for single keypress and return it
# Returns: the pressed key (handles multi-char sequences like arrow keys)
function nav_read_key() {
    local key
    read -k1 -s key

    # Handle special keys (arrow keys are multi-character sequences)
    if [[ "$key" == $'\033' ]]; then
        # Check if there's more input (arrow key sequence)
        read -t 0.01 -k2 -s rest 2>/dev/null
        if [[ $? -eq 0 ]]; then
            key=$'\033'"$rest"
        fi
    fi

    echo "$key"
}

# ============================================================================
# Export Functions
# ============================================================================

autoload -U nav_update_display
autoload -U nav_update_selection_counter
autoload -U nav_update_all_items_display
autoload -U nav_update_breadcrumb
autoload -U nav_reset_display_state
autoload -U nav_handle_keypress
autoload -U nav_handle_control_item
autoload -U nav_enter_submenu
autoload -U nav_return_to_parent
autoload -U nav_read_key
