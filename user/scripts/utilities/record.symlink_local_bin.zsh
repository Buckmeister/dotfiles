#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# record - CLI Audio Recorder
# ============================================================================
#
# Simple, elegant voice recording from your terminal. Perfect for creating
# voice notes, documenting thoughts, or preparing messages for transcription.
#
# Usage:
#   record                    # Record 30 seconds (default)
#   record 60                 # Record 60 seconds
#   record 45 my-note         # Record 45 seconds, save as my-note.wav
#   record --help             # Show help
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
        DF_OS=$(get_os 2>/dev/null || echo "darwin")
    else
        LIBRARIES_LOADED=false
        DF_OS=$(get_os_minimal)
    fi
else
    # Ultra-minimal fallback if bootstrap library missing
    LIBRARIES_LOADED=false
    DF_DIR="${HOME}/.config/dotfiles"
    print_error() { echo "Error: $1" >&2; }
    print_success() { echo "✅ $1"; }
    print_info() { echo "ℹ️  $1"; }
    print_warning() { echo "⚠️  $1"; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }
    DF_OS="$(uname | tr '[:upper:]' '[:lower:]')"
fi

# ============================================================================
# Configuration
# ============================================================================

# Default recording settings
DEFAULT_DURATION=30
DEFAULT_SAMPLE_RATE=44100
DEFAULT_CHANNELS=1  # Mono (2 for stereo)

# Recordings directory
RECORDINGS_DIR="${HOME}/.aria/recordings"

# Detect recording tool based on OS
RECORDING_TOOL=""
if [[ "$DF_OS" == "darwin" || "$DF_OS" == "macos" ]]; then
    if command_exists ffmpeg; then
        RECORDING_TOOL="ffmpeg"
    fi
elif [[ "$DF_OS" == "linux" || "$DF_OS" == "wsl" ]]; then
    if command_exists ffmpeg; then
        RECORDING_TOOL="ffmpeg"
    elif command_exists arecord; then
        RECORDING_TOOL="arecord"
    fi
fi

# ============================================================================
# Helper Functions
# ============================================================================

# Get human-readable file size
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        du -h "$file" | cut -f1
    else
        echo "unknown"
    fi
}

# Generate timestamped filename
generate_filename() {
    local base_name="${1:-recording}"
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    echo "${base_name}-${timestamp}.wav"
}

# Show help message
show_help() {
    cat <<'EOF'
record - CLI Audio Recorder

Simple, elegant voice recording from your terminal.

USAGE:
    record [duration] [filename]
    record [options]

ARGUMENTS:
    duration              Recording duration in seconds (default: 30)
    filename              Output filename without extension (default: timestamped)

OPTIONS:
    -h, --help            Show this help message
    -d, --dir DIR         Custom recordings directory
    -r, --rate RATE       Sample rate in Hz (default: 44100)
    -s, --stereo          Record in stereo (default: mono)

EXAMPLES:
    # Record 30 seconds (default)
    record

    # Record 60 seconds
    record 60

    # Record 45 seconds with custom name
    record 45 meeting-notes

    # Record in stereo for music
    record 120 song-idea --stereo

    # Specify custom directory
    record --dir ~/Documents/recordings

CONFIGURATION:
    Default directory:    ~/.aria/recordings
    Default duration:     30 seconds
    Default sample rate:  44100 Hz
    Default channels:     Mono

INTEGRATION:
    # Use with speak for confirmation
    record 30 && speak --celebrate "Recording complete!"

    # Chain with transcription (coming soon)
    record 60 my-note && transcribe ~/.aria/recordings/my-note-*.wav

FUTURE FEATURES:
    - Automatic transcription via Whisper
    - Direct sharing with Aria
    - Voice command detection
    - Background noise reduction

Recordings are saved as WAV files (PCM 16-bit) for maximum compatibility
and quality. Perfect for voice notes, thoughts, and message preparation.

EOF
}

# ============================================================================
# Parse Arguments
# ============================================================================

duration="$DEFAULT_DURATION"
output_name=""
custom_dir=""
sample_rate="$DEFAULT_SAMPLE_RATE"
channels="$DEFAULT_CHANNELS"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dir)
            custom_dir="$2"
            shift 2
            ;;
        -r|--rate)
            sample_rate="$2"
            shift 2
            ;;
        -s|--stereo)
            channels=2
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            print_info "Use --help for usage information"
            exit 1
            ;;
        *)
            # First non-flag argument is duration
            if [[ -z "$duration" || "$duration" == "$DEFAULT_DURATION" ]]; then
                duration="$1"
            else
                # Second non-flag argument is filename
                output_name="$1"
            fi
            shift
            ;;
    esac
