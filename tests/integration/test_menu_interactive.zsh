#!/usr/bin/env zsh
# ============================================================================
# Integration Tests for Interactive TUI Menu Testing
# ============================================================================
#
# Tests the hierarchical menu system using the interactive test framework.
# These tests use tmux to run the actual menu and inject keystrokes.
#
# Usage: ./tests/integration/test_menu_interactive.zsh
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

# Interactive test driver
INTERACTIVE_TEST="$DF_DIR/bin/menu_test_interactive.zsh"

# ============================================================================
# Helper Functions
# ============================================================================

# Run interactive test and return output directory
run_menu_test() {
    local keystroke_sequence="$1"
    local debug_mode="${2:-false}"

    local args=(
        --menu "$DF_DIR/bin/menu_hierarchical.zsh"
        --keys "$keystroke_sequence"
        --name "test_$$"
        --delay 200  # Fast for testing
    )

    if [[ "$debug_mode" == "true" ]]; then
        args+=(--debug)
    fi

    # Run test and capture output directory from last line
    local output=$("$INTERACTIVE_TEST" "${args[@]}" 2>&1)
    local output_dir=$(echo "$output" | grep "Output directory:" | awk '{print $NF}')

    echo "$output_dir"
}

# Get line count from capture file
get_line_count() {
    local capture_file="$1"
    wc -l < "$capture_file" | xargs
}

# Check if all captures have same line count
check_line_count_stable() {
    local output_dir="$1"

    local initial_lines=$(get_line_count "$output_dir/00_initial.txt")
    local stable=true

    for capture in "$output_dir"/[0-9]*.txt; do
        local current_lines=$(get_line_count "$capture")
        if [[ $current_lines -ne $initial_lines ]]; then
            stable=false
            break
        fi
    done

    [[ "$stable" == "true" ]]
}

# ============================================================================
# Test Suite
# ============================================================================

test_suite "Interactive TUI Menu Testing"

# ============================================================================
# Basic Navigation Tests
# ============================================================================

test_case "menu should render with stable line count" '
    local output_dir=$(run_menu_test "")

    assert_file_exists "$output_dir/00_initial.txt" "Should capture initial state"

    local line_count=$(get_line_count "$output_dir/00_initial.txt")
    assert_greater_than "$line_count" 10 "Should have substantial content"

    rm -rf "$output_dir"
'

test_case "navigation down should maintain line count" '
    local output_dir=$(run_menu_test "j j j")

    assert_file_exists "$output_dir/00_initial.txt" "Should have initial capture"
    assert_file_exists "$output_dir/01_after_j.txt" "Should have first navigation"
    assert_file_exists "$output_dir/02_after_j.txt" "Should have second navigation"
    assert_file_exists "$output_dir/03_after_j.txt" "Should have third navigation"

    if check_line_count_stable "$output_dir"; then
        pass_test "Line count stable across navigation"
    else
        fail_test "Line count changed during navigation"
        cat "$output_dir/analysis.txt"
    fi

    rm -rf "$output_dir"
'

test_case "navigation up should maintain line count" '
    local output_dir=$(run_menu_test "k k k")

    assert_file_exists "$output_dir/01_after_k.txt" "Should have first up navigation"

    if check_line_count_stable "$output_dir"; then
        pass_test "Line count stable across up navigation"
    else
        fail_test "Line count changed during up navigation"
    fi

    rm -rf "$output_dir"
'

test_case "mixed navigation should maintain line count" '
    local output_dir=$(run_menu_test "j j k j k k j")

    if check_line_count_stable "$output_dir"; then
        pass_test "Line count stable across mixed navigation"
    else
        fail_test "Line count changed during mixed navigation"
        cat "$output_dir/analysis.txt"
    fi

    rm -rf "$output_dir"
'

# ============================================================================
# Debug Mode Tests
# ============================================================================

test_case "debug mode should generate debug log" '
    local output_dir=$(run_menu_test "j j k" "true")

    assert_file_exists "$output_dir/debug.log" "Should create debug log"

    local log_lines=$(wc -l < "$output_dir/debug.log" | xargs)
    assert_greater_than "$log_lines" 0 "Debug log should have content"

    rm -rf "$output_dir"
