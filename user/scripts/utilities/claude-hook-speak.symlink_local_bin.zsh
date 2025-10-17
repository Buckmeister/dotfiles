#!/usr/bin/env zsh

# ============================================================================
# Claude Code Hook - Acoustic Feedback
# ============================================================================
#
# This script provides acoustic feedback for Claude Code events using the
# speak utility. It receives JSON event data via stdin and generates
# appropriate audio feedback.
#
# Usage: Called automatically by Claude Code hooks
# ============================================================================

emulate -LR zsh
setopt PIPE_FAIL

# Read JSON from stdin
input=$(cat)

# Extract event type and data
event_type=$(echo "$input" | jq -r '.eventType // "unknown"')
tool_name=$(echo "$input" | jq -r '.tool // "unknown"')
session_id=$(echo "$input" | jq -r '.sessionId // "unknown"')

# Speak script location (cross-platform TTS wrapper)
SPEAK="${HOME}/.local/bin/speak"

# Check if speak wrapper is available, otherwise try direct TTS
if [[ ! -x "$SPEAK" ]]; then
    # Fallback: try to find system TTS directly
    if command -v say >/dev/null 2>&1; then
        SPEAK="say"
    elif command -v espeak-ng >/dev/null 2>&1; then
        SPEAK="espeak-ng"
    elif command -v espeak >/dev/null 2>&1; then
        SPEAK="espeak"
    else
        # No TTS available, exit silently (don't block Claude Code)
        exit 0
    fi
fi

# Generate feedback based on event type
case "$event_type" in
    "PreToolUse")
        # Tool is about to be used
        case "$tool_name" in
            "Bash")
                $SPEAK "Running command" &
                ;;
            "Read")
                $SPEAK "Reading file" &
                ;;
            "Edit"|"Write")
                $SPEAK "Writing file" &
                ;;
            "Grep"|"Glob")
                $SPEAK "Searching" &
                ;;
            *)
                # Subtle click for other tools
                $SPEAK "Tool" &
                ;;
        esac
        ;;

    "PostToolUse")
        # Tool completed
        success=$(echo "$input" | jq -r '.result.success // true')
        if [[ "$success" == "true" ]]; then
            # Success - short pleasant sound
            $SPEAK "Done" &
        else
            # Error - alert sound
            $SPEAK "Error occurred" &
        fi
        ;;

    "SessionStart")
        $SPEAK "Claude Code session started" &
        ;;

    "SessionEnd")
        $SPEAK "Session complete" &
        ;;

    "UserPromptSubmit")
        # User submitted a prompt
        $SPEAK "Processing" &
        ;;

    "Notification")
        # System notification
        level=$(echo "$input" | jq -r '.level // "info"')
        case "$level" in
            "error")
                $SPEAK "Error notification" &
                ;;
            "warning")
                $SPEAK "Warning" &
                ;;
            *)
                $SPEAK "Notification" &
                ;;
        esac
        ;;

    "Stop")
        # User stopped execution
        $SPEAK "Stopped" &
        ;;

    *)
        # Unknown event type - subtle feedback
        $SPEAK "Event" &
        ;;
esac

# Always return success (non-blocking)
exit 0
