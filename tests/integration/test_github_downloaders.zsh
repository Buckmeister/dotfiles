#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for GitHub Downloader Utilities
# ============================================================================
# Tests get_github_url and get_jdtls_url utility scripts

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

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "GitHub Downloader Utilities Tests"

# ============================================================================
# Test Helpers
# ============================================================================


# Function to check if a tool exists
function tool_exists() {
    local tool="$1"
    if [[ -f "$HOME/.local/bin/$tool" ]] || [[ -f "$DOTFILES_ROOT/github/${tool}.symlink_local_bin.zsh" ]]; then
        return 0
    fi
    return 1
}

# Function to get tool path
function get_tool_path() {
    local tool="$1"
    if [[ -f "$HOME/.local/bin/$tool" ]]; then
        echo "$HOME/.local/bin/$tool"
    elif [[ -f "$DOTFILES_ROOT/github/${tool}.symlink_local_bin.zsh" ]]; then
        echo "$DOTFILES_ROOT/github/${tool}.symlink_local_bin.zsh"
    fi
}

# ============================================================================
# Test Cases - get_github_url
# ============================================================================

test_case "get_github_url should exist and be executable" '
    if ! tool_exists "get_github_url"; then
        echo "get_github_url not found (skipping remaining tests)"
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")

    if [[ ! -x "$tool_path" ]]; then
        echo "get_github_url is not executable"
        return 1
    fi

    return 0
'

test_case "get_github_url should require username argument" '
    if ! tool_exists "get_github_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")

    # Run without username, should show usage and exit non-zero
    # Capture exit code before assigning output
    "$tool_path" -r test > /tmp/test_gh_output_$$ 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test_gh_output_$$)
    rm -f /tmp/test_gh_output_$$

    # Should show usage message
    if [[ "$output" != *"Usage"* ]]; then
        echo "No usage message shown"
        return 1
    fi

    # Should exit with non-zero
    if [[ $exit_code -eq 0 ]]; then
        echo "Script did not fail when username was missing (exit code: $exit_code)"
        return 1
    fi

    return 0
'

test_case "get_github_url should require repository argument" '
    if ! tool_exists "get_github_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")

    # Run without repository, should show usage and exit non-zero
    # Capture exit code before assigning output
    "$tool_path" -u test > /tmp/test_gh_output_$$ 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test_gh_output_$$)
    rm -f /tmp/test_gh_output_$$

    # Should show usage message
    if [[ "$output" != *"Usage"* ]]; then
        echo "No usage message shown"
        return 1
    fi

    # Should exit with non-zero
    if [[ $exit_code -eq 0 ]]; then
        echo "Script did not fail when repository was missing (exit code: $exit_code)"
        return 1
    fi

    return 0
'

test_case "get_github_url should have shebang for zsh" '
    if ! tool_exists "get_github_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")
    local shebang=$(head -n 1 "$tool_path")

    if [[ "$shebang" == "#!/usr/bin/env zsh" || "$shebang" == "#!/bin/zsh" ]]; then
        return 0
    else
        echo "Unexpected shebang: $shebang"
        return 1
    fi
'

test_case "get_github_url should support silent mode flag" '
    if ! tool_exists "get_github_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")

    # Check if script recognizes silent flag
    if grep -q "silent" "$tool_path" && grep -q "IS_SILENT" "$tool_path"; then
        return 0
    else
        echo "Silent mode support not found in script"
        return 1
    fi
'

test_case "get_github_url should use zparseopts for argument parsing" '
    if ! tool_exists "get_github_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")

    # Check if script uses zparseopts
    if grep -q "zparseopts" "$tool_path"; then
        return 0
    else
        echo "zparseopts not found in script"
        return 1
    fi
'

test_case "get_github_url should validate JSON responses" '
    if ! tool_exists "get_github_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_github_url")

    # Check if script validates JSON with jq
    if grep -q "jq" "$tool_path"; then
        return 0
    else
        echo "JSON validation (jq) not found in script"
        return 1
    fi
