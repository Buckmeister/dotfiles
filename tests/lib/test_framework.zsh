#!/usr/bin/env zsh

# ============================================================================
# Test Framework Library for Dotfiles Testing
# ============================================================================
#
# A lightweight testing framework for shell scripts, providing assertion
# functions, test organization, and beautiful output.
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
# Color Definitions (embedded for test isolation)
# ============================================================================

readonly TEST_COLOR_RESET='\033[0m'
readonly TEST_COLOR_BOLD='\033[1m'
readonly TEST_COLOR_GREEN='\033[32m'
readonly TEST_COLOR_RED='\033[31m'
readonly TEST_COLOR_YELLOW='\033[33m'
readonly TEST_COLOR_CYAN='\033[36m'
readonly TEST_COLOR_GRAY='\033[90m'

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
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Expected: ${TEST_COLOR_GREEN}$expected${TEST_COLOR_RESET}"
        echo "  Actual:   ${TEST_COLOR_RED}$actual${TEST_COLOR_RESET}"
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
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Expected NOT to equal: ${TEST_COLOR_RED}$expected${TEST_COLOR_RESET}"
        return 1
    fi
}

function assert_true() {
    local condition="$1"
    local message="${2:-Assertion failed: expected true}"

    if [[ "$condition" == "true" ]] || [[ "$condition" -eq 1 ]]; then
        return 0
    else
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Expected: ${TEST_COLOR_GREEN}true${TEST_COLOR_RESET}"
        echo "  Actual:   ${TEST_COLOR_RED}$condition${TEST_COLOR_RESET}"
        return 1
    fi
}

function assert_false() {
    local condition="$1"
    local message="${2:-Assertion failed: expected false}"

    if [[ "$condition" == "false" ]] || [[ "$condition" -eq 0 ]] || [[ -z "$condition" ]]; then
        return 0
    else
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Expected: ${TEST_COLOR_GREEN}false${TEST_COLOR_RESET}"
        echo "  Actual:   ${TEST_COLOR_RED}$condition${TEST_COLOR_RESET}"
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
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Haystack: ${TEST_COLOR_GRAY}$haystack${TEST_COLOR_RESET}"
        echo "  Needle:   ${TEST_COLOR_RED}$needle${TEST_COLOR_RESET}"
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
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Haystack: ${TEST_COLOR_GRAY}$haystack${TEST_COLOR_RESET}"
        echo "  Should NOT contain: ${TEST_COLOR_RED}$needle${TEST_COLOR_RESET}"
        return 1
    fi
}

function assert_file_exists() {
    local filepath="$1"
    local message="${2:-Assertion failed: file does not exist}"

    if [[ -f "$filepath" ]]; then
        return 0
    else
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  File: ${TEST_COLOR_RED}$filepath${TEST_COLOR_RESET}"
        return 1
    fi
}

function assert_file_not_exists() {
    local filepath="$1"
    local message="${2:-Assertion failed: file exists}"

    if [[ ! -f "$filepath" ]]; then
        return 0
    else
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  File should NOT exist: ${TEST_COLOR_RED}$filepath${TEST_COLOR_RESET}"
        return 1
    fi
}

function assert_dir_exists() {
    local dirpath="$1"
    local message="${2:-Assertion failed: directory does not exist}"

    if [[ -d "$dirpath" ]]; then
        return 0
    else
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Directory: ${TEST_COLOR_RED}$dirpath${TEST_COLOR_RESET}"
        return 1
    fi
}

function assert_command_exists() {
    local command="$1"
    local message="${2:-Assertion failed: command not found}"

    if command -v "$command" >/dev/null 2>&1; then
        return 0
    else
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Command: ${TEST_COLOR_RED}$command${TEST_COLOR_RESET}"
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
        echo "${TEST_COLOR_RED}✗${TEST_COLOR_RESET} $message"
        echo "  Expected exit code: ${TEST_COLOR_GREEN}$expected_code${TEST_COLOR_RESET}"
        echo "  Actual exit code:   ${TEST_COLOR_RED}$actual_code${TEST_COLOR_RESET}"
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

    printf "  ${TEST_COLOR_CYAN}▸${TEST_COLOR_RESET} %s ... " "$test_name"

    # Run test in subshell to isolate failures
    local output
    local exit_code

    output=$(eval "$test_body" 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        printf "${TEST_COLOR_GREEN}✓${TEST_COLOR_RESET}\n"
        ((TESTS_PASSED++))
        return 0
    else
        printf "${TEST_COLOR_RED}✗${TEST_COLOR_RESET}\n"
        if [[ -n "$output" ]]; then
            echo "$output" | sed 's/^/    /'
        fi
        ((TESTS_FAILED++))
        return 1
    fi
}

function run_tests() {
    echo ""
    printf "${TEST_COLOR_BOLD}${TEST_COLOR_CYAN}Running Test Suite: %s${TEST_COLOR_RESET}\n" "$TEST_SUITE_NAME"
    printf "${TEST_COLOR_GRAY}══════════════════════════════════════════════════════════════════════════════${TEST_COLOR_RESET}\n"
    echo ""

    local total_tests=${#TEST_CASES[@]}

    for test_case in "${TEST_CASES[@]}"; do
        run_single_test "$test_case"
    done

    echo ""
    printf "${TEST_COLOR_GRAY}──────────────────────────────────────────────────────────────────────────────${TEST_COLOR_RESET}\n"

    # Summary
    printf "${TEST_COLOR_BOLD}Test Summary:${TEST_COLOR_RESET}\n"
    printf "  Total:   %d\n" "$total_tests"
    printf "  ${TEST_COLOR_GREEN}Passed:  %d${TEST_COLOR_RESET}\n" "$TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        printf "  ${TEST_COLOR_RED}Failed:  %d${TEST_COLOR_RESET}\n" "$TESTS_FAILED"
    fi

    if [[ $TESTS_SKIPPED -gt 0 ]]; then
        printf "  ${TEST_COLOR_YELLOW}Skipped: %d${TEST_COLOR_RESET}\n" "$TESTS_SKIPPED"
    fi

    echo ""

    # Exit with appropriate code
    if [[ $TESTS_FAILED -gt 0 ]]; then
        printf "${TEST_COLOR_RED}${TEST_COLOR_BOLD}✗ Tests FAILED${TEST_COLOR_RESET}\n"
        return 1
    else
        printf "${TEST_COLOR_GREEN}${TEST_COLOR_BOLD}✓ All tests PASSED${TEST_COLOR_RESET}\n"
        return 0
    fi
}

# ============================================================================
# Test Utilities
# ============================================================================

function skip_test() {
    local reason="${1:-No reason provided}"
    printf "${TEST_COLOR_YELLOW}⊘${TEST_COLOR_RESET} (skipped: $reason)\n"
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
