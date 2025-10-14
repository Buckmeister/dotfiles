#!/usr/bin/env zsh

# ============================================================================
# Docker Installation Testing Script
# ============================================================================
#
# Tests dotfiles installation on fresh Linux containers (Ubuntu, Debian)
# Tests both interactive (dfsetup) and automatic (dfauto) modes
#
# Usage:
#   ./tests/test_docker_install.zsh
#   ./tests/test_docker_install.zsh --quick    # Skip dfsetup (faster)
#   ./tests/test_docker_install.zsh --distro ubuntu:24.04
#
# ============================================================================

emulate -LR zsh
setopt ERR_EXIT PIPE_FAIL

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

# Test configurations
DISTROS=(
    "ubuntu:24.04"
    "ubuntu:22.04"
    "debian:12"
    "debian:11"
)

TEST_MODES=(
    "dfauto"   # Always test automatic mode (faster, non-interactive)
)

# Parse arguments
QUICK_MODE=false
SINGLE_DISTRO=""

for arg in "$@"; do
    case "$arg" in
        --quick)
            QUICK_MODE=true
            ;;
        --distro)
            shift
            SINGLE_DISTRO="$1"
            ;;
        -h|--help)
            cat <<EOF
Docker Installation Testing Script

Usage:
  $0 [OPTIONS]

Options:
  --quick           Skip dfsetup tests (faster, only test dfauto)
  --distro IMAGE    Test only specified distro (e.g., ubuntu:24.04)
  -h, --help        Show this help message

Examples:
  $0                              # Full test suite
  $0 --quick                      # Quick test (dfauto only)
  $0 --distro ubuntu:24.04        # Test specific distro

EOF
            exit 0
            ;;
    esac
done

# If not quick mode, also test dfsetup
if [[ "$QUICK_MODE" = false ]]; then
    TEST_MODES+=("dfsetup")
fi

# If single distro specified, use only that
if [[ -n "$SINGLE_DISTRO" ]]; then
    DISTROS=("$SINGLE_DISTRO")
fi

# ============================================================================
# Test Functions
# ============================================================================

# Test a single installation
test_installation() {
    local distro="$1"
    local mode="$2"
    local container_name="dotfiles-test-${distro//[:.]/-}-${mode}"
    local installer_url="https://buckmeister.github.io/${mode}"

    # Temporary file for capturing output
    local output_file=$(mktemp)

    draw_section_header "Testing: $distro with $mode"
    echo ""

    print_info "Container: $container_name"
    print_info "Installer URL: $installer_url"
    print_info "Test mode: ${mode}"
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
            printf 'Y\nY\nY\nq\n' | curl -fsSL $installer_url | sh 2>&1 || true
        else
            # dfauto runs non-interactively
            curl -fsSL $installer_url | sh 2>&1
        fi

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

        echo 'PROGRESS:Complete'
        echo \"INFO:Distribution: \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')\"
        echo \"INFO:Install mode: $mode\"
        echo \"INFO:Dotfiles location: ~/.config/dotfiles\"
    "

    # Progress tracking
    local current_phase=1
    local total_phases=4
    local test_passed=true

    print_info "Running test phases..."
    echo ""

    # Run the test in a container and capture output
    docker run --rm \
        --name "$container_name" \
        -e DEBIAN_FRONTEND=noninteractive \
        "$distro" \
        bash -c "$test_cmd" > "$output_file" 2>&1 &

    local docker_pid=$!

    # Monitor the output file in real-time
    sleep 1  # Give docker a moment to start

    show_progress 1 4 "Pulling container image"

    # Tail the output file and show progress
    (
        tail -f "$output_file" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
                PROGRESS:Installing*)
                    current_phase=2
                    ;;
                PROGRESS:Running*)
                    current_phase=3
                    ;;
                PROGRESS:Verifying*)
                    current_phase=4
                    ;;
                SUCCESS:*)
                    local message="${line#SUCCESS:}"
                    print_success "$message"
                    ;;
                FAILED:*)
                    local message="${line#FAILED:}"
                    print_error "$message"
                    test_passed=false
                    ;;
                INFO:*)
                    local message="${line#INFO:}"
                    echo "   ${COLOR_COMMENT}$message${COLOR_RESET}"
                    ;;
                PROGRESS:Complete)
                    break
                    ;;
            esac
        done
    ) &
    local tail_pid=$!

    # Wait for docker to complete
    if wait $docker_pid; then
        # Kill the tail process
        kill $tail_pid 2>/dev/null || true
        wait $tail_pid 2>/dev/null || true

        # Show final progress
        for phase in {2..4}; do
            local phase_name
            case $phase in
                2) phase_name="Installing prerequisites" ;;
                3) phase_name="Running web installer" ;;
                4) phase_name="Verifying installation" ;;
            esac
            show_progress $phase 4 "$phase_name"
        done

        echo ""
        echo ""
        print_success "Test passed: $distro with $mode"
        rm -f "$output_file"
        return 0
    else
        # Kill the tail process
        kill $tail_pid 2>/dev/null || true
        wait $tail_pid 2>/dev/null || true

        echo ""
        echo ""
        print_error "Test failed: $distro with $mode"
        print_info "Last output:"
        tail -20 "$output_file" 2>/dev/null || true
        rm -f "$output_file"
        return 1
    fi
}

# ============================================================================
# Main Test Suite
# ============================================================================

run_tests() {
    draw_section_header "Docker Installation Testing" "Testing dotfiles on fresh containers"
    echo ""

    # TL;DR Introduction
    draw_box \
        "What This Test Does:" \
        "• Spins up fresh Docker container(s)" \
        "• Downloads and runs the web installer" \
        "• Verifies the dotfiles installation worked" \
        "• Cleans up containers when done" \
        "" \
        "⏱️  Estimated time: ~2-3 minutes per distribution" \
        "" \
        "💡 Tip: Watch the progress bars to see what's happening"

    echo ""

    print_info "Test configuration:"
    echo "   Distributions: ${#DISTROS[@]}"
    echo "   Modes: ${TEST_MODES[@]}"
    echo "   Total tests: $((${#DISTROS[@]} * ${#TEST_MODES[@]}))"
    echo ""

    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    # Track failed tests for summary
    local -a failed_list

    for distro in "${DISTROS[@]}"; do
        for mode in "${TEST_MODES[@]}"; do
            ((total_tests++))

            if test_installation "$distro" "$mode"; then
                ((passed_tests++))
            else
                ((failed_tests++))
                failed_list+=("$distro ($mode)")
            fi

            echo ""
        done
    done

    # Print summary
    draw_section_header "Test Results Summary"
    echo ""

    echo "   ${COLOR_BOLD}Total tests:${COLOR_RESET}  $total_tests"
    echo "   ${COLOR_SUCCESS}${COLOR_BOLD}Passed:${COLOR_RESET}       $passed_tests"
    echo "   ${COLOR_ERROR}${COLOR_BOLD}Failed:${COLOR_RESET}       $failed_tests"
    echo ""

    if [[ $failed_tests -gt 0 ]]; then
        print_error "Failed tests:"
        for failed in "${failed_list[@]}"; do
            echo "   - $failed"
        done
        echo ""
        return 1
    else
        print_success "All tests passed! 🎉"
        echo ""
        print_success "$(get_random_friend_greeting)"
        echo ""
        return 0
    fi
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
trap cleanup EXIT INT TERM

# ============================================================================
# Entry Point
# ============================================================================

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
