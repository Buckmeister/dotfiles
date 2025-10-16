#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Dotfiles Test Suite Runner - Flexible Testing Made Easy
# ============================================================================
# This script provides a flexible, fast, and friendly test execution system
# that reads configuration from test_config.yaml and orchestrates test runs.
#
# Usage:
#   ./run_suite.zsh --suite smoke                  # Quick smoke tests
#   ./run_suite.zsh --suite standard               # Standard test suite
#   ./run_suite.zsh --suite comprehensive          # Full comprehensive tests
#   ./run_suite.zsh --component symlinks           # Test specific component
#   ./run_suite.zsh --tag quick                    # Run tests with specific tag
#   ./run_suite.zsh --docker ubuntu:24.04          # Test specific distro
#   ./run_suite.zsh --xen --hosts all              # XEN tests with all hosts

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load shared libraries
source "$DF_DIR/bin/lib/colors.zsh" 2>/dev/null || {
    COLOR_RESET='\033[0m'
    UI_SUCCESS_COLOR='\033[32m'
    UI_ERROR_COLOR='\033[31m'
    UI_WARNING_COLOR='\033[33m'
    UI_INFO_COLOR='\033[90m'
}

source "$DF_DIR/bin/lib/ui.zsh" 2>/dev/null || {
    function print_success() { echo "✅ $1"; }
    function print_error() { echo "❌ $1"; }
    function print_warning() { echo "⚠️  $1"; }
    function print_info() { echo "ℹ️  $1"; }
}

source "$DF_DIR/bin/lib/utils.zsh" 2>/dev/null || {
    function command_exists() { command -v "$1" >/dev/null 2>&1; }
}

# ============================================================================
# Configuration
# ============================================================================

CONFIG_FILE="$SCRIPT_DIR/test_config.yaml"
RESULTS_DIR="$SCRIPT_DIR/results"
TEST_START_TIME=$(date +%s)

# Test execution state
declare -A TEST_RESULTS
declare -a TESTS_TO_RUN
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# ============================================================================
# YAML Configuration Parser
# ============================================================================

# Simple YAML parser for our config file
# This is a lightweight implementation that handles the specific structure
# of our test_config.yaml file.

function parse_yaml_value() {
    local key="$1"
    local config_file="${2:-$CONFIG_FILE}"

    grep "^[[:space:]]*${key}:" "$config_file" | head -1 | sed -E "s/^[[:space:]]*${key}:[[:space:]]*//" | sed 's/^["'"'"']\(.*\)["'"'"']$/\1/' | xargs
}

