#!/usr/bin/env zsh

# ============================================================================
# Test Helpers Library for Dotfiles Testing
# ============================================================================
#
# Reusable utilities for integration and end-to-end tests.
# Complements test_framework.zsh (unit testing) with higher-level helpers
# for VM/container testing, SSH operations, and test orchestration.
#
# Usage:
#   source "tests/lib/test_helpers.zsh"
#
#   # Initialize test tracking
#   init_test_tracking
#
#   # Track test results
#   track_test_result "Ubuntu 24.04" true
#   track_test_result "Debian 12" false
#
#   # Print summary
#   print_test_summary  # Returns 0 if all passed, 1 if any failed
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Dependencies
# ============================================================================

# Determine paths
TESTS_LIB_DIR="${0:a:h}"
DOTFILES_ROOT="${TESTS_LIB_DIR:h:h}"

# Load shared libraries
source "${DOTFILES_ROOT}/bin/lib/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load colors.zsh"
    return 1
}
source "${DOTFILES_ROOT}/bin/lib/ui.zsh" 2>/dev/null || {
    echo "Error: Could not load ui.zsh"
    return 1
}
source "${DOTFILES_ROOT}/bin/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh"
    return 1
}
source "${DOTFILES_ROOT}/bin/lib/greetings.zsh" 2>/dev/null || {
    # Greetings are optional - tests work without them
    :
}

# ============================================================================
# Test Result Tracking
# ============================================================================

# Global variables for tracking test results across a test run
typeset -g -i TEST_TOTAL=0
typeset -g -i TEST_PASSED=0
typeset -g -i TEST_FAILED=0
typeset -g -a TEST_FAILED_LIST=()

# Initialize or reset test tracking
#
# Usage:
#   init_test_tracking
init_test_tracking() {
    TEST_TOTAL=0
    TEST_PASSED=0
    TEST_FAILED=0
    TEST_FAILED_LIST=()
}

# Track a test result
#
# Parameters:
#   $1 - Test name (string)
#   $2 - Test passed (true/false)
#
# Usage:
#   track_test_result "Ubuntu 24.04" true
#   track_test_result "Debian 12" false
track_test_result() {
    local test_name="$1"
    local test_passed="$2"

    ((TEST_TOTAL++))

    if [[ "$test_passed" = true ]] || [[ "$test_passed" = "0" ]]; then
        ((TEST_PASSED++))
    else
        ((TEST_FAILED++))
        TEST_FAILED_LIST+=("$test_name")
    fi
}

# Print test results summary with beautiful formatting
#
# Returns:
#   0 - All tests passed
#   1 - Some tests failed
#
# Usage:
#   print_test_summary || exit 1
print_test_summary() {
    draw_section_header "Test Results Summary"

    print_info "📊 Test Statistics:"
    echo "   Total tests:  $TEST_TOTAL"
    echo "   ${COLOR_SUCCESS}Passed:       $TEST_PASSED${COLOR_RESET}"
    echo "   ${COLOR_ERROR}Failed:       $TEST_FAILED${COLOR_RESET}"
    echo ""

    if [[ $TEST_FAILED -gt 0 ]]; then
        print_error "Failed tests:"
        for failed in "${TEST_FAILED_LIST[@]}"; do
            echo "   - $failed"
        done
        echo ""
        return 1
    else
        print_success "All tests passed! 🎉"
        echo ""

        # Show friendly greeting if available
        if command -v get_random_friend_greeting >/dev/null 2>&1; then
            print_success "$(get_random_friend_greeting)"
            echo ""
        fi

        return 0
    fi
}

# ============================================================================
# Wait/Retry Utilities
# ============================================================================

