#!/usr/bin/env zsh

# ============================================================================
# Performance Benchmarking Tool
# ============================================================================
#
# Benchmarks key operations in the dotfiles system to track performance
# and identify bottlenecks.
#
# Usage:
#   ./bin/benchmark.zsh [--quick] [--verbose] [--json]
#
# Options:
#   --quick     Run quick benchmarks only (skip slow tests)
#   --verbose   Show detailed output
#   --json      Output results in JSON format
#   --help, -h  Show this help message
# ============================================================================

emulate -LR zsh
setopt PIPE_FAIL

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Load shared libraries (with timing)
LIB_LOAD_START=$(date +%s%N)
source "$REPO_ROOT/bin/lib/colors.zsh"
source "$REPO_ROOT/bin/lib/ui.zsh"
source "$REPO_ROOT/bin/lib/utils.zsh"
LIB_LOAD_END=$(date +%s%N)
LIB_LOAD_TIME=$(( (LIB_LOAD_END - LIB_LOAD_START) / 1000000 ))  # Convert to ms

# Configuration
QUICK_MODE=false
VERBOSE=false
JSON_OUTPUT=false
ITERATIONS=100  # For repeated measurements

# Results storage
declare -A RESULTS

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --quick)
            QUICK_MODE=true
            ITERATIONS=10
            ;;
        --verbose|-v)
            VERBOSE=true
            ;;
        --json)
            JSON_OUTPUT=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Benchmark key operations in the dotfiles system.

OPTIONS:
  --quick     Quick benchmarks only (10 iterations)
  --verbose   Show detailed output
  --json      Output in JSON format
  --help, -h  Show this help message

BENCHMARKS:
  - Library loading time
  - OS detection
  - Symlink operations
  - File operations
  - String operations
  - Array operations
  - Function calls
  - Test execution

EXAMPLES:
  $(basename "$0")              # Full benchmark suite
  $(basename "$0") --quick      # Quick benchmark (faster)
  $(basename "$0") --json       # Output as JSON

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Benchmarking Functions
# ============================================================================

# Measure execution time in nanoseconds
benchmark() {
    local name="$1"
    local command="$2"
    local iterations="${3:-1}"

    local start=$(date +%s%N)
    for ((i=1; i<=iterations; i++)); do
        eval "$command" >/dev/null 2>&1
    done
    local end=$(date +%s%N)

    local total_ns=$((end - start))
    local avg_ns=$((total_ns / iterations))
    local avg_ms=$((avg_ns / 1000000))
    local avg_us=$((avg_ns / 1000))

    RESULTS[$name]="$avg_ms"

    if [[ "$VERBOSE" == "true" ]]; then
        printf "%-40s %8d ms (avg over %d iterations)\n" "$name" "$avg_ms" "$iterations"
    fi
}

# Format results
format_result() {
    local name="$1"
    local time_ms="${RESULTS[$name]}"

    if [[ -z "$time_ms" ]]; then
        time_ms=0
    fi

    printf "  %-45s %6d ms\n" "$name" "$time_ms"
}

# ============================================================================
# Main Benchmarks
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    draw_header "Dotfiles Performance Benchmarks"
    print_info "Iterations: $ITERATIONS per benchmark"
    echo ""
fi

# ============================================================================
# Benchmark 1: Library Loading
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    draw_section_header "1. Library Loading Performance"
fi

# Already measured during script initialization
RESULTS["Library loading (3 libs)"]="$LIB_LOAD_TIME"

benchmark "Load colors.zsh" \
    "source '$REPO_ROOT/bin/lib/colors.zsh'" 1

benchmark "Load ui.zsh" \
    "source '$REPO_ROOT/bin/lib/ui.zsh'" 1

benchmark "Load utils.zsh" \
    "source '$REPO_ROOT/bin/lib/utils.zsh'" 1

if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
    format_result "Library loading (3 libs)"
fi

# ============================================================================
# Benchmark 2: OS Detection
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    draw_section_header "2. OS Detection Performance"
fi

benchmark "get_os function" \
    "get_os" \
    "$ITERATIONS"

benchmark "uname -s call" \
    "uname -s" \
    "$ITERATIONS"

if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
    format_result "get_os function"
    format_result "uname -s call"
fi

# ============================================================================
# Benchmark 3: File Operations
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    draw_section_header "3. File Operations Performance"
fi

TEST_DIR="/tmp/benchmark_$$"
mkdir -p "$TEST_DIR"

benchmark "File creation (touch)" \
    "touch '$TEST_DIR/test_\$RANDOM'" \
    "$ITERATIONS"

benchmark "File existence check" \
    "[[ -f '$TEST_DIR/test_*' ]]" \
    "$ITERATIONS"

benchmark "Directory creation" \
    "mkdir -p '$TEST_DIR/subdir_\$RANDOM'" \
    "$ITERATIONS"

benchmark "Symlink creation" \
    "ln -sf '$TEST_DIR/test_1' '$TEST_DIR/link_\$RANDOM'" \
    "$ITERATIONS"

