#!/usr/bin/env zsh

# ============================================================================
# Test Helpers for Post-Install Scripts
# ============================================================================
# This library provides utility functions for creating, managing, and testing
# post-install scripts in test environments.
#
# Usage:
#   source tests/lib/test_pi_helpers.zsh
#   create_test_pi_script "/tmp/test.zsh" "echo 'test'"
#   mark_script_ignored "/tmp/test.zsh"
#   cleanup_test_pi_scripts

emulate -LR zsh

# ============================================================================
# Global Test State
# ============================================================================

# Track test scripts created for cleanup
declare -a TEST_PI_SCRIPTS=()

# Default test directory
TEST_PI_DEFAULT_DIR="${TEST_PI_DEFAULT_DIR:-/tmp/test_pi_scripts_$$}"

# ============================================================================
# Script Creation Helpers
# ============================================================================

# Create a test post-install script with specified content
# Args:
#   $1 - Script path
#   $2 - Script content (optional, defaults to echo statement)
function create_test_pi_script() {
    local script_path="$1"
    local script_content="${2:-echo 'Test script executed'}"

    # Create directory if needed
    local script_dir="$(dirname "$script_path")"
    mkdir -p "$script_dir"

    # Write script
    cat > "$script_path" <<EOF
#!/usr/bin/env zsh
$script_content
EOF

    # Make executable
    chmod +x "$script_path"

    # Track for cleanup
    TEST_PI_SCRIPTS+=("$script_path")

    return 0
}

# Create multiple test scripts quickly
# Args:
#   $1 - Directory for scripts
#   $2+ - Script names (without .zsh extension)
function create_test_pi_scripts() {
    local dir="$1"
    shift

    mkdir -p "$dir"

    for script_name in "$@"; do
        local script_path="$dir/${script_name}.zsh"
        create_test_pi_script "$script_path" "echo '${script_name} executed'"
    done
}

# ============================================================================
# Marker File Helpers (.ignored and .disabled)
# ============================================================================

# Mark a script as ignored (local-only)
# Args:
#   $1 - Script path
#   $2 - Reason (optional, written to .ignored file)
function mark_script_ignored() {
    local script_path="$1"
    local reason="${2:-Temporarily ignored for testing}"
    local ignored_file="${script_path}.ignored"

    echo "$reason" > "$ignored_file"

    # Track for cleanup
    TEST_PI_SCRIPTS+=("$ignored_file")

    return 0
}

# Mark a script as disabled (can be checked in)
# Args:
#   $1 - Script path
#   $2 - Reason (optional, written to .disabled file)
function mark_script_disabled() {
    local script_path="$1"
    local reason="${2:-Disabled for testing}"
    local disabled_file="${script_path}.disabled"

    echo "$reason" > "$disabled_file"

    # Track for cleanup
    TEST_PI_SCRIPTS+=("$disabled_file")

    return 0
}

# Remove .ignored marker from a script
# Args:
#   $1 - Script path
function unmark_script_ignored() {
    local script_path="$1"
    local ignored_file="${script_path}.ignored"

    rm -f "$ignored_file"

    # Remove from tracking
    TEST_PI_SCRIPTS=("${(@)TEST_PI_SCRIPTS:#$ignored_file}")

    return 0
}

# Remove .disabled marker from a script
# Args:
#   $1 - Script path
function unmark_script_disabled() {
    local script_path="$1"
    local disabled_file="${script_path}.disabled"

    rm -f "$disabled_file"

    # Remove from tracking
    TEST_PI_SCRIPTS=("${(@)TEST_PI_SCRIPTS:#$disabled_file}")

    return 0
}

# ============================================================================
# Test Setup and Teardown
# ============================================================================

# Create a test environment with mixed enabled/disabled scripts
# Args:
#   $1 - Test directory (optional, defaults to TEST_PI_DEFAULT_DIR)
# Returns:
#   Sets TEST_PI_ENV_DIR with the created directory
function setup_test_pi_environment() {
    local test_dir="${1:-$TEST_PI_DEFAULT_DIR}"

    mkdir -p "$test_dir"

    # Create enabled scripts
    create_test_pi_script "$test_dir/enabled-1.zsh" "echo 'ENABLED_1'"
    create_test_pi_script "$test_dir/enabled-2.zsh" "echo 'ENABLED_2'"

    # Create ignored script
    create_test_pi_script "$test_dir/ignored-1.zsh" "echo 'IGNORED_1'"
    mark_script_ignored "$test_dir/ignored-1.zsh" "Ignored for testing"

    # Create disabled script
    create_test_pi_script "$test_dir/disabled-1.zsh" "echo 'DISABLED_1'"
    mark_script_disabled "$test_dir/disabled-1.zsh" "Disabled for testing"

    # Create script with both markers
    create_test_pi_script "$test_dir/both-markers.zsh" "echo 'BOTH'"
    mark_script_ignored "$test_dir/both-markers.zsh"
    mark_script_disabled "$test_dir/both-markers.zsh"

    export TEST_PI_ENV_DIR="$test_dir"

    return 0
}

