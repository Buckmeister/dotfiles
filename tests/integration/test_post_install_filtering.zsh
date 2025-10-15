#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Integration Tests for Post-Install Script Filtering
# ============================================================================
# Tests the .ignored and .disabled functionality in a realistic setup
# environment, verifying that the filtering works correctly when integrated
# with setup.zsh, menu_tui.zsh, and librarian.zsh.

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../bin/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths
init_dotfiles_paths

source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Load libraries
source "$DF_DIR/bin/lib/colors.zsh"
source "$DF_DIR/bin/lib/ui.zsh"

# ============================================================================
# Test Setup and Teardown
# ============================================================================

TEST_PI_DIR="/tmp/test_post_install_$$"

function setup_test_environment() {
    # Create temporary post-install directory
    mkdir -p "$TEST_PI_DIR/scripts"

    # Create test scripts
    cat > "$TEST_PI_DIR/scripts/test-enabled.zsh" <<'EOF'
#!/usr/bin/env zsh
echo "ENABLED_SCRIPT_RAN"
EOF

    cat > "$TEST_PI_DIR/scripts/test-ignored.zsh" <<'EOF'
#!/usr/bin/env zsh
echo "IGNORED_SCRIPT_RAN"
EOF

    cat > "$TEST_PI_DIR/scripts/test-disabled.zsh" <<'EOF'
#!/usr/bin/env zsh
echo "DISABLED_SCRIPT_RAN"
EOF

    cat > "$TEST_PI_DIR/scripts/test-both.zsh" <<'EOF'
#!/usr/bin/env zsh
echo "BOTH_SCRIPT_RAN"
EOF

    # Make scripts executable
    chmod +x "$TEST_PI_DIR/scripts/"*.zsh

    # Create .ignored and .disabled files
    touch "$TEST_PI_DIR/scripts/test-ignored.zsh.ignored"
    touch "$TEST_PI_DIR/scripts/test-disabled.zsh.disabled"
    touch "$TEST_PI_DIR/scripts/test-both.zsh.ignored"
    touch "$TEST_PI_DIR/scripts/test-both.zsh.disabled"
}

function teardown_test_environment() {
    rm -rf "$TEST_PI_DIR"
}

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "Post-Install Script Filtering Integration Tests"

# ============================================================================
# Test Cases
# ============================================================================

