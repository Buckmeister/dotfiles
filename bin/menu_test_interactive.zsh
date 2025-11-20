#!/usr/bin/env zsh
# ============================================================================
# Interactive TUI Menu Testing Framework
# ============================================================================
#
# Runs menu systems in tmux sessions, injects keystrokes, and captures
# terminal states for automated testing and debugging of TUI applications.
#
# Usage:
#   menu_test_interactive.zsh [options]
#   menu_test_interactive.zsh --menu ./bin/menu_hierarchical.zsh --keys "j j k ENTER"
#   menu_test_interactive.zsh --help
#
# Features:
#   - Runs menu in isolated tmux session
#   - Injects keystroke sequences
#   - Captures terminal state at each step
#   - Provides text-based analysis
#   - Optional screenshot generation
#   - Debug trace integration
#
# Options:
#   --menu PATH         Menu script to test (default: ./bin/menu_hierarchical.zsh)
#   --keys SEQUENCE     Space-separated keystroke sequence (default: "j j k")
#   --name NAME         Test name for output files (default: menu_test)
#   --width COLS        Terminal width (default: 80)
#   --height ROWS       Terminal height (default: 24)
#   --delay MS          Delay between keystrokes in ms (default: 300)
#   --keep-session      Keep tmux session after test (for debugging)
#   --screenshot        Generate screenshots at each step
#   --debug             Enable debug mode in menu
#   --output-dir DIR    Output directory for captures (default: /tmp/menu_test_*)
#   --help              Show this help message
#
# Keystroke Syntax:
#   j, k, h, l          Navigation keys
#   ENTER               Enter/Select
#   ESC                 Escape
#   SPACE               Space bar
#   q                   Quit
#   Any letter/number   Literal keystroke
#
# Output:
#   Creates directory with captured states:
#     00_initial.txt         - Initial menu state
#     01_after_j.txt         - After first keystroke
#     02_after_j.txt         - After second keystroke
#     ...
#     analysis.txt           - State analysis report
#     screenshots/ (optional) - Visual captures
#
# Examples:
#   # Basic navigation test
#   menu_test_interactive.zsh --keys "j j k j"
#
#   # Test submenu navigation
#   menu_test_interactive.zsh --keys "j ENTER j ESC"
#
#   # Debug mode with screenshots
#   menu_test_interactive.zsh --debug --screenshot --keys "j j j"
#
#   # Keep session for manual inspection
#   menu_test_interactive.zsh --keep-session --keys "j k"
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Setup and Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Try to load shared libraries
if [[ -f "$DF_DIR/bin/lib/colors.zsh" ]]; then
    source "$DF_DIR/bin/lib/colors.zsh"
    source "$DF_DIR/bin/lib/ui.zsh"
else
    # Minimal fallback
    COLOR_RESET='\033[0m'
    COLOR_BOLD='\033[1m'
    COLOR_CYAN='\033[36m'
    COLOR_GREEN='\033[32m'
    COLOR_YELLOW='\033[33m'
    COLOR_RED='\033[31m'

    function print_success() { echo "${COLOR_GREEN}✓${COLOR_RESET} $1"; }
    function print_error() { echo "${COLOR_RED}✗${COLOR_RESET} $1" >&2; }
    function print_info() { echo "${COLOR_CYAN}ℹ${COLOR_RESET} $1"; }
fi

# Default configuration
MENU_SCRIPT="./bin/menu_hierarchical.zsh"
KEYSTROKE_SEQUENCE="j j k"
TEST_NAME="menu_test"
TERMINAL_WIDTH=80
TERMINAL_HEIGHT=24
KEYSTROKE_DELAY=300  # milliseconds
KEEP_SESSION=false
GENERATE_SCREENSHOTS=false
DEBUG_MODE=false
OUTPUT_DIR=""

# ============================================================================
# Help and Argument Parsing
# ============================================================================

