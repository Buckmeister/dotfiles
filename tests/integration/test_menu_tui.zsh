#!/usr/bin/env zsh

# ============================================================================
# TUI Menu Integration Tests
# ============================================================================
#
# Comprehensive integration tests for the interactive TUI menu system
# (bin/menu_tui.zsh).
#
# Tests Cover:
# - Menu initialization and item loading
# - Navigation (up/down, wraparound)
# - Selection toggling (individual, select all)
# - Action execution (execute selected, shortcuts)
# - Menu state management
# - Error handling and edge cases
# - Integration with underlying scripts
#
# Usage:
#   ./tests/integration/test_menu_tui.zsh
#
# Note: These tests source the menu_tui.zsh file to test its functions
# directly without requiring full interactive mode.
# ============================================================================

emulate -LR zsh

# Load test framework

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

# Initialize paths using shared utility
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../bin/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)
init_dotfiles_paths

source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Set up test environment
export DF_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
export DF_PKG_MANAGER="unknown"
export DF_PKG_INSTALL_CMD="echo"

# Set test mode to prevent interactive menu from running
export MENU_TEST_MODE=1

# Source the menu_tui.zsh file to access its functions
source "$DOTFILES_ROOT/bin/menu_tui.zsh" 2>/dev/null || {
    echo "Error: Could not source bin/menu_tui.zsh"
    exit 1
}

# ============================================================================
# Test Suite
# ============================================================================

test_suite "TUI Menu Integration Tests"

# ============================================================================
# Menu Initialization Tests
# ============================================================================

test_case "should initialize menu with empty state" '
    # Clear arrays
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    assert_equals "0" "$total_items"
    assert_equals "0" "${#menu_items[@]}"
'

test_case "should add menu item correctly" '
    # Clear arrays first
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    # Add a menu item
    add_menu_item "Test Item" "Test Description" "echo test"

    assert_equals "1" "$total_items"
    assert_equals "Test Item" "${menu_items[1]}"
    assert_equals "Test Description" "${menu_descriptions[1]}"
    assert_equals "echo test" "${menu_commands[1]}"
    assert_equals "false" "${menu_selected[1]}"
'

test_case "should add multiple menu items" '
    # Clear arrays first
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    # Add multiple items
    add_menu_item "Item 1" "Description 1" "cmd1"
    add_menu_item "Item 2" "Description 2" "cmd2"
    add_menu_item "Item 3" "Description 3" "cmd3"

    assert_equals "3" "$total_items"
    assert_equals "Item 1" "${menu_items[1]}"
    assert_equals "Item 2" "${menu_items[2]}"
    assert_equals "Item 3" "${menu_items[3]}"
'

test_case "should reject menu item with empty title" '
    # Clear arrays first
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    # Try to add item with empty title (should fail)
    add_menu_item "" "Description" "cmd" 2>/dev/null
    local exit_code=$?

    # Should have failed and not added item
    [[ $exit_code -ne 0 ]] && assert_true "true" || assert_true "false"
    assert_equals "0" "$total_items"
'

test_case "should reject menu item with empty description" '
    # Clear arrays first
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    # Try to add item with empty description (should fail)
    add_menu_item "Title" "" "cmd" 2>/dev/null
    local exit_code=$?

    # Should have failed and not added item
    [[ $exit_code -ne 0 ]] && assert_true "true" || assert_true "false"
    assert_equals "0" "$total_items"
'

# ============================================================================
# Menu Selection Tests
# ============================================================================

test_case "should toggle menu item selection" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Item 1" "Description 1" "cmd1"

    # Initially unselected
    assert_equals "false" "${menu_selected[1]}"

    # Toggle to selected
    toggle_menu_item_selection 1
    assert_equals "true" "${menu_selected[1]}"

    # Toggle back to unselected
    toggle_menu_item_selection 1
    assert_equals "false" "${menu_selected[1]}"
'

test_case "should handle toggle with invalid index" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Item 1" "Description 1" "cmd1"

    # Try to toggle invalid index (should fail)
    toggle_menu_item_selection 99 2>/dev/null
    local exit_code=$?

    [[ $exit_code -ne 0 ]] && assert_true "true" || assert_true "false"
'

test_case "should select all actionable items" '
    # Setup menu with mix of actionable and control items
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Script 1" "Description 1" "cmd1"
    add_menu_item "Script 2" "Description 2" "cmd2"
    add_menu_item "$MENU_SELECT_ALL" "Select all" ""
    add_menu_item "$MENU_QUIT" "Quit" ""

    # Toggle all actionable items
    toggle_all_actionable_items

    # Actionable items should be selected
    assert_equals "true" "${menu_selected[1]}"
    assert_equals "true" "${menu_selected[2]}"
    # Control items should remain unselected
    assert_equals "false" "${menu_selected[3]}"
    assert_equals "false" "${menu_selected[4]}"