# Wait for a condition to become true with timeout and retry logic
#
# Parameters:
#   $1 - Command to test (should return 0 when condition is met)
#   $2 - Timeout in seconds (default: 120)
#   $3 - Check interval in seconds (default: 2)
#   $4 - Progress message prefix (default: "Waiting...")
#   $5 - Show progress updates (true/false, default: false)
#
# Returns:
#   0 - Condition met within timeout
#   1 - Timeout reached
#
# Usage:
#   wait_for_condition "test -f /tmp/ready" 60 2 "Waiting for file" true
#   wait_for_condition "curl -s http://localhost:8080 >/dev/null" 30
wait_for_condition() {
    local condition_cmd="$1"
    local timeout_seconds="${2:-120}"
    local check_interval="${3:-2}"
    local progress_message="${4:-Waiting...}"
    local show_progress="${5:-false}"

    local elapsed=0
    local attempts=0

    while [[ $elapsed -lt $timeout_seconds ]]; do
        ((attempts++))

        # Test the condition
        if eval "$condition_cmd" >/dev/null 2>&1; then
            return 0
        fi

        # Show progress periodically
        if [[ "$show_progress" = true ]] && [[ $((attempts % 30)) -eq 0 ]]; then
            echo "   ${COLOR_COMMENT}$progress_message ($elapsed seconds / $((elapsed / 60)) minutes)${COLOR_RESET}"
        fi

        sleep "$check_interval"
        ((elapsed += check_interval))
    done

    # Timeout reached
    return 1
}

# Wait for SSH to become accessible on a remote host
#
# Parameters:
#   $1 - SSH key path
#   $2 - User
#   $3 - Host/IP
#   $4 - Timeout in seconds (default: 120)
#   $5 - Show progress (true/false, default: false)
#
# Returns:
#   0 - SSH accessible
#   1 - Timeout reached
#
# Usage:
#   wait_for_ssh ~/.ssh/key aria 192.168.1.100 60 true
wait_for_ssh() {
    local ssh_key="$1"
    local user="$2"
    local host="$3"
    local timeout="${4:-120}"
    local show_progress="${5:-false}"

    local condition="ssh -i '$ssh_key' -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes '$user@$host' 'echo OK' >/dev/null 2>&1"

    wait_for_condition "$condition" "$timeout" 2 "Still waiting for SSH access..." "$show_progress"
}

# ============================================================================
# SSH Helpers
# ============================================================================

# Execute SSH command on remote host with standard options
#
# Parameters:
#   $1 - SSH key path
#   $2 - User
#   $3 - Host/IP
#   $@ - Command to execute
#
# Returns:
#   Exit code of remote command
#
# Usage:
#   remote_ssh ~/.ssh/key root host.local "ls -la"
#   remote_ssh ~/.ssh/key aria 192.168.1.100 "cat /etc/os-release"
remote_ssh() {
    local ssh_key="$1"
    local user="$2"
    local host="$3"
    shift 3
    local command="$@"

    ssh -i "$ssh_key" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=10 \
        -o BatchMode=yes \
        "$user@$host" \
        "$command" 2>&1
}

# ============================================================================
# Output Parsing
# ============================================================================

# Parse test output with standard markers (PROGRESS:, SUCCESS:, FAILED:, INFO:)
#
# This function processes lines of output and formats them using UI functions.
# Typically used in a while-read loop.
#
# Markers:
#   PROGRESS: - Shows as info message (arrow prefix)
#   SUCCESS:  - Shows as success message (green checkmark)
#   FAILED:   - Shows as error message (red X)
#   INFO:     - Shows as comment (gray text)
#
# Parameters:
#   $1 - Line to parse
#
# Usage:
#   some_command | while IFS= read -r line; do
#       parse_test_output "$line"
#   done
parse_test_output() {
    local line="$1"

    case "$line" in
        PROGRESS:*)
            local message="${line#PROGRESS:}"
            echo "   ${COLOR_COMMENT}→ $message${COLOR_RESET}"
            ;;
        SUCCESS:*)
            local message="${line#SUCCESS:}"
            print_success "$message"
            ;;
        FAILED:*)
            local message="${line#FAILED:}"
            print_error "$message"
            ;;
        INFO:*)
            local message="${line#INFO:}"
            echo "   ${COLOR_COMMENT}$message${COLOR_RESET}"
            ;;
        # Default: pass through (or comment out to suppress)
        *)
            # Uncomment to show all output:
            # echo "$line"
            ;;
    esac
}

# ============================================================================
# Phase-Based Testing
# ============================================================================

# Print test phase indicator with consistent formatting
#
# Parameters:
#   $1 - Current phase number
#   $2 - Total number of phases
#   $3 - Phase description
#
# Usage:
#   print_test_phase 1 5 "Creating VM with cloud-init"
#   print_test_phase 2 5 "Waiting for VM to boot"
print_test_phase() {
    local current_phase="$1"
    local total_phases="$2"
    local phase_description="$3"

    print_info "Phase $current_phase/$total_phases: $phase_description..."
}

