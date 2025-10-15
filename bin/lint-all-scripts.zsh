#!/usr/bin/env zsh

# ============================================================================
# Lint All Scripts
# ============================================================================
#
# Runs shellcheck and shfmt on all shell scripts in the repository.
# Generates a comprehensive linting report.
#
# Usage:
#   ./bin/lint-all-scripts.zsh [--fix] [--verbose]
#
# Options:
#   --fix       Automatically fix formatting issues with shfmt
#   --verbose   Show detailed output for each file
#   --help, -h  Show this help message
# ============================================================================

emulate -LR zsh
setopt PIPE_FAIL

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Load shared libraries
source "$REPO_ROOT/bin/lib/colors.zsh" 2>/dev/null || {
    # Fallback colors if library not available
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
}
source "$REPO_ROOT/bin/lib/ui.zsh" 2>/dev/null || {
    # Fallback functions
    print_success() { echo "${GREEN}✓${NC} $1"; }
    print_error() { echo "${RED}✗${NC} $1"; }
    print_warning() { echo "${YELLOW}⚠${NC} $1"; }
    print_info() { echo "${BLUE}ℹ${NC} $1"; }
    draw_header() { echo; echo "${BLUE}$1${NC}"; echo; }
}

# Configuration
FIX_MODE=false
VERBOSE=false

# Counters
TOTAL_FILES=0
SHELLCHECK_PASS=0
SHELLCHECK_FAIL=0
SHELLCHECK_SKIP=0
SHFMT_PASS=0
SHFMT_FAIL=0
SHFMT_SKIP=0

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --fix)
            FIX_MODE=true
            ;;
        --verbose|-v)
            VERBOSE=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Lint all shell scripts with shellcheck and shfmt.

OPTIONS:
  --fix       Automatically fix formatting issues
  --verbose   Show detailed output
  --help, -h  Show this help message

EXAMPLES:
  $(basename "$0")              # Check all scripts
  $(basename "$0") --fix        # Check and auto-fix formatting
  $(basename "$0") --verbose    # Show detailed output

REQUIREMENTS:
  shellcheck - Install with: brew install shellcheck (macOS)
  shfmt      - Install with: brew install shfmt (macOS)

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
# Tool Detection
# ============================================================================

SHELLCHECK_AVAILABLE=false
SHFMT_AVAILABLE=false

if command -v shellcheck >/dev/null 2>&1; then
    SHELLCHECK_AVAILABLE=true
else
    print_warning "shellcheck not found - skipping shellcheck linting"
    print_info "Install with: brew install shellcheck (macOS) or apt install shellcheck (Linux)"
    echo ""
fi

if command -v shfmt >/dev/null 2>&1; then
    SHFMT_AVAILABLE=true
else
    print_warning "shfmt not found - skipping formatting checks"
    print_info "Install with: brew install shfmt (macOS) or go install mvdan.cc/sh/v3/cmd/shfmt@latest"
    echo ""
fi

if [[ "$SHELLCHECK_AVAILABLE" == "false" ]] && [[ "$SHFMT_AVAILABLE" == "false" ]]; then
    print_error "Neither shellcheck nor shfmt are available"
    print_info "Install at least one linting tool to continue"
    exit 1
fi

# ============================================================================
# Find All Shell Scripts
# ============================================================================

draw_header "Discovering Shell Scripts"

# Find all .zsh, .sh, .bash files and scripts without extension
SCRIPT_FILES=()

# Find in bin/
while IFS= read -r file; do
    SCRIPT_FILES+=("$file")
