#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for Menu Engine Components
# ============================================================================
#
# Tests the hierarchical menu system components:
# - menu_engine.zsh - Core rendering and data structures
# - menu_state.zsh - State management and navigation stack
#
# Usage: ./tests/unit/test_menu_engine.zsh
# ============================================================================

# Note: emulate -LR zsh removed to prevent array scoping issues in tested functions

# ============================================================================
# Test Framework Setup
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DF_DIR="$(cd "$TEST_ROOT/.." && pwd)"

# Load test framework
source "$TEST_ROOT/lib/test_framework.zsh" 2>/dev/null || {
    echo "❌ Error: test_framework.zsh not found"
    exit 1
}

# Load libraries needed for menu system
export LIB_DIR="$DF_DIR/bin/lib"

source "$LIB_DIR/colors.zsh" 2>/dev/null || {
    readonly COLOR_RESET='\033[0m'
    readonly UI_SUCCESS_COLOR='\033[32m'
    readonly UI_ERROR_COLOR='\033[31m'
}

source "$LIB_DIR/ui.zsh" 2>/dev/null || {
    function print_success() { echo "✅ $1"; }
    function print_error() { echo "❌ $1"; }
}

# Load menu system modules
source "$LIB_DIR/menu_engine.zsh" || {
    echo "❌ Error: menu_engine.zsh not found"
    exit 1
}

source "$LIB_DIR/menu_state.zsh" || {
    echo "❌ Error: menu_state.zsh not found"
    exit 1
}

# ============================================================================
# Define Test Suite
# ============================================================================

test_suite "Menu Engine Unit Tests"

# ============================================================================
# Menu Engine Tests
# ============================================================================

test_case "menu_engine_add_item should add items correctly" '
    menu_engine_clear_items
    menu_engine_add_item "Test Item" "Test Description" "$MENU_TYPE_ACTION" "echo test" "🔧" "test_id"

    assert_equals "1" "$MENU_TOTAL_ITEMS" "Total items should be 1"
    assert_equals "Test Item" "${MENU_ITEMS[1]}" "Item title should match"
    assert_equals "Test Description" "${MENU_DESCRIPTIONS[1]}" "Item description should match"
    assert_equals "$MENU_TYPE_ACTION" "${MENU_TYPES[1]}" "Item type should match"
'

test_case "menu_engine_clear_items should reset all arrays" '
    menu_engine_add_item "Item 1" "Desc 1" "$MENU_TYPE_ACTION"
    menu_engine_add_item "Item 2" "Desc 2" "$MENU_TYPE_ACTION"

    assert_equals "2" "$MENU_TOTAL_ITEMS" "Should have 2 items before clear"

    menu_engine_clear_items

    assert_equals "0" "$MENU_TOTAL_ITEMS" "Total items should be 0 after clear"
'

test_case "menu_engine_validate_index should validate indices correctly" '
    menu_engine_clear_items
    menu_engine_add_item "Item 1" "Desc 1" "$MENU_TYPE_ACTION"
    menu_engine_add_item "Item 2" "Desc 2" "$MENU_TYPE_ACTION"

    menu_engine_validate_index 1
    assert_exit_code 0 $? "Index 1 should be valid"

    menu_engine_validate_index 2
    assert_exit_code 0 $? "Index 2 should be valid"

    menu_engine_validate_index 0
    assert_exit_code 1 $? "Index 0 should be invalid"

    menu_engine_validate_index 3
    assert_exit_code 1 $? "Index 3 should be invalid"
'

test_case "menu_engine_get_item_property should retrieve properties" '
    menu_engine_clear_items
    menu_engine_add_item "My Item" "My Description" "$MENU_TYPE_ACTION" "my_command" "🎯" "my_id"

    title=$(menu_engine_get_item_property 1 "title")
    desc=$(menu_engine_get_item_property 1 "description")
    type=$(menu_engine_get_item_property 1 "type")

    assert_equals "My Item" "$title" "Title should match"
    assert_equals "My Description" "$desc" "Description should match"
    assert_equals "$MENU_TYPE_ACTION" "$type" "Type should match"
'

test_case "menu_engine_toggle_selection should toggle selection state" '
    menu_engine_clear_items
    menu_engine_add_item "Item 1" "Desc 1" "$MENU_TYPE_MULTI_SELECT"

    assert_equals "false" "${MENU_SELECTED[1]}" "Initially should be unselected"

    menu_engine_toggle_selection 1
    assert_equals "true" "${MENU_SELECTED[1]}" "Should be selected after first toggle"

    menu_engine_toggle_selection 1
    assert_equals "false" "${MENU_SELECTED[1]}" "Should be unselected after second toggle"
'

test_case "menu_engine navigation should move cursor correctly" '
    menu_engine_clear_items
    menu_engine_add_item "Item 1" "Desc 1" "$MENU_TYPE_ACTION"
    menu_engine_add_item "Item 2" "Desc 2" "$MENU_TYPE_ACTION"
    menu_engine_add_item "Item 3" "Desc 3" "$MENU_TYPE_ACTION"

    MENU_CURRENT_ITEM=0

    menu_engine_move_down
    assert_equals "1" "$MENU_CURRENT_ITEM" "Should move to item 1"

    menu_engine_move_down
    assert_equals "2" "$MENU_CURRENT_ITEM" "Should move to item 2"

    menu_engine_move_down
    assert_equals "0" "$MENU_CURRENT_ITEM" "Should wrap to item 0"

    menu_engine_move_up
    assert_equals "2" "$MENU_CURRENT_ITEM" "Should wrap to last item"
'

