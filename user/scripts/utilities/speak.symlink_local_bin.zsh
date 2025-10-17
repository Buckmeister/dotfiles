#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# speak - Text-to-Speech Utility for macOS
# ============================================================================
#
# A delightful wrapper around macOS's 'say' command that makes your dotfiles
# system speak to you! Perfect for status updates, celebrations, and making
# long-running tasks more engaging.
#
# Usage:
#   speak "Hello, friend!"
#   echo "Build complete!" | speak
#   speak -v Samantha "Welcome to your dotfiles"
#   speak --celebrate "All tests passing!"
#
# ============================================================================

# ============================================================================
# Library Loading (with graceful fallback)
# ============================================================================

# Resolve symlink to get actual script location
SCRIPT_PATH="${0:A}"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Determine DF_DIR from script location (user/scripts/utilities -> 3 levels up)
DF_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Try to load shared libraries
if [[ -f "$DF_DIR/bin/lib/colors.zsh" ]]; then
    source "$DF_DIR/bin/lib/colors.zsh" 2>/dev/null
    source "$DF_DIR/bin/lib/ui.zsh" 2>/dev/null
    source "$DF_DIR/bin/lib/utils.zsh" 2>/dev/null
    LIBRARIES_LOADED=true
    # Get OS from shared library
    DF_OS=$(get_os 2>/dev/null || echo "darwin")
else
    # Graceful fallback: define minimal functions if libraries unavailable
    LIBRARIES_LOADED=false
    print_error() { echo "Error: $1" >&2; }
    print_success() { echo "$1"; }
    print_info() { echo "$1"; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }
    # Detect OS manually in fallback mode
    DF_OS="$(uname | tr '[:upper:]' '[:lower:]')"
fi

# ============================================================================
# Configuration
# ============================================================================

# Premium voice preferences (Neural voices sound much more natural)
# Maps role -> preferred voices (in priority order)
typeset -A PREMIUM_VOICES
PREMIUM_VOICES[friendly]="Serena (Premium) Serena (Enhanced) Eddy (English (US)) Flo (English (US)) Samantha"
PREMIUM_VOICES[male]="Eddy (English (US)) Reed (English (US)) Alex"
PREMIUM_VOICES[female]="Serena (Premium) Serena (Enhanced) Flo (English (US)) Samantha Sandy (English (US))"
PREMIUM_VOICES[british]="Serena (Premium) Serena (Enhanced) Eddy (English (UK)) Daniel"

# Default voice (Serena Premium if available, otherwise fallback)
DEFAULT_VOICE="Serena (Premium)"

# Default speech rate (words per minute, 175 is natural)
DEFAULT_RATE="175"

# Check if running on macOS
if [[ "$DF_OS" != "darwin" && "$DF_OS" != "macos" ]]; then
    print_error "The 'say' command is only available on macOS"
    exit 1
fi

# Check if 'say' command exists
if ! command_exists say; then
    print_error "'say' command not found. Are you on macOS?"
    exit 1
fi

# ============================================================================
# Helper Functions
# ============================================================================

# Strip ANSI color codes and formatting
strip_ansi() {
    local text="$1"
    # Remove ANSI escape sequences
    echo "$text" | sed -E 's/\x1b\[[0-9;]*m//g' | sed -E 's/\x1b\[?[0-9;]*[a-zA-Z]//g'
}

# Select the best available voice from a preference list
# Args: space-separated list of voice names (in priority order)
# Returns: first available voice, or last fallback
select_best_voice() {
    local preferences="$1"
    local available_voices=$(say -v '?' 2>/dev/null)

    # Try each preferred voice in order
    for voice in ${=preferences}; do
        if echo "$available_voices" | grep -q "^${voice}"; then
            echo "$voice"
            return 0
        fi
    done

    # Return last voice as fallback
    echo "${preferences##* }"
}

