#!/usr/bin/env zsh

# ============================================================================
# Unified Docker Installation Testing Script
# ============================================================================
#
# Comprehensive testing framework for dotfiles installation on fresh containers
# Combines basic installation verification with advanced feature validation
#
# Usage:
#   ./tests/test_docker.zsh [OPTIONS]
#
# Quick Examples:
#   ./tests/test_docker.zsh --quick                    # Fast smoke test
#   ./tests/test_docker.zsh --skip-pi --basic          # Basic test without PI scripts
#   ./tests/test_docker.zsh --enable-pi "git-*"        # Test only git configs
#   ./tests/test_docker.zsh --comprehensive --quick    # Full feature validation
#
# ============================================================================

emulate -LR zsh
# Note: Not using ERR_EXIT to allow proper error handling in test loops
setopt PIPE_FAIL

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="${0:a:h}"
DOTFILES_ROOT="${SCRIPT_DIR:h}"

# Source shared libraries
source "${DOTFILES_ROOT}/bin/lib/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load shared libraries"
    exit 1
}
source "${DOTFILES_ROOT}/bin/lib/ui.zsh"
source "${DOTFILES_ROOT}/bin/lib/utils.zsh"
source "${DOTFILES_ROOT}/bin/lib/greetings.zsh"

# Source test helpers
source "${SCRIPT_DIR}/lib/test_helpers.zsh" 2>/dev/null || {
    echo "Error: Could not load test helpers"
    exit 1
}

# Test configurations
DISTROS=(
    "ubuntu:24.04"
    "ubuntu:22.04"
    "debian:12"
    "debian:11"
)

# Default settings
TEST_MODE="basic"              # basic, comprehensive, or full
INSTALLER_MODE="dfauto"        # dfauto, dfsetup, or both
SKIP_PI=false
DISABLE_PI_GLOB=""
ENABLE_PI_GLOB=""
SINGLE_DISTRO=""
NO_CLEANUP=false               # Keep containers for debugging

# ============================================================================
# Argument Parsing
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Test modes
            --basic)
                TEST_MODE="basic"
                shift
                ;;
            --comprehensive)
                TEST_MODE="comprehensive"
                shift
                ;;
            --full)
                TEST_MODE="full"
                shift
                ;;

            # Installer modes
            --dfauto)
                INSTALLER_MODE="dfauto"
                shift
                ;;
            --dfsetup)
                INSTALLER_MODE="dfsetup"
                shift
                ;;
            --both-modes)
                INSTALLER_MODE="both"
                shift
                ;;

            # PI script control
            --skip-pi)
                SKIP_PI=true
                shift
                ;;
            --disable-pi)
                DISABLE_PI_GLOB="$2"
                shift 2
                ;;
            --enable-pi)
                ENABLE_PI_GLOB="$2"
                shift 2
                ;;

            # Distribution selection
            --quick)
                DISTROS=("ubuntu:24.04")
                shift
                ;;
            --distro)
                SINGLE_DISTRO="$2"
                shift 2
                ;;
            --all-distros)
                # Use default DISTROS array
                shift
                ;;

            # Container management
            --no-cleanup)
                NO_CLEANUP=true
                shift
                ;;

            # Help
            -h|--help)
                show_help
                exit 0
                ;;

            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Apply single distro if specified
    if [[ -n "$SINGLE_DISTRO" ]]; then
        DISTROS=("$SINGLE_DISTRO")
    fi
}

