#!/usr/bin/env zsh

# ============================================================================
# Test Runner - Execute All Test Suites
# ============================================================================
#
# Runs all unit and integration tests for the dotfiles repository.
# Uses shared libraries for consistent, beautiful output.
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

# Load shared libraries
source "${DOTFILES_ROOT}/bin/lib/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load shared libraries"
    exit 1
}
source "${DOTFILES_ROOT}/bin/lib/ui.zsh"
source "${DOTFILES_ROOT}/bin/lib/utils.zsh"

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

${UI_INFO_COLOR}USAGE:${COLOR_RESET}
    $0 [OPTIONS] [TEST_TYPE]

${UI_INFO_COLOR}TEST TYPES:${COLOR_RESET}
    unit            Run only unit tests
    integration     Run only integration tests
    (no argument)   Run all tests

${UI_INFO_COLOR}OPTIONS:${COLOR_RESET}
    --help, -h      Show this help message
    --verbose, -v   Verbose output

${UI_INFO_COLOR}EXAMPLES:${COLOR_RESET}
    $0                    # Run all tests
    $0 unit              # Run unit tests only
    $0 integration       # Run integration tests only
    $0 --verbose unit    # Run unit tests with verbose output

${UI_INFO_COLOR}TEST STRUCTURE:${COLOR_RESET}
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

    draw_section_header "Running: $test_name"

    ((TOTAL_SUITES++))

    # Run the test file
    zsh "$test_file"
    local exit_code=$?

    echo ""

    if [[ $exit_code -eq 0 ]]; then
        ((PASSED_SUITES++))
        print_success "Suite PASSED: $test_name"
        echo ""
        return 0
    else
        ((FAILED_SUITES++))
        print_error "Suite FAILED: $test_name"
        echo ""
        return 1
    fi
}

function run_tests_in_directory() {
    local test_dir="$1"
    local test_type="$2"

    if [[ ! -d "$test_dir" ]]; then
        print_warning "No $test_type tests found in: $test_dir"
        return 0
    fi

    # Find all test files
    local test_files=(${(f)"$(find "$test_dir" -name "test_*.zsh" -type f | sort)"})

    if [[ ${#test_files[@]} -eq 0 ]]; then
        print_warning "No test files found in: $test_dir"
        return 0
    fi

    print_info "Running ${#test_files[@]} $test_type test suite(s)..."
    echo ""

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
                printf "${COLOR_ERROR}Unknown argument: $arg${COLOR_RESET}\n"
                show_help
                exit 1
                ;;
        esac
    done

    # Show header
    echo ""
    draw_header "Dotfiles Test Suite Runner" "Execute unit and integration tests"
    echo ""

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
    echo ""
    draw_section_header "Test Suite Summary"

    print_info "📊 Test Results:"
    echo "   Total Suites:  $TOTAL_SUITES"
    echo "   ${COLOR_SUCCESS}Passed:        $PASSED_SUITES${COLOR_RESET}"

    if [[ $FAILED_SUITES -gt 0 ]]; then
        echo "   ${COLOR_ERROR}Failed:        $FAILED_SUITES${COLOR_RESET}"
    fi

    echo ""

    # Final result
    if [[ $FAILED_SUITES -eq 0 ]]; then
        print_success "ALL TEST SUITES PASSED ✓ ✓ ✓"
        echo ""
        return 0
    else
        print_error "SOME TEST SUITES FAILED ✗ ✗ ✗"
        echo ""
        return 1
    fi
}

# Execute main function
main "$@"
exit $?
