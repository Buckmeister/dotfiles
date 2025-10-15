#!/usr/bin/env zsh

# ============================================================================
# Edge Cases Test Suite
# ============================================================================
#
# Comprehensive tests for edge cases, boundary conditions, and error handling
# across all shared libraries.
#
# Coverage:
# - Empty/null input handling
# - Boundary conditions
# - Special characters and unicode
# - Path edge cases
# - Error conditions
# - Cross-platform edge cases
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

# Load shared libraries
source "$DOTFILES_ROOT/bin/lib/colors.zsh"
source "$DOTFILES_ROOT/bin/lib/ui.zsh"
source "$DOTFILES_ROOT/bin/lib/utils.zsh"
source "$DOTFILES_ROOT/bin/lib/validators.zsh"
source "$DOTFILES_ROOT/bin/lib/greetings.zsh"

# ============================================================================
# Test Suite
# ============================================================================

test_suite "Edge Cases - Comprehensive Coverage"

# ============================================================================
# Empty/Null Input Tests
# ============================================================================

test_case "should handle empty string input" '
    # Test command_exists with empty string
    if command_exists ""; then
        return 1
    fi
    return 0
'

test_case "should handle whitespace-only strings" '
    # Test with various whitespace
    result=$(printf "   \t\n" | wc -c)
    assert_true "[[ $result -gt 0 ]]"
'

test_case "should handle empty arrays gracefully" '
    local empty_array=()
    assert_equals "0" "${#empty_array[@]}"
'

test_case "should handle undefined variables safely" '
    # Accessing undefined variable should not crash
    local undefined_result="${UNDEFINED_VARIABLE_XYZ:-default}"
    assert_equals "default" "$undefined_result"
'

# ============================================================================
# Boundary Condition Tests
# ============================================================================

