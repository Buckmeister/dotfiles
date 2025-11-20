#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Menu Rendering System
# ============================================================================
#
# Tests the hierarchical menu system's programmatic rendering capabilities
# using the menu_render_test.zsh harness.
#
# Usage: ./tests/integration/test_menu_rendering.zsh
# ============================================================================

emulate -LR zsh

# ============================================================================
# Test Framework Setup
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DF_DIR="$(cd "$TEST_ROOT/.." && pwd)"

# Load test framework
source "$TEST_ROOT/lib/test_framework.zsh" 2>/dev/null || {
    echo "❌ Error: test_framework.zsh not found"
    exit 1
}

# Menu render test script
MENU_RENDER="$DF_DIR/bin/menu_render_test.zsh"

# ============================================================================
# Test Suite
# ============================================================================

test_suite "Menu Rendering Integration Tests"

# ============================================================================
# Basic Validation Tests
# ============================================================================

test_case "menu_render_test should list all available menus" '
    local output=$("$MENU_RENDER" --list-menus 2>/dev/null)

    assert_contains "$output" "main_menu" "Should list main_menu"
    assert_contains "$output" "post_install_menu" "Should list post_install_menu"
    assert_contains "$output" "profile_menu" "Should list profile_menu"
    assert_contains "$output" "wizard_menu" "Should list wizard_menu"
    assert_contains "$output" "package_menu" "Should list package_menu"
    assert_contains "$output" "system_tools_menu" "Should list system_tools_menu"
'

test_case "menu_render_test should validate all menus successfully" '
    "$MENU_RENDER" --validate-all 2>&1 >/dev/null
    assert_exit_code 0 $? "All menus should validate"
'

# ============================================================================
# Main Menu Rendering Tests
# ============================================================================

test_case "main menu should render with all expected submenus" '
    local output=$("$MENU_RENDER" --menu-id main_menu 2>/dev/null)

    assert_contains "$output" "Post-Install Scripts" "Should have Post-Install Scripts"
    assert_contains "$output" "Profile Management" "Should have Profile Management"
    assert_contains "$output" "Configuration Wizard" "Should have Configuration Wizard"
    assert_contains "$output" "Package Management" "Should have Package Management"
    assert_contains "$output" "System Tools" "Should have System Tools"
    assert_contains "$output" "Quit" "Should have Quit option"
    assert_contains "$output" "Total Items: 7" "Should have 7 items (including separator)"
'

test_case "main menu should show correct menu IDs" '
    local output=$("$MENU_RENDER" --menu-id main_menu 2>/dev/null)

    assert_contains "$output" "[ID: post_install_menu]" "Should show post_install_menu ID"
    assert_contains "$output" "[ID: profile_menu]" "Should show profile_menu ID"
    assert_contains "$output" "[ID: wizard_menu]" "Should show wizard_menu ID"
    assert_contains "$output" "[ID: package_menu]" "Should show package_menu ID"
    assert_contains "$output" "[ID: system_tools_menu]" "Should show system_tools_menu ID"
'

# ============================================================================
# Submenu Rendering Tests
# ============================================================================

test_case "post_install_menu should list available scripts" '
    local output=$("$MENU_RENDER" --menu-id post_install_menu 2>/dev/null)

    assert_contains "$output" "Link Dotfiles" "Should have Link Dotfiles"
    assert_contains "$output" "[MULTI]" "Should show MULTI type for selectable items"
    # Should have at least 10 items (varies based on installed scripts)
    assert_contains "$output" "Total Items:" "Should show total items count"
'

test_case "profile_menu should show profile management options" '
    local output=$("$MENU_RENDER" --menu-id profile_menu 2>/dev/null)

    assert_contains "$output" "List Profiles" "Should have List Profiles"
    assert_contains "$output" "Show Current Profile" "Should have Show Current Profile"
    assert_contains "$output" "Apply Profile" "Should have Apply Profile"
    assert_contains "$output" "Back" "Should have Back option"
'

test_case "wizard_menu should show wizard options" '
    local output=$("$MENU_RENDER" --menu-id wizard_menu 2>/dev/null)

    assert_contains "$output" "Quick Setup" "Should have Quick Setup"
    assert_contains "$output" "Custom Setup" "Should have Custom Setup"
    assert_contains "$output" "[ACTION]" "Should show ACTION type"