function parse_yaml_list() {
    local section="$1"
    local key="$2"
    local config_file="${3:-$CONFIG_FILE}"

    awk "
        /^${section}:/,/^[a-z]/ {
            if (/^[[:space:]]+${key}:/) {
                in_list = 1
                next
            }
            if (in_list && /^[[:space:]]+-/) {
                gsub(/^[[:space:]]+-[[:space:]]*/, \"\")
                print
            }
            if (in_list && /^[[:space:]]*[a-z]/ && !/^[[:space:]]+-/) {
                exit
            }
        }
    " "$config_file"
}

function get_suite_distros() {
    local suite="$1"

    awk "
        /^[[:space:]]*${suite}:/,/^[[:space:]]*[a-z]+:/ {
            if (/^[[:space:]]+distros:/) {
                in_distros = 1
                next
            }
            if (in_distros && /^[[:space:]]+-/) {
                gsub(/^[[:space:]]+-[[:space:]]*/, \"\")
                print
                next
            }
            if (in_distros && !/^[[:space:]]+-/) {
                exit
            }
        }
    " "$CONFIG_FILE"
}

function get_suite_components() {
    local suite="$1"

    awk "
        /^[[:space:]]*${suite}:/,/^[[:space:]]*[a-z]+:/ {
            if (/^[[:space:]]+components:/) {
                in_components = 1
                next
            }
            if (in_components && /^[[:space:]]+- name:/) {
                gsub(/^[[:space:]]+- name:[[:space:]]*/, \"\")
                print
                next
            }
            if (in_components && /^[[:space:]]+[a-z]+:/ && !/^[[:space:]]+- name:/) {
                exit
            }
        }
    " "$CONFIG_FILE"
}

function is_docker_enabled() {
    local suite="$1"

    awk "
        /^[[:space:]]*${suite}:/,/^[[:space:]]*[a-z]+:/ {
            if (/^[[:space:]]+docker:/) {
                in_docker = 1
                next
            }
            if (in_docker && /enabled:/) {
                if (/enabled:[[:space:]]*true/) {
                    print \"true\"
                    exit
                } else {
                    print \"false\"
                    exit
                }
            }
            if (in_docker && /^[[:space:]]+[a-z]+:/ && !/^[[:space:]]+enabled:/) {
                exit
            }
        }
    " "$CONFIG_FILE"
}

function is_xen_enabled() {
    local suite="$1"

    awk "
        /^[[:space:]]*${suite}:/,/^[[:space:]]*[a-z]+:/ {
            if (/^[[:space:]]+xen:/) {
                in_xen = 1
                next
            }
            if (in_xen && /enabled:/) {
                if (/enabled:[[:space:]]*true/) {
                    print \"true\"
                    exit
                } else {
                    print \"false\"
                    exit
                }
            }
            if (in_xen && /^[[:space:]]+[a-z]+:/ && !/^[[:space:]]+enabled:/) {
                exit
            }
        }
    " "$CONFIG_FILE"
}

# ============================================================================
# Test Execution Functions
# ============================================================================

function execute_docker_test() {
    local distro="$1"
    local mode="${2:-dfauto}"
    local test_name="docker-${distro//[:.\/]/-}-${mode}"

    print_info "Running Docker test: $distro ($mode)"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    local test_output="$RESULTS_DIR/${test_name}.log"
    mkdir -p "$RESULTS_DIR"

    # Run the Docker test using unified script
    local mode_flag="--${mode}"  # Convert mode to flag (dfauto -> --dfauto)
    if "$SCRIPT_DIR/test_docker.zsh" --distro "$distro" "$mode_flag" > "$test_output" 2>&1; then
        TEST_RESULTS[$test_name]="PASS"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        print_success "Docker test passed: $distro ($mode)"
        return 0
    else
        TEST_RESULTS[$test_name]="FAIL"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        print_error "Docker test failed: $distro ($mode)"
        print_info "  Log: $test_output"
        return 1
    fi
}

function execute_xen_test() {
    local template="$1"
    local test_name="xen-${template//[:.\/]/-}"

    print_info "Running XEN test: $template"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    local test_output="$RESULTS_DIR/${test_name}.log"
    mkdir -p "$RESULTS_DIR"

    # Run the XEN test
    if "$SCRIPT_DIR/test_xen_install.zsh" --template "$template" > "$test_output" 2>&1; then
        TEST_RESULTS[$test_name]="PASS"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        print_success "XEN test passed: $template"
        return 0
    else
        TEST_RESULTS[$test_name]="FAIL"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        print_error "XEN test failed: $template"
        print_info "  Log: $test_output"
        return 1
    fi
}

function execute_component_test() {
    local component="$1"
    local test="$2"
    local test_name="component-${component}-${test}"

    print_info "Running component test: $component/$test"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    # Component tests are typically part of the main test scripts
    # For now, we'll mark them as skipped until we implement granular component testing
    TEST_RESULTS[$test_name]="SKIP"
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    print_warning "Component test skipped (not yet implemented): $component/$test"

    return 0
}

# ============================================================================
# Test Suite Execution
# ============================================================================

function run_test_suite() {
    local suite="$1"

    echo
    draw_section_header "🧪 Running Test Suite: ${suite}"
    echo

    # Get suite description
    local description=$(awk "/^[[:space:]]*${suite}:/{flag=1; next} flag && /description:/{print; exit}" "$CONFIG_FILE" | sed 's/.*description:[[:space:]]*"\(.*\)"/\1/')
    print_info "$description"
    echo

    # Check if Docker tests are enabled for this suite
    local docker_enabled=$(is_docker_enabled "$suite")
    if [[ "$docker_enabled" == "true" ]]; then
        echo
        draw_section_header "🐳 Docker Tests"
        echo

        # Get distros for this suite
        local distros=(${(f)"$(get_suite_distros "$suite")"})

        for distro in "${distros[@]}"; do
            # Run with dfauto mode
            execute_docker_test "$distro" "dfauto"
        done
    fi

    # Check if XEN tests are enabled for this suite
    local xen_enabled=$(is_xen_enabled "$suite")
    if [[ "$xen_enabled" == "true" ]]; then
        echo
        draw_section_header "🖥️  XEN Tests"
        echo

        # For now, just run one template as a proof of concept
        # We'll expand this once we implement the multi-host failover
        print_warning "XEN tests not yet fully implemented (coming in Task 5.3)"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    fi

    echo
}

# ============================================================================
# Test Reporting
# ============================================================================

function generate_test_report() {
    local test_end_time=$(date +%s)
    local test_duration=$((test_end_time - TEST_START_TIME))

    echo
    echo "════════════════════════════════════════════════════════════════"
    draw_section_header "📊 Test Results Summary"
    echo "════════════════════════════════════════════════════════════════"
    echo

    printf "  ${UI_INFO_COLOR}Total Tests:${COLOR_RESET}   %d\n" $TOTAL_TESTS
    printf "  ${UI_SUCCESS_COLOR}✓ Passed:${COLOR_RESET}      %d\n" $PASSED_TESTS
    printf "  ${UI_ERROR_COLOR}✗ Failed:${COLOR_RESET}      %d\n" $FAILED_TESTS
    printf "  ${UI_WARNING_COLOR}⊘ Skipped:${COLOR_RESET}     %d\n" $SKIPPED_TESTS
    echo
    printf "  ${UI_INFO_COLOR}Duration:${COLOR_RESET}      %d seconds\n" $test_duration
    echo

    # Calculate success rate
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        local success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
        printf "  ${UI_INFO_COLOR}Success Rate:${COLOR_RESET}  %d%%\n" $success_rate
        echo
    fi

    # Show detailed results if there are failures
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo "Failed Tests:"
        for test in ${(k)TEST_RESULTS}; do
            if [[ ${TEST_RESULTS[$test]} == "FAIL" ]]; then
                printf "  ${UI_ERROR_COLOR}✗${COLOR_RESET} %s\n" "$test"
            fi
        done
        echo
    fi

    echo "════════════════════════════════════════════════════════════════"
    echo

    # Exit with failure if any tests failed
    if [[ $FAILED_TESTS -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

function export_json_results() {
    local json_file="$RESULTS_DIR/test_results.json"

    cat > "$json_file" <<EOF
{
  "test_run": {
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "duration_seconds": $(($(date +%s) - TEST_START_TIME)),
    "total_tests": $TOTAL_TESTS,
    "passed": $PASSED_TESTS,
    "failed": $FAILED_TESTS,
    "skipped": $SKIPPED_TESTS
  },
  "tests": {
EOF

    local first=true
    for test in ${(k)TEST_RESULTS}; do
        if [[ "$first" == true ]]; then
            first=false
        else
            echo "," >> "$json_file"
        fi
        cat >> "$json_file" <<EOF
    "$test": {
      "result": "${TEST_RESULTS[$test]}",
      "log": "$RESULTS_DIR/${test}.log"
    }
EOF
    done

    cat >> "$json_file" <<EOF

  }
}
EOF

    print_success "Test results exported to: $json_file"
}

# ============================================================================
# Command Line Interface
# ============================================================================

function show_help() {
    cat <<EOF

Dotfiles Test Suite Runner - Flexible Testing Made Easy

Usage:
  $0 [OPTIONS]

Test Suite Options:
  --suite SUITE             Run a specific test suite
                            Options: smoke, standard, comprehensive
                            Default: standard

  --component COMPONENT     Run tests for a specific component
                            Options: installation, symlinks, config, scripts

  --tag TAG                 Run tests matching a specific tag
                            Options: quick, core, standard, comprehensive

Platform Options:
  --docker                  Run only Docker tests
  --docker DISTRO           Run Docker tests for specific distro
                            Examples: ubuntu:24.04, debian:12

  --xen                     Run only XEN tests
  --xen TEMPLATE            Run XEN tests for specific template

Execution Options:
  --parallel                Enable parallel test execution
  --no-cleanup              Don't cleanup resources after tests (for debugging)
  --verbose                 Enable verbose output

Output Options:
  --json                    Export results as JSON
  --report                  Generate HTML report

  -h, --help                Show this help message

Examples:
  # Quick smoke tests (fastest)
  $0 --suite smoke

  # Standard test suite (before commits)
  $0 --suite standard

  # Comprehensive tests (before releases)
  $0 --suite comprehensive

  # Test specific distro
  $0 --docker ubuntu:24.04

  # Test specific component
  $0 --component symlinks

  # Run with JSON export
  $0 --suite smoke --json

Configuration:
  Test configuration is defined in: test_config.yaml
  Test results are stored in: $RESULTS_DIR/

EOF
}

# ============================================================================
# Main Execution
# ============================================================================

# Parse command line arguments
SUITE="standard"
COMPONENT=""
TAG=""
DOCKER_ONLY=false
XEN_ONLY=false
DOCKER_DISTRO=""
XEN_TEMPLATE=""
PARALLEL=false
NO_CLEANUP=false
VERBOSE=false
JSON_EXPORT=false
HTML_REPORT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --suite)
            SUITE="$2"
            shift 2
            ;;
        --component)
            COMPONENT="$2"
            shift 2
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --docker)
            DOCKER_ONLY=true
            if [[ -n "$2" && "$2" != --* ]]; then
                DOCKER_DISTRO="$2"
                shift
            fi
            shift
            ;;
        --xen)
            XEN_ONLY=true
            if [[ -n "$2" && "$2" != --* ]]; then
                XEN_TEMPLATE="$2"
                shift
            fi
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --no-cleanup)
            NO_CLEANUP=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --json)
            JSON_EXPORT=true
            shift
            ;;
        --report)
            HTML_REPORT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Verify config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

