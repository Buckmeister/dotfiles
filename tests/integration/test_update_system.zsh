#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Update System
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "Update System Integration Tests"

# ============================================================================
# Test Helpers
# ============================================================================

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ============================================================================
# Test Cases
# ============================================================================

test_case "update_all.zsh should exist and be executable" '
    local update_script="$DOTFILES_ROOT/bin/update_all.zsh"

    assert_file_exists "$update_script" "update_all.zsh should exist"

    if [[ -x "$update_script" ]]; then
        return 0
    else
        echo "update_all.zsh is not executable"
        return 1
    fi
'

test_case "update_all.zsh --help should work" '
    local update_script="$DOTFILES_ROOT/bin/update_all.zsh"
    local help_output=$("$update_script" --help 2>&1)

    assert_contains "$help_output" "Usage" "Help should contain usage info"
    assert_contains "$help_output" "--dry-run" "Help should mention dry-run"
'

test_case "update_all.zsh --dry-run should not make changes" '
    local update_script="$DOTFILES_ROOT/bin/update_all.zsh"
    local output=$("$update_script" --dry-run --npm 2>&1)

    assert_contains "$output" "DRY RUN" "Output should indicate dry run"
'

test_case "npm-global-packages.zsh should have --update flag" '
    local npm_script="$DOTFILES_ROOT/post-install/scripts/npm-global-packages.zsh"

    assert_file_exists "$npm_script" "npm-global-packages.zsh should exist"

    local help_output=$("$npm_script" --help 2>&1)
    assert_contains "$help_output" "--update" "Should have --update flag"
'

test_case "cargo-packages.zsh should have --update flag" '
    local cargo_script="$DOTFILES_ROOT/post-install/scripts/cargo-packages.zsh"

    assert_file_exists "$cargo_script" "cargo-packages.zsh should exist"

    local help_output=$("$cargo_script" --help 2>&1)
    assert_contains "$help_output" "--update" "Should have --update flag"
'

test_case "ruby-gems.zsh should have --update flag" '
    local gem_script="$DOTFILES_ROOT/post-install/scripts/ruby-gems.zsh"

    assert_file_exists "$gem_script" "ruby-gems.zsh should exist"

    local help_output=$("$gem_script" --help 2>&1)
    assert_contains "$help_output" "--update" "Should have --update flag"
'

test_case "versions.env should document update strategy" '
    local versions_file="$DOTFILES_ROOT/config/versions.env"

    assert_file_exists "$versions_file" "versions.env should exist"

    local content=$(cat "$versions_file")
    assert_contains "$content" "update_all.zsh" "Should mention update_all.zsh"
    assert_contains "$content" "VERSION PINNING" "Should document version pinning"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