done < <(find "$REPO_ROOT/bin" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.bash" \) 2>/dev/null)

# Find in bin/lib/
while IFS= read -r file; do
    SCRIPT_FILES+=("$file")
done < <(find "$REPO_ROOT/bin/lib" -type f \( -name "*.zsh" -o -name "*.sh" \) 2>/dev/null)

# Find in post-install/scripts/
while IFS= read -r file; do
    SCRIPT_FILES+=("$file")
done < <(find "$REPO_ROOT/post-install/scripts" -type f -name "*.zsh" 2>/dev/null)

# Find in tests/
while IFS= read -r file; do
    SCRIPT_FILES+=("$file")
done < <(find "$REPO_ROOT/tests" -type f -name "*.zsh" 2>/dev/null)

# Find wrapper scripts (setup, update, backup)
for wrapper in setup update backup; do
    if [[ -f "$REPO_ROOT/$wrapper" ]]; then
        SCRIPT_FILES+=("$REPO_ROOT/$wrapper")
    fi
done

TOTAL_FILES=${#SCRIPT_FILES[@]}

print_info "Found $TOTAL_FILES shell script(s) to lint"
echo ""

# ============================================================================
# Shellcheck Linting
# ============================================================================

if [[ "$SHELLCHECK_AVAILABLE" == "true" ]]; then
    draw_header "Shellcheck Linting"

    for file in "${SCRIPT_FILES[@]}"; do
        relative_path="${file#$REPO_ROOT/}"

        # Determine shell type from shebang
        shebang=$(head -1 "$file" 2>/dev/null)
        shell_type="bash"  # Default

        if [[ "$shebang" =~ zsh ]]; then
            shell_type="bash"  # Shellcheck doesn't fully support zsh, use bash dialect
        elif [[ "$shebang" =~ bash ]]; then
            shell_type="bash"
        elif [[ "$shebang" =~ sh ]]; then
            shell_type="sh"
        fi

        if [[ "$VERBOSE" == "true" ]]; then
            echo "Checking: $relative_path"
        fi

        # Run shellcheck with appropriate exclusions
        if shellcheck -s "$shell_type" \
            -e SC1090 \
            -e SC1091 \
            -e SC2034 \
            -e SC2154 \
            "$file" 2>&1 | grep -v "^$"; then

            SHELLCHECK_FAIL=$((SHELLCHECK_FAIL + 1))
            if [[ "$VERBOSE" == "false" ]]; then
                print_error "$relative_path"
            fi
        else
            SHELLCHECK_PASS=$((SHELLCHECK_PASS + 1))
            if [[ "$VERBOSE" == "true" ]]; then
                print_success "$relative_path"
            fi
        fi
    done

    echo ""
    print_info "Shellcheck Results:"
    echo "   Passed: $SHELLCHECK_PASS"
    echo "   Failed: $SHELLCHECK_FAIL"
    echo ""
else
    SHELLCHECK_SKIP=$TOTAL_FILES
fi

# ============================================================================
# shfmt Formatting
# ============================================================================

if [[ "$SHFMT_AVAILABLE" == "true" ]]; then
    if [[ "$FIX_MODE" == "true" ]]; then
        draw_header "Fixing Formatting with shfmt"
    else
        draw_header "Checking Formatting with shfmt"
    fi

    for file in "${SCRIPT_FILES[@]}"; do
        relative_path="${file#$REPO_ROOT/}"

        if [[ "$VERBOSE" == "true" ]]; then
            echo "Checking: $relative_path"
        fi

        if [[ "$FIX_MODE" == "true" ]]; then
            # Fix formatting
            if shfmt -w -i 2 -ci "$file" >/dev/null 2>&1; then
                SHFMT_PASS=$((SHFMT_PASS + 1))
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "$relative_path (fixed)"
                fi
            else
                SHFMT_FAIL=$((SHFMT_FAIL + 1))
                if [[ "$VERBOSE" == "false" ]]; then
                    print_warning "$relative_path (could not fix)"
                fi
            fi
        else
            # Check formatting
            if shfmt -d -i 2 -ci "$file" >/dev/null 2>&1; then
                SHFMT_PASS=$((SHFMT_PASS + 1))
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "$relative_path"
                fi
            else
                SHFMT_FAIL=$((SHFMT_FAIL + 1))
                if [[ "$VERBOSE" == "false" ]]; then
                    print_warning "$relative_path (needs formatting)"
                fi
            fi
        fi
    done

    echo ""
    if [[ "$FIX_MODE" == "true" ]]; then
        print_info "shfmt Fix Results:"
        echo "   Fixed:      $SHFMT_PASS"
        echo "   Could not fix: $SHFMT_FAIL"
    else
        print_info "shfmt Check Results:"
        echo "   Formatted:  $SHFMT_PASS"
        echo "   Needs work: $SHFMT_FAIL"
    fi
    echo ""
else
    SHFMT_SKIP=$TOTAL_FILES
fi

# ============================================================================
# Summary
# ============================================================================

draw_header "Linting Summary"

echo "Total Files: $TOTAL_FILES"
echo ""

if [[ "$SHELLCHECK_AVAILABLE" == "true" ]]; then
    echo "Shellcheck:"
    echo "   ✓ Passed: $SHELLCHECK_PASS"
    if [[ $SHELLCHECK_FAIL -gt 0 ]]; then
        echo "   ✗ Failed: $SHELLCHECK_FAIL"
    fi
else
    echo "Shellcheck: Skipped (not installed)"
fi

echo ""

if [[ "$SHFMT_AVAILABLE" == "true" ]]; then
    echo "shfmt:"
    echo "   ✓ Pass: $SHFMT_PASS"
    if [[ $SHFMT_FAIL -gt 0 ]]; then
        echo "   ⚠ Needs attention: $SHFMT_FAIL"
    fi
else
    echo "shfmt: Skipped (not installed)"
fi

echo ""

# Exit with appropriate code
if [[ $SHELLCHECK_FAIL -gt 0 ]] || [[ $SHFMT_FAIL -gt 0 ]]; then
    print_warning "Some files need attention"
    if [[ "$FIX_MODE" == "false" ]] && [[ $SHFMT_FAIL -gt 0 ]]; then
        print_info "Run with --fix to automatically fix formatting issues"
    fi
    exit 1
else
    print_success "All linting checks passed!"
    exit 0
fi