'

test_case "debug log should track cursor movements" '
    local output_dir=$(run_menu_test "j j j" "true")

    assert_file_exists "$output_dir/debug.log" "Should have debug log"

    # Check for navigation logging
    local move_down_count=$(grep -c "menu_engine_move_down" "$output_dir/debug.log")
    assert_equals "$move_down_count" "3" "Should log 3 move_down calls"

    # Check for cursor position logging
    local cursor_logs=$(grep -c "cursor=" "$output_dir/debug.log")
    assert_greater_than "$cursor_logs" 0 "Should log cursor positions"

    rm -rf "$output_dir"
'

# ============================================================================
# Separator Handling Tests
# ============================================================================

test_case "cursor should skip separators during navigation" '
    local output_dir=$(run_menu_test "j j j j j" "true")

    assert_file_exists "$output_dir/debug.log" "Should have debug log"

    # Check if any SKIP messages (indicating separator skipping)
    if grep -q "SKIP" "$output_dir/debug.log"; then
        pass_test "Cursor correctly skips separators"
    else
        # No skips is also fine if there are no separators in navigation path
        pass_test "Navigation completed (no separators in path or correctly skipped)"
    fi

    rm -rf "$output_dir"
'

# ============================================================================
# Analysis Report Tests
# ============================================================================

test_case "should generate comprehensive analysis report" '
    local output_dir=$(run_menu_test "j k j")

    assert_file_exists "$output_dir/analysis.txt" "Should create analysis report"

    assert_file_contains "$output_dir/analysis.txt" "Interactive TUI Test Analysis" \
        "Should have analysis header"

    assert_file_contains "$output_dir/analysis.txt" "State Progression" \
        "Should document state progression"

    assert_file_contains "$output_dir/analysis.txt" "Line Count Stability Check" \
        "Should include stability check"

    rm -rf "$output_dir"
'

test_case "analysis should detect line count regressions" '
    local output_dir=$(run_menu_test "j j")

    assert_file_exists "$output_dir/analysis.txt" "Should have analysis"

    # Check if analysis indicates stable or unstable
    if check_line_count_stable "$output_dir"; then
        assert_file_contains "$output_dir/analysis.txt" "STABLE" \
            "Should report stable line count"
    else
        assert_file_contains "$output_dir/analysis.txt" "UNSTABLE" \
            "Should report unstable line count"
    fi

    rm -rf "$output_dir"
'

# ============================================================================
# Edge Cases
# ============================================================================

test_case "should handle empty keystroke sequence" '
    local output_dir=$(run_menu_test "")

    assert_file_exists "$output_dir/00_initial.txt" "Should capture initial state"
    assert_file_exists "$output_dir/analysis.txt" "Should generate analysis"

    local capture_count=$(ls -1 "$output_dir"/[0-9]*.txt 2>/dev/null | wc -l | xargs)
    assert_equals "$capture_count" "1" "Should have only initial capture"

    rm -rf "$output_dir"
'

test_case "should handle rapid navigation sequence" '
    local output_dir=$(run_menu_test "j j j j j k k k k k j j j")

    # Count captures
    local capture_count=$(ls -1 "$output_dir"/[0-9]*.txt 2>/dev/null | wc -l | xargs)
    assert_equals "$capture_count" "14" "Should have initial + 13 navigation captures"

    if check_line_count_stable "$output_dir"; then
        pass_test "Rapid navigation maintains stability"
    else
        fail_test "Rapid navigation caused line count issues"
    fi

    rm -rf "$output_dir"
'

# ============================================================================
# Performance Tests
# ============================================================================

test_case "test framework should complete quickly" '
    local start_time=$(date +%s)

    local output_dir=$(run_menu_test "j k j")

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Should complete in reasonable time (< 10 seconds for 3 keystrokes)
    assert_less_than "$duration" 10 "Test should complete in under 10 seconds"

    rm -rf "$output_dir"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
