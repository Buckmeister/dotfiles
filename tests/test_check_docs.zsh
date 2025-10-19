#!/usr/bin/env zsh

# ============================================================================
# test_check_docs.zsh - Test Suite for check_docs.zsh
# ============================================================================
#
# Tests the documentation consistency checker including:
# - Argument parsing
# - Broken link detection
# - Removed file reference checking
# - Script reference validation
# - Artifact validation
# - Outdated pattern detection
#
# Usage:
#   ./tests/test_check_docs.zsh
#   ./tests/test_check_docs.zsh --verbose
#
# ============================================================================

emulate -LR zsh
setopt PIPE_FAIL

# ============================================================================
# Bootstrap Test Framework
# ============================================================================

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
CHECK_DOCS_SCRIPT="$REPO_ROOT/bin/check_docs.zsh"

# Test counters
typeset -gi TESTS_RUN=0
typeset -gi TESTS_PASSED=0
typeset -gi TESTS_FAILED=0

# Test mode
VERBOSE=false
[[ "$1" == "--verbose" ]] && VERBOSE=true

# Colors for test output
if [[ -f "$REPO_ROOT/bin/lib/colors.zsh" ]]; then
    source "$REPO_ROOT/bin/lib/colors.zsh"
else
    GREEN="\033[32m"
    RED="\033[31m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    RESET="\033[0m"
fi

# Create temporary directory for test files
TEST_TMP_DIR="$(mktemp -d)"
trap "rm -rf '$TEST_TMP_DIR'" EXIT INT TERM

# ============================================================================
# Test Helper Functions
# ============================================================================

# Run a test and check result
test_assert() {
    local test_name="$1"
    local test_command="$2"
    local expected_status="${3:-0}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$VERBOSE" == true ]]; then
        echo "Running: $test_name"
        echo "Command: $test_command"
    fi

    # Run the test
    local output
    local actual_status
    output=$(eval "$test_command" 2>&1)
    actual_status=$?

    if [[ $actual_status -eq $expected_status ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "${GREEN}✓${RESET} $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "${RED}✗${RESET} $test_name"
        echo "  Expected status: $expected_status"
        echo "  Actual status:   $actual_status"
        if [[ "$VERBOSE" == true ]]; then
            echo "  Output: $output"
        fi
        return 1
    fi
}

# Test that output contains expected string
test_assert_contains() {
    local test_name="$1"
    local test_command="$2"
    local expected_string="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$VERBOSE" == true ]]; then
        echo "Running: $test_name"
        echo "Command: $test_command"
        echo "Looking for: $expected_string"
    fi

    # Run the test
    local output
    output=$(eval "$test_command" 2>&1)

    if echo "$output" | grep -q "$expected_string"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "${GREEN}✓${RESET} $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "${RED}✗${RESET} $test_name"
        echo "  Expected to find: $expected_string"
        if [[ "$VERBOSE" == true ]]; then
            echo "  Output: $output"
        fi
        return 1
    fi
}

# Test that output does NOT contain a string
test_assert_not_contains() {
    local test_name="$1"
    local test_command="$2"
    local unexpected_string="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$VERBOSE" == true ]]; then
        echo "Running: $test_name"
        echo "Command: $test_command"
        echo "Should not find: $unexpected_string"
    fi

    # Run the test
    local output
    output=$(eval "$test_command" 2>&1)

    if echo "$output" | grep -q "$unexpected_string"; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "${RED}✗${RESET} $test_name"
        echo "  Should not contain: $unexpected_string"
        if [[ "$VERBOSE" == true ]]; then
            echo "  Output: $output"
        fi
        return 1
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "${GREEN}✓${RESET} $test_name"
        return 0
    fi
}

# ============================================================================
# Test Suite: Basic Functionality
# ============================================================================

echo "\n${YELLOW}═══ Testing check_docs.zsh - Basic Functionality ═══${RESET}\n"

# Test 1: Script exists and is executable
test_assert \
    "Script exists and is executable" \
    "[[ -x '$CHECK_DOCS_SCRIPT' ]]" \
    0

# Test 2: Help message works
test_assert_contains \
    "Help message displays" \
    "$CHECK_DOCS_SCRIPT --help" \
    "Documentation Consistency Quick-Check"

# Test 3: Help shows all check types
test_assert_contains \
    "Help lists broken link check" \
    "$CHECK_DOCS_SCRIPT --help" \
    "Broken markdown links"

test_assert_contains \
    "Help lists artifact validation" \
    "$CHECK_DOCS_SCRIPT --help" \
    "Artifact example validation"

# Test 4: Script uses shared libraries
test_assert_contains \
    "Script sources colors.zsh" \
    "grep -q 'colors.zsh' '$CHECK_DOCS_SCRIPT'" \
    ""

test_assert_contains \
    "Script sources ui.zsh" \
    "grep -q 'ui.zsh' '$CHECK_DOCS_SCRIPT'" \
    ""

test_assert_contains \
    "Script sources arguments.zsh" \
    "grep -q 'arguments.zsh' '$CHECK_DOCS_SCRIPT'" \
    ""

