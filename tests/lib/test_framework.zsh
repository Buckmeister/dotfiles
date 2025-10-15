#!/usr/bin/env zsh

# ============================================================================
# Test Framework Library for Dotfiles Testing
# ============================================================================
#
# A lightweight testing framework for shell scripts, providing assertion
# functions, test organization, and beautiful output using shared libraries.
#
# Usage:
#   source "tests/lib/test_framework.zsh"
#
#   test_suite "My Test Suite"
#
#   test_case "should do something" {
#       assert_equals "expected" "actual"
#   }
#
#   run_tests
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

# Determine paths
TESTS_LIB_DIR="${0:a:h}"
DOTFILES_ROOT="${TESTS_LIB_DIR:h:h}"

# Load colors for consistent output
source "${DOTFILES_ROOT}/bin/lib/colors.zsh" 2>/dev/null || {
    # Fallback if colors.zsh not available
    readonly COLOR_RESET='\033[0m'
    readonly COLOR_BOLD='\033[1m'
    readonly COLOR_SUCCESS='\033[32m'
    readonly COLOR_ERROR='\033[31m'
    readonly COLOR_WARNING='\033[33m'
    readonly COLOR_INFO='\033[36m'
    readonly COLOR_COMMENT='\033[90m'
}

# ============================================================================
# Test Framework State
# ============================================================================

typeset -g TEST_SUITE_NAME=""
typeset -g -a TEST_CASES=()
typeset -g -a TEST_RESULTS=()
typeset -g -i TESTS_PASSED=0
typeset -g -i TESTS_FAILED=0
typeset -g -i TESTS_SKIPPED=0
typeset -g TEST_OUTPUT_VERBOSE=false

# ============================================================================
# Test Suite Management
# ============================================================================

function test_suite() {
    TEST_SUITE_NAME="$1"
    TEST_CASES=()
    TEST_RESULTS=()
    TESTS_PASSED=0
    TESTS_FAILED=0
    TESTS_SKIPPED=0
}

function test_case() {
    local test_name="$1"
    local test_body="$2"

    TEST_CASES+=("$test_name|$test_body")
}

# ============================================================================
# Assertion Functions
# ============================================================================

function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Expected: ${COLOR_SUCCESS}$expected${COLOR_RESET}"
        echo "  Actual:   ${COLOR_ERROR}$actual${COLOR_RESET}"
        return 1
    fi
}