show_help() {
    cat << EOF
${COLOR_BOLD}${COLOR_CYAN}Interactive TUI Menu Testing Framework${COLOR_RESET}

Automated testing for terminal user interfaces using tmux and keystroke injection.

${COLOR_BOLD}Usage:${COLOR_RESET}
  menu_test_interactive.zsh [options]

${COLOR_BOLD}Options:${COLOR_RESET}
  --menu PATH         Menu script to test (default: ./bin/menu_hierarchical.zsh)
  --keys SEQUENCE     Space-separated keystroke sequence (default: "j j k")
  --name NAME         Test name for output files (default: menu_test)
  --width COLS        Terminal width (default: 80)
  --height ROWS       Terminal height (default: 24)
  --delay MS          Delay between keystrokes in ms (default: 300)
  --keep-session      Keep tmux session after test (for debugging)
  --screenshot        Generate screenshots at each step
  --debug             Enable debug mode in menu
  --output-dir DIR    Output directory for captures (default: /tmp/menu_test_*)
  --help              Show this help message

${COLOR_BOLD}Keystroke Syntax:${COLOR_RESET}
  j, k, h, l          Navigation keys
  ENTER               Enter/Select
  ESC                 Escape
  SPACE               Space bar
  q                   Quit
  a                   Select all (multi-select)
  Any other char      Literal keystroke

${COLOR_BOLD}Examples:${COLOR_RESET}
  ${COLOR_CYAN}# Basic navigation test${COLOR_RESET}
  menu_test_interactive.zsh --keys "j j k j"

  ${COLOR_CYAN}# Test submenu entry and exit${COLOR_RESET}
  menu_test_interactive.zsh --keys "j ENTER j ESC"

  ${COLOR_CYAN}# Debug with screenshots${COLOR_RESET}
  menu_test_interactive.zsh --debug --screenshot --keys "j j j"

  ${COLOR_CYAN}# Keep session for manual inspection${COLOR_RESET}
  menu_test_interactive.zsh --keep-session --keys "j k"

${COLOR_BOLD}Output Structure:${COLOR_RESET}
  /tmp/menu_test_<timestamp>/
    00_initial.txt              - Initial menu state
    01_after_j.txt              - After first keystroke
    02_after_j.txt              - After second keystroke
    ...
    analysis.txt                - State analysis report
    debug.log (if --debug)      - Debug trace from menu
    screenshots/ (if --screenshot) - Visual captures

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --menu)
            MENU_SCRIPT="$2"
            shift 2
            ;;
        --keys)
            KEYSTROKE_SEQUENCE="$2"
            shift 2
            ;;
        --name)
            TEST_NAME="$2"
            shift 2
            ;;
        --width)
            TERMINAL_WIDTH="$2"
            shift 2
            ;;
        --height)
            TERMINAL_HEIGHT="$2"
            shift 2
            ;;
        --delay)
            KEYSTROKE_DELAY="$2"
            shift 2
            ;;
        --keep-session)
            KEEP_SESSION=true
            shift
            ;;
        --screenshot)
            GENERATE_SCREENSHOTS=true
            shift
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Validation
# ============================================================================

# Check if menu script exists
if [[ ! -f "$MENU_SCRIPT" ]]; then
    print_error "Menu script not found: $MENU_SCRIPT"
    exit 1
fi

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    print_error "tmux is not installed"
    echo "Install with: brew install tmux  (macOS)"
    echo "         or: sudo apt install tmux  (Linux)"
    exit 1
fi

# ============================================================================
# Core Functions
# ============================================================================

# Send keystroke to tmux session
send_keystroke() {
    local session="$1"
    local key="$2"

    case "$key" in
        ENTER)
            tmux send-keys -t "$session" C-m
            ;;
        ESC)
            tmux send-keys -t "$session" Escape
            ;;
        SPACE)
            tmux send-keys -t "$session" Space
            ;;
        *)
            tmux send-keys -t "$session" "$key"
            ;;
    esac
}

# Capture terminal state
capture_state() {
    local session="$1"
    local output_file="$2"

    tmux capture-pane -t "$session" -p > "$output_file"
}

