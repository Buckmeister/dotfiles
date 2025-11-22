#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# speak - Cross-Platform Text-to-Speech Utility
# ============================================================================
#
# A delightful TTS wrapper that makes your dotfiles system speak to you!
# Supports macOS (say), Linux (espeak-ng/espeak/festival).
# Perfect for status updates, celebrations, and making long-running tasks
# more engaging.
#
# Usage:
#   speak "Hello, friend!"
#   echo "Build complete!" | speak
#   speak -v Samantha "Welcome to your dotfiles"
#   speak --celebrate "All tests passing!"
#
# ============================================================================

# ============================================================================
# Bootstrap: Load Shared Libraries
# ============================================================================

# Resolve script path and load bootstrap library
SCRIPT_PATH="${0:A}"
BOOTSTRAP_LIB="${SCRIPT_PATH%/user/scripts/*}/user/scripts/lib/functions.zsh"

if [[ -f "$BOOTSTRAP_LIB" ]]; then
    source "$BOOTSTRAP_LIB"
    DF_DIR=$(detect_df_dir)
    if load_shared_libs "$DF_DIR"; then
        LIBRARIES_LOADED=true
        # Get OS from shared library
        DF_OS=$(get_os 2>/dev/null || echo "darwin")
    else
        LIBRARIES_LOADED=false
        # Use minimal OS detection
        DF_OS=$(get_os_minimal)
    fi
else
    # Ultra-minimal fallback if bootstrap library missing
    LIBRARIES_LOADED=false
    DF_DIR="${HOME}/.config/dotfiles"
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

# German voice preferences
typeset -A GERMAN_VOICES
GERMAN_VOICES[friendly]="Flo (German (Germany)) Anna (German (Germany)) Eddy (German (Germany))"
GERMAN_VOICES[male]="Eddy (German (Germany)) Reed (German (Germany)) Rocko (German (Germany))"
GERMAN_VOICES[female]="Flo (German (Germany)) Anna (German (Germany)) Sandy (German (Germany))"

# Default voice (Serena Premium if available, otherwise fallback)
DEFAULT_VOICE="Serena (Premium)"
DEFAULT_GERMAN_VOICE="Anna (German (Germany))"

# Language settings (can be overridden by SPEAK_LANG environment variable)
DEFAULT_LANG="${SPEAK_LANG:-en}"

# Default speech rate (words per minute, 175 is natural)
DEFAULT_RATE="175"

# Detect available TTS engine based on OS and installed commands
TTS_ENGINE=""
if [[ "$DF_OS" == "darwin" || "$DF_OS" == "macos" ]]; then
    if command_exists say; then
        TTS_ENGINE="say"
    fi
elif [[ "$DF_OS" == "linux" || "$DF_OS" == "wsl" ]]; then
    # Prefer espeak-ng (enhanced), fall back to espeak, then festival
    # WSL can use Linux TTS engines (espeak-ng, espeak, festival)
    if command_exists espeak-ng; then
        TTS_ENGINE="espeak-ng"
    elif command_exists espeak; then
        TTS_ENGINE="espeak"
    elif command_exists festival; then
        TTS_ENGINE="festival"
    fi
fi

# Exit if no TTS engine available
if [[ -z "$TTS_ENGINE" ]]; then
    print_error "No text-to-speech engine found"
    print_info "Install one of: espeak-ng, espeak (Linux) or use macOS"
    print_info "  Ubuntu/Debian: sudo apt install espeak-ng"
    print_info "  Fedora/RHEL:   sudo dnf install espeak-ng"
    print_info "  Arch:          sudo pacman -S espeak-ng"
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
speak - Cross-Platform Text-to-Speech Utility

A delightful TTS wrapper supporting macOS (say) and Linux (espeak-ng/espeak/festival).

USAGE:
    speak [options] "text to speak"
    echo "text" | speak [options]

OPTIONS:
    -v, --voice VOICE       Voice to use (default: Serena Premium)
    -r, --rate RATE         Speech rate in WPM (default: 175)
    -l, --lang LANG         Language (en, de) (default: $SPEAK_LANG or en)
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

    # German language
    speak --lang de "Guten Morgen!"
    speak -l de --celebrate "Alle Tests erfolgreich!"

    # Use different voice
    speak -v Alex "Testing different voice"

    # Faster speech
    speak -r 200 "Speaking quickly"

    # Celebrate success
    speak --celebrate "All tests passing!"

    # Read from file
    speak -f README.md