test_case "should filter out .ignored scripts when listing" '
    setup_test_environment

    # Get list of enabled scripts
    local enabled_scripts=()
    for script in "$TEST_PI_DIR/scripts/"*.zsh; do
        if is_post_install_script_enabled "$script"; then
            enabled_scripts+=("$(basename "$script")")
        fi
    done

    # Should only have test-enabled.zsh
    local count=${#enabled_scripts[@]}

    teardown_test_environment

    if [[ $count -eq 1 && "${enabled_scripts[1]}" == "test-enabled.zsh" ]]; then
        return 0
    else
        echo "Expected 1 enabled script (test-enabled.zsh), got $count: ${enabled_scripts[*]}"
        return 1
    fi
'

test_case "should not execute .ignored scripts" '
    setup_test_environment

    local output=""
    for script in "$TEST_PI_DIR/scripts/"*.zsh; do
        if is_post_install_script_enabled "$script"; then
            output+=$("$script")
        fi
    done

    teardown_test_environment

    # Should only see ENABLED_SCRIPT_RAN in output
    if [[ "$output" == "ENABLED_SCRIPT_RAN" ]]; then
        return 0
    else
        echo "Expected only ENABLED_SCRIPT_RAN, got: $output"
        return 1
    fi
'

test_case "should not execute .disabled scripts" '
    setup_test_environment

    # Check that test-disabled.zsh is filtered
    local script="$TEST_PI_DIR/scripts/test-disabled.zsh"

    if is_post_install_script_enabled "$script"; then
        teardown_test_environment
        echo ".disabled script was not filtered"
        return 1
    else
        teardown_test_environment
        return 0
    fi
'

test_case "should handle multiple filtering markers (.ignored takes precedence)" '
    setup_test_environment

    # test-both.zsh has both .ignored and .disabled
    local script="$TEST_PI_DIR/scripts/test-both.zsh"

    if is_post_install_script_enabled "$script"; then
        teardown_test_environment
        echo "Script with both .ignored and .disabled was not filtered"
        return 1
    else
        teardown_test_environment
        return 0
    fi
'

test_case "should work with find command (typical setup.zsh usage)" '
    setup_test_environment

    # Simulate how setup.zsh finds and filters scripts
    local all_scripts=(${(0)"$(find "$TEST_PI_DIR/scripts" -perm 755 -name "*.zsh" -print0)"})
    local enabled_scripts=()

    for script in "${all_scripts[@]}"; do
        if is_post_install_script_enabled "$script"; then
            enabled_scripts+=($(basename "$script"))
        fi
    done

    teardown_test_environment

    local count=${#enabled_scripts[@]}

    if [[ $count -eq 1 && "${enabled_scripts[1]}" == "test-enabled.zsh" ]]; then
        return 0
    else
        echo "Expected 1 enabled script when using find, got $count: ${enabled_scripts[*]}"
        return 1
    fi
'

test_case "should correctly count enabled vs disabled scripts" '
    setup_test_environment

    local total=0
    local enabled=0
    local disabled=0

    for script in "$TEST_PI_DIR/scripts/"*.zsh; do
        total=$((total + 1))
        if is_post_install_script_enabled "$script"; then
            enabled=$((enabled + 1))
        else
            disabled=$((disabled + 1))
        fi
    done

    teardown_test_environment

    # Total: 4, Enabled: 1, Disabled: 3
    if [[ $total -eq 4 && $enabled -eq 1 && $disabled -eq 3 ]]; then
        return 0
    else
        echo "Expected 4 total (1 enabled, 3 disabled), got $total total ($enabled enabled, $disabled disabled)"
        return 1
    fi
'

test_case "should handle empty post-install directory" '
    local empty_dir="/tmp/test_empty_pi_$$"
    mkdir -p "$empty_dir"

    local enabled_count=0

    # Use nullglob to handle empty directory gracefully
    setopt local_options nullglob

    for script in "$empty_dir/"*.zsh; do
        if [[ -f "$script" ]] && is_post_install_script_enabled "$script"; then
            enabled_count=$((enabled_count + 1))
        fi
    done

    rm -rf "$empty_dir"

    if [[ $enabled_count -eq 0 ]]; then
        return 0
    else
        echo "Expected 0 scripts in empty directory, got $enabled_count"
        return 1
    fi
'

test_case "should work with scripts that have spaces in names" '
    local test_dir="/tmp/test_spaces_pi_$$"
    mkdir -p "$test_dir"

    cat > "$test_dir/test script with spaces.zsh" <<'"'"'EOF'"'"'
#!/usr/bin/env zsh
echo "SPACES_SCRIPT_RAN"
EOF

    chmod +x "$test_dir/test script with spaces.zsh"

    if is_post_install_script_enabled "$test_dir/test script with spaces.zsh"; then
        rm -rf "$test_dir"
        return 0
    else
        rm -rf "$test_dir"
        echo "Script with spaces was incorrectly filtered"
        return 1
    fi
'

test_case "should work with .ignored file containing explanation" '
    local test_dir="/tmp/test_explained_$$"
    mkdir -p "$test_dir"

    cat > "$test_dir/test.zsh" <<'"'"'EOF'"'"'
#!/usr/bin/env zsh
echo "TEST"
EOF

    cat > "$test_dir/test.zsh.ignored" <<'"'"'EOF'"'"'
Temporarily disabled for testing purposes.
Will re-enable after fixing the issue.
EOF

    chmod +x "$test_dir/test.zsh"

    if is_post_install_script_enabled "$test_dir/test.zsh"; then
        rm -rf "$test_dir"
        echo "Script with .ignored explanation was not filtered"
        return 1
    else
        rm -rf "$test_dir"
        return 0
    fi
'

test_case "should maintain correct behavior when .ignored is removed" '
    local test_dir="/tmp/test_removed_$$"
    mkdir -p "$test_dir"

    cat > "$test_dir/test.zsh" <<'"'"'EOF'"'"'
#!/usr/bin/env zsh
echo "TEST"
EOF

    chmod +x "$test_dir/test.zsh"
    touch "$test_dir/test.zsh.ignored"

    # Should be disabled
    if is_post_install_script_enabled "$test_dir/test.zsh"; then
        rm -rf "$test_dir"
        echo "Script should have been disabled with .ignored file"
        return 1
    fi

    # Remove .ignored file
    rm -f "$test_dir/test.zsh.ignored"

    # Should now be enabled
    if is_post_install_script_enabled "$test_dir/test.zsh"; then
        rm -rf "$test_dir"
        return 0
    else
        rm -rf "$test_dir"
        echo "Script should have been enabled after removing .ignored file"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
