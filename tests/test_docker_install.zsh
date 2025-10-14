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

# Colors
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_RED="\033[38;5;204m"
COLOR_GREEN="\033[38;5;114m"
COLOR_YELLOW="\033[38;5;180m"
COLOR_BLUE="\033[38;5;39m"
COLOR_PURPLE="\033[38;5;170m"
COLOR_CYAN="\033[38;5;38m"

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
# UI Functions
# ============================================================================

print_header() {
    printf "\n${COLOR_PURPLE}${COLOR_BOLD}"
    printf "╔════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║                                                                            ║\n"
    printf "║                   DOCKER INSTALLATION TESTING                              ║\n"
    printf "║                                                                            ║\n"
    printf "╚════════════════════════════════════════════════════════════════════════════╝\n"
    printf "${COLOR_RESET}\n"
}

print_section() {
    printf "\n${COLOR_CYAN}${COLOR_BOLD}═══ %s ═══${COLOR_RESET}\n\n" "$1"
}

print_success() {
    printf "${COLOR_GREEN}✅ %s${COLOR_RESET}\n" "$1"
}

print_error() {
    printf "${COLOR_RED}❌ %s${COLOR_RESET}\n" "$1"
}

print_warning() {
    printf "${COLOR_YELLOW}⚠️  %s${COLOR_RESET}\n" "$1"
}

print_info() {
    printf "${COLOR_BLUE}ℹ️  %s${COLOR_RESET}\n" "$1"
}

# ============================================================================
# Test Functions
# ============================================================================

# Test a single installation
test_installation() {
    local distro="$1"
    local mode="$2"
    local container_name="dotfiles-test-${distro//[:.]/-}-${mode}"

    print_section "Testing: $distro with $mode"

    print_info "Creating container: $container_name"

    # Determine the installer URL
    local installer_url="https://buckmeister.github.io/${mode}"

    # Build the test command
    local test_cmd="
        set -e
        echo '=== Installing curl ==='
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -qq && apt-get install -y -qq curl git
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y -q curl git
        fi

        echo '=== Running installer: $mode ==='
        # For dfsetup, we need to simulate user input (just pressing Enter to accept defaults)
        if [ '$mode' = 'dfsetup' ]; then
            # Provide automated responses: Y for git, Y for zsh, Y for clone, then quit menu
            printf 'Y\nY\nY\nq\n' | curl -fsSL $installer_url | sh || true
        else
            # dfauto runs non-interactively
            curl -fsSL $installer_url | sh
        fi

        echo '=== Verifying installation ==='
        if [ -d ~/.config/dotfiles ]; then
            echo 'SUCCESS: Dotfiles directory created'
        else
            echo 'FAILED: Dotfiles directory not found'
            exit 1
        fi

        if [ -d ~/.config/dotfiles/.git ]; then
            echo 'SUCCESS: Git repository initialized'
        else
            echo 'FAILED: Not a git repository'
            exit 1
        fi

        echo '=== Installation Summary ==='
        echo \"Distribution: \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2)\"
        echo \"Install mode: $mode\"
        echo \"Dotfiles location: ~/.config/dotfiles\"
        if [ -f ~/.config/dotfiles/bin/setup.zsh ]; then
            echo 'Setup script: Found'
        fi
    "

    # Run the test in a container
    if docker run --rm \
        --name "$container_name" \
        -e DEBIAN_FRONTEND=noninteractive \
        "$distro" \
        bash -c "$test_cmd" 2>&1; then

        print_success "Test passed: $distro with $mode"
        return 0
    else
        print_error "Test failed: $distro with $mode"
        return 1
    fi
}

# ============================================================================
# Main Test Suite
# ============================================================================

run_tests() {
    print_header

    print_info "Test configuration:"
    echo "  Distributions: ${#DISTROS[@]}"
    echo "  Modes: ${TEST_MODES[@]}"
    echo "  Total tests: $((${#DISTROS[@]} * ${#TEST_MODES[@]}))"
    echo

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

            echo
        done
    done

    # Print summary
    print_section "Test Results Summary"

    echo "${COLOR_BOLD}Total tests:${COLOR_RESET}  $total_tests"
    echo "${COLOR_GREEN}${COLOR_BOLD}Passed:${COLOR_RESET}       $passed_tests"
    echo "${COLOR_RED}${COLOR_BOLD}Failed:${COLOR_RESET}       $failed_tests"
    echo

    if [[ $failed_tests -gt 0 ]]; then
        print_error "Failed tests:"
        for failed in "${failed_list[@]}"; do
            echo "  - $failed"
        done
        echo
        return 1
    else
        print_success "All tests passed! 🎉"
        echo
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

# Run the test suite
run_tests
