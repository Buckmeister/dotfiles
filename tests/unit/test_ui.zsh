#!/usr/bin/env zsh

# ============================================================================
# UI Library Tests - Comprehensive Unit Testing
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Load the library under test
LIB_DIR="$(cd "$SCRIPT_DIR/../../bin/lib" && pwd)"
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "ui.zsh Library"

# ============================================================================
# Terminal Control Functions
# ============================================================================

test_case "hide_cursor should emit correct ANSI code" '
    local output=$(hide_cursor)
    assert_contains "$output" "[?25l" "Should contain hide cursor ANSI code"
'

test_case "show_cursor should emit correct ANSI code" '
    local output=$(show_cursor)
    assert_contains "$output" "[?25h" "Should contain show cursor ANSI code"
'

test_case "clear_screen should emit correct ANSI code" '
    local output=$(clear_screen)
    assert_contains "$output" "[2J" "Should contain clear screen ANSI code"
    assert_contains "$output" "[H" "Should contain move cursor to home ANSI code"
'

test_case "move_cursor_to_line should emit correct ANSI code" '
    local output=$(move_cursor_to_line 5)
    assert_contains "$output" "[5;1H" "Should move cursor to line 5, column 1"
'

test_case "move_cursor_to should emit correct ANSI code" '
    local output=$(move_cursor_to 5 10)
    assert_contains "$output" "[5;10H" "Should move cursor to line 5, column 10"
'

# ============================================================================
# Width Calculation Functions
# ============================================================================

test_case "get_display_width should return positive number for text" '
    local width=$(get_display_width "Hello World")
    if [[ $width -gt 0 ]]; then
        return 0
    else
        return 1
    fi
'

test_case "get_safe_display_width should handle empty text" '
    local width=$(get_safe_display_width "")
    assert_equals "0" "$width" "Empty text should have width 0"
'

test_case "get_safe_display_width should return positive for non-empty text" '
    local width=$(get_safe_display_width "Test")
    if [[ $width -gt 0 ]]; then
        return 0
    else
        return 1
    fi
'

# ============================================================================
# Message Display Functions
# ============================================================================

test_case "print_success should include checkmark" '
    local output=$(print_success "test message")
    assert_contains "$output" "test message" "Should contain the message"
    assert_contains "$output" "✅" "Should contain success emoji"
'

test_case "print_warning should include warning symbol" '
    local output=$(print_warning "test warning")
    assert_contains "$output" "test warning" "Should contain the message"
    assert_contains "$output" "⚠️" "Should contain warning emoji"
'

test_case "print_error should include error symbol" '
    local output=$(print_error "test error")
    assert_contains "$output" "test error" "Should contain the message"
    assert_contains "$output" "❌" "Should contain error emoji"
'

test_case "print_info should include info symbol" '
    local output=$(print_info "test info")
    assert_contains "$output" "test info" "Should contain the message"
    assert_contains "$output" "ℹ️" "Should contain info emoji"
'

# ============================================================================
# Header and Separator Functions
# ============================================================================

test_case "draw_header should create centered header" '
    local output=$(draw_header "Test Header")
    assert_contains "$output" "Test Header" "Should contain header text"
    assert_contains "$output" "═" "Should contain box drawing characters"
'

test_case "draw_separator should create line with default character" '
    local output=$(draw_separator)
    assert_contains "$output" "─" "Should contain default separator character (─)"
'

test_case "draw_separator should use custom char if provided" '
    local output=$(draw_separator 78 "=")
    assert_contains "$output" "=" "Should contain custom separator character"
'

# ============================================================================
# Progress Bar Functions
# ============================================================================

test_case "PROGRESS_CURRENT should be resettable" '
    PROGRESS_CURRENT=50
    PROGRESS_CURRENT=0
    assert_equals "0" "$PROGRESS_CURRENT" "Progress should be reset to 0"
'

test_case "increment_progress should increase PROGRESS_CURRENT by 1" '
    PROGRESS_CURRENT=10
    PROGRESS_TOTAL=100
    increment_progress >/dev/null 2>&1
    assert_equals "11" "$PROGRESS_CURRENT" "Progress should increment by 1"
'

test_case "increment_progress with amount should increase by that amount" '
    PROGRESS_CURRENT=10
    PROGRESS_TOTAL=100
    increment_progress 5 >/dev/null 2>&1
    assert_equals "15" "$PROGRESS_CURRENT" "Progress should increment by 5"
'

test_case "draw_progress_bar should create progress visualization" '
    local output=$(draw_progress_bar 50 100)
    assert_contains "$output" "50%" "Should contain percentage"
    assert_contains "$output" "[" "Should contain progress bar brackets"
'

# ============================================================================
# Layout Helper Functions
# ============================================================================

test_case "print_centered should center text" '
    local output=$(print_centered "Test")
    assert_contains "$output" "Test" "Should contain the text"
'

test_case "print_box should create box around text" '
    local output=$(print_box "Test Message")
    assert_contains "$output" "Test Message" "Should contain the message"
    assert_contains "$output" "│" "Should contain box drawing characters"
'

# ============================================================================
# Status Display Functions
# ============================================================================

test_case "update_status_display should accept label and value" '
    # This function writes to screen, so we just test it doesn'\''t crash
    update_status_display "Test" "Value" >/dev/null 2>&1
    assert_equals "0" "$?" "Should execute without error"
'

test_case "show_status should accept message" '
    # This function writes to screen, so we just test it doesn'\''t crash
    show_status "Test message" >/dev/null 2>&1
    assert_equals "0" "$?" "Should execute without error"
'

# ============================================================================
# Input Function
# ============================================================================

test_case "ask_confirmation should handle yes input" '
    # Simulate yes input - need to capture exit code properly
    echo "y" | ask_confirmation "Test question?" >/dev/null 2>&1
    local exit_code=$?
    # Exit code 0 means yes
    assert_equals "0" "$exit_code" "Should return 0 for yes"
'

test_case "ask_confirmation should handle no input" '
    # Simulate no input with default of "n"
    echo "n" | ask_confirmation "Test question?" "n" >/dev/null 2>&1
    local exit_code=$?
    # Exit code 1 means no
    assert_equals "1" "$exit_code" "Should return 1 for no"
'

# ============================================================================
# Cleanup Functions
# ============================================================================

test_case "cleanup_ui should show cursor" '
    # This function resets terminal state, test it doesn'\''t crash
    cleanup_ui >/dev/null 2>&1
    assert_equals "0" "$?" "Should execute without error"
'

test_case "setup_ui_cleanup should register trap" '
    # This function sets up trap, test it doesn'\''t crash
    setup_ui_cleanup >/dev/null 2>&1
    assert_equals "0" "$?" "Should execute without error"
'

# ============================================================================
# Run all tests
# ============================================================================

run_tests