# Display banner
echo
echo "════════════════════════════════════════════════════════════════"
echo "  🧪 Dotfiles Test Suite Runner"
echo "════════════════════════════════════════════════════════════════"
echo
print_info "Configuration: $CONFIG_FILE"
print_info "Results directory: $RESULTS_DIR"
echo

# Execute tests based on options
if [[ -n "$DOCKER_DISTRO" ]]; then
    # Single Docker distro test
    execute_docker_test "$DOCKER_DISTRO" "dfauto"
elif [[ -n "$XEN_TEMPLATE" ]]; then
    # Single XEN template test
    execute_xen_test "$XEN_TEMPLATE"
elif [[ -n "$COMPONENT" ]]; then
    # Component tests (to be implemented)
    print_warning "Component-specific testing not yet implemented"
    print_info "Coming in Phase 5, Task 5.2!"
    exit 0
elif [[ -n "$TAG" ]]; then
    # Tag-based filtering (to be implemented)
    print_warning "Tag-based filtering not yet implemented"
    print_info "Coming in Phase 5, Task 5.2!"
    exit 0
else
    # Run full test suite
    run_test_suite "$SUITE"
fi

# Generate test report
generate_test_report
test_result=$?

# Export JSON if requested
if [[ "$JSON_EXPORT" == true ]]; then
    export_json_results
fi

# Exit with appropriate code
exit $test_result