show_help() {
    cat <<'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                   Unified Docker Installation Testing                      ║
║                    Flexible, Fast, and Comprehensive                       ║
╚════════════════════════════════════════════════════════════════════════════╝

Usage: ./tests/test_docker.zsh [OPTIONS]

TEST MODES:
  --basic              Basic installation verification (default)
                       • Web installer works
                       • Dotfiles cloned correctly
                       • Librarian health check passes
                       • Phase 11 refactoring validation (3 new scripts)
                       Estimated time: ~1-2 minutes per distro

  --comprehensive      Full feature validation
                       • All basic tests
                       • Profile system functionality
                       • Package manifest validation
                       • Wizard and tool availability
                       Estimated time: ~2-3 minutes per distro

  --full               Run both basic AND comprehensive tests
                       Estimated time: ~3-5 minutes per distro

INSTALLER MODES:
  --dfauto             Test automatic installer only (default)
  --dfsetup            Test interactive installer only
  --both-modes         Test both dfauto and dfsetup

POST-INSTALL SCRIPT CONTROL:
  --skip-pi            Disable ALL post-install scripts (fastest!)
                       Useful for testing installation mechanics only

  --disable-pi GLOB    Disable PI scripts matching glob pattern
                       Example: --disable-pi "*packages*"
                       Example: --disable-pi "language-servers"

  --enable-pi GLOB     Enable ONLY PI scripts matching glob
                       (All others are disabled)
                       Example: --enable-pi "git-*"
                       Example: --enable-pi "cargo-*"

DISTRIBUTION SELECTION:
  --quick              Test only Ubuntu 24.04 (fastest)
  --distro IMAGE       Test specific distribution
                       Example: --distro debian:12
  --all-distros        Test all 4 distributions (default)

CONTAINER MANAGEMENT:
  --no-cleanup         Keep containers after test (for debugging)
                       Use 'docker ps -a' to see stopped containers
                       Use 'docker exec -it <name> bash' to inspect

COMMON USAGE PATTERNS:

  Fast Smoke Test (30 seconds):
    ./tests/test_docker.zsh --skip-pi --basic --quick

  Test Only Git Configuration:
    ./tests/test_docker.zsh --enable-pi "git-*" --quick

  Test Profile System (No PI Scripts):
    ./tests/test_docker.zsh --comprehensive --skip-pi --quick

  Test Cargo Packages on Debian:
    ./tests/test_docker.zsh --enable-pi "cargo-*" --distro debian:12

  Full Test Suite (Slow but Thorough):
    ./tests/test_docker.zsh --full --all-distros --both-modes

  Test Interactive Installer:
    ./tests/test_docker.zsh --dfsetup --skip-pi --quick

EXAMPLES:

  # Quick validation after making changes
  ./tests/test_docker.zsh --quick --skip-pi

  # Test a specific PI script works correctly
  ./tests/test_docker.zsh --enable-pi "ruby-gems" --quick

  # Comprehensive validation on all distros
  ./tests/test_docker.zsh --comprehensive --all-distros

  # Full regression test (longest, most thorough)
  ./tests/test_docker.zsh --full --both-modes --all-distros

OPTIONS:
  -h, --help           Show this help message

EOF
}

# ============================================================================
# PI Script Filtering Functions
# ============================================================================

