#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for utils.zsh Library
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Load library under test
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_ROOT/bin/lib/colors.zsh"
source "$DOTFILES_ROOT/bin/lib/utils.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "utils.zsh Library"

# ============================================================================
# Test Cases
# ============================================================================

test_case "command_exists should return true for existing commands" '
    if command_exists ls; then
        return 0
    else
        echo "command_exists failed for ls"
        return 1
    fi
'

test_case "command_exists should return false for non-existing commands" '
    if command_exists this_command_definitely_does_not_exist_12345; then
        echo "command_exists returned true for non-existent command"
        return 1
    else
        return 0
    fi
'

test_case "get_timestamp should return formatted timestamp" '
    local timestamp=$(get_timestamp)
    assert_not_equals "" "$timestamp" "Timestamp should not be empty"

    # Check format YYYYMMDD-HHMMSS (20 characters)
    local length=${#timestamp}
    if [[ $length -eq 15 ]]; then
        return 0
    else
        echo "Timestamp format incorrect: $timestamp (length: $length)"
        return 1
    fi
'

test_case "get_os should detect darwin on macOS" '
    local detected_os=$(get_os)
    # This test is macOS-specific since we are running on macOS
    assert_equals "macos" "$detected_os" "Should detect macOS"
'

test_case "create_directory_safe should create directory" '
    local test_dir="/tmp/test_dotfiles_dir_$$"

    create_directory_safe "$test_dir" >/dev/null 2>&1

    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
        return 0
    else
        echo "create_directory_safe failed to create directory"
        return 1
    fi
'

test_case "create_directory_safe should handle existing directory" '
    local test_dir="/tmp/test_dotfiles_existing_$$"
    mkdir -p "$test_dir"

    create_directory_safe "$test_dir" >/dev/null 2>&1
    local result=$?

    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
        assert_exit_code 0 $result "Should handle existing directory"
    else
        return 1
    fi
'

test_case "path_exists should detect existing paths" '
    # Test with a path that should always exist
    if path_exists "/tmp"; then
        return 0
    else
        echo "path_exists failed to detect /tmp"
        return 1
    fi
'

test_case "expand_path should expand tilde" '
    local expanded=$(expand_path "~/test")
    assert_contains "$expanded" "$HOME" "Should expand tilde to HOME"
'

test_case "should set DOTFILES_UTILS_LOADED flag" '
    assert_equals "1" "$DOTFILES_UTILS_LOADED" "DOTFILES_UTILS_LOADED should be set"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
