#!/bin/sh

# ============================================================================
# iPerl - Interactive Perl REPL
# ============================================================================
#
# A simple, delightful Perl REPL (Read-Eval-Print Loop) using rlwrap
# for readline support and history.
#
# Usage:
#   iperl              # Start interactive Perl session
#   iperl --help       # Show help message
#
# Requirements:
#   - perl (Perl interpreter)
#   - rlwrap (readline wrapper)
#
# ============================================================================

# ============================================================================
# Colors (POSIX-compatible)
# ============================================================================

if [ -t 1 ]; then
    BLUE='\033[38;2;97;175;239m'
    PURPLE='\033[38;2;198;120;221m'
    GREEN='\033[38;2;152;195;121m'
    RED='\033[38;2;224;108;117m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    BLUE='' PURPLE='' GREEN='' RED='' BOLD='' RESET=''
fi

# ============================================================================
# Help Function
# ============================================================================

show_help() {
    cat <<EOF
${BOLD}${PURPLE}iPerl - Interactive Perl REPL${RESET}

A simple, delightful Perl REPL with readline support and history.

${BOLD}${PURPLE}USAGE${RESET}
    iperl [OPTIONS]

${BOLD}${PURPLE}OPTIONS${RESET}
    -h, --help          Show this help message

${BOLD}${PURPLE}EXAMPLES${RESET}
    ${BLUE}# Start interactive Perl session${RESET}
    iperl

    ${BLUE}# Try some Perl expressions${RESET}
    perl> 2 + 2
    4
    perl> "Hello, " . "World!"
    Hello, World!
    perl> [1..10]
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

${BOLD}${PURPLE}FEATURES${RESET}
    • Readline support (arrow keys, history)
    • Command history with Up/Down arrows
    • Automatic expression evaluation
    • Pretty-printed output

${BOLD}${PURPLE}REQUIREMENTS${RESET}
    • perl       (Perl interpreter)
    • rlwrap     (Readline wrapper)

${BOLD}${PURPLE}INSTALLATION${RESET}
    ${BLUE}# Install rlwrap (macOS)${RESET}
    brew install rlwrap

    ${BLUE}# Install rlwrap (Ubuntu/Debian)${RESET}
    sudo apt install rlwrap

${BOLD}${PURPLE}TIPS${RESET}
    • Use Ctrl+D or type 'exit' to quit
    • Use Up/Down arrows for command history
    • All Perl expressions are automatically evaluated

EOF
    exit 0
}

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            ;;
        *)
            printf "${RED}Error: Unknown option: %s${RESET}\n" "$arg" >&2
            printf "${BLUE}Use 'iperl --help' for usage information${RESET}\n" >&2
            exit 1
            ;;
    esac
done

# ============================================================================
# Dependency Checks
# ============================================================================

if ! command -v perl >/dev/null 2>&1; then
    printf "${RED}❌ Error: 'perl' not found${RESET}\n" >&2
    printf "${BLUE}   Install Perl to use this REPL${RESET}\n" >&2
    exit 1
fi

if ! command -v rlwrap >/dev/null 2>&1; then
    printf "${RED}❌ Error: 'rlwrap' not found${RESET}\n" >&2
    printf "${BLUE}   Install with: brew install rlwrap  # macOS${RESET}\n" >&2
    printf "${BLUE}   Install with: sudo apt install rlwrap  # Linux${RESET}\n" >&2
    exit 1
fi

# ============================================================================
# Launch Perl REPL
# ============================================================================

printf "${BOLD}${PURPLE}Welcome to iPerl 🐫${RESET}\n"
printf "${BLUE}Type Perl expressions and press Enter to evaluate${RESET}\n"
printf "${BLUE}Use Ctrl+D to exit${RESET}\n\n"

rlwrap -A -pblue -S"perl> " perl -wnE'say eval()//$@'
