#!/usr/bin/env bash

# ============================================================================
# Rust Playground (rustp)
# ============================================================================
#
# Create a temporary Rust playground with automatic recompilation using
# cargo-watch. Perfect for quick experiments and testing Rust code.
#
# Features:
#   - Creates temporary cargo project in /tmp
#   - Opens editor in one tmux pane
#   - Runs cargo watch in another pane for automatic recompilation
#   - Automatically adds specified crates as dependencies
#   - Works both inside and outside tmux
#
# Usage:
#   rustp [crate1] [crate2] ...
#
# Examples:
#   rustp                    # Empty playground
#   rustp serde tokio        # Playground with serde and tokio
#   rustp clap rand          # Playground with clap and rand
#
# Requirements:
#   - cargo (Rust toolchain)
#   - tmux (terminal multiplexer)
#   - cargo-watch (install with: cargo install cargo-watch)
#
# ============================================================================

set -e

# ============================================================================
# Colors (simple fallback-safe)
# ============================================================================

if [[ -t 1 ]]; then
    RED='\033[38;2;224;108;117m'
    GREEN='\033[38;2;152;195;121m'
    BLUE='\033[38;2;97;175;239m'
    YELLOW='\033[38;2;229;192;123m'
    PURPLE='\033[38;2;198;120;221m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' BLUE='' YELLOW='' PURPLE='' BOLD='' RESET=''
fi

# ============================================================================
# Helper Functions
# ============================================================================

print_error() {
    echo -e "${RED}❌ Error: $1${RESET}" >&2
}

print_success() {
    echo -e "${GREEN}✅ $1${RESET}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${RESET}"
}

check_dependency() {
    local cmd="$1"
    local install_hint="$2"

    if ! command -v "$cmd" &> /dev/null; then
        print_error "'$cmd' not found"
        [[ -n "$install_hint" ]] && echo -e "   ${BLUE}Install with: ${RESET}$install_hint"
        return 1
    fi
    return 0
}

show_help() {
    cat <<EOF
${BOLD}${PURPLE}Rust Playground (rustp)${RESET}

Create a temporary Rust playground with automatic recompilation.
Perfect for quick experiments and testing Rust code.

${BOLD}${PURPLE}USAGE${RESET}
    rustp [OPTIONS] [crate1] [crate2] ...

${BOLD}${PURPLE}OPTIONS${RESET}
    -h, --help          Show this help message

${BOLD}${PURPLE}ARGUMENTS${RESET}
    crate1, crate2...   Crates to add as dependencies (optional)

${BOLD}${PURPLE}EXAMPLES${RESET}
    ${BLUE}# Create empty playground${RESET}
    rustp

    ${BLUE}# Playground with serde and tokio${RESET}
    rustp serde tokio

    ${BLUE}# Playground with clap and rand${RESET}
    rustp clap rand

${BOLD}${PURPLE}HOW IT WORKS${RESET}
    1. Creates temporary cargo project in /tmp
    2. Opens your \$EDITOR (default: nvim) in one tmux pane
    3. Runs 'cargo watch' in another pane for auto-recompilation
    4. Each save triggers automatic rebuild and run

${BOLD}${PURPLE}TMUX LAYOUT${RESET}
    ┌─────────────────────────┬─────────────────────────┐
    │                         │                         │
    │    Editor (nvim)        │   cargo watch -s        │
    │    src/main.rs          │   'clear && cargo       │
    │                         │    run -q'              │
    │                         │                         │
    └─────────────────────────┴─────────────────────────┘

${BOLD}${PURPLE}REQUIREMENTS${RESET}
    • cargo          (Rust toolchain)
    • tmux           (Terminal multiplexer)
    • cargo-watch    (Auto-recompilation)
    • \$EDITOR        (Text editor, default: nvim)

${BOLD}${PURPLE}INSTALLATION${RESET}
    ${BLUE}# Install Rust${RESET}
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    ${BLUE}# Install cargo-watch${RESET}
    cargo install cargo-watch

    ${BLUE}# Install tmux (macOS)${RESET}
    brew install tmux

    ${BLUE}# Install tmux (Ubuntu/Debian)${RESET}
    sudo apt install tmux

${BOLD}${PURPLE}TIPS${RESET}
    • Use Ctrl+B then arrow keys to switch between panes
    • Press Ctrl+B then 'd' to detach from tmux session
    • The playground auto-deletes when tmux session ends
    • All crates are added with latest version ("*")

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
    esac
done

# ============================================================================
# Dependency Checks
# ============================================================================

print_info "Checking dependencies..."

check_dependency "cargo" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" || exit 1
check_dependency "mktemp" "" || exit 1
check_dependency "sed" "" || exit 1
check_dependency "tmux" "brew install tmux  # macOS   OR   sudo apt install tmux  # Linux" || exit 1

if ! command -v cargo-watch &> /dev/null; then
    print_warning "cargo-watch not found (recommended for auto-recompilation)"
    print_info "Install with: ${BOLD}cargo install cargo-watch${RESET}"
    echo
    read -p "Continue without cargo-watch? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi
fi

print_success "All dependencies available"
echo

# ============================================================================
# Create Playground
# ============================================================================

# Editor preference
editor=${EDITOR:-nvim}

print_info "Creating Rust playground..."

# Create temporary directory
root_dir="$(mktemp --directory --tmpdir rustp-XXXXXX)/playground"
mkdir -p "$root_dir"

print_info "Location: ${BOLD}$root_dir${RESET}"

# Initialize cargo project
cargo init "$root_dir" --quiet

cd "$root_dir"

# Add crate dependencies
if [[ $# -gt 0 ]]; then
    print_info "Adding crates: ${BOLD}$*${RESET}"
    for crate in "$@"; do
        sed "/^\[dependencies\]/a $crate = \"*\"" -i Cargo.toml
        print_success "Added $crate"
    done
    echo
fi

# ============================================================================
# Launch tmux playground
# ============================================================================

print_success "Launching Rust playground in tmux!"
print_info "Edit code in left pane, see output in right pane"
print_info "Press ${BOLD}Ctrl+B then 'd'${RESET} to detach from session"
echo

# Give user a moment to read the messages
sleep 1

# Launch tmux with split panes
if [ -n "$TMUX" ]; then
    # Already in tmux - create new window
    tmux new-window \; \
        send-keys "$editor ./src/main.rs" C-m \; \
        split-window -h \; \
        send-keys "cargo watch -s 'clear && cargo run -q'" C-m \; \
        select-pane -L
else
    # Not in tmux - create new session
    tmux new-session \; \
        send-keys "$editor ./src/main.rs" C-m \; \
        split-window -h \; \
        send-keys "cargo watch -s 'clear && cargo run -q'" C-m \; \
        select-pane -L
fi