'

# ============================================================================
# Test Cases - get_jdtls_url
# ============================================================================

test_case "get_jdtls_url should exist and be executable" '
    if ! tool_exists "get_jdtls_url"; then
        echo "get_jdtls_url not found (skipping remaining tests)"
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")

    if [[ ! -x "$tool_path" ]]; then
        echo "get_jdtls_url is not executable"
        return 1
    fi

    return 0
'

test_case "get_jdtls_url should show help with --help flag" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")
    local help_output=$("$tool_path" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found"
        return 1
    fi
'

test_case "get_jdtls_url should show help with -h flag" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")
    local help_output=$("$tool_path" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found"
        return 1
    fi
'

test_case "get_jdtls_url should have shebang for zsh" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")
    local shebang=$(head -n 1 "$tool_path")

    if [[ "$shebang" == "#!/usr/bin/env zsh" || "$shebang" == "#!/bin/zsh" ]]; then
        return 0
    else
        echo "Unexpected shebang: $shebang"
        return 1
    fi
'

test_case "get_jdtls_url should support version flag" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")

    # Check if script recognizes version flag
    if grep -q "version" "$tool_path" && grep -q "o_version" "$tool_path"; then
        return 0
    else
        echo "Version flag support not found in script"
        return 1
    fi
'

test_case "get_jdtls_url should support silent mode flag" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")

    # Check if script recognizes silent flag
    if grep -q "silent" "$tool_path" && grep -q "IS_SILENT" "$tool_path"; then
        return 0
    else
        echo "Silent mode support not found in script"
        return 1
    fi
'

test_case "get_jdtls_url should use zparseopts for argument parsing" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")

    # Check if script uses zparseopts
    if grep -q "zparseopts" "$tool_path"; then
        return 0
    else
        echo "zparseopts not found in script"
        return 1
    fi
'

test_case "get_jdtls_url should have fallback URL mechanism" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")

    # Check if script has fallback logic
    if grep -q "fallback" "$tool_path" || grep -q "urls_to_try" "$tool_path"; then
        return 0
    else
        echo "Fallback URL mechanism not found in script"
        return 1
    fi
'

test_case "get_jdtls_url should validate URL availability" '
    if ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if not installed
    fi

    local tool_path=$(get_tool_path "get_jdtls_url")

    # Check if script validates URLs before returning
    if grep -q "url_exists" "$tool_path" || grep -q "curl.*-I" "$tool_path"; then
        return 0
    else
        echo "URL validation not found in script"
        return 1
    fi
'

# ============================================================================
# Test Cases - Integration between downloaders
# ============================================================================

test_case "both downloaders should have consistent help format" '
    if ! tool_exists "get_github_url" || ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if either not installed
    fi

    local gh_tool=$(get_tool_path "get_github_url")
    local jdtls_tool=$(get_tool_path "get_jdtls_url")

    local gh_help=$("$gh_tool" --help 2>&1)
    local jdtls_help=$("$jdtls_tool" --help 2>&1)

    # Both should have Usage section
    if [[ "$gh_help" == *"Usage"* ]] && [[ "$jdtls_help" == *"Usage"* ]]; then
        return 0
    else
        echo "Inconsistent help format between downloaders"
        return 1
    fi
'

test_case "both downloaders should support silent mode" '
    if ! tool_exists "get_github_url" || ! tool_exists "get_jdtls_url"; then
        return 0  # Skip if either not installed
    fi

    local gh_tool=$(get_tool_path "get_github_url")
    local jdtls_tool=$(get_tool_path "get_jdtls_url")

    # Both should support -s/--silent
    if grep -q "silent" "$gh_tool" && grep -q "silent" "$jdtls_tool"; then
        return 0
    else
        echo "Inconsistent silent mode support"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
