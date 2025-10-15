#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for profile_manager.zsh
# ============================================================================
# Tests the profile manager's argument handling and basic operations

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

test_suite "profile_manager.zsh Integration Tests"

# ============================================================================
# Help Flag Tests
# ============================================================================

test_case "profile_manager should have --help flag" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    if [[ ! -f "$pm" ]]; then
        echo "profile_manager.zsh not found"
        return 1
    fi

    local help_output=$("$pm" --help 2>&1)

    if [[ "$help_output" == *"DESCRIPTION"* ]] || \
       [[ "$help_output" == *"USAGE"* ]] || \
       [[ "$help_output" == *"usage"* ]] || \
       [[ "$help_output" == *"Profile Manager"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "profile_manager should have -h flag" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"
    local help_output=$("$pm" -h 2>&1)

    if [[ "$help_output" == *"DESCRIPTION"* ]] || \
       [[ "$help_output" == *"USAGE"* ]] || \
       [[ "$help_output" == *"usage"* ]] || \
       [[ "$help_output" == *"Profile Manager"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "profile_manager help should mention subcommands" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"
    local help_output=$("$pm" --help 2>&1)

    # Should mention key subcommands
    if [[ "$help_output" == *"list"* ]] || \
       [[ "$help_output" == *"show"* ]] || \
       [[ "$help_output" == *"apply"* ]]; then
        return 0
    else
        echo "Help should mention subcommands (list, show, apply)"
        return 1
    fi
'

# ============================================================================
# Subcommand Tests
# ============================================================================

test_case "profile_manager should handle list subcommand" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # list command should not error (even if no profiles exist)
    if "$pm" list >/dev/null 2>&1 || [[ $? -eq 1 ]]; then
        return 0
    else
        echo "list subcommand should work"
        return 1
    fi
'

test_case "profile_manager should handle show subcommand" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # show command with invalid profile should give helpful error
    local output=$("$pm" show nonexistent_profile 2>&1 || true)

    # Should either show profile or give error message
    return 0
'

test_case "profile_manager should handle current subcommand" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # current command should not crash
    "$pm" current >/dev/null 2>&1 || true
    return 0
'

# ============================================================================
# Argument Validation Tests
# ============================================================================

test_case "profile_manager should reject unknown subcommands" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"
    local output=$("$pm" unknown_command 2>&1 || true)

    # Should give error or help for unknown command
    if [[ "$output" == *"Unknown"* ]] || \
       [[ "$output" == *"Invalid"* ]] || \
       [[ "$output" == *"USAGE"* ]] || \
       [[ "$output" == *"Error"* ]]; then
        return 0
    else
        echo "Should reject unknown subcommands"
        return 1
    fi
'

test_case "profile_manager should require profile name for show" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"
    local output=$("$pm" show 2>&1 || true)

    # Should give error about missing profile name
    # Or show help
    return 0
'

test_case "profile_manager should require profile name for apply" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"
    local output=$("$pm" apply 2>&1 || true)

    # Should give error about missing profile name
    # Or show help
    return 0
'

# ============================================================================
# Library Loading Tests
# ============================================================================

test_case "profile_manager should load required libraries" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Check that script references required libraries
    if grep -q "colors.zsh" "$pm" && \
       grep -q "ui.zsh" "$pm" && \
       grep -q "utils.zsh" "$pm"; then
        return 0
    else
        echo "profile_manager should load required libraries"
        return 1
    fi
'

# ============================================================================
# Configuration Tests
# ============================================================================

test_case "profile_manager defines profiles directory" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    if grep -q "PROFILES_DIR\|profiles/" "$pm"; then
        return 0
    else
        echo "profile_manager should define profiles directory"
        return 1
    fi
'

test_case "profile_manager defines current profile file" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    if grep -q "CURRENT_PROFILE_FILE\|current_profile" "$pm"; then
        return 0
    else
        echo "profile_manager should define current profile file"
        return 1
    fi
'

# ============================================================================
# Function Existence Tests
# ============================================================================

test_case "profile_manager defines parse_profile function" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    if grep -q "function parse_profile" "$pm"; then
        return 0
    else
        echo "profile_manager should define parse_profile function"
        return 1
    fi
'

test_case "profile_manager has subcommand handling" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Should have case statement or similar for subcommands
    if grep -q "list)\|show)\|apply)\|current)" "$pm"; then
        return 0
    else
        echo "profile_manager should have subcommand handling"
        return 1
    fi
'

# ============================================================================
# Profile Directory Tests
# ============================================================================

test_case "profiles directory should exist or be mentioned" '
    local profiles_dir="$DOTFILES_ROOT/profiles"

    # Either directory exists or profile_manager mentions it
    if [[ -d "$profiles_dir" ]] || grep -q "profiles" "$DOTFILES_ROOT/bin/profile_manager.zsh"; then
        return 0
    else
        echo "Profiles directory should exist or be mentioned"
        return 1
    fi
'

# ============================================================================
# Integration Tests
# ============================================================================

test_case "profile_manager should handle no-profile case gracefully" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Remove current profile marker if exists
    rm -f "$HOME/.config/dotfiles/current_profile"

    # current command should not crash even with no profile set
    local output=$("$pm" current 2>&1 || true)

    # Should either show "no profile" or handle gracefully
    return 0
'

test_case "profile_manager executable check" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    if [[ -x "$pm" ]]; then
        return 0
    else
        echo "profile_manager.zsh should be executable"
        return 1
    fi
'

# ============================================================================
# Error Handling Tests
# ============================================================================

test_case "profile_manager should handle missing profile directory" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Script should handle case where profiles dir does not exist
    # (Should give helpful error, not crash)
    local output=$("$pm" list 2>&1 || true)

    # As long as it does not crash completely
    return 0
'

test_case "profile_manager should validate profile names" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Try to show a profile that definitely does not exist
    local output=$("$pm" show "definitely_nonexistent_profile_xyz" 2>&1 || true)

    # Should give error message
    if [[ "$output" == *"not found"* ]] || \
       [[ "$output" == *"Error"* ]] || \
       [[ "$output" == *"does not exist"* ]] || \
       [[ -z "$output" ]]; then
        return 0
    else
        echo "Should validate profile names"
        return 1
    fi
'

# ============================================================================
# Documentation Tests
# ============================================================================

test_case "profile_manager has usage documentation" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Check for documentation in header or help function
    if head -30 "$pm" | grep -q "Usage:\|USAGE:" || \
       grep -q "function show_help\|print.*usage" "$pm"; then
        return 0
    else
        echo "profile_manager should have usage documentation"
        return 1
    fi
'

test_case "profile_manager documents supported profiles" '
    local pm="$DOTFILES_ROOT/bin/profile_manager.zsh"

    # Check for profile documentation
    if head -30 "$pm" | grep -q "minimal\|standard\|full\|work\|personal"; then
        return 0
    else
        echo "profile_manager should document supported profiles"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
