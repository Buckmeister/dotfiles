#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Symlink Creation
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

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "Symlink Creation Integration Tests"

# ============================================================================
# Test Helpers
# ============================================================================

TEST_TEMP_DIR="/tmp/dotfiles_test_$$"

function setup() {
    # Create temporary test directory
    mkdir -p "$TEST_TEMP_DIR"
}

function teardown() {
    # Clean up temporary test directory
    rm -rf "$TEST_TEMP_DIR"
}

# ============================================================================
# Test Cases
# ============================================================================

test_case "should find .symlink files in repository" '
    local symlink_files=$(find "$DOTFILES_ROOT" -name "*.symlink" -type f | wc -l | tr -d " ")

    if [[ $symlink_files -gt 0 ]]; then
        return 0
    else
        echo "No .symlink files found in repository"
        return 1
    fi
'

test_case "should find .symlink_config directories in repository" '
    local symlink_dirs=$(find "$DOTFILES_ROOT" -name "*.symlink_config" -type d | wc -l | tr -d " ")

    if [[ $symlink_dirs -gt 0 ]]; then
        return 0
    else
        echo "No .symlink_config directories found in repository"
        return 1
    fi
'

test_case "should find .symlink_local_bin files in repository" '
    local local_bin_files=$(find "$DOTFILES_ROOT" -name "*.symlink_local_bin.*" -type f | wc -l | tr -d " ")

    if [[ $local_bin_files -gt 0 ]]; then
        return 0
    else
        echo "No .symlink_local_bin files found in repository"
        return 1
    fi
'

test_case "link_dotfiles.zsh script should exist and be executable" '
    local link_script="$DOTFILES_ROOT/bin/link_dotfiles.zsh"

    if [[ ! -f "$link_script" ]]; then
        echo "link_dotfiles.zsh not found"
        return 1
    fi

    if [[ ! -x "$link_script" ]]; then
        echo "link_dotfiles.zsh is not executable"
        return 1
    fi

    return 0
'

test_case "link_dotfiles.zsh should have --help flag" '
    local link_script="$DOTFILES_ROOT/bin/link_dotfiles.zsh"
    local help_output=$("$link_script" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"help"* ]]; then
        return 0
    else
        echo "No help output found"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
