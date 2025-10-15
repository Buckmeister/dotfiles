#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Help Flags
# ============================================================================
# Tests that all core scripts properly support -h and --help flags

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

test_suite "Help Flag Support Tests"

# ============================================================================
# Test Helpers
# ============================================================================


# ============================================================================
# Test Cases - Core Management Scripts
# ============================================================================

test_case "backup_dotfiles_repo.zsh should have --help flag" '
    local backup_script="$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"

    if [[ ! -f "$backup_script" ]]; then
        echo "backup_dotfiles_repo.zsh not found"
        return 1
    fi

    local help_output=$("$backup_script" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "backup_dotfiles_repo.zsh should have -h flag" '
    local backup_script="$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"
    local help_output=$("$backup_script" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "setup.zsh should have --help flag" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -f "$setup_script" ]]; then
        echo "setup.zsh not found"
        return 1
    fi

    local help_output=$("$setup_script" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "setup.zsh should have -h flag" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local help_output=$("$setup_script" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

# ============================================================================
# Test Cases - Test Scripts
# ============================================================================

test_case "test_docker_install.zsh should have --help flag" '
    local docker_test="$DOTFILES_ROOT/tests/test_docker_install.zsh"

    if [[ ! -f "$docker_test" ]]; then
        echo "test_docker_install.zsh not found"
        return 1
    fi

    local help_output=$("$docker_test" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "test_docker_install.zsh should have -h flag" '
    local docker_test="$DOTFILES_ROOT/tests/test_docker_install.zsh"
    local help_output=$("$docker_test" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "run_tests.zsh should have --help flag" '
    local test_runner="$DOTFILES_ROOT/tests/run_tests.zsh"

    if [[ ! -f "$test_runner" ]]; then
        echo "run_tests.zsh not found"
        return 1
    fi

    local help_output=$("$test_runner" --help 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "run_tests.zsh should have -h flag" '
    local test_runner="$DOTFILES_ROOT/tests/run_tests.zsh"
    local help_output=$("$test_runner" -h 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

# ============================================================================
# Test Cases - GitHub Downloaders
# ============================================================================

test_case "get_github_url should have --help flag" '
    local github_tool="$HOME/.local/bin/get_github_url"

    if [[ ! -f "$github_tool" ]]; then
        # Try alternate location
        github_tool="$DOTFILES_ROOT/github/get_github_url.symlink_local_bin.zsh"
        if [[ ! -f "$github_tool" ]]; then
            echo "get_github_url not found (this is okay if not installed)"
            return 0  # Skip test if tool not installed
        fi
    fi

    local help_output=$("$github_tool" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]] || [[ "$help_output" == *"help"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "get_github_url should have -h flag" '
    local github_tool="$HOME/.local/bin/get_github_url"

    if [[ ! -f "$github_tool" ]]; then
        github_tool="$DOTFILES_ROOT/github/get_github_url.symlink_local_bin.zsh"
        if [[ ! -f "$github_tool" ]]; then
            return 0  # Skip test if tool not installed
        fi
    fi

    local help_output=$("$github_tool" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]] || [[ "$help_output" == *"help"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

# ============================================================================
# Test Cases - New Management Scripts
# ============================================================================

test_case "wizard.zsh should have --help flag" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"

    if [[ ! -f "$wizard" ]]; then
        echo "wizard.zsh not found"
        return 1
    fi

    local help_output=$("$wizard" --help 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "wizard.zsh should have -h flag" '
    local wizard="$DOTFILES_ROOT/bin/wizard.zsh"
    local help_output=$("$wizard" -h 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "profile_manager.zsh should have --help flag" '
    local profile_manager="$DOTFILES_ROOT/bin/profile_manager.zsh"

    if [[ ! -f "$profile_manager" ]]; then
        echo "profile_manager.zsh not found"
        return 1
    fi

    local help_output=$("$profile_manager" --help 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "profile_manager.zsh should have -h flag" '
    local profile_manager="$DOTFILES_ROOT/bin/profile_manager.zsh"
    local help_output=$("$profile_manager" -h 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "update_all.zsh should have --help flag" '
    local update_all="$DOTFILES_ROOT/bin/update_all.zsh"

    if [[ ! -f "$update_all" ]]; then
        echo "update_all.zsh not found"
        return 1
    fi

    local help_output=$("$update_all" --help 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "update_all.zsh should have -h flag" '
    local update_all="$DOTFILES_ROOT/bin/update_all.zsh"
    local help_output=$("$update_all" -h 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

test_case "librarian.zsh should have --help flag" '
    local librarian="$DOTFILES_ROOT/bin/librarian.zsh"

    if [[ ! -f "$librarian" ]]; then
        echo "librarian.zsh not found"
        return 1
    fi

    local help_output=$("$librarian" --help 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "No help output found in --help"
        return 1
    fi
'

test_case "librarian.zsh should have -h flag" '
    local librarian="$DOTFILES_ROOT/bin/librarian.zsh"
    local help_output=$("$librarian" -h 2>&1)

    if [[ "$help_output" == *"USAGE"* ]] || [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"DESCRIPTION"* ]]; then
        return 0
    else
        echo "No help output found in -h"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
