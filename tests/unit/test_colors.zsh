#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for colors.zsh Library
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

# Load library under test
source "$DOTFILES_ROOT/bin/lib/colors.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "colors.zsh Library"

# ============================================================================
# Test Cases
# ============================================================================

test_case "should define COLOR_RESET" '
    assert_not_equals "" "$COLOR_RESET" "COLOR_RESET should be defined"
'

test_case "should define COLOR_BOLD" '
    assert_not_equals "" "$COLOR_BOLD" "COLOR_BOLD should be defined"
'

test_case "should define OneDark primary colors" '
    assert_not_equals "" "$ONEDARK_FG" "ONEDARK_FG should be defined"
    assert_not_equals "" "$ONEDARK_BG" "ONEDARK_BG should be defined"
    assert_not_equals "" "$ONEDARK_RED" "ONEDARK_RED should be defined"
    assert_not_equals "" "$ONEDARK_GREEN" "ONEDARK_GREEN should be defined"
    assert_not_equals "" "$ONEDARK_YELLOW" "ONEDARK_YELLOW should be defined"
    assert_not_equals "" "$ONEDARK_BLUE" "ONEDARK_BLUE should be defined"
    assert_not_equals "" "$ONEDARK_PURPLE" "ONEDARK_PURPLE should be defined"
    assert_not_equals "" "$ONEDARK_CYAN" "ONEDARK_CYAN should be defined"
    assert_not_equals "" "$ONEDARK_ORANGE" "ONEDARK_ORANGE should be defined"
    assert_not_equals "" "$ONEDARK_GRAY" "ONEDARK_GRAY should be defined"
'

test_case "should define UI semantic colors" '
    assert_not_equals "" "$UI_SUCCESS_COLOR" "UI_SUCCESS_COLOR should be defined"
    assert_not_equals "" "$UI_WARNING_COLOR" "UI_WARNING_COLOR should be defined"
    assert_not_equals "" "$UI_ERROR_COLOR" "UI_ERROR_COLOR should be defined"
    assert_not_equals "" "$UI_INFO_COLOR" "UI_INFO_COLOR should be defined"
    assert_not_equals "" "$UI_HEADER_COLOR" "UI_HEADER_COLOR should be defined"
    assert_not_equals "" "$UI_ACCENT_COLOR" "UI_ACCENT_COLOR should be defined"
    assert_not_equals "" "$UI_PROGRESS_COLOR" "UI_PROGRESS_COLOR should be defined"
'

test_case "should set DOTFILES_COLORS_LOADED flag" '
    assert_equals "1" "$DOTFILES_COLORS_LOADED" "DOTFILES_COLORS_LOADED should be set to 1"
'

test_case "should define terminal control sequences" '
    assert_not_equals "" "$CURSOR_HIDE" "CURSOR_HIDE should be defined"
    assert_not_equals "" "$CURSOR_SHOW" "CURSOR_SHOW should be defined"
    assert_not_equals "" "$CLEAR_SCREEN" "CLEAR_SCREEN should be defined"
    assert_not_equals "" "$CLEAR_LINE" "CLEAR_LINE should be defined"
'

test_case "should prevent multiple loading" '
    # Source again - should be a no-op
    source "$DOTFILES_ROOT/bin/lib/colors.zsh" 2>&1
    local exit_code=$?
    assert_exit_code 0 $exit_code "Should not error on re-sourcing"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
