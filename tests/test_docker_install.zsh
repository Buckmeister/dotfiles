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

    draw_header "Docker Test: $distro" "Running $mode installer"
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

    draw_section_header "Running Test Phases"

    print_info "Phase 1/4: Pulling container image..."

    if docker run --rm \
        --name "$container_name" \
        -e DEBIAN_FRONTEND=noninteractive \
        "$distro" \
        bash -c "$test_cmd" 2>&1 | while IFS= read -r line; do
            # Process output in real-time
            case "$line" in
                PROGRESS:Installing*)
                    print_info "Phase 2/4: Installing prerequisites..."
                    ;;
                PROGRESS:Running*)
                    print_info "Phase 3/4: Running web installer..."
                    ;;
                PROGRESS:Verifying*)
                    print_info "Phase 4/4: Verifying installation..."
                    ;;
                SUCCESS:*)
                    local message="${line#SUCCESS:}"
                    print_success "$message"
                    ;;
                FAILED:*)
                    local message="${line#FAILED:}"
                    print_error "$message"
                    ;;
                INFO:*)
                    local message="${line#INFO:}"
                    echo "   ${COLOR_COMMENT}$message${COLOR_RESET}"
                    ;;
                PROGRESS:Complete)
                    # Test completed successfully
                    ;;
                *)
                    # Optionally show other output (uncomment for debugging)
                    # echo "$line"
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
# Main Test Suite
# ============================================================================

run_tests() {
    draw_header "Docker Installation Testing" "Testing on fresh containers"
    echo ""

    draw_section_header "Test Overview"

    print_info "What This Test Does:"
    echo "   • Spins up fresh Docker container(s)"
    echo "   • Downloads and runs the web installer"
    echo "   • Verifies the dotfiles installation worked"
    echo "   • Cleans up containers when done"
    echo ""
    echo "   ${COLOR_BOLD}${UI_WARNING_COLOR}⏱️  Estimated time:${COLOR_RESET} ~2-3 minutes per distribution"
    echo ""
    echo "   ${COLOR_BOLD}${UI_INFO_COLOR}💡 Tip:${COLOR_RESET} Watch the progress updates below"
    echo ""

    draw_section_header "Test Configuration"

    print_info "Test parameters:"
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

            # Run test and capture result (don't let failures exit the loop)
            if test_installation "$distro" "$mode"; then
                ((passed_tests++)) || true
            else
                ((failed_tests++)) || true
                failed_list+=("$distro ($mode)")
            fi

            echo ""
        done
    done

    # Print summary
    draw_section_header "Test Results Summary"

    print_info "📊 Test Statistics:"
    echo "   Total tests:  $total_tests"
    echo "   ${COLOR_SUCCESS}Passed:       $passed_tests${COLOR_RESET}"
    echo "   ${COLOR_ERROR}Failed:       $failed_tests${COLOR_RESET}"
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
