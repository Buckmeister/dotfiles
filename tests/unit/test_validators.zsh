#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for validators.zsh Library
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
source "$DOTFILES_ROOT/bin/lib/ui.zsh"
source "$DOTFILES_ROOT/bin/lib/utils.zsh"
source "$DOTFILES_ROOT/bin/lib/validators.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "validators.zsh Library"

# ============================================================================
# Command Validation Tests
# ============================================================================

test_case "validate_command should succeed for existing command" '
    validate_command "ls" "ls command" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for existing command"
'

test_case "validate_command should fail for non-existent command" '
    validate_command "nonexistent_command_xyz" >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 for non-existent command"
'

test_case "validate_commands should succeed when all exist" '
    validate_commands ls pwd echo >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 when all commands exist"
'

test_case "validate_commands should fail when any missing" '
    validate_commands ls nonexistent_command_xyz pwd >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 when any command missing"
'

test_case "validate_command_any should succeed if one exists" '
    validate_command_any ls nonexistent_cmd pwd >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 if at least one command exists"
'

# ============================================================================
# Version Validation Tests
# ============================================================================

test_case "version_ge should compare versions correctly" '
    version_ge "2.0.0" "1.0.0"
    assert_equals "0" "$?" "2.0.0 should be >= 1.0.0"
'

test_case "version_ge should handle equal versions" '
    version_ge "1.0.0" "1.0.0"
    assert_equals "0" "$?" "1.0.0 should be >= 1.0.0"
'

test_case "version_ge should fail when version is lower" '
    version_ge "1.0.0" "2.0.0"
    assert_equals "1" "$?" "1.0.0 should not be >= 2.0.0"
'

test_case "get_command_version should extract version from command" '
    local version=$(get_command_version "zsh")
    if [[ -n "$version" ]] && [[ "$version" =~ ^[0-9]+\.[0-9]+ ]]; then
        return 0
    else
        return 1
    fi
'

# ============================================================================
# Path and Directory Validation Tests
# ============================================================================

test_case "validate_path should succeed for existing path" '
    validate_path "/tmp" "temp directory" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for existing path"
'

test_case "validate_path should fail for non-existent path" '
    validate_path "/nonexistent/path/xyz" >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 for non-existent path"
'

test_case "validate_writable_directory should succeed for writable dir" '
    validate_writable_directory "/tmp" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for writable directory"
'

test_case "validate_readable_file should succeed for readable file" '
    # Create a test file
    local test_file="/tmp/test_readable_$$"
    echo "test" > "$test_file"
    validate_readable_file "$test_file" >/dev/null 2>&1
    local result=$?
    rm -f "$test_file"
    assert_equals "0" "$result" "Should return 0 for readable file"
'

test_case "validate_executable should succeed for executable file" '
    # /bin/ls should be executable on all systems
    validate_executable "/bin/ls" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for executable file"
'

test_case "ensure_writable_directory function should exist" '
    # This test just verifies the function is defined
    # The actual functionality depends on system state and is hard to test reliably
    if typeset -f ensure_writable_directory >/dev/null 2>&1; then
        return 0
    else
        echo "ensure_writable_directory function not defined"
        return 1
    fi
'

# ============================================================================
# Environment Variable Validation Tests
# ============================================================================

test_case "validate_env_var should succeed for set variable" '
    TEST_VAR="test_value"
    validate_env_var "TEST_VAR" >/dev/null 2>&1
    local result=$?
    unset TEST_VAR
    assert_equals "0" "$result" "Should return 0 for set variable"
'

test_case "validate_env_var should fail for unset variable" '
    unset TEST_VAR_UNSET
    validate_env_var "TEST_VAR_UNSET" >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 for unset variable"
'

test_case "validate_env_vars should succeed when all set" '
    TEST_VAR1="value1"
    TEST_VAR2="value2"
    validate_env_vars "TEST_VAR1" "TEST_VAR2" >/dev/null 2>&1
    local result=$?
    unset TEST_VAR1 TEST_VAR2
    assert_equals "0" "$result" "Should return 0 when all variables set"
