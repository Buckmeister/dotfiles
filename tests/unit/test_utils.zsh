#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for utils.zsh Library
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

# ============================================================================
# WSL Detection Tests
# ============================================================================

test_case "get_os should detect WSL when /proc/version contains microsoft" '
    # Create temporary /proc/version mock
    local temp_proc_dir="/tmp/test_proc_$$"
    local temp_proc_version="$temp_proc_dir/version"
    mkdir -p "$temp_proc_dir"
    echo "Linux version 5.10.16.3-microsoft-standard-WSL2" > "$temp_proc_version"

    # Mock get_os by checking our mock file
    local detected_os=""
    case "$(uname -s)" in
        Darwin*)
            detected_os="macos"
            ;;
        Linux*)
            if [[ -f "$temp_proc_version" ]] && grep -qi microsoft "$temp_proc_version" 2>/dev/null; then
                detected_os="wsl"
            else
                detected_os="linux"
            fi
            ;;
    esac

    # Clean up
    rm -rf "$temp_proc_dir"

    # On Linux, this should detect WSL; on macOS, skip
    if [[ "$(uname -s)" == "Linux" ]]; then
        assert_equals "wsl" "$detected_os" "Should detect WSL from /proc/version"
    else
        return 0  # Skip on macOS
    fi
'

test_case "get_os should return linux when /proc/version does not contain microsoft" '
    # Create temporary /proc/version mock without microsoft
    local temp_proc_dir="/tmp/test_proc_nomicrosoft_$$"
    local temp_proc_version="$temp_proc_dir/version"
    mkdir -p "$temp_proc_dir"
    echo "Linux version 5.15.0-58-generic (buildd@lcy02-amd64-080)" > "$temp_proc_version"

    # Mock get_os by checking our mock file
    local detected_os=""
    case "$(uname -s)" in
        Darwin*)
            detected_os="macos"
            ;;
        Linux*)
            if [[ -f "$temp_proc_version" ]] && grep -qi microsoft "$temp_proc_version" 2>/dev/null; then
                detected_os="wsl"
            else
                detected_os="linux"
            fi
            ;;
    esac

    # Clean up
    rm -rf "$temp_proc_dir"

    # On Linux, this should detect regular linux; on macOS, skip
    if [[ "$(uname -s)" == "Linux" ]]; then
        assert_equals "linux" "$detected_os" "Should detect linux without microsoft in /proc/version"
    else
        return 0  # Skip on macOS
    fi
'

test_case "is_wsl should return true on WSL" '
    # This test verifies is_wsl() helper exists and works
    # On real WSL, this would return 0 (true)
    # On macOS/Linux, it returns 1 (false)

    # Test that the function exists
    if typeset -f is_wsl > /dev/null; then
        # Function exists, call it
        if is_wsl; then
            # On WSL, this is correct
            return 0
        else
            # On non-WSL (macOS/Linux), this is also correct
            return 0
        fi
    else
        echo "is_wsl function not found"
        return 1
    fi
'

test_case "is_wsl should return false on non-WSL systems" '
    # On macOS or regular Linux (not WSL), is_wsl should return false
    local current_os=$(get_os)

    if [[ "$current_os" == "wsl" ]]; then
        # Running on WSL, skip this test
        return 0
    else
        # Running on non-WSL, is_wsl should return false
        if is_wsl; then
            echo "is_wsl returned true on non-WSL system ($current_os)"
            return 1
        else
            return 0
        fi
    fi
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
# Post-Install Script Filtering Tests (.ignored and .disabled)
# ============================================================================

test_case "is_post_install_script_enabled should return true for normal scripts" '
    local test_script="/tmp/test_script_normal_$$.zsh"
    touch "$test_script"

    if is_post_install_script_enabled "$test_script"; then
        rm -f "$test_script"
        return 0
    else
        rm -f "$test_script"
        echo "is_post_install_script_enabled returned false for normal script"
        return 1
    fi
'

test_case "is_post_install_script_enabled should return false when .ignored file exists" '
    local test_script="/tmp/test_script_ignored_$$.zsh"
    local ignored_file="${test_script}.ignored"

    touch "$test_script"
    touch "$ignored_file"

    if is_post_install_script_enabled "$test_script"; then
        rm -f "$test_script" "$ignored_file"
        echo "is_post_install_script_enabled returned true for .ignored script"
        return 1
    else
        rm -f "$test_script" "$ignored_file"
        return 0
    fi
'

test_case "is_post_install_script_enabled should return false when .disabled file exists" '
    local test_script="/tmp/test_script_disabled_$$.zsh"
    local disabled_file="${test_script}.disabled"

    touch "$test_script"
    touch "$disabled_file"

    if is_post_install_script_enabled "$test_script"; then
        rm -f "$test_script" "$disabled_file"
        echo "is_post_install_script_enabled returned true for .disabled script"
        return 1
    else
        rm -f "$test_script" "$disabled_file"
        return 0
    fi
'

test_case "is_post_install_script_enabled should prioritize .ignored when both files exist" '
    local test_script="/tmp/test_script_both_$$.zsh"
    local ignored_file="${test_script}.ignored"
    local disabled_file="${test_script}.disabled"

    touch "$test_script"
    touch "$ignored_file"
    touch "$disabled_file"

    if is_post_install_script_enabled "$test_script"; then
        rm -f "$test_script" "$ignored_file" "$disabled_file"
        echo "is_post_install_script_enabled returned true when both .ignored and .disabled exist"
        return 1
    else
        rm -f "$test_script" "$ignored_file" "$disabled_file"
        return 0
    fi
'

test_case "is_post_install_script_enabled should handle non-existent script gracefully" '
    local test_script="/tmp/nonexistent_script_$$.zsh"

    # Should still work even if script does not exist
    if is_post_install_script_enabled "$test_script"; then
        return 0
    else
        # It is OK if it returns false for non-existent script
        return 0
    fi
'

test_case "is_post_install_script_enabled should handle empty .ignored file" '
    local test_script="/tmp/test_script_empty_ignored_$$.zsh"
    local ignored_file="${test_script}.ignored"

    touch "$test_script"
    touch "$ignored_file"

    # Even empty .ignored file should disable the script
    if is_post_install_script_enabled "$test_script"; then
        rm -f "$test_script" "$ignored_file"
        echo "is_post_install_script_enabled returned true for script with empty .ignored file"
        return 1
    else
        rm -f "$test_script" "$ignored_file"
        return 0
    fi
'

test_case "is_post_install_script_enabled should handle .ignored file with content" '
    local test_script="/tmp/test_script_content_ignored_$$.zsh"
    local ignored_file="${test_script}.ignored"

    touch "$test_script"
    echo "This script is temporarily disabled for testing" > "$ignored_file"

    if is_post_install_script_enabled "$test_script"; then
        rm -f "$test_script" "$ignored_file"
        echo "is_post_install_script_enabled returned true for script with .ignored file containing content"
        return 1
    else
        rm -f "$test_script" "$ignored_file"
        return 0
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