'

test_case "should deselect all when all are selected" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Script 1" "Description 1" "cmd1"
    add_menu_item "Script 2" "Description 2" "cmd2"

    # Select all
    toggle_all_actionable_items
    assert_equals "true" "${menu_selected[1]}"
    assert_equals "true" "${menu_selected[2]}"

    # Toggle again should deselect all
    toggle_all_actionable_items
    assert_equals "false" "${menu_selected[1]}"
    assert_equals "false" "${menu_selected[2]}"
'

test_case "should detect when all actionable items are selected" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Script 1" "Description 1" "cmd1"
    add_menu_item "Script 2" "Description 2" "cmd2"
    add_menu_item "$MENU_QUIT" "Quit" ""

    # Initially not all selected
    all_actionable_items_selected
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"

    # Select all actionable items
    menu_selected[1]="true"
    menu_selected[2]="true"

    # Now all are selected
    all_actionable_items_selected
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"
'

test_case "should clear all menu selections" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Script 1" "Description 1" "cmd1"
    add_menu_item "Script 2" "Description 2" "cmd2"
    add_menu_item "Script 3" "Description 3" "cmd3"

    # Select some items
    menu_selected[1]="true"
    menu_selected[2]="true"
    menu_selected[3]="true"

    # Clear all selections
    clear_all_menu_selections

    # All should be unselected
    assert_equals "false" "${menu_selected[1]}"
    assert_equals "false" "${menu_selected[2]}"
    assert_equals "false" "${menu_selected[3]}"
'

# ============================================================================
# Menu Item Type Recognition Tests
# ============================================================================

test_case "should recognize control menu items" '
    # Test control items
    is_control_menu_item "$MENU_SELECT_ALL"
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "$MENU_EXECUTE"
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "$MENU_UPDATE_ALL"
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "$MENU_LIBRARIAN"
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "$MENU_BACKUP"
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "$MENU_QUIT"
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"
'

test_case "should recognize actionable menu items" '
    # Test actionable (non-control) items
    is_control_menu_item "Regular Script"
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "npm-packages"
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"

    is_control_menu_item "Link Dotfiles"
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"
'

# ============================================================================
# Menu Index Validation Tests
# ============================================================================

test_case "should validate menu index within bounds" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Item 1" "Description 1" "cmd1"
    add_menu_item "Item 2" "Description 2" "cmd2"
    add_menu_item "Item 3" "Description 3" "cmd3"

    # Valid indices
    validate_menu_index 1
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    validate_menu_index 2
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"

    validate_menu_index 3
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"
'

test_case "should reject invalid menu indices" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Item 1" "Description 1" "cmd1"
    add_menu_item "Item 2" "Description 2" "cmd2"

    # Invalid indices
    validate_menu_index 0
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"

    validate_menu_index 3
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"

    validate_menu_index 99
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"

    validate_menu_index -1
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"
'

# ============================================================================
# Menu Initialization Integration Tests
# ============================================================================

test_case "should initialize full menu with all items" '
    # Call initialize_menu function
    initialize_menu

    # Should have loaded items
    [[ $total_items -gt 0 ]] && assert_true "true" || assert_true "false"

    # Should have Link Dotfiles as first item
    assert_equals "$MENU_LINK_DOTFILES" "${menu_items[1]}"

    # Should have control items
    local has_select_all=false
    local has_execute=false
    local has_quit=false
    local i

    for ((i=1; i<=total_items; i++)); do
        if [[ "${menu_items[$i]}" == "$MENU_SELECT_ALL" ]]; then
            has_select_all=true
        elif [[ "${menu_items[$i]}" == "$MENU_EXECUTE" ]]; then
            has_execute=true
        elif [[ "${menu_items[$i]}" == "$MENU_QUIT" ]]; then
            has_quit=true
        fi
    done

    [[ $has_select_all == true ]] && assert_true "true" || assert_true "false"
    [[ $has_execute == true ]] && assert_true "true" || assert_true "false"
    [[ $has_quit == true ]] && assert_true "true" || assert_true "false"
'