# Print additional phase context (indented comment)
#
# Parameters:
#   $1 - Context message
#
# Usage:
#   print_phase_context "This may take 5-10 minutes for Windows"
print_phase_context() {
    local context_message="$1"
    echo "   ${COLOR_COMMENT}($context_message)${COLOR_RESET}"
}

# ============================================================================
# Cleanup Handlers
# ============================================================================

# Register a cleanup function to run on exit/interrupt
#
# Parameters:
#   $1 - Function name to call on cleanup
#
# Usage:
#   cleanup_docker() {
#       docker rm -f test-container
#   }
#   register_cleanup_handler cleanup_docker
register_cleanup_handler() {
    local cleanup_function="$1"

    trap "$cleanup_function" EXIT INT TERM
}

# ============================================================================
# Prerequisites Checking
# ============================================================================

# Check if a prerequisite file exists
#
# Parameters:
#   $1 - File path
#   $2 - Description (for error message)
#
# Returns:
#   0 - File exists
#   1 - File not found
#
# Usage:
#   check_prereq_file ~/.ssh/key "SSH key"
check_prereq_file() {
    local file_path="$1"
    local description="$2"

    if [[ ! -f "$file_path" ]]; then
        print_error "$description not found: $file_path"
        return 1
    fi

    print_success "$description found"
    return 0
}

# Check if a prerequisite command exists
#
# Parameters:
#   $1 - Command name
#   $2 - Description (for error message)
#
# Returns:
#   0 - Command exists
#   1 - Command not found
#
# Usage:
#   check_prereq_command docker "Docker daemon"
check_prereq_command() {
    local command_name="$1"
    local description="$2"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        print_error "$description not found: $command_name"
        return 1
    fi

    print_success "$description is available"
    return 0
}

# Check if a remote host is accessible via SSH
#
# Parameters:
#   $1 - SSH key path
#   $2 - User
#   $3 - Host/IP
#   $4 - Description (for messages)
#
# Returns:
#   0 - Host accessible
#   1 - Host not accessible
#
# Usage:
#   check_prereq_ssh ~/.ssh/key root host.local "XCP-NG host"
check_prereq_ssh() {
    local ssh_key="$1"
    local user="$2"
    local host="$3"
    local description="$4"

    if ! remote_ssh "$ssh_key" "$user" "$host" "echo OK" >/dev/null 2>&1; then
        print_error "Cannot connect to $description: $host"
        return 1
    fi

    print_success "$description accessible: $host"
    return 0
}

# ============================================================================
# Test Utilities
# ============================================================================

# Run a command with timeout
#
# Parameters:
#   $1 - Timeout in seconds
#   $@ - Command to run
#
# Returns:
#   Exit code of command (or 124 if timeout)
#
# Usage:
#   run_with_timeout 30 docker pull ubuntu:24.04
run_with_timeout() {
    local timeout_seconds="$1"
    shift
    local command="$@"

    timeout "$timeout_seconds" bash -c "$command"
}

# Create temporary directory for test artifacts
#
# Parameters:
#   $1 - Prefix for temp directory (default: "test")
#
# Returns:
#   Prints path to temporary directory
#
# Usage:
#   TEST_DIR=$(create_test_tempdir "docker-test")
create_test_tempdir() {
    local prefix="${1:-test}"
    local temp_dir=$(mktemp -d "/tmp/${prefix}-XXXXXX")

    echo "$temp_dir"
}

# ============================================================================
# Export Functions (Make available to scripts that source this library)
# ============================================================================

# Test result tracking
export -f init_test_tracking
export -f track_test_result
export -f print_test_summary

# Wait/retry utilities
export -f wait_for_condition
export -f wait_for_ssh

# SSH helpers
export -f remote_ssh

# Output parsing
export -f parse_test_output

# Phase-based testing
export -f print_test_phase
export -f print_phase_context

# Cleanup handlers
export -f register_cleanup_handler

# Prerequisites checking
export -f check_prereq_file
export -f check_prereq_command
export -f check_prereq_ssh

# Test utilities
export -f run_with_timeout
export -f create_test_tempdir

# ============================================================================
# Library Loaded Flag
# ============================================================================

typeset -g DOTFILES_TEST_HELPERS_LOADED=1