prepare_pi_filtering() {
    local distro="$1"
    local pi_filter_cmd=""

    if [[ "$SKIP_PI" == true ]]; then
        pi_filter_cmd="
            echo '📝 Disabling ALL post-install scripts...'
            cd ~/.config/dotfiles/post-install/scripts
            for script in *.zsh; do
                if [[ -f \"\$script\" && ! -f \"\${script}.disabled\" ]]; then
                    mv \"\$script\" \"\${script}.disabled\"
                    echo \"   Disabled: \$script\"
                fi
            done
            echo '✅ All PI scripts disabled'
        "
    elif [[ -n "$DISABLE_PI_GLOB" ]]; then
        pi_filter_cmd="
            echo '📝 Disabling PI scripts matching: $DISABLE_PI_GLOB'
            cd ~/.config/dotfiles/post-install/scripts
            for script in $DISABLE_PI_GLOB; do
                if [[ -f \"\$script\" ]]; then
                    mv \"\$script\" \"\${script}.disabled\"
                    echo \"   Disabled: \$script\"
                fi
            done
        "
    elif [[ -n "$ENABLE_PI_GLOB" ]]; then
        pi_filter_cmd="
            echo '📝 Enabling ONLY PI scripts matching: $ENABLE_PI_GLOB'
            cd ~/.config/dotfiles/post-install/scripts

            # First, disable everything
            for script in *.zsh; do
                if [[ -f \"\$script\" ]]; then
                    mv \"\$script\" \"\${script}.disabled\"
                fi
            done

            # Then re-enable matching patterns
            for script in ${ENABLE_PI_GLOB}.disabled; do
                if [[ -f \"\$script\" ]]; then
                    original=\"\${script%.disabled}\"
                    mv \"\$script\" \"\$original\"
                    echo \"   Enabled: \$original\"
                fi
            done
        "
    fi

    echo "$pi_filter_cmd"
}

# ============================================================================
# Test Functions - Basic Installation
# ============================================================================

run_basic_installation_tests() {
    local test_cmd="$1"

    # Basic installation verification
    test_cmd+="
        echo 'PROGRESS:Verifying installation'

        if [ -d ~/.config/dotfiles ]; then
            echo 'SUCCESS:Dotfiles directory created'
        else
            echo 'FAILED:Dotfiles directory not found'
            exit 1
        fi

        if [ -d ~/.config/dotfiles/.git ]; then
            echo 'SUCCESS:Git repository initialized'
        else
            echo 'FAILED:Not a git repository'
            exit 1
        fi

        if [ -f ~/.config/dotfiles/bin/setup.zsh ]; then
            echo 'SUCCESS:Setup script found'
        fi

        echo 'PROGRESS:Running librarian health check'
        cd ~/.config/dotfiles

        # Run librarian and capture output
        librarian_output=\$(./bin/librarian.zsh 2>&1 || true)

        # Check for errors and warnings in librarian output
        if echo \"\$librarian_output\" | grep -qi 'error'; then
            echo 'FAILED:Librarian detected errors'
            echo \"\$librarian_output\" | grep -i 'error' | head -5
            exit 1
        fi

        if echo \"\$librarian_output\" | grep -qi 'warning'; then
            echo 'INFO:Librarian warnings detected (non-critical)'
            echo \"\$librarian_output\" | grep -i 'warning' | head -3
        else
            echo 'SUCCESS:Librarian health check passed'
        fi

        echo 'PROGRESS:Complete'
        echo \"INFO:Distribution: \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\\\"')\"
    "

    echo "$test_cmd"
}

# ============================================================================
# Test Functions - Phase 11 Post-Install Script Validation
# ============================================================================

run_phase11_validation_tests() {
    local test_cmd="$1"

    test_cmd+="
        echo 'PROGRESS:Phase 11 post-install script validation'
        cd ~/.config/dotfiles

        echo 'INFO:Validating Phase 11 refactoring...'

        # Check that new scripts exist and are executable
        PI_SCRIPTS_DIR='post-install/scripts'

        # Verify haskell-toolchain.zsh exists
        if [ -f \"\$PI_SCRIPTS_DIR/haskell-toolchain.zsh\" ] && [ -x \"\$PI_SCRIPTS_DIR/haskell-toolchain.zsh\" ]; then
            echo 'SUCCESS:haskell-toolchain.zsh exists and is executable'
        else
            echo 'FAILED:haskell-toolchain.zsh not found or not executable'
            exit 1
        fi

        # Verify rust-toolchain.zsh exists
        if [ -f \"\$PI_SCRIPTS_DIR/rust-toolchain.zsh\" ] && [ -x \"\$PI_SCRIPTS_DIR/rust-toolchain.zsh\" ]; then
            echo 'SUCCESS:rust-toolchain.zsh exists and is executable'
        else
            echo 'FAILED:rust-toolchain.zsh not found or not executable'
            exit 1
        fi

        # Verify starship-prompt.zsh exists
        if [ -f \"\$PI_SCRIPTS_DIR/starship-prompt.zsh\" ] && [ -x \"\$PI_SCRIPTS_DIR/starship-prompt.zsh\" ]; then
            echo 'SUCCESS:starship-prompt.zsh exists and is executable'
        else
            echo 'FAILED:starship-prompt.zsh not found or not executable'
            exit 1
        fi

        # Verify old toolchains.zsh is GONE
        if [ -f \"\$PI_SCRIPTS_DIR/toolchains.zsh\" ]; then
            echo 'FAILED:Old toolchains.zsh still exists (should be deleted)'
            exit 1
        else
            echo 'SUCCESS:Old toolchains.zsh properly removed'
        fi

        # Verify dependency references are updated
        if grep -q 'rust-toolchain.zsh' \"\$PI_SCRIPTS_DIR/cargo-packages.zsh\"; then
            echo 'SUCCESS:cargo-packages.zsh dependency updated to rust-toolchain.zsh'
        else
            echo 'FAILED:cargo-packages.zsh still references old toolchains.zsh'
            exit 1
        fi

        if grep -q 'haskell-toolchain.zsh' \"\$PI_SCRIPTS_DIR/ghcup-packages.zsh\"; then
            echo 'SUCCESS:ghcup-packages.zsh dependency updated to haskell-toolchain.zsh'
        else
            echo 'FAILED:ghcup-packages.zsh still references old toolchains.zsh'
            exit 1
        fi

        # Count total post-install scripts (should be at least 15)
        PI_SCRIPT_COUNT=\$(ls -1 \"\$PI_SCRIPTS_DIR\"/*.zsh 2>/dev/null | wc -l | tr -d ' ')
        if [ \$PI_SCRIPT_COUNT -ge 15 ]; then
            echo \"SUCCESS:Post-install script count: \$PI_SCRIPT_COUNT (expected >=15)\"
        else
            echo \"FAILED:Expected at least 15 PI scripts, found \$PI_SCRIPT_COUNT\"
            exit 1
        fi

        # Test --help flags on new scripts
        if cd \"\$PI_SCRIPTS_DIR\" && ./haskell-toolchain.zsh --help >/dev/null 2>&1; then
            echo 'SUCCESS:haskell-toolchain.zsh --help works'
        else
            echo 'INFO:haskell-toolchain.zsh --help not available (may not have flag)'
        fi

        if ./rust-toolchain.zsh --help >/dev/null 2>&1; then
            echo 'SUCCESS:rust-toolchain.zsh --help works'
        else
            echo 'INFO:rust-toolchain.zsh --help not available (may not have flag)'
        fi

        if ./starship-prompt.zsh --help >/dev/null 2>&1; then
            echo 'SUCCESS:starship-prompt.zsh --help works'
        else
            echo 'INFO:starship-prompt.zsh --help not available (may not have flag)'
        fi

        cd ~/.config/dotfiles
        echo 'SUCCESS:Phase 11 validation complete'
    "

    echo "$test_cmd"
}

# ============================================================================
# Test Functions - Comprehensive Features
# ============================================================================

run_comprehensive_tests() {
    local test_cmd="$1"

    test_cmd+="
        echo 'PROGRESS:Comprehensive feature validation'
        cd ~/.config/dotfiles

        # Profile System Tests
        echo 'INFO:Testing profile system...'

        if [ -x ./bin/profile_manager.zsh ]; then
            echo 'SUCCESS:profile_manager.zsh is executable'
        else
            echo 'FAILED:profile_manager.zsh not found'
            exit 1
        fi

        if ./bin/profile_manager.zsh --help >/dev/null 2>&1; then
            echo 'SUCCESS:profile_manager --help works'
        else
            echo 'FAILED:profile_manager --help failed'
            exit 1
        fi

        # Check profile manifests exist
        PROFILE_MANIFESTS=0
        for manifest in profiles/manifests/*.yaml; do
            if [ -f \"\$manifest\" ]; then
                ((PROFILE_MANIFESTS++))
            fi
        done

        if [ \$PROFILE_MANIFESTS -ge 5 ]; then
            echo \"SUCCESS:All profile manifests found (\$PROFILE_MANIFESTS)\"
        else
            echo \"FAILED:Expected 5+ manifests, found \$PROFILE_MANIFESTS\"
            exit 1
        fi

        # Package Management Tests
        echo 'INFO:Testing package management...'

        if [ -f ./packages/install_from_manifest.symlink_local_bin.zsh ]; then
            echo 'SUCCESS:Package management scripts present'
        else
            echo 'FAILED:Package management scripts not found'
            exit 1
        fi

        # Verify manifest YAML structure
        for manifest in profiles/manifests/*.yaml; do
            if [ -f \"\$manifest\" ]; then
                if grep -q '^version:' \"\$manifest\" && grep -q '^packages:' \"\$manifest\"; then
                    PKG_COUNT=\$(grep -c '^\\s*-\\s*id:' \"\$manifest\" || echo 0)
                    echo \"SUCCESS:\${manifest##*/} has \$PKG_COUNT packages\"
                else
                    echo \"FAILED:Invalid YAML in \${manifest##*/}\"
                    exit 1
                fi
            fi
        done

        # System Tools Validation
        echo 'INFO:Testing system tools...'

        if [ -x ./bin/wizard.zsh ]; then
            echo 'SUCCESS:wizard.zsh is executable'
            if ./bin/wizard.zsh --help >/dev/null 2>&1; then
                echo 'SUCCESS:wizard.zsh --help works'
            fi
        else
            echo 'FAILED:wizard.zsh not found'
            exit 1
        fi

        if [ -x ./bin/librarian.zsh ]; then
            echo 'SUCCESS:librarian.zsh is executable'
        else
            echo 'FAILED:librarian.zsh not found'
            exit 1
        fi

        if [ -x ./bin/link_dotfiles.zsh ]; then
            echo 'SUCCESS:link_dotfiles.zsh is executable'
        fi

        echo 'SUCCESS:Comprehensive validation complete'
    "

    echo "$test_cmd"
}

# ============================================================================
# Performance Metrics and Resource Monitoring
# ============================================================================

# Global variables for performance tracking
declare -A TEST_START_TIMES
declare -A TEST_END_TIMES
declare -A TEST_DURATIONS

# Start tracking test performance
start_test_timer() {
    local test_name="$1"
    TEST_START_TIMES[$test_name]=$(date +%s)
}

# End tracking test performance
end_test_timer() {
    local test_name="$1"
    TEST_END_TIMES[$test_name]=$(date +%s)

    local start=${TEST_START_TIMES[$test_name]}
    local end=${TEST_END_TIMES[$test_name]}
    local duration=$((end - start))
    TEST_DURATIONS[$test_name]=$duration
}

# Get container resource usage stats
get_container_stats() {
    local container_name="$1"

    # Try to get stats (may fail if container is already stopped)
    local stats=$(docker stats --no-stream --format "{{.CPUPerc}} {{.MemUsage}}" "$container_name" 2>/dev/null || echo "N/A N/A")
    echo "$stats"
}

# Print performance summary
print_performance_summary() {
    if [[ ${#TEST_DURATIONS[@]} -eq 0 ]]; then
        return
    fi

    echo ""
    draw_section_header "Performance Metrics"

    print_info "📊 Test Duration Breakdown:"
    echo ""

    local total_duration=0
    for test_name in "${(@k)TEST_DURATIONS}"; do
        local duration=${TEST_DURATIONS[$test_name]}
        total_duration=$((total_duration + duration))

        local minutes=$((duration / 60))
        local seconds=$((duration % 60))

        printf "   %-40s %2dm %2ds\n" "$test_name" "$minutes" "$seconds"
    done

    echo ""
    local total_minutes=$((total_duration / 60))
    local total_seconds=$((total_duration % 60))
    print_info "⏱️  Total test time: ${COLOR_BOLD}${total_minutes}m ${total_seconds}s${COLOR_RESET}"

    # Calculate average
    local test_count=${#TEST_DURATIONS[@]}
    if [[ $test_count -gt 0 ]]; then
        local avg_duration=$((total_duration / test_count))
        local avg_minutes=$((avg_duration / 60))
        local avg_seconds=$((avg_duration % 60))
        print_info "📈 Average per test: ${avg_minutes}m ${avg_seconds}s"
    fi
    echo ""
}

# ============================================================================
# Main Test Execution
# ============================================================================

test_installation() {
    local distro="$1"
    local mode="$2"  # dfauto or dfsetup
    local container_name="dotfiles-test-${distro//[:.]/-}-${mode}"
    local installer_url="https://buckmeister.github.io/${mode}"

    draw_header "Docker Test: $distro" "Running $mode installer"
    echo ""

    print_info "Container: $container_name"
    print_info "Installer URL: $installer_url"
    print_info "Test mode: ${TEST_MODE}"
    echo ""
    echo "   ${COLOR_BOLD}${UI_ACCENT_COLOR}💡 Follow live:${COLOR_RESET} docker logs -f $container_name"
    echo ""

    # Build the test command
    local test_cmd="
        set -e
        echo 'PROGRESS:Installing prerequisites'
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -qq 2>&1 && apt-get install -y -qq curl git 2>&1
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y -q curl git 2>&1
        fi

        echo 'PROGRESS:Running web installer'
        # For dfsetup, we need to simulate user input
        if [ '$mode' = 'dfsetup' ]; then
            # Provide automated responses: Y for git, Y for zsh, Y for clone, then quit menu
            printf 'Y\\nY\\nY\\nq\\n' | curl -fsSL $installer_url | sh 2>&1 || true
        else
            # dfauto runs non-interactively
            curl -fsSL $installer_url | sh 2>&1
        fi
    "

    # Add basic tests (always run)
    test_cmd=$(run_basic_installation_tests "$test_cmd")

    # Add Phase 11 validation tests (BEFORE PI filtering, always run to ensure refactoring is correct)
    test_cmd=$(run_phase11_validation_tests "$test_cmd")

    # Add PI filtering if needed (AFTER Phase 11 validation so it doesn't interfere with checks)
    local pi_filter=$(prepare_pi_filtering "$distro")
    if [[ -n "$pi_filter" ]]; then
        test_cmd+="$pi_filter"
    fi

    # Add comprehensive tests if requested
    if [[ "$TEST_MODE" == "comprehensive" ]] || [[ "$TEST_MODE" == "full" ]]; then
        test_cmd=$(run_comprehensive_tests "$test_cmd")
    fi

    # Determine number of phases based on test mode
    local total_phases=6  # Basic (5) + Phase 11 validation (1)
    if [[ "$TEST_MODE" == "comprehensive" ]] || [[ "$TEST_MODE" == "full" ]]; then
        total_phases=7  # Basic (5) + Phase 11 (1) + Comprehensive (1)
    fi

    draw_section_header "Running Test Phases"

    print_info "Phase 1/$total_phases: Pulling container image..."

    # Conditionally set --rm flag based on NO_CLEANUP setting
    local rm_flag="--rm"
    if [[ "$NO_CLEANUP" == true ]]; then
        rm_flag=""
        echo ""
        print_warning "Container will be preserved for debugging: $container_name"
        print_info "Use 'docker ps -a' to see stopped containers"
        print_info "Use 'docker exec -it $container_name bash' to inspect (if still running)"
        print_info "Use 'docker start $container_name && docker attach $container_name' to resume"
        echo ""
    fi

    if docker run $rm_flag \
        --name "$container_name" \
        -e DEBIAN_FRONTEND=noninteractive \
        "$distro" \
        bash -c "$test_cmd" 2>&1 | while IFS= read -r line; do
            # Process output in real-time
            case "$line" in
                PROGRESS:Installing*)
                    print_info "Phase 2/$total_phases: Installing prerequisites..."
                    ;;
                PROGRESS:Running*)
                    print_info "Phase 3/$total_phases: Running web installer..."
                    ;;
                PROGRESS:Verifying*)
                    print_info "Phase 4/$total_phases: Verifying installation..."
                    ;;
                PROGRESS:Running\ librarian*)
                    print_info "Phase 5/$total_phases: Running librarian health check..."
                    ;;
                PROGRESS:Phase\ 11*)
                    print_info "Phase 6/$total_phases: Validating Phase 11 refactoring..."
                    ;;
                PROGRESS:Comprehensive*)
                    if [[ "$TEST_MODE" == "comprehensive" ]] || [[ "$TEST_MODE" == "full" ]]; then
                        print_info "Phase 7/$total_phases: Comprehensive feature validation..."
                    fi
                    ;;
                *)
                    # Use parse_test_output for standard markers
                    parse_test_output "$line"
                    ;;
            esac
        done; then
        echo ""
        print_success "Test passed: $distro with $mode"
        return 0
    else
        echo ""
        print_error "Test failed: $distro with $mode"
        return 1
    fi
}

# ============================================================================
# Main Test Suite Orchestration
# ============================================================================

run_tests() {
    draw_header "Unified Docker Testing" "Flexible and Comprehensive"
    echo ""

    draw_section_header "Test Configuration"

    print_info "Test mode: ${COLOR_BOLD}$TEST_MODE${COLOR_RESET}"
    print_info "Installer mode: ${COLOR_BOLD}$INSTALLER_MODE${COLOR_RESET}"

    if [[ "$SKIP_PI" == true ]]; then
        print_warning "Post-install scripts: ALL DISABLED (--skip-pi)"
    elif [[ -n "$ENABLE_PI_GLOB" ]]; then
        print_info "Post-install scripts: ONLY '$ENABLE_PI_GLOB'"
    elif [[ -n "$DISABLE_PI_GLOB" ]]; then
        print_info "Post-install scripts: DISABLED '$DISABLE_PI_GLOB'"
    else
        print_info "Post-install scripts: ALL ENABLED"
    fi

    print_info "Distributions: ${#DISTROS[@]}"
    for distro in "${DISTROS[@]}"; do
        echo "   • $distro"
    done
    echo ""

    local modes_to_test=("$INSTALLER_MODE")
    if [[ "$INSTALLER_MODE" == "both" ]]; then
        modes_to_test=("dfauto" "dfsetup")
    fi

    local total_tests=$((${#DISTROS[@]} * ${#modes_to_test[@]}))
    print_info "Total tests to run: ${COLOR_BOLD}$total_tests${COLOR_RESET}"
    echo ""

    # Estimate time
    local time_per_test=2
    if [[ "$TEST_MODE" == "full" ]]; then
        time_per_test=5
    elif [[ "$TEST_MODE" == "comprehensive" ]]; then
        time_per_test=3
    elif [[ "$SKIP_PI" == true ]]; then
        time_per_test=1
    fi

    local total_minutes=$((total_tests * time_per_test))
    echo "   ${COLOR_BOLD}${UI_WARNING_COLOR}⏱️  Estimated time:${COLOR_RESET} ~$total_minutes minutes"
    echo ""

    # Initialize test result tracking
    init_test_tracking

    for distro in "${DISTROS[@]}"; do
        for mode in "${modes_to_test[@]}"; do
            local test_name="$distro ($mode)"

            # Start performance tracking
            start_test_timer "$test_name"

            # Run test and track result
            if test_installation "$distro" "$mode"; then
                track_test_result "$test_name" true
            else
                track_test_result "$test_name" false
            fi

            # End performance tracking
            end_test_timer "$test_name"

            echo ""
        done
    done

    # Print summary using helper function
    print_test_summary

    # Print performance metrics
    print_performance_summary
}

# ============================================================================
# Cleanup Function
# ============================================================================

cleanup() {
    print_info "Cleaning up any remaining test containers..."
    docker ps -a --filter "name=dotfiles-test-" --format "{{.Names}}" | while read container; do
        docker rm -f "$container" 2>/dev/null || true
    done
}

# Register cleanup on exit
register_cleanup_handler cleanup

# ============================================================================
# Entry Point
# ============================================================================

# Parse command-line arguments
parse_arguments "$@"

# Verify Docker is running
if ! docker ps >/dev/null 2>&1; then
    print_error "Docker daemon is not running"
    print_info "Please start Docker and try again"
    exit 1
fi

print_success "Docker is running"
echo ""

# Run the test suite
run_tests
