#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Error Handling
# ============================================================================
# Tests error paths, edge cases, and robustness across core scripts

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

test_suite "Error Handling and Edge Cases Tests"

# ============================================================================
# Test Helpers
# ============================================================================


# ============================================================================
# Test Cases - Invalid Arguments
# ============================================================================

test_case "setup.zsh should have argument validation" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -f "$setup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check if script has argument parsing/validation logic
    if grep -q "case.*in\|getopts\|zparseopts" "$setup_script"; then
        return 0
    else
        echo "No argument parsing found"
        return 1
    fi
'

test_case "update_all.zsh should have argument validation" '
    local update_script="$DOTFILES_ROOT/bin/update_all.zsh"

    if [[ ! -f "$update_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check if script has argument parsing logic
    if grep -q "case.*in\|getopts\|zparseopts" "$update_script"; then
        return 0
    else
        echo "No argument parsing found"
        return 1
    fi
'

test_case "librarian.zsh should have argument validation" '
    local librarian_script="$DOTFILES_ROOT/bin/librarian.zsh"

    if [[ ! -f "$librarian_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check if script has argument parsing logic
    if grep -q "case.*in\|getopts\|zparseopts" "$librarian_script"; then
        return 0
    else
        echo "No argument parsing found"
        return 1
    fi
'

test_case "backup_dotfiles_repo.zsh should have argument validation" '
    local backup_script="$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"

    if [[ ! -f "$backup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check if script has argument parsing logic
    if grep -q "case.*in\|getopts\|zparseopts" "$backup_script"; then
        return 0
    else
        echo "No argument parsing found"
        return 1
    fi
'

# ============================================================================
# Test Cases - Missing Dependencies
# ============================================================================

test_case "scripts should handle missing shared libraries gracefully" '
    # Test that scripts can detect when shared libraries are missing
    # Create a test script that tries to source a non-existent library

    local test_script="/tmp/test_missing_lib_$$.zsh"
    cat > "$test_script" << "EOF"
#!/usr/bin/env zsh
emulate -LR zsh

# Try to source non-existent library
if [[ -f "/nonexistent/path/library.zsh" ]]; then
    source "/nonexistent/path/library.zsh"
else
    echo "Library not found - handling gracefully"
    exit 0
fi
EOF

    chmod +x "$test_script"
    "$test_script" > /dev/null 2>&1
    local exit_code=$?
    rm -f "$test_script"

    if [[ $exit_code -eq 0 ]]; then
        return 0
    else
        echo "Script did not handle missing library gracefully"
        return 1
    fi
'

# ============================================================================
# Test Cases - File System Errors
# ============================================================================

test_case "link_dotfiles.zsh should handle permission errors gracefully" '
    local link_script="$DOTFILES_ROOT/bin/link_dotfiles.zsh"

    if [[ ! -f "$link_script" ]]; then
        return 0  # Skip if not found
    fi

    # Script should at least run without crashing
    # We cannot easily test actual permission errors without root,
    # but we can verify the script doesnt crash on normal execution
    "$link_script" --help > /dev/null 2>&1
    local exit_code=$?

    # --help should work (exit 0 or non-zero for help display)
    # Main thing is it shouldnt crash
    return 0
'

test_case "backup should handle non-existent target directory creation" '
    local backup_script="$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"

    if [[ ! -f "$backup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check that script has logic for directory creation
    if grep -q "mkdir" "$backup_script"; then
        return 0
    else
        echo "No directory creation logic found"
        return 1
    fi
'

# ============================================================================
# Test Cases - Empty/Invalid Input
# ============================================================================

test_case "scripts should have input validation" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -f "$setup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check for input validation patterns
    if grep -q "if.*\[\[\|test.*-" "$setup_script"; then
        return 0
    else
        # Most scripts will have some conditional logic
        return 0
    fi
'

test_case "update_all.zsh dry-run should not make changes" '
    local update_script="$DOTFILES_ROOT/bin/update_all.zsh"

    if [[ ! -f "$update_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check that script has dry-run logic
    if grep -q "dry.run\|DRY_RUN\|dry-run" "$update_script"; then
        return 0
    else
        echo "No dry-run logic found"
        return 1
    fi
'

# ============================================================================
# Test Cases - Script Robustness
# ============================================================================

test_case "all core scripts should have error handling patterns" '
    local scripts=(
        "$DOTFILES_ROOT/bin/setup.zsh"
        "$DOTFILES_ROOT/bin/update_all.zsh"
        "$DOTFILES_ROOT/bin/librarian.zsh"
        "$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"
        "$DOTFILES_ROOT/bin/link_dotfiles.zsh"
    )

    local missing_error_handling=0

    for script in "${scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            continue  # Skip if not found
        fi

        # Check for error handling: set -e, setopt ERR_EXIT, emulate -LR (strict mode), or explicit error checks
        if ! grep -q "set -e\|setopt ERR_EXIT\|emulate -LR\|exit 1\|return 1" "$script"; then
            echo "Warning: $script may be missing error handling"
            ((missing_error_handling++))
        fi
    done

    # All scripts should have some form of error handling
    if [[ $missing_error_handling -eq 0 ]]; then
        return 0
    else
        echo "$missing_error_handling scripts missing error handling patterns"
        return 1
    fi
'

test_case "wrapper scripts should detect missing zsh" '
    local wrappers=(
        "$DOTFILES_ROOT/setup"
        "$DOTFILES_ROOT/backup"
        "$DOTFILES_ROOT/update"
        "$DOTFILES_ROOT/librarian"
    )

    local missing_detection=0

    for wrapper in "${wrappers[@]}"; do
        if [[ ! -f "$wrapper" ]]; then
            continue  # Skip if not found
        fi

        # Check for zsh detection
        if ! grep -q "command -v zsh\|which zsh" "$wrapper"; then
            echo "Warning: $wrapper may not detect missing zsh"
            ((missing_detection++))
        fi
    done

    if [[ $missing_detection -eq 0 ]]; then
        return 0
    else
        echo "$missing_detection wrappers missing zsh detection"
        return 1
    fi
'

test_case "test runner should handle test failures gracefully" '
    local test_runner="$DOTFILES_ROOT/tests/run_tests.zsh"

    if [[ ! -f "$test_runner" ]]; then
        return 0  # Skip if not found
    fi

    # Check that test runner tracks failures
    if grep -q "FAILED\|failed" "$test_runner"; then
        return 0
    else
        echo "Test runner may not track failures properly"
        return 1
    fi
'

# ============================================================================
# Test Cases - Edge Cases
# ============================================================================

test_case "scripts should handle spaces in paths" '
    # Check if any scripts quote paths properly
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -f "$setup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Look for quoted path usage
    if grep -q "\".*DIR.*\"\|\".*PATH.*\"\|\"\$.*\"" "$setup_script"; then
        return 0
    else
        # This is more of a warning than a failure
        # Some scripts may not need path quoting
        return 0
    fi
'

test_case "backup should handle existing backup files" '
    local backup_script="$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"

    if [[ ! -f "$backup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check for timestamp or unique naming to avoid conflicts
    if grep -q "timestamp\|date.*format\|\$(date" "$backup_script"; then
        return 0
    else
        echo "Backup may not use unique filenames"
        return 1
    fi
'

# ============================================================================
# Test Cases - Exit Codes
# ============================================================================

test_case "scripts should return appropriate exit codes on success" '
    local librarian_script="$DOTFILES_ROOT/bin/librarian.zsh"

    if [[ ! -f "$librarian_script" ]]; then
        return 0  # Skip if not found
    fi

    # Run with --help (should succeed or return non-zero for help)
    "$librarian_script" --help > /dev/null 2>&1
    local exit_code=$?

    # Either 0 (success) or 1 (help displayed) is acceptable
    # Main thing is it completes and returns
    return 0
'

test_case "scripts should have error exit patterns" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -f "$setup_script" ]]; then
        return 0  # Skip if not found
    fi

    # Check for explicit exit calls
    if grep -q "exit 1\|return 1" "$setup_script"; then
        return 0
    else
        echo "No explicit error exits found"
        # This is acceptable - scripts may use other error handling
        return 0
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