if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
    format_result "File creation (touch)"
    format_result "File existence check"
    format_result "Directory creation"
    format_result "Symlink creation"
fi

# Cleanup
rm -rf "$TEST_DIR"

# ============================================================================
# Benchmark 4: String Operations
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    draw_section_header "4. String Operations Performance"
fi

benchmark "String concatenation" \
    'local str="hello"; str="${str}_world"' \
    "$ITERATIONS"

benchmark "String length calculation" \
    'local str="hello_world"; local len=${#str}' \
    "$ITERATIONS"

benchmark "String substitution" \
    'local str="hello_world"; str="${str/world/universe}"' \
    "$ITERATIONS"

benchmark "Regex matching" \
    '[[ "hello_world" =~ ^hello ]]' \
    "$ITERATIONS"

if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
    format_result "String concatenation"
    format_result "String length calculation"
    format_result "String substitution"
    format_result "Regex matching"
fi

# ============================================================================
# Benchmark 5: Array Operations
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    draw_section_header "5. Array Operations Performance"
fi

benchmark "Array creation" \
    'local arr=(1 2 3 4 5)' \
    "$ITERATIONS"

benchmark "Array append" \
    'local arr=(1 2 3); arr+=(4)' \
    "$ITERATIONS"

benchmark "Array iteration" \
    'local arr=(1 2 3 4 5); for item in "${arr[@]}"; do :; done' \
    "$ITERATIONS"

benchmark "Array size check" \
    'local arr=(1 2 3 4 5); local size=${#arr[@]}' \
    "$ITERATIONS"

if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
    format_result "Array creation"
    format_result "Array append"
    format_result "Array iteration"
    format_result "Array size check"
fi

# ============================================================================
# Benchmark 6: Function Calls
# ============================================================================

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    draw_section_header "6. Function Call Performance"
fi

# Simple function
simple_func() { return 0; }
benchmark "Simple function call" \
    "simple_func" \
    "$ITERATIONS"

# Function with parameters
param_func() { local a=$1; local b=$2; return 0; }
benchmark "Function with params" \
    "param_func hello world" \
    "$ITERATIONS"

# Command substitution
benchmark "Command substitution" \
    'local result=$(echo "test")' \
    "$ITERATIONS"

if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
    format_result "Simple function call"
    format_result "Function with params"
    format_result "Command substitution"
fi

# ============================================================================
# Benchmark 7: UI Operations (if not quick mode)
# ============================================================================

if [[ "$QUICK_MODE" == "false" ]]; then
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo ""
        draw_section_header "7. UI Operations Performance"
    fi

    benchmark "print_success call" \
        "print_success 'test'" \
        "$ITERATIONS"

    benchmark "print_error call" \
        "print_error 'test'" \
        "$ITERATIONS"

    benchmark "print_info call" \
        "print_info 'test'" \
        "$ITERATIONS"

    if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
        format_result "print_success call"
        format_result "print_error call"
        format_result "print_info call"
    fi
fi

# ============================================================================
# Benchmark 8: Test Execution (if not quick mode)
# ============================================================================

if [[ "$QUICK_MODE" == "false" ]] && [[ -x "$REPO_ROOT/tests/run_tests.zsh" ]]; then
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo ""
        draw_section_header "8. Test Execution Performance"
    fi

    # Benchmark full test suite
    start=$(date +%s%N)
    "$REPO_ROOT/tests/run_tests.zsh" >/dev/null 2>&1
    end=$(date +%s%N)
    test_time=$(( (end - start) / 1000000 ))
    RESULTS["Full test suite execution"]="$test_time"

    if [[ "$VERBOSE" == "false" ]] && [[ "$JSON_OUTPUT" == "false" ]]; then
        format_result "Full test suite execution"
    fi
fi

# ============================================================================
# Output Results
# ============================================================================

if [[ "$JSON_OUTPUT" == "true" ]]; then
    # JSON output
    echo "{"
    echo '  "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",'
    echo '  "iterations": '$ITERATIONS','
    echo '  "results": {'

    local count=0
    local total=${#RESULTS[@]}

    for key in ${(k)RESULTS}; do
        count=$((count + 1))
        printf '    "%s": %d' "$key" "${RESULTS[$key]}"
        if [[ $count -lt $total ]]; then
            echo ","
        else
            echo ""
        fi
    done

    echo "  }"
    echo "}"
else
    # Summary
    echo ""
    draw_section_header "Benchmark Summary"

    # Calculate total time
    local total_time=0
    for value in ${(v)RESULTS}; do
        total_time=$((total_time + value))
    done

    print_info "Benchmarks completed:"
    echo "   Total operations: ${#RESULTS[@]}"
    echo "   Total time: ${total_time} ms"
    echo ""

    print_success "Performance benchmark complete!"
    echo ""

    print_info "💡 Tips for improving performance:"
    echo "   • Keep library loading under 50ms"
    echo "   • Minimize file operations in hot paths"
    echo "   • Use built-in string operations over external commands"
    echo "   • Cache expensive operations"
    echo "   • Profile scripts with: time ./your-script.zsh"
fi