LANGUAGE SUPPORT:
    English (en)  - Default, premium neural voices
    German (de)   - Anna, Eddy, Flo voices

    Set default language via environment variable:
    export SPEAK_LANG=de  # Use German by default

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

    case "$TTS_ENGINE" in
        say)
            say -v '?'
            echo
            print_info "Recommended voices:"
            echo "  Serena (Premium)  - Best quality (default)"
            echo "  Samantha          - Friendly and clear"
            echo "  Alex              - Professional male voice"
            echo "  Victoria          - British accent"
            echo "  Karen             - Australian accent"
            ;;
        espeak-ng|espeak)
            "$TTS_ENGINE" --voices
            echo
            print_info "Common voice variants:"
            echo "  en-us+f2  - US female (default)"
            echo "  en-us+f3  - US female variant"
            echo "  en-us+m3  - US male"
            echo "  en-gb+f1  - British female"
            echo "  en-gb+m1  - British male"
            ;;
        festival)
            print_info "Festival uses system default voice"
            echo "  Configure in /etc/festival.scm or ~/.festivalrc"
            ;;
    esac
}

# ============================================================================
# Parse Arguments
# ============================================================================

voice=""  # Will be set based on language
rate="$DEFAULT_RATE"
text=""
mode="normal"
input_file=""
lang="$DEFAULT_LANG"

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
        -l|--lang)
            lang="$2"
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
# Apply Language and Mode Modifications
# ============================================================================

# Normalize language
lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]')

# Set default voice based on language if not explicitly set
if [[ -z "$voice" ]]; then
    case "$lang" in
        de|german)
            voice="$DEFAULT_GERMAN_VOICE"
            ;;
        en|english|*)
            voice="$DEFAULT_VOICE"
            ;;
    esac
fi

# Apply mode modifications with language-specific messages
case "$mode" in
    celebrate)
        # Add celebratory prefix and use enthusiastic premium voice
        case "$lang" in
            de|german)
                voice=$(select_best_voice "${GERMAN_VOICES[friendly]}")
                rate="190"  # Slightly faster for excitement
                text="Toll! $text Glückwunsch!"
                ;;
            *)
                voice=$(select_best_voice "${PREMIUM_VOICES[friendly]}")
                rate="190"  # Slightly faster for excitement
                text="Hooray! $text Congratulations!"
                ;;
        esac
        ;;
    friendly)
        # Add friendly greeting with premium voice
        case "$lang" in
            de|german)
                voice=$(select_best_voice "${GERMAN_VOICES[friendly]}")
                rate="170"  # Slightly slower for warmth
                text="Hallo! $text"
                ;;
            *)
                voice=$(select_best_voice "${PREMIUM_VOICES[friendly]}")
                rate="170"  # Slightly slower for warmth
                text="Hey there, friend! $text"
                ;;
        esac
        ;;
    alert)
        # Add alert prefix and use more serious voice
        case "$lang" in
            de|german)
                voice=$(select_best_voice "${GERMAN_VOICES[male]}")
                rate="160"  # Slower for emphasis
                text="Achtung! $text"
                ;;
            *)
                voice=$(select_best_voice "${PREMIUM_VOICES[male]}")
                rate="160"  # Slower for emphasis
                text="Attention! $text"
                ;;
        esac
        ;;
esac

# ============================================================================
# Speak the Text
# ============================================================================

case "$TTS_ENGINE" in
    say)
        # macOS: Use 'say' with specified voice and rate
        say -v "$voice" -r "$rate" "$text"
        ;;

    espeak-ng|espeak)
        # Linux espeak: Map parameters
        # espeak uses -s for speed (words per minute, same as say)
        # espeak voices are different (e.g., en, en-us, en-gb, de, de+f1)

        # Select voice based on language and mode
        case "$lang" in
            de|german)
                # German voices
                case "$mode" in
                    friendly|celebrate)
                        espeak_voice="de+f1"  # German female voice
                        ;;
                    alert)
                        espeak_voice="de+m1"  # German male voice
                        ;;
                    *)
                        espeak_voice="de+f1"  # Default German female voice
                        ;;
                esac
                ;;
            *)
                # English voices
                case "$mode" in
                    friendly|celebrate)
                        espeak_voice="en-us+f3"  # Female voice, variant 3
                        ;;
                    alert)
                        espeak_voice="en-us+m3"  # Male voice, variant 3
                        ;;
                    *)
                        espeak_voice="en-us+f2"  # Default female voice
                        ;;
                esac
                ;;
        esac

        # espeak-ng has better quality than espeak
        "$TTS_ENGINE" -v "$espeak_voice" -s "$rate" "$text"
        ;;

    festival)
        # Festival: Uses different syntax
        # Create temp file with text (festival reads from file or stdin)
        echo "$text" | festival --tts
        ;;

    *)
        print_error "Unknown TTS engine: $TTS_ENGINE"
        exit 1
        ;;
esac

exit 0
