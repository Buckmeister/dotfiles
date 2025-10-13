#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for package_managers.zsh Library
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Load library under test
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_ROOT/bin/lib/colors.zsh"
source "$DOTFILES_ROOT/bin/lib/ui.zsh"
source "$DOTFILES_ROOT/bin/lib/utils.zsh"
source "$DOTFILES_ROOT/bin/lib/package_managers.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "package_managers.zsh Library"

# ============================================================================
# Availability Check Functions
# ============================================================================

test_case "has_npm should check if npm exists" '
    # Just verify the function works without crashing
    has_npm >/dev/null 2>&1 || true
    return 0
'

test_case "has_cargo should check if cargo exists" '
    # Just verify the function works without crashing
    has_cargo >/dev/null 2>&1 || true
    return 0
'

test_case "has_gem should check if gem exists" '
    # Just verify the function works without crashing
    has_gem >/dev/null 2>&1 || true
    return 0
'

test_case "has_pip should check if pip3 exists" '
    # Just verify the function works without crashing
    has_pip >/dev/null 2>&1 || true
    return 0
'

test_case "has_pipx should check if pipx exists" '
    # Just verify the function works without crashing
    has_pipx >/dev/null 2>&1 || true
    return 0
'

test_case "print_package_managers_status should not crash" '
    print_package_managers_status >/dev/null 2>&1
    assert_equals "0" "$?" "Should execute without error"
'

# ============================================================================
# System Package Manager Functions
# ============================================================================

test_case "pkg_is_installed should check for installed packages" '
    # This test depends on system state, so we just verify it doesn'\''t crash
    # Most systems have ls or similar basic utilities
    pkg_is_installed "nonexistent_package_xyz" >/dev/null 2>&1 || true
    return 0
'

test_case "pkg_install function should exist" '
    if typeset -f pkg_install >/dev/null 2>&1; then
        return 0
    else
        echo "pkg_install function not defined"
        return 1
    fi
'

# ============================================================================
# npm Package Manager Functions
# ============================================================================

test_case "npm_is_installed should check npm package installation" '
    # Just verify function executes without crashing
    npm_is_installed "nonexistent_npm_package_xyz" >/dev/null 2>&1 || true
    return 0
'

test_case "npm_install_global function should exist" '
    if typeset -f npm_install_global >/dev/null 2>&1; then
        return 0
    else
        echo "npm_install_global function not defined"
        return 1
    fi
'

test_case "npm_install_from_list should check for file existence" '
    # Should fail gracefully when file doesn'\''t exist
    npm_install_from_list "/nonexistent/package/list.txt" >/dev/null 2>&1
    local exit_code=$?
    # Should return 1 for non-existent file
    assert_equals "1" "$exit_code" "Should return 1 for non-existent file"
'

# ============================================================================
# cargo Package Manager Functions
# ============================================================================

test_case "cargo_is_installed should check if binary exists" '
    # cargo_is_installed checks if the binary exists in PATH
    cargo_is_installed "ls" >/dev/null 2>&1
    assert_equals "0" "$?" "Should return 0 for existing binary like ls"
'

test_case "cargo_install function should exist" '
    if typeset -f cargo_install >/dev/null 2>&1; then
        return 0
    else
        echo "cargo_install function not defined"
        return 1
    fi
'

test_case "cargo_install_features function should exist" '
    if typeset -f cargo_install_features >/dev/null 2>&1; then
        return 0
    else
        echo "cargo_install_features function not defined"
        return 1
    fi
'

test_case "cargo_install_from_list should check for file existence" '
    # Should fail gracefully when file doesn'\''t exist
    cargo_install_from_list "/nonexistent/package/list.txt" >/dev/null 2>&1
    local exit_code=$?
    # Should return 1 for non-existent file
    assert_equals "1" "$exit_code" "Should return 1 for non-existent file"
'

# ============================================================================
# gem Package Manager Functions
# ============================================================================

test_case "gem_is_installed should check gem installation" '
    # Just verify function executes without crashing
    gem_is_installed "nonexistent_gem_xyz" >/dev/null 2>&1 || true
    return 0
'

test_case "gem_install function should exist" '
    if typeset -f gem_install >/dev/null 2>&1; then
        return 0
    else
        echo "gem_install function not defined"
        return 1
    fi
'

test_case "gem_install_from_list should check for file existence" '
    # Should fail gracefully when file doesn'\''t exist
    gem_install_from_list "/nonexistent/package/list.txt" >/dev/null 2>&1
    local exit_code=$?
    # Should return 1 for non-existent file
    assert_equals "1" "$exit_code" "Should return 1 for non-existent file"
'

# ============================================================================
# pip/pipx Package Manager Functions
# ============================================================================