done

# Use custom directory if specified
if [[ -n "$custom_dir" ]]; then
    RECORDINGS_DIR="$custom_dir"
fi

# ============================================================================
# Main Recording Function
# ============================================================================

main() {
    # Check for recording tool
    if [[ -z "$RECORDING_TOOL" ]]; then
        print_error "No recording tool found"
        print_info "Install ffmpeg: brew install ffmpeg (macOS) or sudo apt install ffmpeg (Linux)"
        exit 1
    fi

    # Create recordings directory
    mkdir -p "$RECORDINGS_DIR" || {
        print_error "Could not create recordings directory: $RECORDINGS_DIR"
        exit 1
    }

    # Generate output filename
    local filename
    if [[ -n "$output_name" ]]; then
        filename="${output_name}.wav"
    else
        filename=$(generate_filename "recording")
    fi

    local output_file="${RECORDINGS_DIR}/${filename}"

    # Show recording info
    if [[ "$LIBRARIES_LOADED" == "true" ]]; then
        draw_section_header "🎤 Audio Recorder" "Recording voice note"
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🎤 Audio Recorder"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi

    print_info "Directory: ${RECORDINGS_DIR}"
    print_info "Duration: ${duration}s"
    print_info "Channels: $([ "$channels" -eq 1 ] && echo "Mono" || echo "Stereo")"
    print_info "Sample rate: ${sample_rate} Hz"
    print_info "Output: ${filename}"
    echo

    print_success "🔴 Recording... (${duration} seconds)"
    print_info "Speak into your microphone now!"
    echo

    # Record based on tool
    case "$RECORDING_TOOL" in
        ffmpeg)
            # macOS/Linux with ffmpeg
            local device_param
            if [[ "$DF_OS" == "darwin" || "$DF_OS" == "macos" ]]; then
                # macOS: avfoundation
                device_param="-f avfoundation -i :0"
            else
                # Linux: alsa
                device_param="-f alsa -i default"
            fi

            ffmpeg $device_param \
                -t "$duration" \
                -ar "$sample_rate" \
                -ac "$channels" \
                -c:a pcm_s16le \
                -y \
                "$output_file" \
                2>&1 | grep -E "Duration|time=" || true
            ;;
        arecord)
            # Linux with arecord (ALSA)
            arecord \
                -f cd \
                -t wav \
                -d "$duration" \
                -r "$sample_rate" \
                -c "$channels" \
                "$output_file"
            ;;
    esac

    local record_status=$?
    echo

    if [[ $record_status -eq 0 && -f "$output_file" ]]; then
        print_success "Recording complete!"
        echo

        local file_size=$(get_file_size "$output_file")
        print_info "File size: ${file_size}"
        print_info "Location: ${output_file}"
        echo

        # Interactive options
        print_info "What would you like to do?"
        echo
        echo "  [p] Play recording"
        echo "  [t] Transcribe (coming soon)"
        echo "  [s] Share with Aria (copy path)"
        echo "  [d] Delete"
        echo "  [q] Quit"
        echo
        echo -n "Choose: "
        read -r choice

        case "$choice" in
            p|P)
                print_info "▶️  Playing..."
                if [[ "$DF_OS" == "darwin" || "$DF_OS" == "macos" ]]; then
                    afplay "$output_file"
                elif command_exists aplay; then
                    aplay "$output_file"
                elif command_exists ffplay; then
                    ffplay -nodisp -autoexit "$output_file" 2>/dev/null
                else
                    print_warning "No audio player found (afplay, aplay, or ffplay)"
                fi
                ;;
            t|T)
                print_warning "Transcription feature coming soon!"
                print_info "Will use Whisper model on your GPU infrastructure"
                ;;
            s|S)
                echo -n "$output_file" | pbcopy 2>/dev/null || echo -n "$output_file" | xclip -selection clipboard 2>/dev/null
                print_success "Path copied to clipboard!"
                print_info "You can now paste it into Claude Code"
                ;;
            d|D)
                echo -n "Delete recording? [y/N] "
                read -r confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    rm "$output_file"
                    print_success "Recording deleted"
                else
                    print_info "Recording kept"
                fi
                ;;
            q|Q|"")
                print_info "Recording saved!"
                ;;
            *)
                print_warning "Unknown option"
                print_info "Recording saved at: $output_file"
                ;;
        esac
    else
        print_error "Recording failed"
        exit 1
    fi

    echo
    print_info "💡 Tip: List all recordings with: ls ${RECORDINGS_DIR}"
    print_info "📚 Help: record --help"
}

# ============================================================================
# Execute
# ============================================================================

# Run if executed directly
if [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