function assert_not_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [[ "$expected" != "$actual" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Expected NOT to equal: ${COLOR_ERROR}$expected${COLOR_RESET}"
        return 1
    fi
}

function assert_true() {
    local condition="$1"
    local message="${2:-Assertion failed: expected true}"

    if [[ "$condition" == "true" ]] || [[ "$condition" -eq 1 ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Expected: ${COLOR_SUCCESS}true${COLOR_RESET}"
        echo "  Actual:   ${COLOR_ERROR}$condition${COLOR_RESET}"
        return 1
    fi
}

function assert_false() {
    local condition="$1"
    local message="${2:-Assertion failed: expected false}"

    if [[ "$condition" == "false" ]] || [[ "$condition" -eq 0 ]] || [[ -z "$condition" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Expected: ${COLOR_SUCCESS}false${COLOR_RESET}"
        echo "  Actual:   ${COLOR_ERROR}$condition${COLOR_RESET}"
        return 1
    fi
}

function assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Assertion failed: string does not contain substring}"

    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Haystack: ${COLOR_COMMENT}$haystack${COLOR_RESET}"
        echo "  Needle:   ${COLOR_ERROR}$needle${COLOR_RESET}"
        return 1
    fi
}

function assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Assertion failed: string contains substring}"

    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Haystack: ${COLOR_COMMENT}$haystack${COLOR_RESET}"
        echo "  Should NOT contain: ${COLOR_ERROR}$needle${COLOR_RESET}"
        return 1
    fi
}

function assert_file_exists() {
    local filepath="$1"
    local message="${2:-Assertion failed: file does not exist}"

    if [[ -f "$filepath" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  File: ${COLOR_ERROR}$filepath${COLOR_RESET}"
        return 1
    fi
}

function assert_file_not_exists() {
    local filepath="$1"
    local message="${2:-Assertion failed: file exists}"

    if [[ ! -f "$filepath" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  File should NOT exist: ${COLOR_ERROR}$filepath${COLOR_RESET}"
        return 1
    fi
}

function assert_dir_exists() {
    local dirpath="$1"
    local message="${2:-Assertion failed: directory does not exist}"

    if [[ -d "$dirpath" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Directory: ${COLOR_ERROR}$dirpath${COLOR_RESET}"
        return 1
    fi
}

function assert_command_exists() {
    local command="$1"
    local message="${2:-Assertion failed: command not found}"

    if command -v "$command" >/dev/null 2>&1; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Command: ${COLOR_ERROR}$command${COLOR_RESET}"
        return 1
    fi
}

function assert_exit_code() {
    local expected_code="$1"
    local actual_code="$2"
    local message="${3:-Assertion failed: unexpected exit code}"

    if [[ "$expected_code" -eq "$actual_code" ]]; then
        return 0
    else
        echo "${COLOR_ERROR}✗${COLOR_RESET} $message"
        echo "  Expected exit code: ${COLOR_SUCCESS}$expected_code${COLOR_RESET}"
        echo "  Actual exit code:   ${COLOR_ERROR}$actual_code${COLOR_RESET}"
        return 1
    fi
}

# ============================================================================
# Test Execution
# ============================================================================

function run_single_test() {
    local test_info="$1"
    local test_name="${test_info%%|*}"
    local test_body="${test_info#*|}"

    printf "  ${COLOR_INFO}▸${COLOR_RESET} %s ... " "$test_name"

    # Run test in subshell to isolate failures
    local output
    local exit_code

    output=$(eval "$test_body" 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        printf "${COLOR_SUCCESS}✓${COLOR_RESET}\n"
        ((TESTS_PASSED++))
        return 0
    else
        printf "${COLOR_ERROR}✗${COLOR_RESET}\n"
        if [[ -n "$output" ]]; then
            echo "$output" | sed 's/^/    /'
        fi
        ((TESTS_FAILED++))
        return 1
    fi
}

function run_tests() {
    echo ""
    printf "${COLOR_BOLD}${COLOR_INFO}Running Test Suite: %s${COLOR_RESET}\n" "$TEST_SUITE_NAME"
    printf "${COLOR_COMMENT}══════════════════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    echo ""

    local total_tests=${#TEST_CASES[@]}

    for test_case in "${TEST_CASES[@]}"; do
        run_single_test "$test_case"
    done

    echo ""
    printf "${COLOR_COMMENT}──────────────────────────────────────────────────────────────────────────────${COLOR_RESET}\n"

    # Summary
    printf "${COLOR_BOLD}Test Summary:${COLOR_RESET}\n"
    printf "  Total:   %d\n" "$total_tests"
    printf "  ${COLOR_SUCCESS}Passed:  %d${COLOR_RESET}\n" "$TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        printf "  ${COLOR_ERROR}Failed:  %d${COLOR_RESET}\n" "$TESTS_FAILED"
    fi

    if [[ $TESTS_SKIPPED -gt 0 ]]; then
        printf "  ${COLOR_WARNING}Skipped: %d${COLOR_RESET}\n" "$TESTS_SKIPPED"
    fi

    echo ""

    # Exit with appropriate code
    if [[ $TESTS_FAILED -gt 0 ]]; then
        printf "${COLOR_ERROR}${COLOR_BOLD}✗ Tests FAILED${COLOR_RESET}\n"
        return 1
    else
        printf "${COLOR_SUCCESS}${COLOR_BOLD}✓ All tests PASSED${COLOR_RESET}\n"
        return 0
    fi
}

# ============================================================================
# Test Utilities
# ============================================================================

function skip_test() {
    local reason="${1:-No reason provided}"
    printf "${COLOR_WARNING}⊘${COLOR_RESET} (skipped: $reason)\n"
    ((TESTS_SKIPPED++))
    return 0
}

function mock_command() {
    local command_name="$1"
    local mock_output="$2"

    eval "function $command_name() { echo '$mock_output'; return 0; }"
}

function capture_output() {
    local command="$1"
    eval "$command" 2>&1
}

# ============================================================================
# Setup/Teardown Hooks
# ============================================================================

function setup() {
    # Override in test files for per-suite setup
    :
}

function teardown() {
    # Override in test files for per-suite teardown
    :
}

function setup_test() {
    # Override in test files for per-test setup
    :
}

function teardown_test() {
    # Override in test files for per-test teardown
    :
}
