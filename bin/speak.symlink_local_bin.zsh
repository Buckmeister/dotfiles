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
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: The 'say' command is only available on macOS" >&2
    exit 1
fi

# Check if 'say' command exists
if ! command -v say >/dev/null 2>&1; then
    echo "Error: 'say' command not found. Are you on macOS?" >&2
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
    -v, --voice VOICE       Voice to use (default: Samantha)
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
    echo "Available voices on your system:"
    echo
    say -v '?'
    echo
    echo "Recommended voices:"
    echo "  Samantha (default) - Friendly and clear"
    echo "  Alex               - Professional male voice"
    echo "  Victoria           - British accent"
    echo "  Karen              - Australian accent"
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
            echo "Error: Unknown option: $1" >&2
            echo "Use 'speak --help' for usage information" >&2
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
        echo "Error: File not found: $input_file" >&2
        exit 1
    fi
    text=$(cat "$input_file")
elif [[ -z "$text" ]]; then
    # Check if stdin has data
    if [[ ! -t 0 ]]; then
        text=$(cat)
    else
        echo "Error: No text provided to speak" >&2
        echo "Usage: speak 'text' or echo 'text' | speak" >&2
        exit 1
    fi
fi

# Strip ANSI codes for clean speech
text=$(strip_ansi "$text")

# Check if text is empty after stripping
if [[ -z "$text" ]]; then
    echo "Error: No text to speak (empty input)" >&2
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