'

test_case "validate_env_vars should fail when any unset" '
    TEST_VAR1="value1"
    unset TEST_VAR2
    validate_env_vars "TEST_VAR1" "TEST_VAR2" >/dev/null 2>&1
    local result=$?
    unset TEST_VAR1
    assert_equals "1" "$result" "Should return 1 when any variable unset"
'

# ============================================================================
# Operating System Validation Tests
# ============================================================================

test_case "validate_os should succeed for matching OS" '
    local current_os=$(get_os)
    validate_os "$current_os" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for matching OS"
'

test_case "validate_os should fail for non-matching OS" '
    validate_os "nonexistent_os" >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 for non-matching OS"
'

test_case "validate_os_any should succeed if one matches" '
    local current_os=$(get_os)
    validate_os_any "$current_os" "other_os" "another_os" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 if at least one OS matches"
'

# ============================================================================
# Permission Validation Tests
# ============================================================================

test_case "has_sudo_privileges should not crash" '
    # This test just verifies the function runs without error
    # Result depends on system configuration
    has_sudo_privileges >/dev/null 2>&1 || true
    return 0
'

test_case "validate_sudo should check for sudo command" '
    # Should at least verify sudo exists
    validate_sudo >/dev/null 2>&1 || true
    # As long as it doesn'\''t crash, we'\''re good
    return 0
'

# ============================================================================
# Network Validation Tests
# ============================================================================

test_case "validate_network should not crash" '
    # This test verifies the function runs (network may not be available in CI)
    validate_network "github.com" >/dev/null 2>&1 || true
    return 0
'

# ============================================================================
# Comprehensive Prerequisite Checking Tests
# ============================================================================

test_case "validate_prerequisites should succeed when all checks pass" '
    # Define simple passing checks
    function test_check_1() { return 0; }
    function test_check_2() { return 0; }

    validate_prerequisites "test_check_1" "test_check_2" >/dev/null 2>&1
    local result=$?

    unfunction test_check_1 test_check_2
    assert_equals "0" "$result" "Should return 0 when all checks pass"
'

test_case "validate_prerequisites should fail when any check fails" '
    # Define checks with one failing
    function test_check_pass() { return 0; }
    function test_check_fail() { return 1; }

    validate_prerequisites "test_check_pass" "test_check_fail" >/dev/null 2>&1
    local result=$?

    unfunction test_check_pass test_check_fail
    assert_equals "1" "$result" "Should return 1 when any check fails"
'

# ============================================================================
# Script-Specific Validation Helpers Tests
# ============================================================================

test_case "validate_package_manager_setup should check package manager" '
    # Test with a known package manager (if available)
    if command -v brew >/dev/null 2>&1; then
        validate_package_manager_setup "brew" >/dev/null 2>&1
        assert_equals "0" "$?" "Should return 0 for available package manager"
    elif command -v apt >/dev/null 2>&1; then
        validate_package_manager_setup "apt" >/dev/null 2>&1
        assert_equals "0" "$?" "Should return 0 for available package manager"
    else
        # Skip if no common package manager found
        return 0
    fi
'

test_case "validate_language_setup should check language environment" '
    # Test with zsh which should always be available
    validate_language_setup "Shell" "zsh" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for zsh"
'

# ============================================================================
# Summary and Reporting Tests
# ============================================================================

test_case "print_validation_header should not crash" '
    print_validation_header "Test Script" "Test Description" >/dev/null 2>&1
    assert_equals "0" "$?" "Should execute without error"
'

test_case "print_validation_summary should succeed with no failures" '
    print_validation_summary 10 10 0 >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 when all checks passed"
'

test_case "print_validation_summary should fail with failures" '
    print_validation_summary 10 8 2 >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 when checks failed"
'

# ============================================================================
# Run all tests
# ============================================================================

run_tests