# Clean up all test post-install scripts and markers
function cleanup_test_pi_scripts() {
    for script in "${TEST_PI_SCRIPTS[@]}"; do
        rm -f "$script"
    done

    # Clear tracking array
    TEST_PI_SCRIPTS=()

    # Remove test environment directory if it exists
    if [[ -n "$TEST_PI_ENV_DIR" && -d "$TEST_PI_ENV_DIR" ]]; then
        rm -rf "$TEST_PI_ENV_DIR"
        unset TEST_PI_ENV_DIR
    fi

    # Remove default directory if it exists
    if [[ -d "$TEST_PI_DEFAULT_DIR" ]]; then
        rm -rf "$TEST_PI_DEFAULT_DIR"
    fi

    return 0
}

# ============================================================================
# Counting and Filtering Helpers
# ============================================================================

# Count enabled scripts in a directory
# Args:
#   $1 - Directory path
# Outputs:
#   Number of enabled scripts
function count_enabled_scripts() {
    local dir="$1"
    local count=0

    setopt local_options nullglob

    for script in "$dir/"*.zsh; do
        if [[ -f "$script" ]] && is_post_install_script_enabled "$script"; then
            count=$((count + 1))
        fi
    done

    echo "$count"
}

# Count disabled scripts (with .ignored or .disabled) in a directory
# Args:
#   $1 - Directory path
# Outputs:
#   Number of disabled scripts
function count_disabled_scripts() {
    local dir="$1"
    local count=0

    setopt local_options nullglob

    for script in "$dir/"*.zsh; do
        if [[ -f "$script" ]] && ! is_post_install_script_enabled "$script"; then
            count=$((count + 1))
        fi
    done

    echo "$count"
}

# List enabled scripts in a directory
# Args:
#   $1 - Directory path
# Outputs:
#   List of enabled script paths (one per line)
function list_enabled_scripts() {
    local dir="$1"

    setopt local_options nullglob

    for script in "$dir/"*.zsh; do
        if [[ -f "$script" ]] && is_post_install_script_enabled "$script"; then
            echo "$script"
        fi
    done
}

# List disabled scripts in a directory
# Args:
#   $1 - Directory path
# Outputs:
#   List of disabled script paths (one per line)
function list_disabled_scripts() {
    local dir="$1"

    setopt local_options nullglob

    for script in "$dir/"*.zsh; do
        if [[ -f "$script" ]] && ! is_post_install_script_enabled "$script"; then
            echo "$script"
        fi
    done
}

# ============================================================================
# Execution Helpers
# ============================================================================

# Execute only enabled scripts from a directory
# Args:
#   $1 - Directory path
# Returns:
#   0 if all enabled scripts executed successfully, 1 otherwise
function execute_enabled_scripts() {
    local dir="$1"
    local failed=0

    setopt local_options nullglob

    for script in "$dir/"*.zsh; do
        if [[ -f "$script" ]] && is_post_install_script_enabled "$script"; then
            if ! "$script"; then
                failed=$((failed + 1))
            fi
        fi
    done

    return $failed
}

# Capture output from enabled scripts only
# Args:
#   $1 - Directory path
# Outputs:
#   Combined output from all enabled scripts
function capture_enabled_script_output() {
    local dir="$1"
    local output=""

    setopt local_options nullglob

    for script in "$dir/"*.zsh; do
        if [[ -f "$script" ]] && is_post_install_script_enabled "$script"; then
            output+=$("$script" 2>&1)
        fi
    done

    echo "$output"
}

# ============================================================================
# Assertion Helpers for Tests
# ============================================================================

# Assert that a script is enabled
# Args:
#   $1 - Script path
# Returns:
#   0 if enabled, 1 if disabled
function assert_script_enabled() {
    local script_path="$1"

    if is_post_install_script_enabled "$script_path"; then
        return 0
    else
        echo "ASSERTION FAILED: Script should be enabled: $script_path"
        return 1
    fi
}

# Assert that a script is disabled
# Args:
#   $1 - Script path
# Returns:
#   0 if disabled, 1 if enabled
function assert_script_disabled() {
    local script_path="$1"

    if is_post_install_script_enabled "$script_path"; then
        echo "ASSERTION FAILED: Script should be disabled: $script_path"
        return 1
    else
        return 0
    fi
}

# Assert exact count of enabled scripts
# Args:
#   $1 - Directory path
#   $2 - Expected count
# Returns:
#   0 if count matches, 1 otherwise
function assert_enabled_count() {
    local dir="$1"
    local expected="$2"
    local actual=$(count_enabled_scripts "$dir")

    if [[ $actual -eq $expected ]]; then
        return 0
    else
        echo "ASSERTION FAILED: Expected $expected enabled scripts, got $actual"
        return 1
    fi
}

# Export functions for use in tests
export -f create_test_pi_script
export -f create_test_pi_scripts
export -f mark_script_ignored
export -f mark_script_disabled
export -f unmark_script_ignored
export -f unmark_script_disabled
export -f setup_test_pi_environment
export -f cleanup_test_pi_scripts
export -f count_enabled_scripts
export -f count_disabled_scripts
export -f list_enabled_scripts
export -f list_disabled_scripts
export -f execute_enabled_scripts
export -f capture_enabled_script_output
export -f assert_script_enabled
export -f assert_script_disabled
export -f assert_enabled_count