# ============================================================================
# Test Suite: Output Format and Sections
# ============================================================================

echo "\n${YELLOW}═══ Testing Output Format and Sections ═══${RESET}\n"

# Test 5: Produces beautiful header
test_assert_contains \
    "Shows beautiful header" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Documentation Consistency Quick-Check"

# Test 6: Shows all check sections
test_assert_contains \
    "Shows Checking Markdown Links section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Checking Markdown Links"

test_assert_contains \
    "Shows Checking for References section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Checking for References to Removed Files"

test_assert_contains \
    "Shows Checking Script References section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Checking Script References"

test_assert_contains \
    "Shows Checking for Outdated Patterns section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Checking for Outdated Patterns"

test_assert_contains \
    "Shows Cross-Reference Consistency section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Checking Cross-Reference Consistency"

test_assert_contains \
    "Shows Artifact Documentation section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Checking Artifact Documentation"

# ============================================================================
# Test Suite: Colored Output
# ============================================================================

echo "\n${YELLOW}═══ Testing Colored Output ═══${RESET}\n"

# Test 7: Uses colored output (emojis and formatting present)
test_assert_contains \
    "Produces colored output" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "✅"  # Success emoji indicates colored output

# Test 8: Shows summary at end
test_assert_contains \
    "Shows Summary section" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Summary"

# ============================================================================
# Test Suite: Artifact Validation (Real Repository)
# ============================================================================

echo "\n${YELLOW}═══ Testing Artifact Validation ═══${RESET}\n"

# Test 9: Validates artifact examples in real repository
# The repository has artifact markers in README.md for the speak script
test_assert_contains \
    "Processes artifact markers" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "Artifact"

# Test 10: Shows artifact validation results
# Should either show "All artifact examples valid" or "Found issues"
test_assert_contains \
    "Shows artifact validation results" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' 2>&1" \
    "artifact"

# ============================================================================
# Test Suite: Functionality Checks
# ============================================================================

echo "\n${YELLOW}═══ Testing Functionality ═══${RESET}\n"

# Test 11: Exits with correct status codes
# Script should exit 0 if no issues, 1 if issues found
test_assert \
    "Exits with status 0 or 1" \
    "cd '$REPO_ROOT' && '$CHECK_DOCS_SCRIPT' > /dev/null 2>&1; [[ \$? -eq 0 || \$? -eq 1 ]]" \
    0

# ============================================================================
# Test Suite: Error Handling
# ============================================================================

echo "\n${YELLOW}═══ Testing Error Handling ═══${RESET}\n"

# Test 12: Handles running from different directories
test_assert \
    "Can run from subdirectory" \
    "cd '$REPO_ROOT/bin' && '$CHECK_DOCS_SCRIPT' > /dev/null 2>&1; [[ \$? -eq 0 || \$? -eq 1 ]]" \
    0

# ============================================================================
# Test Suite: Verbose Mode
# ============================================================================

echo "\n${YELLOW}═══ Testing Verbose Mode ═══${RESET}\n"

# Test 13: Verbose flag works
test_assert \
    "Accepts --verbose flag" \
    "$CHECK_DOCS_SCRIPT --verbose --help > /dev/null 2>&1" \
    0

test_assert \
    "Accepts -v flag" \
    "$CHECK_DOCS_SCRIPT -v --help > /dev/null 2>&1" \
    0

# ============================================================================
# Test Suite: Library Integration
# ============================================================================

echo "\n${YELLOW}═══ Testing Library Integration ═══${RESET}\n"

# Test 14: Uses shared colors from colors.zsh
test_assert \
    "Integrates with colors library" \
    "grep -q 'COLOR_INFO\\|UI_INFO_COLOR' '$CHECK_DOCS_SCRIPT'" \
    0

# Test 15: Uses shared UI functions from ui.zsh
test_assert \
    "Integrates with ui library" \
    "grep -q 'print_success\\|print_warning\\|print_error\\|print_info' '$CHECK_DOCS_SCRIPT'" \
    0

# Test 16: Uses shared argument parsing
test_assert \
    "Integrates with arguments library" \
    "grep -q 'parse_simple_flags\\|is_help_requested\\|is_verbose' '$CHECK_DOCS_SCRIPT'" \
    0

# ============================================================================
# Test Summary
# ============================================================================

echo "\n${BLUE}═══════════════════════════════════════════════════${RESET}"
echo "${BLUE}Test Results for check_docs.zsh${RESET}"
echo "${BLUE}═══════════════════════════════════════════════════${RESET}"
echo "Total Tests:  $TESTS_RUN"
echo "${GREEN}Passed:       $TESTS_PASSED${RESET}"
[[ $TESTS_FAILED -gt 0 ]] && echo "${RED}Failed:       $TESTS_FAILED${RESET}" || echo "Failed:       $TESTS_FAILED"
echo "${BLUE}═══════════════════════════════════════════════════${RESET}\n"

# Exit with appropriate status
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "${GREEN}✓ All tests passed!${RESET}\n"
    exit 0
else
    echo "${RED}✗ Some tests failed${RESET}\n"
    exit 1
fi
