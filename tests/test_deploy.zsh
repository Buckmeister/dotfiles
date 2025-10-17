#!/usr/bin/env zsh

# ============================================================================
# test_deploy.zsh - Test Suite for deploy.zsh
# ============================================================================
#
# Tests the remote deployment script functionality including:
# - Argument parsing
# - Host file parsing
# - SSH validation
# - Deployment modes (sequential, parallel, dry-run)
# - Error handling
#
# Usage:
#   ./tests/test_deploy.zsh
#   ./tests/test_deploy.zsh --verbose
#
# ============================================================================

emulate -LR zsh
setopt PIPE_FAIL

# ============================================================================
# Bootstrap Test Framework
# ============================================================================

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
DEPLOY_SCRIPT="$REPO_ROOT/bin/deploy.zsh"

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
    RESET="\033[0m"
fi

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
        echo "  Output: ${output:0:200}..."
        return 1
    fi
}

# Create a temporary hosts file for testing
create_test_hosts_file() {
    local tmpfile="$1"
    cat > "$tmpfile" <<'EOF'
# Test hosts file
server1.example.com
server2.example.com

# Staging
staging.example.com
EOF
}

# ============================================================================
# Test Suite: Basic Functionality
# ============================================================================

echo "\n${YELLOW}═══ Testing deploy.zsh - Basic Functionality ═══${RESET}\n"

# Test 1: Script exists and is executable
test_assert \
    "Script exists and is executable" \
    "[[ -x '$DEPLOY_SCRIPT' ]]" \
    0

# Test 2: Help message works
test_assert_contains \
    "Help message displays" \
    "$DEPLOY_SCRIPT --help" \
    "deploy.zsh - Remote Dotfiles Deployment Script"

# Test 3: Help message shows usage
test_assert_contains \
    "Help shows usage examples" \
    "$DEPLOY_SCRIPT --help" \
    "EXAMPLES"

# ============================================================================
# Test Suite: Argument Parsing
# ============================================================================

echo "\n${YELLOW}═══ Testing Argument Parsing ═══${RESET}\n"

# Test 4: Invalid option returns error
test_assert \
    "Invalid option returns error" \
    "$DEPLOY_SCRIPT --invalid-option" \
    1

# Test 5: Dry-run mode activates
test_assert_contains \
    "Dry-run mode shows warning" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "DRY-RUN MODE"

# Test 6: Auto mode works
test_assert_contains \
    "Auto mode selects dfauto" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "Automatic (dfauto)"

# Test 7: Interactive mode (default)
test_assert_contains \
    "Interactive mode is default" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost" \
    "Interactive (dfsetup)"

# Test 8: Parallel mode flag
test_assert_contains \
    "Parallel mode flag works" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --parallel" \
    "Parallel"

# Test 9: Sequential mode flag
test_assert_contains \
    "Sequential mode flag works" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --sequential" \
    "Sequential"

# ============================================================================
# Test Suite: Host Specification
# ============================================================================

echo "\n${YELLOW}═══ Testing Host Specification ═══${RESET}\n"

# Test 10: Single host specification
test_assert_contains \
    "Single host specification works" \
    "$DEPLOY_SCRIPT --dry-run --hosts server.example.com --auto" \
    "server.example.com"

# Test 11: Multiple hosts specification
test_assert_contains \
    "Multiple hosts specification works" \
    "$DEPLOY_SCRIPT --dry-run --hosts host1 host2 host3 --auto" \
    "3 total"

# Test 12: Hosts file parsing
TMP_HOSTS_FILE="/tmp/test_deploy_hosts_$$"
create_test_hosts_file "$TMP_HOSTS_FILE"
test_assert_contains \
    "Hosts file parsing works" \
    "$DEPLOY_SCRIPT --dry-run --hosts-file '$TMP_HOSTS_FILE' --auto" \
    "3 total"

# Test 13: Hosts file skips comments and empty lines
test_assert_contains \
    "Hosts file skips comments" \
    "$DEPLOY_SCRIPT --dry-run --hosts-file '$TMP_HOSTS_FILE' --auto" \
    "server1.example.com"

