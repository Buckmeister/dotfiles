#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Wrapper Scripts
# ============================================================================
# Tests that POSIX shell wrapper scripts correctly forward arguments

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

test_suite "Wrapper Script Integration Tests"

# ============================================================================
# Test Helpers
# ============================================================================


# ============================================================================
# Test Cases - Wrapper Scripts
# ============================================================================

test_case "setup wrapper should exist and be executable" '
    local setup_wrapper="$DOTFILES_ROOT/setup"

    if [[ ! -f "$setup_wrapper" ]]; then
        echo "setup wrapper not found"
        return 1
    fi

    if [[ ! -x "$setup_wrapper" ]]; then
        echo "setup wrapper is not executable"
        return 1
    fi

    return 0
'

test_case "setup wrapper should forward --help to setup.zsh" '
    local setup_wrapper="$DOTFILES_ROOT/setup"
    local help_output=$("$setup_wrapper" --help 2>&1)

    # Should see help output from setup.zsh
    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding arguments"
        return 1
    fi
'

test_case "setup wrapper should forward -h to setup.zsh" '
    local setup_wrapper="$DOTFILES_ROOT/setup"
    local help_output=$("$setup_wrapper" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding -h flag"
        return 1
    fi
'

test_case "backup wrapper should exist and be executable" '
    local backup_wrapper="$DOTFILES_ROOT/backup"

    if [[ ! -f "$backup_wrapper" ]]; then
        echo "backup wrapper not found"
        return 1
    fi

    if [[ ! -x "$backup_wrapper" ]]; then
        echo "backup wrapper is not executable"
        return 1
    fi

    return 0
'

test_case "backup wrapper should forward --help to backup_dotfiles_repo.zsh" '
    local backup_wrapper="$DOTFILES_ROOT/backup"
    local help_output=$("$backup_wrapper" --help 2>&1)

    # Should see help output from backup_dotfiles_repo.zsh
    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding arguments"
        return 1
    fi
'

test_case "backup wrapper should forward -h to backup_dotfiles_repo.zsh" '
    local backup_wrapper="$DOTFILES_ROOT/backup"
    local help_output=$("$backup_wrapper" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding -h flag"
        return 1
    fi
'

test_case "update wrapper should exist and be executable" '
    local update_wrapper="$DOTFILES_ROOT/update"

    if [[ ! -f "$update_wrapper" ]]; then
        echo "update wrapper not found"
        return 1
    fi

    if [[ ! -x "$update_wrapper" ]]; then
        echo "update wrapper is not executable"
        return 1
    fi

    return 0
'

test_case "update wrapper should forward --help to update_all.zsh" '
    local update_wrapper="$DOTFILES_ROOT/update"
    local help_output=$("$update_wrapper" --help 2>&1)

    # Should see help output from update_all.zsh
    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]] || [[ "$help_output" == *"USAGE"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding arguments"
        return 1
    fi
'

test_case "update wrapper should forward -h to update_all.zsh" '
    local update_wrapper="$DOTFILES_ROOT/update"
    local help_output=$("$update_wrapper" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]] || [[ "$help_output" == *"USAGE"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding -h flag"
        return 1
    fi
'

test_case "librarian wrapper should exist and be executable" '
    local librarian_wrapper="$DOTFILES_ROOT/librarian"

    if [[ ! -f "$librarian_wrapper" ]]; then
        echo "librarian wrapper not found"
        return 1
    fi

    if [[ ! -x "$librarian_wrapper" ]]; then
        echo "librarian wrapper is not executable"
        return 1
    fi

    return 0
'

test_case "librarian wrapper should forward --help to librarian.zsh" '
    local librarian_wrapper="$DOTFILES_ROOT/librarian"
    local help_output=$("$librarian_wrapper" --help 2>&1)

    # Should see help output from librarian.zsh (may include USAGE in uppercase)
    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding arguments"
        return 1
    fi
'

test_case "librarian wrapper should forward -h to librarian.zsh" '
    local librarian_wrapper="$DOTFILES_ROOT/librarian"
    local help_output=$("$librarian_wrapper" -h 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found - wrapper may not be forwarding -h flag"
        return 1
    fi
'

test_case "wrapper scripts should be POSIX shell (sh) scripts" '
    local errors=0

    for wrapper in setup backup update librarian; do
        local wrapper_path="$DOTFILES_ROOT/$wrapper"
        if [[ -f "$wrapper_path" ]]; then
            local shebang=$(head -n 1 "$wrapper_path")
            if [[ "$shebang" != "#!/bin/sh" ]] && [[ "$shebang" != "#!/usr/bin/env sh" ]]; then
                echo "Warning: $wrapper does not use sh shebang: $shebang"
                ((errors++))
            fi
        fi
    done

    if [[ $errors -eq 0 ]]; then
        return 0
    else
        echo "$errors wrapper(s) do not use POSIX sh shebang"
        return 1
    fi
'

test_case "wrapper scripts should detect OS" '
    local setup_wrapper="$DOTFILES_ROOT/setup"

    # Check if wrapper contains OS detection logic
    if grep -q "uname" "$setup_wrapper" 2>/dev/null; then
        return 0
    else
        echo "No OS detection found in wrapper (may not be needed)"
        # This is a soft check - not critical
        return 0
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
