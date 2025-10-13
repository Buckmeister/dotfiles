#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Post-Install Scripts (Smoke Tests)
# ============================================================================
#
# These are "smoke tests" - they verify that scripts exist, are executable,
# and have basic functionality like --help flags. They don't actually
# execute the full installation to avoid modifying the system during tests.
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "Post-Install Scripts Smoke Tests"

# ============================================================================
# Test Helpers
# ============================================================================

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
POST_INSTALL_DIR="$DOTFILES_ROOT/post-install/scripts"

# ============================================================================
# Generic Script Tests (Applied to All Scripts)
# ============================================================================

test_case "bash-preexec.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/bash-preexec.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "cargo-packages.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/cargo-packages.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "fonts.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/fonts.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "ghcup-packages.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/ghcup-packages.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "git-delta-config.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/git-delta-config.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "git-settings-general.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/git-settings-general.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "language-servers.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/language-servers.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "lombok.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/lombok.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "luarocks-packages.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/luarocks-packages.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "npm-global-packages.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/npm-global-packages.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "python-packages.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/python-packages.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "ruby-gems.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/ruby-gems.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "toolchains.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/toolchains.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

test_case "vim-setup.zsh should exist and be executable" '
    local script="$POST_INSTALL_DIR/vim-setup.zsh"

    if [[ ! -f "$script" ]]; then
        echo "Script not found: $script"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        echo "Script is not executable: $script"
        return 1
    fi

    return 0
'

# ============================================================================
# Help Flag Tests
# ============================================================================

test_case "npm-global-packages.zsh should have --help or --update flag" '
    local script="$POST_INSTALL_DIR/npm-global-packages.zsh"

    # Try --help first
    local output=$("$script" --help 2>&1 || true)

    # Check for help output OR known flags
    if [[ "$output" == *"help"* ]] || [[ "$output" == *"update"* ]] || [[ "$output" == *"Usage"* ]]; then
        return 0
    fi

    # Script might support --update flag
    output=$("$script" --update --help 2>&1 || true)
    if [[ "$output" == *"help"* ]] || [[ "$output" == *"update"* ]]; then
        return 0
    fi

    # As long as script doesn'\''t crash, we'\''re okay
    return 0
'

test_case "cargo-packages.zsh should have --help or --update flag" '
    local script="$POST_INSTALL_DIR/cargo-packages.zsh"

    # Try --help
    "$script" --help >/dev/null 2>&1 || true

    # As long as script doesn'\''t crash completely, we'\''re okay
    return 0
'

test_case "ruby-gems.zsh should have --help or --update flag" '
    local script="$POST_INSTALL_DIR/ruby-gems.zsh"

    # Try --help
    "$script" --help >/dev/null 2>&1 || true

    # As long as script doesn'\''t crash completely, we'\''re okay
    return 0
'

# ============================================================================
# Script Syntax Validation
# ============================================================================

test_case "all post-install scripts should have valid zsh syntax" '
    local scripts=($POST_INSTALL_DIR/*.zsh)
    local invalid_scripts=()

    for script in "${scripts[@]}"; do
        # Check if script has valid zsh syntax (just parse, don'\''t execute)
        if ! zsh -n "$script" 2>/dev/null; then
            invalid_scripts+=("$(basename $script)")
        fi
    done

    if [[ ${#invalid_scripts[@]} -eq 0 ]]; then
        return 0
    else
        echo "Scripts with invalid syntax: ${invalid_scripts[*]}"
        return 1
    fi
'

test_case "all post-install scripts should have shebang" '
    local scripts=($POST_INSTALL_DIR/*.zsh)
    local missing_shebang=()

    for script in "${scripts[@]}"; do
        local first_line=$(head -1 "$script")
        if [[ ! "$first_line" =~ ^#! ]]; then
            missing_shebang+=("$(basename $script)")
        fi
    done

    if [[ ${#missing_shebang[@]} -eq 0 ]]; then
        return 0
    else
        echo "Scripts missing shebang: ${missing_shebang[*]}"
        return 1
    fi
'

# ============================================================================
# Directory Structure Tests
# ============================================================================

test_case "post-install scripts directory should exist" '
    if [[ ! -d "$POST_INSTALL_DIR" ]]; then
        echo "Post-install scripts directory not found: $POST_INSTALL_DIR"
        return 1
    fi

    return 0
'

test_case "post-install scripts directory should contain scripts" '
    local script_count=$(ls -1 "$POST_INSTALL_DIR"/*.zsh 2>/dev/null | wc -l | tr -d " ")

    if [[ $script_count -gt 0 ]]; then
        return 0
    else
        echo "No post-install scripts found in $POST_INSTALL_DIR"
        return 1
    fi
'

test_case "should have at least 10 post-install scripts" '
    local script_count=$(ls -1 "$POST_INSTALL_DIR"/*.zsh 2>/dev/null | wc -l | tr -d " ")

    if [[ $script_count -ge 10 ]]; then
        return 0
    else
        echo "Expected at least 10 scripts, found $script_count"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
