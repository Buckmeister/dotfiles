#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for arguments.zsh Library
# ============================================================================
# Tests the standardized argument parsing library used across all scripts

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
source "$DOTFILES_ROOT/bin/lib/arguments.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "arguments.zsh Library"

# ============================================================================
# parse_simple_flags() Tests
# ============================================================================

test_case "parse_simple_flags should set ARG_HELP for -h" '
    reset_arg_flags
    parse_simple_flags -h
    assert_equals "true" "$ARG_HELP" "ARG_HELP should be true"
'

test_case "parse_simple_flags should set ARG_HELP for --help" '
    reset_arg_flags
    parse_simple_flags --help
    assert_equals "true" "$ARG_HELP" "ARG_HELP should be true"
'

test_case "parse_simple_flags should set ARG_VERBOSE for -v" '
    reset_arg_flags
    parse_simple_flags -v
    assert_equals "true" "$ARG_VERBOSE" "ARG_VERBOSE should be true"
'

test_case "parse_simple_flags should set ARG_VERBOSE for --verbose" '
    reset_arg_flags
    parse_simple_flags --verbose
    assert_equals "true" "$ARG_VERBOSE" "ARG_VERBOSE should be true"
'

test_case "parse_simple_flags should set ARG_DRY_RUN for -n" '
    reset_arg_flags
    parse_simple_flags -n
    assert_equals "true" "$ARG_DRY_RUN" "ARG_DRY_RUN should be true"
'

test_case "parse_simple_flags should set ARG_DRY_RUN for --dry-run" '
    reset_arg_flags
    parse_simple_flags --dry-run
    assert_equals "true" "$ARG_DRY_RUN" "ARG_DRY_RUN should be true"
'

test_case "parse_simple_flags should set ARG_FORCE for -f" '
    reset_arg_flags
    parse_simple_flags -f
    assert_equals "true" "$ARG_FORCE" "ARG_FORCE should be true"
'

test_case "parse_simple_flags should set ARG_FORCE for --force" '
    reset_arg_flags
    parse_simple_flags --force
    assert_equals "true" "$ARG_FORCE" "ARG_FORCE should be true"
'

test_case "parse_simple_flags should set ARG_SILENT for -s" '
    reset_arg_flags
    parse_simple_flags -s
    assert_equals "true" "$ARG_SILENT" "ARG_SILENT should be true"
'

test_case "parse_simple_flags should set ARG_SILENT for --silent" '
    reset_arg_flags
    parse_simple_flags --silent
    assert_equals "true" "$ARG_SILENT" "ARG_SILENT should be true"
'

test_case "parse_simple_flags should set ARG_UPDATE for --update" '
    reset_arg_flags
    parse_simple_flags --update
    assert_equals "true" "$ARG_UPDATE" "ARG_UPDATE should be true"
'

test_case "parse_simple_flags should set ARG_RESUME for --resume" '
    reset_arg_flags
    parse_simple_flags --resume
    assert_equals "true" "$ARG_RESUME" "ARG_RESUME should be true"
'

test_case "parse_simple_flags should set ARG_RESET for --reset" '
    reset_arg_flags
    parse_simple_flags --reset
    assert_equals "true" "$ARG_RESET" "ARG_RESET should be true"
'

test_case "parse_simple_flags should handle multiple flags" '
    reset_arg_flags
    parse_simple_flags -v -f --dry-run
    if [[ "$ARG_VERBOSE" == "true" ]] && [[ "$ARG_FORCE" == "true" ]] && [[ "$ARG_DRY_RUN" == "true" ]]; then
        return 0
    else
        echo "Not all flags were set correctly"
        return 1
    fi
'

test_case "parse_simple_flags should leave unknown args in place" '
    reset_arg_flags
    parse_simple_flags -h unknown_arg
    # Check that help was parsed
    assert_equals "true" "$ARG_HELP" "ARG_HELP should be true"
'

test_case "parse_simple_flags should not set flags when no args provided" '
    reset_arg_flags
    parse_simple_flags
    if [[ "$ARG_HELP" == "false" ]] && [[ "$ARG_VERBOSE" == "false" ]]; then
        return 0
    else
        echo "Flags should remain false with no args"
        return 1
    fi
'

# ============================================================================
# parse_flag_with_value() Tests
# ============================================================================

test_case "parse_flag_with_value should extract value for flag" '
    reset_arg_flags
    if parse_flag_with_value "--output" --output "myfile.txt"; then
        assert_equals "myfile.txt" "$ARG_VALUE" "ARG_VALUE should be set"
    else
        echo "parse_flag_with_value failed"
        return 1
    fi
'

test_case "parse_flag_with_value should fail when flag not found" '
    reset_arg_flags
    if parse_flag_with_value "--output" --other "value" 2>/dev/null; then
        echo "Should have failed when flag not found"
        return 1
    else
        return 0
    fi
'

test_case "parse_flag_with_value should fail when no value provided" '
    reset_arg_flags
    if parse_flag_with_value "--output" --output 2>/dev/null; then
        echo "Should have failed when no value provided"
        return 1
    else
        return 0
    fi
'

