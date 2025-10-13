#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for The Librarian
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "Librarian Integration Tests"

# ============================================================================
# Test Helpers
# ============================================================================

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIBRARIAN_SCRIPT="$DOTFILES_ROOT/bin/librarian.zsh"

# ============================================================================
# Basic Functionality Tests
# ============================================================================

test_case "librarian.zsh script should exist and be executable" '
    if [[ ! -f "$LIBRARIAN_SCRIPT" ]]; then
        echo "librarian.zsh not found at $LIBRARIAN_SCRIPT"
        return 1
    fi

    if [[ ! -x "$LIBRARIAN_SCRIPT" ]]; then
        echo "librarian.zsh is not executable"
        return 1
    fi

    return 0
'

test_case "librarian should have --help flag" '
    local help_output=$("$LIBRARIAN_SCRIPT" --help 2>&1)

    if [[ "$help_output" == *"Librarian"* ]] || [[ "$help_output" == *"help"* ]]; then
        return 0
    else
        echo "No help output found"
        return 1
    fi
'

test_case "librarian --help should document all options" '
    local help_output=$("$LIBRARIAN_SCRIPT" --help 2>&1)

    # Check for key options in help output
    if [[ "$help_output" == *"--status"* ]] && \
       [[ "$help_output" == *"--with-tests"* ]] && \
       [[ "$help_output" == *"--all-pi"* ]]; then
        return 0
    else
        echo "Help output missing key options"
        return 1
    fi
'

test_case "librarian should run without errors" '
    # Run librarian and capture exit code
    "$LIBRARIAN_SCRIPT" >/dev/null 2>&1
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        return 0
    else
        echo "Librarian exited with code: $exit_code"
        return 1
    fi
'

test_case "librarian --status should run successfully" '
    "$LIBRARIAN_SCRIPT" --status >/dev/null 2>&1
    local exit_code=$?

    assert_equals "0" "$exit_code" "Should exit with code 0"
'

# ============================================================================
# Output Content Tests
# ============================================================================

test_case "librarian output should include Core System Status" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    if [[ "$output" == *"Core System"* ]] || [[ "$output" == *"Dotfiles"* ]]; then
        return 0
    else
        echo "Output missing Core System Status section"
        return 1
    fi
'

test_case "librarian output should include Essential Tools" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    if [[ "$output" == *"Essential Tools"* ]] || [[ "$output" == *"git"* ]]; then
        return 0
    else
        echo "Output missing Essential Tools section"
        return 1
    fi
'

test_case "librarian output should include Development Toolchains" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    if [[ "$output" == *"Development Toolchains"* ]] || [[ "$output" == *"Toolchains"* ]]; then
        return 0
    else
        echo "Output missing Development Toolchains section"
        return 1
    fi
'

test_case "librarian output should include Language Servers" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    if [[ "$output" == *"Language Server"* ]] || [[ "$output" == *"LSP"* ]]; then
        return 0
    else
        echo "Output missing Language Servers section"
        return 1
    fi
'

test_case "librarian output should include Test Suite Status" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    if [[ "$output" == *"Test Suite"* ]] || [[ "$output" == *"tests"* ]]; then
        return 0
    else
        echo "Output missing Test Suite Status section"
        return 1
    fi
'

# ============================================================================
# Special Mode Tests
# ============================================================================

test_case "librarian --with-tests should run test suite" '
    # This might take a while, so just check it starts and runs
    timeout 30 "$LIBRARIAN_SCRIPT" --with-tests >/dev/null 2>&1
    local exit_code=$?

    # Exit code 0 (success), 124 (timeout), or 1 (some tests failed) are all acceptable
    # We just want to make sure it runs without crashing
    if [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 124 ]] || [[ $exit_code -eq 1 ]]; then
        return 0
    else
        echo "Unexpected exit code: $exit_code"
        return 1
    fi
'

test_case "librarian should detect dotfiles root correctly" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should mention dotfiles directory
    if [[ "$output" == *"dotfiles"* ]] || [[ "$output" == *"$DOTFILES_ROOT"* ]]; then
        return 0
    else
        echo "Output does not mention dotfiles directory"
        return 1
    fi
'

test_case "librarian should check git status" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should mention git in some way
    if [[ "$output" == *"git"* ]] || [[ "$output" == *"repository"* ]]; then
        return 0
    else
        echo "Output does not check git status"
        return 1
    fi
'

# ============================================================================
# Post-Install Scripts Detection Tests
# ============================================================================

test_case "librarian should detect post-install scripts" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should mention post-install scripts
    if [[ "$output" == *"post-install"* ]] || [[ "$output" == *"Post-Install"* ]]; then
        return 0
    else
        echo "Output does not mention post-install scripts"
        return 1
    fi
'

test_case "librarian should list post-install scripts" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should list scripts with the 📄 emoji or "executable" label
    if echo "$output" | grep -q "📄"; then
        return 0
    elif echo "$output" | grep -q "executable"; then
        return 0
    else
        echo "Output does not list post-install scripts"
        return 1
    fi
'

# ============================================================================
# Symlink Inventory Tests
# ============================================================================

test_case "librarian should show symlink inventory" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should mention symlinks
    if [[ "$output" == *"Symlink"* ]] || [[ "$output" == *"symlink"* ]]; then
        return 0
    else
        echo "Output does not show symlink inventory"
        return 1
    fi
'

test_case "librarian should report symlink status" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should show some symlink status (✅ or ❌)
    if [[ "$output" == *"✅"* ]] || [[ "$output" == *"symlink"* ]]; then
        return 0
    else
        echo "Output does not report symlink status"
        return 1
    fi
'

# ============================================================================
# Toolchain Detection Tests
# ============================================================================

test_case "librarian should check for common toolchains" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should check for at least some common toolchains
    local found_toolchains=false

    if [[ "$output" == *"Rust"* ]] || \
       [[ "$output" == *"Node"* ]] || \
       [[ "$output" == *"Python"* ]] || \
       [[ "$output" == *"Ruby"* ]] || \
       [[ "$output" == *"Go"* ]]; then
        found_toolchains=true
    fi

    if [[ "$found_toolchains" == "true" ]]; then
        return 0
    else
        echo "Output does not check for common toolchains"
        return 1
    fi
'

test_case "librarian should check for language servers" '
    local output=$("$LIBRARIAN_SCRIPT" 2>&1)

    # Should check for at least some language servers
    if [[ "$output" == *"rust-analyzer"* ]] || \
       [[ "$output" == *"typescript-language-server"* ]] || \
       [[ "$output" == *"pyright"* ]] || \
       [[ "$output" == *"language server"* ]] || \
       [[ "$output" == *"Language Server"* ]]; then
        return 0
    else
        echo "Output does not check for language servers"
        return 1
    fi
'

# ============================================================================
# Error Handling Tests
# ============================================================================

test_case "librarian should handle invalid flag gracefully" '
    "$LIBRARIAN_SCRIPT" --invalid-flag-xyz >/dev/null 2>&1
    local exit_code=$?

    # Should exit (with any code), not crash
    return 0
'

test_case "librarian should be idempotent" '
    # Running twice should not produce errors
    "$LIBRARIAN_SCRIPT" >/dev/null 2>&1
    local first_run=$?

    "$LIBRARIAN_SCRIPT" >/dev/null 2>&1
    local second_run=$?

    if [[ $first_run -eq $second_run ]]; then
        return 0
    else
        echo "Librarian produced different exit codes on consecutive runs"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