# Show help message
show_help() {
    cat <<'EOF'
speak - Text-to-Speech Utility for macOS

A delightful wrapper around macOS's 'say' command.

USAGE:
    speak [options] "text to speak"
    echo "text" | speak [options]

OPTIONS:
    -v, --voice VOICE       Voice to use (default: Serena Premium)
    -r, --rate RATE         Speech rate in WPM (default: 175)
    -f, --file FILE         Read text from file
    --list-voices           List available voices
    --celebrate             Use celebratory tone for success messages
    --friendly              Use extra friendly greeting tone
    --alert                 Use alert tone for important messages
    -h, --help              Show this help message

EXAMPLES:
    # Basic usage
    speak "Hello, friend!"

    # Pipe from command
    echo "Build complete!" | speak

    # Use different voice
    speak -v Alex "Testing different voice"

    # Faster speech
    speak -r 200 "Speaking quickly"

    # Celebrate success
    speak --celebrate "All tests passing!"

    # Read from file
    speak -f README.md

PREMIUM VOICES (Higher Quality Neural TTS):
    Serena (Premium)      - Best quality British female (default)
    Serena (Enhanced)     - Enhanced British female
    Eddy (English (US))   - Natural male voice
    Flo (English (US))    - Natural female voice
    Reed (English (US))   - Professional male voice
    Sandy (English (US))  - Warm female voice

STANDARD VOICES:
    Samantha    - Friendly female voice (fallback)
    Alex        - Clear male voice
    Daniel      - British male voice
    Karen       - Australian female voice

💡 Tip: The script automatically selects premium voices when available!

To see all voices: speak --list-voices

DOTFILES INTEGRATION:
    # Speak success messages
    ./setup && speak --celebrate "Dotfiles setup complete!"

    # Announce test results
    ./tests/run_tests.zsh && speak "All tests passing!" || speak --alert "Tests failed!"

    # Background task notification
    (sleep 300; speak "Time to take a break!") &

EOF
}

# List available voices
list_voices() {
    print_info "Available voices on your system:"
    echo
    say -v '?'
    echo
    print_info "Recommended voices:"
    echo "  Serena (Premium)  - Best quality (default)"
    echo "  Samantha          - Friendly and clear"
    echo "  Alex              - Professional male voice"
    echo "  Victoria          - British accent"
    echo "  Karen             - Australian accent"
}

# ============================================================================
# Parse Arguments
# ============================================================================

voice="$DEFAULT_VOICE"
rate="$DEFAULT_RATE"
text=""
mode="normal"
input_file=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --list-voices)
            list_voices
            exit 0
            ;;
        -v|--voice)
            voice="$2"
            shift 2
            ;;
        -r|--rate)
            rate="$2"
            shift 2
            ;;
        -f|--file)
            input_file="$2"
            shift 2
            ;;
        --celebrate)
            mode="celebrate"
            shift
            ;;
        --friendly)
            mode="friendly"
            shift
            ;;
        --alert)
            mode="alert"
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            print_info "Use 'speak --help' for usage information"
            exit 1
            ;;
        *)
            # Collect remaining arguments as text
            text="$*"
            break
            ;;
    esac
done

# ============================================================================
# Get Input Text
# ============================================================================

# Priority: file > arguments > stdin
if [[ -n "$input_file" ]]; then
    if [[ ! -f "$input_file" ]]; then
        print_error "File not found: $input_file"
        exit 1
    fi
    text=$(cat "$input_file")
elif [[ -z "$text" ]]; then
    # Check if stdin has data
    if [[ ! -t 0 ]]; then
        text=$(cat)
    else
        print_error "No text provided to speak"
        print_info "Usage: speak 'text' or echo 'text' | speak"
        exit 1
    fi
fi

# Strip ANSI codes for clean speech
text=$(strip_ansi "$text")

# Check if text is empty after stripping
if [[ -z "$text" ]]; then
    print_error "No text to speak (empty input)"
    exit 1
fi

# ============================================================================
# Apply Mode Modifications
# ============================================================================

case "$mode" in
    celebrate)
        # Add celebratory prefix and use enthusiastic premium voice
        voice=$(select_best_voice "${PREMIUM_VOICES[friendly]}")
        rate="190"  # Slightly faster for excitement
        text="Hooray! $text Congratulations!"
        ;;
    friendly)
        # Add friendly greeting with premium voice
        voice=$(select_best_voice "${PREMIUM_VOICES[friendly]}")
        rate="170"  # Slightly slower for warmth
        text="Hey there, friend! $text"
        ;;
    alert)
        # Add alert prefix and use more serious voice
        voice=$(select_best_voice "${PREMIUM_VOICES[male]}")
        rate="160"  # Slower for emphasis
        text="Attention! $text"
        ;;
esac

# ============================================================================
# Speak the Text
# ============================================================================

# Use the 'say' command with specified options
say -v "$voice" -r "$rate" "$text"

exit 0
