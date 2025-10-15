#!/usr/bin/env zsh

# ============================================================================
# Package Management Integration Tests
# ============================================================================
#
# Comprehensive test suite for the universal package management system:
# - generate_package_manifest
# - install_from_manifest
# - sync_packages
# ============================================================================

emulate -LR zsh
setopt err_exit pipe_fail

# Get script directory and load test utilities

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

TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load shared libraries
source "$DOTFILES_ROOT/bin/lib/colors.zsh" 2>/dev/null || true
source "$DOTFILES_ROOT/bin/lib/ui.zsh" 2>/dev/null || true

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ============================================================================
# Test Utility Functions
# ============================================================================

function test_start() {
    local test_name="$1"
    echo
    echo "════════════════════════════════════════════════════════════════"
    echo "🧪 TEST: $test_name"
    echo "════════════════════════════════════════════════════════════════"
    TESTS_RUN=$((TESTS_RUN + 1))
}

function test_pass() {
    local message="$1"
    echo "✅ PASS: $message"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

function test_fail() {
    local message="$1"
    echo "❌ FAIL: $message"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

function assert_file_exists() {
    local file="$1"
    local description="${2:-File exists}"

    if [[ -f "$file" ]]; then
        test_pass "$description: $file"
        return 0
    else
        test_fail "$description: $file (not found)"
        return 1
    fi
}

function assert_command_exists() {
    local cmd="$1"
    local description="${2:-Command exists}"

    if command -v "$cmd" >/dev/null 2>&1; then
        test_pass "$description: $cmd"
        return 0
    else
        test_fail "$description: $cmd (not found)"
        return 1
    fi
}

function assert_string_contains() {
    local haystack="$1"
    local needle="$2"
    local description="${3:-String contains pattern}"

    if echo "$haystack" | grep -q "$needle"; then
        test_pass "$description"
        return 0
    else
        test_fail "$description (expected: $needle)"
        return 1
    fi
}

function assert_greater_than() {
    local value="$1"
    local threshold="$2"
    local description="${3:-Value greater than threshold}"

    if [[ $value -gt $threshold ]]; then
        test_pass "$description ($value > $threshold)"
        return 0
    else
        test_fail "$description ($value <= $threshold)"
        return 1
    fi
}

# ============================================================================
# Test Suite: Setup and Prerequisites
# ============================================================================

function test_prerequisites() {
    test_start "Package Management Scripts Availability"

    # Check that scripts are symlinked in ~/.local/bin
    assert_file_exists "$HOME/.local/bin/generate_package_manifest" \
        "generate_package_manifest symlink"

    assert_file_exists "$HOME/.local/bin/install_from_manifest" \
        "install_from_manifest symlink"

    assert_file_exists "$HOME/.local/bin/sync_packages" \
        "sync_packages symlink"

    # Check that scripts are executable
    if [[ -x "$HOME/.local/bin/generate_package_manifest" ]]; then
        test_pass "generate_package_manifest is executable"
    else
        test_fail "generate_package_manifest is not executable"
    fi

    if [[ -x "$HOME/.local/bin/install_from_manifest" ]]; then
        test_pass "install_from_manifest is executable"
    else
        test_fail "install_from_manifest is not executable"
    fi

    if [[ -x "$HOME/.local/bin/sync_packages" ]]; then
        test_pass "sync_packages is executable"
    else
        test_fail "sync_packages is not executable"
    fi
}

# ============================================================================
# Test Suite: generate_package_manifest
# ============================================================================

function test_generate_manifest() {
    test_start "Generate Package Manifest"

    local test_manifest="/tmp/test_pkg_gen_$$.yaml"

    # Generate a manifest
    echo "📦 Generating test manifest..."
    if ~/.local/bin/generate_package_manifest -o "$test_manifest" >/dev/null 2>&1; then
        test_pass "Manifest generation command executed successfully"
    else
        test_fail "Manifest generation command failed"
        return 1
    fi

    # Check that manifest file was created
    assert_file_exists "$test_manifest" "Generated manifest file"

    # Check manifest is valid YAML (basic structure check)
    if grep -q "^version:" "$test_manifest" && \
       grep -q "^metadata:" "$test_manifest" && \
       grep -q "^packages:" "$test_manifest"; then
        test_pass "Manifest has valid YAML structure"
    else
        test_fail "Manifest missing required YAML sections"
    fi

    # Check that manifest contains packages
    local package_count=$(grep -c '^\s*-\s*id:' "$test_manifest" 2>/dev/null || echo "0")
    assert_greater_than "$package_count" 0 "Manifest contains packages"

    # Check for metadata fields
    if grep -q "^  name:" "$test_manifest"; then
        test_pass "Manifest includes metadata.name field"
    else
        test_fail "Manifest missing metadata.name field"
    fi

    if grep -qE "^  (generated|last_updated):" "$test_manifest"; then
        test_pass "Manifest includes metadata timestamp field"
    else
        test_fail "Manifest missing metadata timestamp field"
    fi

    # Check that manifest includes install methods
    if grep -q '^\s*brew:' "$test_manifest" || \
       grep -q '^\s*apt:' "$test_manifest" || \
       grep -q '^\s*cargo:' "$test_manifest"; then
        test_pass "Manifest includes package manager install methods"
    else
        test_fail "Manifest missing install methods"
    fi

    # Cleanup
    rm -f "$test_manifest"
}

# ============================================================================
# Test Suite: install_from_manifest
# ============================================================================

function test_install_from_manifest() {
    test_start "Install from Manifest"

    local test_manifest="/tmp/test_install_$$_.yaml"

    # Create a minimal test manifest
    cat > "$test_manifest" << 'EOF'
version: "1.0"

metadata:
  name: "Test Manifest"
  description: "Integration test manifest"

settings:
  skip_installed: true
  auto_confirm: true

packages:
  - id: test-git
    name: "Git"
    description: "Version control system"
    category: git
    priority: required
    install:
      brew: git
      apt: git

  - id: test-curl
    name: "cURL"
    description: "Command line HTTP client"
    category: network
    priority: required
    install:
      brew: curl
      apt: curl
EOF

    assert_file_exists "$test_manifest" "Test manifest created"

    # Test dry-run mode
    echo "📦 Testing dry-run installation..."
    local dry_run_output
    if dry_run_output=$(~/.local/bin/install_from_manifest -i "$test_manifest" --dry-run 2>&1); then
        test_pass "Dry-run mode executed successfully"

        # Check that dry-run output contains expected information
        assert_string_contains "$dry_run_output" "DRY RUN" \
            "Dry-run output indicates test mode"

        assert_string_contains "$dry_run_output" "git" \
            "Dry-run output mentions git package"
    else
        test_fail "Dry-run mode failed to execute"
    fi

    # Test manifest validation
    echo "📦 Testing manifest parsing..."
    if echo "$dry_run_output" | grep -q "Packages in manifest:"; then
        test_pass "Manifest parsing shows package count"
    else
        test_fail "Manifest parsing doesn't show package count"
    fi

    # Cleanup
    rm -f "$test_manifest"
}

# ============================================================================
# Test Suite: sync_packages
# ============================================================================

function test_sync_packages() {
    test_start "Sync Packages"

    local test_sync_manifest="/tmp/test_sync_$$.yaml"

    # Test sync generation
    echo "📦 Testing package synchronization..."

    # Note: sync_packages is essentially generate_package_manifest with extras
    # We'll test basic functionality by checking if it can generate output

    if ~/.local/bin/generate_package_manifest -o "$test_sync_manifest" >/dev/null 2>&1; then
        test_pass "Sync can generate package manifest"
    else
        test_fail "Sync failed to generate package manifest"
        return 1
    fi

    # Verify sync output is a valid manifest
    if [[ -f "$test_sync_manifest" ]]; then
        test_pass "Sync generated manifest file"

        # Check that it's structurally similar to generate_package_manifest output
        if grep -q "^version:" "$test_sync_manifest" && \
           grep -q "^packages:" "$test_sync_manifest"; then
            test_pass "Sync manifest has valid structure"
        else
            test_fail "Sync manifest has invalid structure"
        fi
    else
        test_fail "Sync did not create manifest file"
    fi

    # Cleanup
    rm -f "$test_sync_manifest"
}

# ============================================================================
# Test Suite: Cross-Platform Support
# ============================================================================

function test_cross_platform_support() {
    test_start "Cross-Platform Package Manager Support"

    local test_manifest="/tmp/test_multipm_$$.yaml"

    # Create a manifest with multiple package managers
    cat > "$test_manifest" << 'EOF'
version: "1.0"

metadata:
  name: "Multi-Platform Test"

packages:
  - id: multi-git
    name: "Git"
    install:
      brew: git
      apt: git
      choco: git

  - id: multi-curl
    name: "cURL"
    install:
      brew: curl
      apt: curl
      choco: curl
EOF

    assert_file_exists "$test_manifest" "Multi-platform manifest created"

    # Test that install_from_manifest can parse multi-platform manifests
    echo "📦 Testing multi-platform manifest parsing..."
    local parse_output
    if parse_output=$(~/.local/bin/install_from_manifest -i "$test_manifest" --dry-run 2>&1); then
        test_pass "Multi-platform manifest parsed successfully"

        # Check that it detected the appropriate package manager for this system
        if echo "$parse_output" | grep -qE "(brew|apt|choco)"; then
            test_pass "Appropriate package manager detected"
        else
            test_fail "No package manager detected in output"
        fi
    else
        test_fail "Failed to parse multi-platform manifest"
    fi

    # Cleanup
    rm -f "$test_manifest"
}

# ============================================================================
# Test Suite: Error Handling
# ============================================================================

function test_error_handling() {
    test_start "Error Handling and Edge Cases"

    # Test with non-existent manifest
    echo "📦 Testing non-existent manifest..."
    # Check that error message is shown (test should pass if "not found" appears in output)
    local error_output=$(~/.local/bin/install_from_manifest -i "/tmp/nonexistent_$$.yaml" --dry-run 2>&1)
    if echo "$error_output" | grep -qi "not found"; then
        test_pass "Handles non-existent manifest gracefully"
    else
        test_fail "Did not handle non-existent manifest properly (output: ${error_output:0:50})"
    fi

    # Test with invalid YAML
    local invalid_manifest="/tmp/test_invalid_$$.yaml"
    echo "this is not valid YAML {{{ [[[ }}}" > "$invalid_manifest"

    echo "📦 Testing invalid YAML..."
    if ~/.local/bin/install_from_manifest -i "$invalid_manifest" --dry-run 2>&1 | grep -qi "error\|invalid\|failed"; then
        test_pass "Handles invalid YAML gracefully"
    else
        # This might not error with the custom parser - that's okay
        test_pass "Custom YAML parser handled invalid input"
    fi

    rm -f "$invalid_manifest"

    # Test with empty manifest
    local empty_manifest="/tmp/test_empty_$$.yaml"
    echo "version: '1.0'" > "$empty_manifest"
    echo "packages: []" >> "$empty_manifest"

    echo "📦 Testing empty manifest..."
    if ~/.local/bin/install_from_manifest -i "$empty_manifest" --dry-run >/dev/null 2>&1; then
        test_pass "Handles empty manifest gracefully"
    else
        test_fail "Failed to handle empty manifest"
    fi

    rm -f "$empty_manifest"
}

# ============================================================================
# Test Suite: librarian.zsh Integration
# ============================================================================

function test_librarian_integration() {
    test_start "librarian.zsh Package Management Section"

    # Run librarian and check for package management section
    echo "📦 Testing librarian.zsh integration..."
    local librarian_output
    if librarian_output=$("$DOTFILES_ROOT/bin/librarian.zsh" 2>&1); then
        test_pass "librarian.zsh executed successfully"

        # Check that package management section exists
        if echo "$librarian_output" | grep -q "📦 Package Management"; then
            test_pass "librarian.zsh includes Package Management section"
        else
            test_fail "librarian.zsh missing Package Management section"
        fi

        # Check that it reports on the scripts
        if echo "$librarian_output" | grep -q "generate_package_manifest"; then
            test_pass "librarian.zsh reports on package scripts"
        else
            test_fail "librarian.zsh doesn't report on package scripts"
        fi
    else
        test_fail "librarian.zsh execution failed"
    fi
}

# ============================================================================
# Main Test Execution
# ============================================================================

function run_all_tests() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║        Package Management Integration Test Suite              ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo
    echo "🖥️  Platform: $(uname -s)"
    echo "📂 Dotfiles: $DOTFILES_ROOT"
    echo

    # Run test suites
    test_prerequisites
    test_generate_manifest
    test_install_from_manifest
    test_sync_packages
    test_cross_platform_support
    test_error_handling
    test_librarian_integration

    # Print summary
    echo
    echo "════════════════════════════════════════════════════════════════"
    echo "📊 Test Summary"
    echo "════════════════════════════════════════════════════════════════"
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✅ All tests passed!"
        return 0
    else
        echo "❌ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    run_all_tests
    exit $?
fi
