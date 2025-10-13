#!/usr/bin/env zsh

# ============================================================================
# Test Runner - Execute All Test Suites
# ============================================================================
#
# Runs all unit and integration tests for the dotfiles repository.
#
# Usage:
#   ./tests/run_tests.zsh                # Run all tests
#   ./tests/run_tests.zsh unit           # Run only unit tests
#   ./tests/run_tests.zsh integration    # Run only integration tests
#   ./tests/run_tests.zsh --help         # Show help
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$SCRIPT_DIR"

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_GREEN='\033[32m'
readonly COLOR_RED='\033[31m'
readonly COLOR_YELLOW='\033[33m'
readonly COLOR_CYAN='\033[36m'

# Test tracking
typeset -g -i TOTAL_SUITES=0
typeset -g -i PASSED_SUITES=0
typeset -g -i FAILED_SUITES=0

# ============================================================================
# Help Message
# ============================================================================

function show_help() {
    cat << EOF
${COLOR_BOLD}Dotfiles Test Runner${COLOR_RESET}

${COLOR_CYAN}USAGE:${COLOR_RESET}
    $0 [OPTIONS] [TEST_TYPE]

${COLOR_CYAN}TEST TYPES:${COLOR_RESET}
    unit            Run only unit tests
    integration     Run only integration tests
    (no argument)   Run all tests

${COLOR_CYAN}OPTIONS:${COLOR_RESET}
    --help, -h      Show this help message
    --verbose, -v   Verbose output

${COLOR_CYAN}EXAMPLES:${COLOR_RESET}
    $0                    # Run all tests
    $0 unit              # Run unit tests only
    $0 integration       # Run integration tests only
    $0 --verbose unit    # Run unit tests with verbose output

${COLOR_CYAN}TEST STRUCTURE:${COLOR_RESET}
    tests/
    ├── unit/            Unit tests for libraries
    ├── integration/     Integration tests for full workflows
    ├── lib/             Test framework and utilities
    └── run_tests.zsh    This script

EOF
}

# ============================================================================
# Test Execution Functions
# ============================================================================

function run_test_suite() {
    local test_file="$1"
    local test_name="$(basename "$test_file" .zsh)"

    printf "${COLOR_CYAN}${COLOR_BOLD}╔════════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}\n"
    printf "${COLOR_CYAN}${COLOR_BOLD}║  Running: %-64s ║${COLOR_RESET}\n" "$test_name"
    printf "${COLOR_CYAN}${COLOR_BOLD}╚════════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}\n"

    ((TOTAL_SUITES++))

    # Run the test file
    zsh "$test_file"
    local exit_code=$?

    echo ""

    if [[ $exit_code -eq 0 ]]; then
        ((PASSED_SUITES++))
        printf "${COLOR_GREEN}${COLOR_BOLD}✓ Suite PASSED: %s${COLOR_RESET}\n\n" "$test_name"
        return 0
    else
        ((FAILED_SUITES++))
        printf "${COLOR_RED}${COLOR_BOLD}✗ Suite FAILED: %s${COLOR_RESET}\n\n" "$test_name"
        return 1
    fi
}

function run_tests_in_directory() {
    local test_dir="$1"
    local test_type="$2"

    if [[ ! -d "$test_dir" ]]; then
        printf "${COLOR_YELLOW}⚠ No $test_type tests found in: $test_dir${COLOR_RESET}\n"
        return 0
    fi

    # Find all test files
    local test_files=(${(f)"$(find "$test_dir" -name "test_*.zsh" -type f | sort)"})

    if [[ ${#test_files[@]} -eq 0 ]]; then
        printf "${COLOR_YELLOW}⚠ No test files found in: $test_dir${COLOR_RESET}\n"
        return 0
    fi

    printf "${COLOR_BOLD}${COLOR_CYAN}Running %d %s test suite(s)...${COLOR_RESET}\n\n" "${#test_files[@]}" "$test_type"

    for test_file in "${test_files[@]}"; do
        run_test_suite "$test_file"
    done
}

# ============================================================================
# Main Execution
# ============================================================================

function main() {
    local test_type="all"
    local verbose=false

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --help|-h)
                show_help
                exit 0
                ;;
            --verbose|-v)
                verbose=true
                ;;
            unit|integration)
                test_type="$arg"
                ;;
            *)
                printf "${COLOR_RED}Unknown argument: $arg${COLOR_RESET}\n"
                show_help
                exit 1
                ;;
        esac
    done

    # Show header
    printf "\n"
    printf "${COLOR_BOLD}${COLOR_CYAN}═══════════════════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    printf "${COLOR_BOLD}${COLOR_CYAN}                        DOTFILES TEST SUITE RUNNER                            ${COLOR_RESET}\n"
    printf "${COLOR_BOLD}${COLOR_CYAN}═══════════════════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    printf "\n"

    # Run requested tests
    case "$test_type" in
        unit)
            run_tests_in_directory "$TESTS_DIR/unit" "unit"
            ;;
        integration)
            run_tests_in_directory "$TESTS_DIR/integration" "integration"
            ;;
        all)
            run_tests_in_directory "$TESTS_DIR/unit" "unit"
            echo ""
            run_tests_in_directory "$TESTS_DIR/integration" "integration"
            ;;
    esac

    # Show summary
    printf "\n"
    printf "${COLOR_BOLD}${COLOR_CYAN}═══════════════════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    printf "${COLOR_BOLD}${COLOR_CYAN}                           TEST SUITE SUMMARY                                  ${COLOR_RESET}\n"
    printf "${COLOR_BOLD}${COLOR_CYAN}═══════════════════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    printf "\n"

    printf "  ${COLOR_BOLD}Total Suites:${COLOR_RESET}   %d\n" "$TOTAL_SUITES"
    printf "  ${COLOR_GREEN}${COLOR_BOLD}Passed:${COLOR_RESET}         %d\n" "$PASSED_SUITES"

    if [[ $FAILED_SUITES -gt 0 ]]; then
        printf "  ${COLOR_RED}${COLOR_BOLD}Failed:${COLOR_RESET}         %d\n" "$FAILED_SUITES"
    fi

    printf "\n"

    # Final result
    if [[ $FAILED_SUITES -eq 0 ]]; then
        printf "${COLOR_GREEN}${COLOR_BOLD}✓ ✓ ✓  ALL TEST SUITES PASSED  ✓ ✓ ✓${COLOR_RESET}\n"
        printf "\n"
        return 0
    else
        printf "${COLOR_RED}${COLOR_BOLD}✗ ✗ ✗  SOME TEST SUITES FAILED  ✗ ✗ ✗${COLOR_RESET}\n"
        printf "\n"
        return 1
    fi
}

# Execute main function
main "$@"
exit $?