test_case "parse_flag_with_value should handle values with spaces" '
    reset_arg_flags
    if parse_flag_with_value "--output" --output "my file.txt"; then
        assert_equals "my file.txt" "$ARG_VALUE" "Should preserve spaces"
    else
        echo "parse_flag_with_value failed with spaces"
        return 1
    fi
'

# ============================================================================
# parse_subcommand() Tests
# ============================================================================

test_case "parse_subcommand should extract subcommand" '
    reset_arg_flags
    parse_subcommand list --verbose
    assert_equals "list" "$ARG_SUBCOMMAND" "Should extract subcommand"
'

test_case "parse_subcommand should store positional args" '
    reset_arg_flags
    parse_subcommand show arg1 arg2
    if [[ "$ARG_SUBCOMMAND" == "show" ]] && [[ ${#ARG_POSITIONAL[@]} -eq 2 ]]; then
        return 0
    else
        echo "Subcommand or positional args not stored correctly"
        return 1
    fi
'

test_case "parse_subcommand should handle -h as help request" '
    reset_arg_flags
    parse_subcommand -h
    if [[ "$ARG_HELP" == "true" ]] && [[ -z "$ARG_SUBCOMMAND" ]]; then
        return 0
    else
        echo "Should set ARG_HELP and clear ARG_SUBCOMMAND"
        return 1
    fi
'

test_case "parse_subcommand should handle --help as help request" '
    reset_arg_flags
    parse_subcommand --help
    if [[ "$ARG_HELP" == "true" ]] && [[ -z "$ARG_SUBCOMMAND" ]]; then
        return 0
    else
        echo "Should set ARG_HELP and clear ARG_SUBCOMMAND"
        return 1
    fi
'

test_case "parse_subcommand should handle empty args" '
    reset_arg_flags
    parse_subcommand
    if [[ -z "$ARG_SUBCOMMAND" ]] && [[ ${#ARG_POSITIONAL[@]} -eq 0 ]]; then
        return 0
    else
        echo "Should handle empty args gracefully"
        return 1
    fi
'

# ============================================================================
# validate_no_unknown_args() Tests
# ============================================================================

test_case "validate_no_unknown_args should succeed with no args" '
    validate_no_unknown_args >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 with no args"
'

test_case "validate_no_unknown_args should fail with unknown args" '
    validate_no_unknown_args --unknown-flag >/dev/null 2>&1
    assert_equals "1" "$?" "Should return 1 with unknown args"
'

test_case "validate_no_unknown_args should show error message" '
    local output=$(validate_no_unknown_args --bad-flag 2>&1)
    if [[ "$output" == *"Unknown option"* ]]; then
        return 0
    else
        echo "Should show error message for unknown option"
        return 1
    fi
'

# ============================================================================
# Convenience Check Functions Tests
# ============================================================================

test_case "is_help_requested should return true when help flag set" '
    reset_arg_flags
    ARG_HELP="true"
    if is_help_requested; then
        return 0
    else
        echo "Should return true when ARG_HELP is true"
        return 1
    fi
'

test_case "is_help_requested should return false when help flag not set" '
    reset_arg_flags
    if is_help_requested; then
        echo "Should return false when ARG_HELP is false"
        return 1
    else
        return 0
    fi
'

test_case "is_verbose should return true when verbose flag set" '
    reset_arg_flags
    ARG_VERBOSE="true"
    if is_verbose; then
        return 0
    else
        echo "Should return true when ARG_VERBOSE is true"
        return 1
    fi
'

test_case "is_verbose should return false when verbose flag not set" '
    reset_arg_flags
    if is_verbose; then
        echo "Should return false when ARG_VERBOSE is false"
        return 1
    else
        return 0
    fi
'

test_case "is_dry_run should return true when dry-run flag set" '
    reset_arg_flags
    ARG_DRY_RUN="true"
    if is_dry_run; then
        return 0
    else
        echo "Should return true when ARG_DRY_RUN is true"
        return 1
    fi
'

test_case "is_dry_run should return false when dry-run flag not set" '
    reset_arg_flags
    if is_dry_run; then
        echo "Should return false when ARG_DRY_RUN is false"
        return 1
    else
        return 0
    fi
'

# ============================================================================
# reset_arg_flags() Tests
# ============================================================================

test_case "reset_arg_flags should reset all flags to defaults" '
    # Set some flags
    ARG_HELP="true"
    ARG_VERBOSE="true"
    ARG_UPDATE="true"
    ARG_VALUE="something"
    ARG_SUBCOMMAND="cmd"
    ARG_POSITIONAL=("arg1" "arg2")

    # Reset
    reset_arg_flags

    # Check all are reset
    if [[ "$ARG_HELP" == "false" ]] && \
       [[ "$ARG_VERBOSE" == "false" ]] && \
       [[ "$ARG_UPDATE" == "false" ]] && \
       [[ -z "$ARG_VALUE" ]] && \
       [[ -z "$ARG_SUBCOMMAND" ]] && \
       [[ ${#ARG_POSITIONAL[@]} -eq 0 ]]; then
        return 0
    else
        echo "Not all flags were reset to defaults"
        return 1
    fi
'

# ============================================================================
# Help Generation Functions Tests
# ============================================================================

test_case "standard_help_header should generate help output" '
    local output=$(standard_help_header "test-script.zsh" "Test description")
    if [[ "$output" == *"test-script.zsh"* ]] && \
       [[ "$output" == *"Test description"* ]] && \
       [[ "$output" == *"USAGE"* ]] && \
       [[ "$output" == *"OPTIONS"* ]]; then
        return 0
    else
        echo "Help header missing required sections"
        return 1
    fi
'

test_case "standard_help_header should use basename when no name provided" '
    local output=$(standard_help_header "" "Test description")
    if [[ "$output" == *"USAGE"* ]] && [[ "$output" == *"OPTIONS"* ]]; then
        return 0
    else
        echo "Should work with empty script name"
        return 1
    fi
'

test_case "standard_common_options should list common flags" '
    local output=$(standard_common_options)
    if [[ "$output" == *"--help"* ]] && \
       [[ "$output" == *"--verbose"* ]] && \
       [[ "$output" == *"--dry-run"* ]] && \
       [[ "$output" == *"--force"* ]]; then
        return 0
    else
        echo "Common options missing expected flags"
        return 1
    fi
'

# ============================================================================
# Integration Tests - Real-World Usage Patterns
# ============================================================================

test_case "Full workflow: parse flags then validate" '
    reset_arg_flags
    parse_simple_flags -v --dry-run

    if is_verbose && is_dry_run && validate_no_unknown_args >/dev/null 2>&1; then
        return 0
    else
        echo "Full workflow failed"
        return 1
    fi
'

test_case "Full workflow: detect help and exit early" '
    reset_arg_flags
    parse_simple_flags --help remaining args

    if is_help_requested; then
        # In real script would show_help && exit 0
        return 0
    else
        echo "Help detection failed"
        return 1
    fi
'

test_case "Full workflow: parse flags with values" '
    reset_arg_flags
    parse_simple_flags -v

    if parse_flag_with_value "--output" --output "result.txt"; then
        if is_verbose && [[ "$ARG_VALUE" == "result.txt" ]]; then
            return 0
        else
            echo "Flags or value not set correctly"
            return 1
        fi
    else
        echo "parse_flag_with_value failed"
        return 1
    fi
'

test_case "Full workflow: subcommand with args" '
    reset_arg_flags
    parse_subcommand list item1 item2

    if [[ "$ARG_SUBCOMMAND" == "list" ]] && \
       [[ "${ARG_POSITIONAL[1]}" == "item1" ]] && \
       [[ "${ARG_POSITIONAL[2]}" == "item2" ]]; then
        return 0
    else
        echo "Subcommand workflow failed"
        return 1
    fi
'

test_case "Error handling: unknown flag rejected" '
    reset_arg_flags
    parse_simple_flags --valid-flag --another-valid

    # These are unknown flags, should be catchable by validate
    if validate_no_unknown_args --valid-flag --another-valid >/dev/null 2>&1; then
        echo "Should have failed validation with unknown flags"
        return 1
    else
        return 0
    fi
'

# ============================================================================
# Edge Cases and Robustness Tests
# ============================================================================

test_case "Edge case: empty string as flag value should be rejected" '
    reset_arg_flags
    if parse_flag_with_value "--output" --output "" 2>/dev/null; then
        echo "Should have rejected empty string as value"
        return 1
    else
        # Correctly rejected empty value
        return 0
    fi
'

test_case "Edge case: flag value looks like another flag" '
    reset_arg_flags
    if parse_flag_with_value "--output" --output "--file"; then
        assert_equals "--file" "$ARG_VALUE" "Should accept flag-like values"
    else
        echo "Should handle flag-like values"
        return 1
    fi
'

test_case "Edge case: multiple calls to parse_simple_flags" '
    reset_arg_flags
    parse_simple_flags -v
    parse_simple_flags -f

    # Both should be set
    if [[ "$ARG_VERBOSE" == "true" ]] && [[ "$ARG_FORCE" == "true" ]]; then
        return 0
    else
        echo "Multiple parse calls should accumulate flags"
        return 1
    fi
'

test_case "Robustness: functions exist and are callable" '
    # Verify all exported functions are available
    typeset -f parse_simple_flags >/dev/null 2>&1 || return 1
    typeset -f parse_flag_with_value >/dev/null 2>&1 || return 1
    typeset -f parse_subcommand >/dev/null 2>&1 || return 1
    typeset -f validate_no_unknown_args >/dev/null 2>&1 || return 1
    typeset -f is_help_requested >/dev/null 2>&1 || return 1
    typeset -f is_verbose >/dev/null 2>&1 || return 1
    typeset -f is_dry_run >/dev/null 2>&1 || return 1
    typeset -f reset_arg_flags >/dev/null 2>&1 || return 1
    typeset -f standard_help_header >/dev/null 2>&1 || return 1
    typeset -f standard_common_options >/dev/null 2>&1 || return 1
    return 0
'

# ============================================================================
# Run all tests
# ============================================================================

run_tests