'

test_case "package_menu should show package management options" '
    local output=$("$MENU_RENDER" --menu-id package_menu 2>/dev/null)

    assert_contains "$output" "Generate Manifest" "Should have Generate Manifest"
    assert_contains "$output" "Install from Manifest" "Should have Install from Manifest"
    assert_contains "$output" "Sync Packages" "Should have Sync Packages"
'

test_case "system_tools_menu should show system tools" '
    local output=$("$MENU_RENDER" --menu-id system_tools_menu 2>/dev/null)

    assert_contains "$output" "Link Dotfiles" "Should have Link Dotfiles"
    assert_contains "$output" "Update All" "Should have Update All"
    assert_contains "$output" "Librarian" "Should have Librarian"
    assert_contains "$output" "Backup Repository" "Should have Backup Repository"
'

# ============================================================================
# Output Format Tests
# ============================================================================

test_case "JSON format should produce valid-looking JSON structure" '
    local output=$("$MENU_RENDER" --menu-id main_menu --format json 2>/dev/null)

    assert_contains "$output" "\"menu_id\"" "Should have menu_id field"
    assert_contains "$output" "\"title\"" "Should have title field"
    assert_contains "$output" "\"total_items\"" "Should have total_items field"
    assert_contains "$output" "\"items\"" "Should have items array"
'

test_case "structure format should show tree hierarchy" '
    local output=$("$MENU_RENDER" --menu-id main_menu --format structure 2>/dev/null)

    assert_contains "$output" "Main Menu [main_menu]" "Should show root menu with ID"
    assert_contains "$output" "├─" "Should use tree characters"
    assert_contains "$output" "└─" "Should use tree end character"
'

# ============================================================================
# Error Handling Tests
# ============================================================================

test_case "invalid menu ID should produce error" '
    "$MENU_RENDER" --menu-id nonexistent_menu 2>&1 >/dev/null
    assert_exit_code 1 $? "Should fail for invalid menu ID"
'

test_case "invalid format should produce error" '
    "$MENU_RENDER" --menu-id main_menu --format invalid 2>&1 >/dev/null
    assert_exit_code 1 $? "Should fail for invalid format"
'

# ============================================================================
# Menu Content Integrity Tests
# ============================================================================

test_case "all menus should have Back navigation option" '
    for menu_id in post_install_menu profile_menu wizard_menu package_menu system_tools_menu; do
        local output=$("$MENU_RENDER" --menu-id "$menu_id" 2>/dev/null)
        assert_contains "$output" "Back" "Menu $menu_id should have Back option"
        assert_contains "$output" "[BACK]" "Back option should be marked as BACK type"
    done
'

test_case "main menu should not have Back option" '
    local output=$("$MENU_RENDER" --menu-id main_menu 2>/dev/null)
    assert_not_contains "$output" "[BACK]" "Main menu should not have Back option"
'

test_case "all submenus should have non-zero items" '
    for menu_id in main_menu post_install_menu profile_menu wizard_menu package_menu system_tools_menu; do
        local output=$("$MENU_RENDER" --menu-id "$menu_id" 2>/dev/null)
        assert_not_contains "$output" "Total Items: 0" "Menu $menu_id should have items"
    done
'

# ============================================================================
# Visual Consistency Tests
# ============================================================================

test_case "all menus should have proper headers" '
    for menu_id in main_menu post_install_menu profile_menu wizard_menu package_menu system_tools_menu; do
        local output=$("$MENU_RENDER" --menu-id "$menu_id" 2>/dev/null)
        assert_contains "$output" "═══════════════════════════════════════════════" "Menu $menu_id should have header separator"
    done
'

test_case "all menu items should have icons" '
    local output=$("$MENU_RENDER" --menu-id main_menu 2>/dev/null)
    assert_contains "$output" "📦" "Should have package icon"
    assert_contains "$output" "👤" "Should have profile icon"
    assert_contains "$output" "🧙" "Should have wizard icon"
    assert_contains "$output" "📋" "Should have package mgmt icon"
    assert_contains "$output" "🔧" "Should have tools icon"
    assert_contains "$output" "🚪" "Should have quit icon"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests

