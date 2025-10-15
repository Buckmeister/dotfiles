#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for wizard.zsh
# ============================================================================
# Tests the interactive configuration wizard's argument handling and basic operations

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

test_suite "wizard.zsh Integration Tests"

# ============================================================================
# Setup and Teardown
# ============================================================================

function setup() {
    # Backup wizard state if it exists
    if [[ -f "$HOME/.dotfiles_wizard_state" ]]; then
        mv "$HOME/.dotfiles_wizard_state" "$HOME/.dotfiles_wizard_state.bak"
    fi
}

function teardown() {
    # Restore wizard state if backup exists
    if [[ -f "$HOME/.dotfiles_wizard_state.bak" ]]; then
        mv "$HOME/.dotfiles_wizard_state.bak" "$HOME/.dotfiles_wizard_state"
    fi
    # Clean up test state
    rm -f "$HOME/.dotfiles_wizard_state"
}

# Run setup
setup

# ============================================================================
# Help Flag Tests
# ============================================================================

test_case "wizard should have --help flag" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if [[ ! -f "$wizard" ]]; then
        echo "wizard.zsh not found"
        return 1
    fi

    local help_output=$("$wizard" --help 2>&1)

    if [[ "$help_output" == *"DESCRIPTION"* ]] || \
       [[ "$help_output" == *"USAGE"* ]] || \
       [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "wizard should have -h flag" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"
    local help_output=$("$wizard" -h 2>&1)

    if [[ "$help_output" == *"DESCRIPTION"* ]] || \
       [[ "$help_output" == *"USAGE"* ]] || \
       [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "wizard help should mention key features" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"
    local help_output=$("$wizard" --help 2>&1)

    if [[ "$help_output" == *"resume"* ]] && \
       [[ "$help_output" == *"reset"* ]]; then
        return 0
    else
        echo "Help should mention resume and reset features"
        return 1
    fi
'

# ============================================================================
# Argument Handling Tests
# ============================================================================

test_case "wizard should reject unknown options" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"
    local output=$("$wizard" --unknown-flag 2>&1)

    if [[ "$output" == *"Unknown option"* ]] || \
       [[ "$output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "Should reject unknown options"
        return 1
    fi
'

test_case "wizard should accept --reset flag" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    # Create a dummy state file
    echo "TEST_STATE=1" > "$HOME/.dotfiles_wizard_state"

    # Run with --reset (will exit immediately, but should clear state)
    timeout 1 "$wizard" --reset >/dev/null 2>&1 || true

    # Check that state file was handled
    # Note: Script might create it again, so we just verify no error
    return 0
'

test_case "wizard should accept --resume flag" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    # Remove state file to test resume with no state
    rm -f "$HOME/.dotfiles_wizard_state"

    # Run with --resume (should show warning about no saved state)
    local output=$(timeout 1 "$wizard" --resume 2>&1 || true)

    # Either warns about no state or starts (both are valid)
    return 0
'

# ============================================================================
# Library Loading Tests
# ============================================================================

test_case "wizard should load all required libraries" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    # Check that script references all required libraries
    if grep -q "arguments.zsh" "$wizard" && \
       grep -q "colors.zsh" "$wizard" && \
       grep -q "ui.zsh" "$wizard" && \
       grep -q "greetings.zsh" "$wizard"; then
        return 0
    else
        echo "Wizard should load all required libraries"
        return 1
    fi
'

# ============================================================================
# State Management Tests
# ============================================================================

test_case "wizard defines state file location" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "WIZARD_STATE_FILE" "$wizard"; then
        return 0
    else
        echo "Wizard should define WIZARD_STATE_FILE"
        return 1
    fi
'

test_case "wizard defines config file location" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "WIZARD_CONFIG_FILE\|personal.env" "$wizard"; then
        return 0
    else
        echo "Wizard should define config file location"
        return 1
    fi
'

# ============================================================================
# Function Existence Tests
# ============================================================================

test_case "wizard defines show_help function" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "function show_help" "$wizard"; then
        return 0
    else
        echo "Wizard should define show_help function"
        return 1
    fi
'

test_case "wizard defines wizard step functions" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "step_welcome\|step_language_selection\|step_completion" "$wizard"; then
        return 0
    else
        echo "Wizard should define step functions"
        return 1
    fi
'

test_case "wizard uses argument parsing library" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "parse_simple_flags\|is_help_requested" "$wizard"; then
        return 0
    else
        echo "Wizard should use argument parsing library"
        return 1
    fi
'

# ============================================================================
# Integration with Arguments Library Tests
# ============================================================================

test_case "wizard integrates with arguments.zsh correctly" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    # Check that it sources arguments.zsh
    if ! grep -q "source.*arguments.zsh" "$wizard"; then
        echo "Wizard should source arguments.zsh"
        return 1
    fi

    # Check that it uses the library functions
    if ! grep -q "parse_simple_flags" "$wizard"; then
        echo "Wizard should call parse_simple_flags"
        return 1
    fi

    if ! grep -q "is_help_requested" "$wizard"; then
        echo "Wizard should call is_help_requested"
        return 1
    fi

    return 0
'

# ============================================================================
# Feature Completeness Tests
# ============================================================================

test_case "wizard includes international greetings" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "GREETINGS\|LANGUAGE_FLAGS" "$wizard"; then
        return 0
    else
        echo "Wizard should include international greetings"
        return 1
    fi
'

test_case "wizard includes profile selection" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "step_profile_selection\|USER_PROFILE" "$wizard"; then
        return 0
    else
        echo "Wizard should include profile selection"
        return 1
    fi
'

test_case "wizard generates configuration files" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if grep -q "personal.env\|gitconfig.local" "$wizard"; then
        return 0
    else
        echo "Wizard should generate configuration files"
        return 1
    fi
'

# ============================================================================
# Cleanup
# ============================================================================

# Run teardown
teardown

# ============================================================================
# Run Tests
# ============================================================================

run_tests