test_case "menu_engine_is_navigable should identify navigable types" '
    menu_engine_is_navigable "$MENU_TYPE_CATEGORY"
    assert_exit_code 0 $? "Category should be navigable"

    menu_engine_is_navigable "$MENU_TYPE_SUBMENU"
    assert_exit_code 0 $? "Submenu should be navigable"

    menu_engine_is_navigable "$MENU_TYPE_ACTION"
    assert_exit_code 1 $? "Action should not be navigable"
'

test_case "menu_engine_is_selectable should identify selectable types" '
    menu_engine_is_selectable "$MENU_TYPE_MULTI_SELECT"
    assert_exit_code 0 $? "Multi-select should be selectable"

    menu_engine_is_selectable "$MENU_TYPE_ACTION"
    assert_exit_code 1 $? "Action should not be selectable"
'

test_case "menu_engine_select_all should select only multi-select items" '
    menu_engine_clear_items
    menu_engine_add_item "Item 1" "Desc 1" "$MENU_TYPE_MULTI_SELECT"
    menu_engine_add_item "Item 2" "Desc 2" "$MENU_TYPE_ACTION"
    menu_engine_add_item "Item 3" "Desc 3" "$MENU_TYPE_MULTI_SELECT"

    menu_engine_select_all

    assert_equals "true" "${MENU_SELECTED[1]}" "Multi-select item 1 should be selected"
    assert_equals "false" "${MENU_SELECTED[2]}" "Action item should not be selected"
    assert_equals "true" "${MENU_SELECTED[3]}" "Multi-select item 3 should be selected"
'

test_case "menu_engine_count_selected should count selected items" '
    menu_engine_clear_items
    menu_engine_add_item "Item 1" "Desc 1" "$MENU_TYPE_MULTI_SELECT"
    menu_engine_add_item "Item 2" "Desc 2" "$MENU_TYPE_MULTI_SELECT"
    menu_engine_add_item "Item 3" "Desc 3" "$MENU_TYPE_MULTI_SELECT"

    count=$(menu_engine_count_selected)
    assert_equals "0" "$count" "Initially should have 0 selected"

    menu_engine_toggle_selection 1
    menu_engine_toggle_selection 3

    count=$(menu_engine_count_selected)
    assert_equals "2" "$count" "Should have 2 selected"
'

# ============================================================================
# Menu State Tests
# ============================================================================

test_case "menu_state_init should initialize state" '
    menu_state_init "main_menu" "Main Menu"

    current_id=$(menu_state_get_current_id)
    current_title=$(menu_state_get_current_title)
    depth=$(menu_state_get_depth)

    assert_equals "main_menu" "$current_id" "Current ID should be set"
    assert_equals "Main Menu" "$current_title" "Current title should be set"
    assert_equals "0" "$depth" "Depth should be 0 at root"

    menu_state_is_root
    assert_exit_code 0 $? "Should be at root"
'

test_case "menu_state push and pop should manage navigation stack" '
    menu_state_init "main" "Main"

    menu_state_push "submenu1" "Submenu 1"
    depth=$(menu_state_get_depth)
    assert_equals "1" "$depth" "Depth should be 1"

    menu_state_is_root
    assert_exit_code 1 $? "Should not be at root"

    menu_state_push "submenu2" "Submenu 2"
    depth=$(menu_state_get_depth)
    assert_equals "2" "$depth" "Depth should be 2"

    # Call without command substitution to avoid subshell (array modifications must happen in current shell)
    menu_state_pop > /dev/null

    # Verify we returned to submenu1
    current_id=$(menu_state_get_current_id)
    assert_equals "submenu1" "$current_id" "Should return to submenu1"

    depth=$(menu_state_get_depth)
    assert_equals "1" "$depth" "Depth should be 1 after pop"
'

test_case "menu_state_get_breadcrumb should generate correct trail" '
    menu_state_init "main" "Main Menu"
    breadcrumb=$(menu_state_get_breadcrumb)
    assert_equals "Main Menu" "$breadcrumb" "Root breadcrumb should be just main"

    menu_state_push "sub1" "Submenu 1"
    breadcrumb=$(menu_state_get_breadcrumb)
    assert_contains "$breadcrumb" "Main Menu" "Breadcrumb should contain Main Menu"
    assert_contains "$breadcrumb" "Submenu 1" "Breadcrumb should contain Submenu 1"
'

test_case "menu_state cursor memory should save and restore positions" '
    menu_state_init "main" "Main"

    menu_state_save_cursor 5
    restored=$(menu_state_restore_cursor "main")
    assert_equals "5" "$restored" "Should restore saved cursor position"

    menu_state_push "sub1" "Submenu 1"
    menu_state_save_cursor 3
    restored=$(menu_state_restore_cursor "sub1")
    assert_equals "3" "$restored" "Should restore submenu cursor position"

    restored=$(menu_state_restore_cursor "main")
    assert_equals "5" "$restored" "Should still have main menu cursor position"
'

test_case "menu_state_get_parent_id should return parent menu ID" '
    menu_state_init "main" "Main"

    # At root, should fail
    menu_state_get_parent_id 2>/dev/null
    assert_exit_code 1 $? "Should fail at root"

    menu_state_push "sub1" "Submenu 1"
    parent=$(menu_state_get_parent_id)
    assert_equals "main" "$parent" "Parent should be main"

    menu_state_push "sub2" "Submenu 2"
    parent=$(menu_state_get_parent_id)
    assert_equals "sub1" "$parent" "Parent should be sub1"
'

# ============================================================================
# Run All Tests
# ============================================================================

# Run tests if executed directly
if [[ "${(%):-%N}" == "$0" || "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