rm -f "$TMP_HOSTS_FILE"

# Test 14: No hosts specified returns error (non-interactive)
# This test would require stdin input, so we skip it for now

# ============================================================================
# Test Suite: Deployment Modes
# ============================================================================

echo "\n${YELLOW}═══ Testing Deployment Modes ═══${RESET}\n"

# Test 15: Dry-run doesn't actually deploy
test_assert_contains \
    "Dry-run shows 'would' messages" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "Would validate SSH connection"

# Test 16: Sequential deployment shows progress
test_assert_contains \
    "Sequential deployment shows host-by-host progress" \
    "$DEPLOY_SCRIPT --dry-run --hosts host1 host2 --sequential --auto" \
    "\[1/2\]"

# Test 17: Deployment summary appears
test_assert_contains \
    "Deployment summary appears" \
    "$DEPLOY_SCRIPT --dry-run --hosts host1 host2 --auto" \
    "Deployment Summary"

# Test 18: Success count is correct
test_assert_contains \
    "Success count shows correct total" \
    "$DEPLOY_SCRIPT --dry-run --hosts host1 host2 host3 --auto" \
    "All deployments completed successfully! (3/3)"

# Test 19: SSH validation section appears
test_assert_contains \
    "SSH validation section appears" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "Validating SSH Connections"

# Test 20: Configuration summary appears
test_assert_contains \
    "Configuration summary appears" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "Deployment Configuration"

# ============================================================================
# Test Suite: Web Installer Integration
# ============================================================================

echo "\n${YELLOW}═══ Testing Web Installer Integration ═══${RESET}\n"

# Test 21: Auto mode uses dfauto
test_assert_contains \
    "Auto mode selects dfauto installer" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "Would deploy to testhost using dfauto"

# Test 22: Interactive mode uses dfsetup
test_assert_contains \
    "Interactive mode selects dfsetup installer" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --interactive" \
    "Would deploy to testhost using dfsetup"

# ============================================================================
# Test Suite: SSH Timeout Configuration
# ============================================================================

echo "\n${YELLOW}═══ Testing SSH Timeout Configuration ═══${RESET}\n"

# Test 23: Default timeout is 10s
test_assert_contains \
    "Default timeout is 10 seconds" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --auto" \
    "Timeout:    10s"

# Test 24: Custom timeout can be set
test_assert_contains \
    "Custom timeout can be set" \
    "$DEPLOY_SCRIPT --dry-run --hosts testhost --timeout 30 --auto" \
    "Timeout:    30s"

# ============================================================================
# Test Suite: Wrapper Script
# ============================================================================

echo "\n${YELLOW}═══ Testing Wrapper Script ═══${RESET}\n"

# Test 25: Wrapper script exists
test_assert \
    "Wrapper script exists" \
    "[[ -f '$REPO_ROOT/deploy' ]]" \
    0

# Test 26: Wrapper is executable
test_assert \
    "Wrapper script is executable" \
    "[[ -x '$REPO_ROOT/deploy' ]]" \
    0

# Test 27: Wrapper passes arguments correctly
test_assert_contains \
    "Wrapper passes --help correctly" \
    "$REPO_ROOT/deploy --help" \
    "deploy.zsh - Remote Dotfiles Deployment Script"

# ============================================================================
# Test Results Summary
# ============================================================================

echo "\n${YELLOW}═══ Test Results Summary ═══${RESET}\n"
echo "Tests run:    $TESTS_RUN"
echo "${GREEN}Tests passed: $TESTS_PASSED${RESET}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo "${RED}Tests failed: $TESTS_FAILED${RESET}"
else
    echo "Tests failed: $TESTS_FAILED"
fi

# Calculate percentage
if [[ $TESTS_RUN -gt 0 ]]; then
    local pass_percentage=$((TESTS_PASSED * 100 / TESTS_RUN))
    echo "Success rate: ${pass_percentage}%"
fi

echo

# Exit with appropriate status
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "${GREEN}✅ All tests passed!${RESET}"
    exit 0
else
    echo "${RED}❌ Some tests failed${RESET}"
    exit 1
fi