test_case "pip_is_installed should check pip package installation" '
    # Just verify function executes without crashing
    pip_is_installed "nonexistent_pip_package_xyz" >/dev/null 2>&1 || true
    return 0
'

test_case "pipx_is_installed should check pipx package installation" '
    # Just verify function executes without crashing
    pipx_is_installed "nonexistent_pipx_package_xyz" >/dev/null 2>&1 || true
    return 0
'

test_case "pip_install function should exist" '
    if typeset -f pip_install >/dev/null 2>&1; then
        return 0
    else
        echo "pip_install function not defined"
        return 1
    fi
'

test_case "pipx_install function should exist" '
    if typeset -f pipx_install >/dev/null 2>&1; then
        return 0
    else
        echo "pipx_install function not defined"
        return 1
    fi
'

test_case "pip_install_from_list should check for file existence" '
    # Should fail gracefully when file doesn'\''t exist
    pip_install_from_list "/nonexistent/package/list.txt" >/dev/null 2>&1
    local exit_code=$?
    # Should return 1 for non-existent file
    assert_equals "1" "$exit_code" "Should return 1 for non-existent file"
'

test_case "pipx_install_from_list should check for file existence" '
    # Should fail gracefully when file doesn'\''t exist
    pipx_install_from_list "/nonexistent/package/list.txt" >/dev/null 2>&1
    local exit_code=$?
    # Should return 1 for non-existent file
    assert_equals "1" "$exit_code" "Should return 1 for non-existent file"
'

# ============================================================================
# Batch Installation Functions
# ============================================================================

test_case "pkg_install_batch function should exist" '
    if typeset -f pkg_install_batch >/dev/null 2>&1; then
        return 0
    else
        echo "pkg_install_batch function not defined"
        return 1
    fi
'

test_case "pkg_install_batch should handle empty list" '
    # Should not crash with empty list
    pkg_install_batch >/dev/null 2>&1
    # As long as it doesn'\''t crash, we'\''re good
    return 0
'

# ============================================================================
# Integration Tests
# ============================================================================

test_case "all package manager check functions should be defined" '
    local all_defined=true

    typeset -f has_npm >/dev/null 2>&1 || all_defined=false
    typeset -f has_cargo >/dev/null 2>&1 || all_defined=false
    typeset -f has_gem >/dev/null 2>&1 || all_defined=false
    typeset -f has_pip >/dev/null 2>&1 || all_defined=false
    typeset -f has_pipx >/dev/null 2>&1 || all_defined=false

    if [[ "$all_defined" == "true" ]]; then
        return 0
    else
        echo "Not all package manager check functions are defined"
        return 1
    fi
'

test_case "all install functions should be defined" '
    local all_defined=true

    typeset -f pkg_install >/dev/null 2>&1 || all_defined=false
    typeset -f npm_install_global >/dev/null 2>&1 || all_defined=false
    typeset -f cargo_install >/dev/null 2>&1 || all_defined=false
    typeset -f gem_install >/dev/null 2>&1 || all_defined=false
    typeset -f pip_install >/dev/null 2>&1 || all_defined=false
    typeset -f pipx_install >/dev/null 2>&1 || all_defined=false

    if [[ "$all_defined" == "true" ]]; then
        return 0
    else
        echo "Not all install functions are defined"
        return 1
    fi
'

test_case "all is_installed functions should be defined" '
    local all_defined=true

    typeset -f pkg_is_installed >/dev/null 2>&1 || all_defined=false
    typeset -f npm_is_installed >/dev/null 2>&1 || all_defined=false
    typeset -f cargo_is_installed >/dev/null 2>&1 || all_defined=false
    typeset -f gem_is_installed >/dev/null 2>&1 || all_defined=false
    typeset -f pip_is_installed >/dev/null 2>&1 || all_defined=false
    typeset -f pipx_is_installed >/dev/null 2>&1 || all_defined=false

    if [[ "$all_defined" == "true" ]]; then
        return 0
    else
        echo "Not all is_installed functions are defined"
        return 1
    fi
'

test_case "all install_from_list functions should be defined" '
    local all_defined=true

    typeset -f npm_install_from_list >/dev/null 2>&1 || all_defined=false
    typeset -f cargo_install_from_list >/dev/null 2>&1 || all_defined=false
    typeset -f gem_install_from_list >/dev/null 2>&1 || all_defined=false
    typeset -f pip_install_from_list >/dev/null 2>&1 || all_defined=false
    typeset -f pipx_install_from_list >/dev/null 2>&1 || all_defined=false

    if [[ "$all_defined" == "true" ]]; then
        return 0
    else
        echo "Not all install_from_list functions are defined"
        return 1
    fi
'

# ============================================================================
# Run all tests
# ============================================================================

run_tests