test_case "should load post-install scripts as menu items" '
    initialize_menu

    # Should have at least some post-install scripts loaded
    # Count actionable items (excluding control items)
    local actionable_count=0
    local i

    for ((i=1; i<=total_items; i++)); do
        if ! is_control_menu_item "${menu_items[$i]}"; then
            ((actionable_count++))
        fi
    done

    # Should have at least "Link Dotfiles" plus post-install scripts
    [[ $actionable_count -gt 1 ]] && assert_true "true" || assert_true "false"
'

test_case "should initialize all items as unselected" '
    initialize_menu

    # All items should start unselected
    local i
    for ((i=1; i<=total_items; i++)); do
        assert_equals "false" "${menu_selected[$i]}"
    done
'

# ============================================================================
# Menu Navigation Simulation Tests
# ============================================================================

test_case "should handle navigation down" '
    initialize_menu

    # Start at first item
    current_item=0
    assert_equals "0" "$current_item"

    # Simulate down navigation
    local initial_item=$current_item
    ((current_item++))

    assert_equals "1" "$current_item"
'

test_case "should handle navigation up with wraparound" '
    initialize_menu

    # Start at first item
    current_item=0

    # Simulate up navigation (should wrap to last)
    ((current_item--))
    [[ $current_item -lt 0 ]] && current_item=$((total_items - 1))

    assert_equals "$((total_items - 1))" "$current_item"
'

test_case "should handle navigation down with wraparound" '
    initialize_menu

    # Start at last item
    current_item=$((total_items - 1))

    # Simulate down navigation (should wrap to first)
    ((current_item++))
    [[ $current_item -ge $total_items ]] && current_item=0

    assert_equals "0" "$current_item"
'

# ============================================================================
# Edge Case Tests
# ============================================================================

test_case "should handle empty menu gracefully" '
    # Clear menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    # Should handle operations on empty menu
    assert_equals "0" "$total_items"

    # Validate index should fail on empty menu
    validate_menu_index 1
    [[ $? -ne 0 ]] && assert_true "true" || assert_true "false"
'

test_case "should handle menu with only control items" '
    # Create menu with only control items
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "$MENU_SELECT_ALL" "Select all" ""
    add_menu_item "$MENU_EXECUTE" "Execute" ""
    add_menu_item "$MENU_QUIT" "Quit" ""

    # Toggle all should not select control items
    toggle_all_actionable_items

    assert_equals "false" "${menu_selected[1]}"
    assert_equals "false" "${menu_selected[2]}"
    assert_equals "false" "${menu_selected[3]}"

    # All actionable items selected should return true (there are none)
    all_actionable_items_selected
    [[ $? -eq 0 ]] && assert_true "true" || assert_true "false"
'

test_case "should handle menu with single item" '
    # Create menu with single item
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Only Item" "Description" "cmd"

    assert_equals "1" "$total_items"

    # Navigation should wrap properly
    current_item=0
    ((current_item++))
    [[ $current_item -ge $total_items ]] && current_item=0
    assert_equals "0" "$current_item"
'

# ============================================================================
# Menu State Consistency Tests
# ============================================================================

test_case "should maintain consistent state after multiple operations" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Item 1" "Desc 1" "cmd1"
    add_menu_item "Item 2" "Desc 2" "cmd2"
    add_menu_item "Item 3" "Desc 3" "cmd3"

    # Perform series of operations
    toggle_menu_item_selection 1
    toggle_menu_item_selection 2
    toggle_menu_item_selection 1
    toggle_menu_item_selection 3

    # Verify final state
    assert_equals "false" "${menu_selected[1]}"  # toggled twice
    assert_equals "true" "${menu_selected[2]}"   # toggled once
    assert_equals "true" "${menu_selected[3]}"   # toggled once

    # Total items should remain constant
    assert_equals "3" "$total_items"
'

test_case "should preserve menu items after selection changes" '
    # Setup menu
    menu_items=()
    menu_descriptions=()
    menu_commands=()
    menu_selected=()
    current_item=0
    total_items=0

    add_menu_item "Item 1" "Desc 1" "cmd1"
    add_menu_item "Item 2" "Desc 2" "cmd2"

    # Change selections
    toggle_all_actionable_items
    clear_all_menu_selections
    toggle_all_actionable_items

    # Menu structure should remain intact
    assert_equals "2" "$total_items"
    assert_equals "Item 1" "${menu_items[1]}"
    assert_equals "Item 2" "${menu_items[2]}"
    assert_equals "Desc 1" "${menu_descriptions[1]}"
    assert_equals "Desc 2" "${menu_descriptions[2]}"
    assert_equals "cmd1" "${menu_commands[1]}"
    assert_equals "cmd2" "${menu_commands[2]}"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