# Check for duplicate menu items
check_duplicates() {
    local capture_file="$1"

    # Extract menu item titles (lines with emoji icons followed by text)
    # Look for patterns like: "📦  Post-Install Scripts" or "🚪  Quit"
    local -a menu_titles=()
    while IFS= read -r line; do
        # Extract text after emoji/icon (skip cursor markers and emojis)
        if [[ "$line" =~ [📦👤🧙📋🔧🚪] ]]; then
            # Get the title part (first significant text after emoji)
            local title=$(echo "$line" | sed -E 's/.*[📦👤🧙📋🔧🚪][[:space:]]+([A-Za-z-]+).*/\1/')
            if [[ -n "$title" && "$title" != "$line" ]]; then
                menu_titles+=("$title")
            fi
        fi
    done < "$capture_file"

    # Check for duplicates
    local total_items=${#menu_titles[@]}
    local unique_items=$(printf '%s\n' "${menu_titles[@]}" | sort -u | wc -l | xargs)

    if [[ $total_items -gt $unique_items ]]; then
        echo "DUPLICATES_FOUND:$((total_items - unique_items))"
        return 1
    else
        echo "NO_DUPLICATES"
        return 0
    fi
}

# Analyze captured state
analyze_state() {
    local capture_file="$1"

    local line_count=$(wc -l < "$capture_file" | xargs)
    local cursor_lines=$(grep -n ">" "$capture_file" 2>/dev/null | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
    local menu_items=$(grep -c "│" "$capture_file" 2>/dev/null || echo "0")
    local duplicate_check=$(check_duplicates "$capture_file")

    if [[ -z "$cursor_lines" ]]; then
        cursor_lines="none"
    fi

    echo "lines:$line_count cursor_at:[$cursor_lines] menu_items:$menu_items duplicates:$duplicate_check"
}

# Generate screenshot (if silicon is available)
generate_screenshot() {
    local capture_file="$1"
    local output_image="$2"

    if ! command -v silicon &> /dev/null; then
        return 1
    fi

    silicon "$capture_file" \
        --output "$output_image" \
        --theme OneHalfDark \
        --font "Hack Nerd Font" \
        --no-window-controls \
        --shadow-color "#00000088" \
        --shadow-blur-radius 10 \
        --background "#282c34" \
        2>/dev/null

    return $?
}

# ============================================================================
# Main Test Execution
# ============================================================================

run_interactive_test() {
    # Setup output directory
    if [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR="/tmp/${TEST_NAME}_$(date +%Y%m%d_%H%M%S)"
    fi

    mkdir -p "$OUTPUT_DIR"

    if [[ "$GENERATE_SCREENSHOTS" == "true" ]]; then
        mkdir -p "$OUTPUT_DIR/screenshots"
    fi

    # Create unique tmux session
    local session="${TEST_NAME}_$$"

    # Get absolute path to menu script
    local menu_script_abs="$MENU_SCRIPT"
    if [[ "$menu_script_abs" == ./* ]]; then
        menu_script_abs="$DF_DIR/${menu_script_abs#./}"
    elif [[ ! "$menu_script_abs" == /* ]]; then
        menu_script_abs="$DF_DIR/$menu_script_abs"
    fi

    # Build the complete command to run in tmux
    local tmux_command="cd '$DF_DIR' && '$menu_script_abs'"

    # Start menu in tmux
    print_info "Starting tmux session: $session"
    print_info "Terminal size: ${TERMINAL_WIDTH}x${TERMINAL_HEIGHT}"
    print_info "Menu script: $menu_script_abs"

    # Build tmux command with optional environment variables
    local -a tmux_args=(
        new-session
        -d
        -s "$session"
        -x "$TERMINAL_WIDTH"
        -y "$TERMINAL_HEIGHT"
    )

    # Add environment variables if debug mode (tmux -e flag)
    if [[ "$DEBUG_MODE" == "true" ]]; then
        tmux_args+=(-e "MENU_DEBUG_MODE=true")
        tmux_args+=(-e "MENU_DEBUG_LOG=$OUTPUT_DIR/debug.log")
        print_info "Debug mode enabled: $OUTPUT_DIR/debug.log"
    fi

    tmux_args+=("$tmux_command")

    # Run tmux with all arguments
    tmux "${tmux_args[@]}" 2>/dev/null

    if [[ $? -ne 0 ]]; then
        print_error "Failed to create tmux session"
        exit 1
    fi

    # Wait for menu to initialize
    sleep 0.5

    # Capture initial state
    print_info "Capturing initial state..."
    capture_state "$session" "$OUTPUT_DIR/00_initial.txt"

    local analysis=$(analyze_state "$OUTPUT_DIR/00_initial.txt")
    echo "  $analysis"

    if [[ "$GENERATE_SCREENSHOTS" == "true" ]]; then
        generate_screenshot "$OUTPUT_DIR/00_initial.txt" \
            "$OUTPUT_DIR/screenshots/00_initial.png"
    fi

    # Execute keystroke sequence
    local step=1
    print_info "Executing keystroke sequence: $KEYSTROKE_SEQUENCE"

    for key in ${(s: :)KEYSTROKE_SEQUENCE}; do
        # Send keystroke
        echo -n "  Step $step: Sending '$key'... "
        send_keystroke "$session" "$key"

        # Wait for rendering
        sleep $(awk "BEGIN {print $KEYSTROKE_DELAY/1000}")

        # Capture state
        local step_padded=$(printf '%02d' $step)
        local capture_file="$OUTPUT_DIR/${step_padded}_after_${key}.txt"
        capture_state "$session" "$capture_file"

        # Analyze
        local analysis=$(analyze_state "$capture_file")
        echo "$analysis"

        # Screenshot if enabled
        if [[ "$GENERATE_SCREENSHOTS" == "true" ]]; then
            generate_screenshot "$capture_file" \
                "$OUTPUT_DIR/screenshots/${step_padded}_after_${key}.png"
        fi

        ((step++))
    done

    # Generate analysis report
    print_info "Generating analysis report..."
    {
        echo "============================================"
        echo "Interactive TUI Test Analysis"
        echo "============================================"
        echo ""
        echo "Test Name: $TEST_NAME"
        echo "Menu Script: $MENU_SCRIPT"
        echo "Keystroke Sequence: $KEYSTROKE_SEQUENCE"
        echo "Terminal Size: ${TERMINAL_WIDTH}x${TERMINAL_HEIGHT}"
        echo "Debug Mode: $DEBUG_MODE"
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "============================================"
        echo "State Progression"
        echo "============================================"
        echo ""

        for capture in "$OUTPUT_DIR"/*.txt; do
            [[ "$capture" == */analysis.txt ]] && continue

            local filename=$(basename "$capture")
            echo "--- $filename ---"
            analyze_state "$capture"
            echo ""
        done

        echo "============================================"
        echo "Line Count Stability Check"
        echo "============================================"
        echo ""

        local initial_lines=$(wc -l < "$OUTPUT_DIR/00_initial.txt" | xargs)
        echo "Initial line count: $initial_lines"

        local stable=true
        for capture in "$OUTPUT_DIR"/[0-9]*.txt; do
            local current_lines=$(wc -l < "$capture" | xargs)
            local filename=$(basename "$capture")

            if [[ $current_lines -ne $initial_lines ]]; then
                echo "⚠️  $filename: $current_lines lines (CHANGED from $initial_lines)"
                stable=false
            else
                echo "✓  $filename: $current_lines lines (stable)"
            fi
        done

        echo ""
        if [[ "$stable" == "true" ]]; then
            echo "✅ Line count STABLE throughout test"
        else
            echo "❌ Line count UNSTABLE - regression detected"
        fi

        echo ""
        echo "============================================"
        echo "Duplicate Menu Items Check"
        echo "============================================"
        echo ""

        local duplicates_found=false
        for capture in "$OUTPUT_DIR"/[0-9]*.txt; do
            local filename=$(basename "$capture")
            local dup_result=$(check_duplicates "$capture")

            if [[ "$dup_result" == NO_DUPLICATES ]]; then
                echo "✓  $filename: No duplicates"
            else
                echo "⚠️  $filename: $dup_result"
                duplicates_found=true
            fi
        done

        echo ""
        if [[ "$duplicates_found" == "false" ]]; then
            echo "✅ NO DUPLICATES detected throughout test"
        else
            echo "❌ DUPLICATE ITEMS DETECTED - menu rendering bug!"
        fi

    } > "$OUTPUT_DIR/analysis.txt"

    # Show analysis
    cat "$OUTPUT_DIR/analysis.txt"

    # Clean up or keep session
    if [[ "$KEEP_SESSION" == "true" ]]; then
        print_info "Session kept for inspection: tmux attach -t $session"
        echo "  To kill session: tmux kill-session -t $session"
    else
        tmux kill-session -t "$session" 2>/dev/null
        print_success "Session cleaned up"
    fi

    # Summary
    echo ""
    print_success "Test complete!"
    echo ""
    echo "${COLOR_BOLD}Output directory:${COLOR_RESET} $OUTPUT_DIR"
    echo "  - Captured states: $(ls -1 "$OUTPUT_DIR"/*.txt 2>/dev/null | wc -l | xargs) files"

    if [[ "$GENERATE_SCREENSHOTS" == "true" ]]; then
        echo "  - Screenshots: $(ls -1 "$OUTPUT_DIR"/screenshots/*.png 2>/dev/null | wc -l | xargs) files"
    fi

    if [[ "$DEBUG_MODE" == "true" && -f "$OUTPUT_DIR/debug.log" ]]; then
        echo "  - Debug log: $(wc -l < "$OUTPUT_DIR/debug.log" | xargs) lines"
    fi

    echo ""
    echo "${COLOR_CYAN}View analysis:${COLOR_RESET} cat $OUTPUT_DIR/analysis.txt"

    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "${COLOR_CYAN}View debug log:${COLOR_RESET} cat $OUTPUT_DIR/debug.log"
    fi
}

# ============================================================================
# Execute
# ============================================================================

run_interactive_test