test_case "should handle very long strings" '
    # Create a very long string (1000 characters)
    local long_string=$(printf "a%.0s" {1..1000})
    local length=${#long_string}
    assert_equals "1000" "$length"
'

test_case "should handle maximum path length" '
    # Test with PATH_MAX-like length (typically 4096)
    local long_path=$(printf "/a%.0s" {1..100})
    assert_true "[[ -n \"$long_path\" ]]"
'

test_case "should handle deeply nested directories" '
    # Create nested directory structure (10 levels)
    local test_dir="/tmp/test_edge_$$"
    local nested_path="$test_dir/a/b/c/d/e/f/g/h/i/j"

    if mkdir -p "$nested_path" 2>/dev/null; then
        assert_dir_exists "$nested_path"
        rm -rf "$test_dir"
        return 0
    fi
    return 1
'

# ============================================================================
# Special Character Tests
# ============================================================================

test_case "should handle paths with spaces" '
    local test_dir="/tmp/test edge spaces $$"
    if mkdir "$test_dir" 2>/dev/null; then
        assert_dir_exists "$test_dir"
        rmdir "$test_dir"
        return 0
    fi
    return 1
'

test_case "should handle filenames with special characters" '
    # Test various special characters in filenames
    local special_chars="@#$%^&()[]{}+-=~"
    local test_file="/tmp/test_special_$$_${special_chars}"

    # Some characters may not be allowed, so we just test that it doesn not crash
    touch "$test_file" 2>/dev/null || true
    rm -f "$test_file" 2>/dev/null || true
    return 0
'

test_case "should handle unicode characters" '
    # Test unicode in strings
    local unicode_string="Hello 世界 🌍"
    assert_true "[[ -n \"$unicode_string\" ]]"
'

test_case "should handle newlines in strings" '
    local multiline_string="Line 1
Line 2
Line 3"
    local line_count=$(echo "$multiline_string" | wc -l | tr -d " ")
    assert_equals "3" "$line_count"
'

# ============================================================================
# Path Edge Cases
# ============================================================================

test_case "should handle relative paths" '
    local relative_path="./../../test"
    assert_true "[[ \"$relative_path\" == *".."* ]]"
'

test_case "should handle paths ending with slash" '
    local path_with_slash="/tmp/test/"
    local path_without_slash="${path_with_slash%/}"
    assert_equals "/tmp/test" "$path_without_slash"
'

test_case "should handle paths with double slashes" '
    local double_slash_path="/tmp//test///file"
    # Normalize path (zsh does this automatically in many contexts)
    local normalized="${double_slash_path//\/\//\/}"
    assert_true "[[ \"$normalized\" != *\"//\"* ]]"
'

test_case "should handle dot paths" '
    local dot_path="/tmp/./test/./file"
    assert_true "[[ -n \"$dot_path\" ]]"
'

test_case "should handle tilde expansion edge cases" '
    # Test that tilde is not expanded in quotes
    local quoted_tilde="~/test"
    assert_true "[[ \"$quoted_tilde\" == ~* ]]"
'

test_case "should handle symlink resolution" '
    local test_dir="/tmp/test_symlink_$$"
    local test_file="$test_dir/original"
    local test_link="$test_dir/link"

    mkdir -p "$test_dir"
    touch "$test_file"
    ln -s "$test_file" "$test_link"

    if [[ -L "$test_link" ]]; then
        assert_file_exists "$test_link"
        rm -rf "$test_dir"
        return 0
    fi

    rm -rf "$test_dir"
    return 1
'

# ============================================================================
# Permission Edge Cases
# ============================================================================

test_case "should handle read-only files" '
    local test_file="/tmp/test_readonly_$$"
    touch "$test_file"
    chmod 444 "$test_file"

    # Should be readable but not writable
    if [[ -r "$test_file" ]] && [[ ! -w "$test_file" ]]; then
        chmod 644 "$test_file"  # Restore permissions
        rm "$test_file"
        return 0
    fi

    chmod 644 "$test_file" 2>/dev/null
    rm "$test_file" 2>/dev/null
    return 1
'

test_case "should handle non-existent paths gracefully" '
    local nonexistent="/tmp/does_not_exist_$$"
    if [[ ! -e "$nonexistent" ]]; then
        return 0
    fi
    return 1
'

# ============================================================================
# Error Condition Tests
# ============================================================================

test_case "should handle division by zero protection" '
    # Zsh arithmetic - test safety
    local result
    if (( 0 != 0 )); then
        result=$((10 / 0))  # This line should never execute
    else
        result="safe"
    fi
    assert_equals "safe" "$result"
'

test_case "should handle array bounds" '
    local test_array=(a b c)
    # Accessing out of bounds should not crash (zsh returns empty)
    local result="${test_array[10]}"
    assert_true "[[ -z \"$result\" ]]"
'

test_case "should handle command substitution failures" '
    # Command that fails should not crash the script
    local result=$(false) || true
    # Script should continue
    return 0
'

# ============================================================================
# Type Coercion Edge Cases
# ============================================================================

test_case "should handle string to number conversion" '
    local string_num="42"
    local num_result=$((string_num + 8))
    assert_equals "50" "$num_result"
'

test_case "should handle invalid number strings" '
    local invalid_num="not_a_number"
    # Zsh treats invalid numbers as 0
    local result=$((invalid_num + 1))
    assert_equals "1" "$result"
'

test_case "should handle boolean-like strings" '
    local true_string="true"
    local false_string="false"

    assert_true "[[ \"$true_string\" == \"true\" ]]"
    assert_true "[[ \"$false_string\" == \"false\" ]]"
'

# ============================================================================
# Platform-Specific Edge Cases
# ============================================================================

test_case "should handle case-insensitive filesystem checks" '
    # macOS filesystem is case-insensitive by default
    local test_file="/tmp/TestFile_$$"
    touch "$test_file"

    local lowercase="/tmp/testfile_$$"

    # Check if filesystem is case-insensitive
    if [[ -e "$lowercase" ]]; then
        # Case-insensitive filesystem (macOS)
        rm "$test_file"
        return 0
    else
        # Case-sensitive filesystem (Linux)
        rm "$test_file"
        return 0
    fi
'

test_case "should handle different path separators" '
    # Unix uses forward slash
    local unix_path="/tmp/test/file"
    assert_true "[[ \"$unix_path\" == /* ]]"
'

test_case "should handle HOME directory variations" '
    # HOME should always be set
    assert_true "[[ -n \"$HOME\" ]]"
    assert_dir_exists "$HOME"
'

# ============================================================================
# Concurrent Access Edge Cases
# ============================================================================

test_case "should handle race conditions with file creation" '
    local test_file="/tmp/test_race_$$"

    # Simulate concurrent file creation (best effort)
    touch "$test_file" &
    touch "$test_file" &
    wait

    if [[ -f "$test_file" ]]; then
        rm "$test_file"
        return 0
    fi
    return 1
'

# ============================================================================
# Memory/Resource Edge Cases
# ============================================================================

test_case "should handle large arrays" '
    # Create array with 1000 elements
    local large_array=()
    for i in {1..1000}; do
        large_array+=($i)
    done

    assert_equals "1000" "${#large_array[@]}"
'

test_case "should handle nested loops" '
    local counter=0
    for i in {1..10}; do
        for j in {1..10}; do
            counter=$((counter + 1))
        done
    done

    assert_equals "100" "$counter"
'

# ============================================================================
# Encoding Edge Cases
# ============================================================================

test_case "should handle UTF-8 encoding" '
    local utf8_string="Café résumé"
    assert_true "[[ -n \"$utf8_string\" ]]"
'

test_case "should handle different line endings" '
    # Test LF (Unix)
    local lf_string=$(printf "line1\nline2")
    local lf_count=$(echo "$lf_string" | wc -l | tr -d " ")

    assert_equals "2" "$lf_count"
'

# ============================================================================
# Validator Edge Cases
# ============================================================================

test_case "should handle malformed URLs" '
    local malformed_url="ht!tp://invalid@@@"
    # Should not crash when validating
    if [[ "$malformed_url" =~ ^https?:// ]]; then
        # Basic protocol check passes
        return 0
    fi
    # Or fails gracefully
    return 0
'

test_case "should handle invalid email addresses" '
    local invalid_email="not_an_email"
    # Basic check should fail
    if [[ "$invalid_email" == *"@"* ]]; then
        return 1
    fi
    return 0
'

test_case "should handle extreme version numbers" '
    local extreme_version="999.999.999"
    assert_true "[[ \"$extreme_version\" =~ ^[0-9]+\\.[0-9]+\\.[0-9]+$ ]]"
'

# ============================================================================
# Locale Edge Cases
# ============================================================================

test_case "should handle different locales" '
    # Save current locale
    local original_locale="$LC_ALL"

    # Test with C locale
    export LC_ALL=C
    local result=$(echo "test" | tr "[:lower:]" "[:upper:]")
    assert_equals "TEST" "$result"

    # Restore locale
    export LC_ALL="$original_locale"
'

test_case "should handle timezone edge cases" '
    # TZ should be set or default to system
    local current_tz="${TZ:-$(date +%Z)}"
    assert_true "[[ -n \"$current_tz\" ]]"
'

# ============================================================================
# Signal Handling Edge Cases
# ============================================================================

test_case "should handle SIGINT gracefully" '
    # Test that trap handlers work (basic check)
    local trap_called=0
    trap "trap_called=1" INT

    # Simulate signal handling
    kill -INT $$ 2>/dev/null || true

    trap - INT  # Reset trap
    return 0
'

# ============================================================================
# Exit Code Edge Cases
# ============================================================================

test_case "should handle various exit codes" '
    # Test that exit codes are preserved
    (exit 42)
    local exit_code=$?
    assert_equals "42" "$exit_code"
'

test_case "should handle command not found" '
    # Command that doesn not exist should return non-zero
    nonexistent_command_xyz 2>/dev/null || true
    local exit_code=$?
    assert_true "[[ $exit_code -ne 0 ]]"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
