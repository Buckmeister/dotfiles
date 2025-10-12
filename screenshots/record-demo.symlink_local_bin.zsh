#!/usr/bin/env zsh
# ============================================================================
# record-demo
#
# Record terminal sessions with asciinema for documentation and demos.
# Creates shareable terminal recordings that can be embedded in READMEs.
#
# Usage:
#   record-demo [output-file] [options]
#   record-demo demo.cast
#   record-demo demo.cast --title "Setup Demo"
#   record-demo --help
#
# Options:
#   --title TITLE         Recording title
#   --command CMD         Command to record (default: $SHELL)
#   --idle-time-limit N   Limit idle time to N seconds
#   --upload              Upload to asciinema.org after recording
#   --help                Show this help message
# ============================================================================

# Resolve script directory for shared libraries
DOTFILES_ROOT="$HOME/.config/dotfiles"

# Try to source shared libraries (fallback gracefully if not available)
if [[ -f "$DOTFILES_ROOT/bin/lib/colors.zsh" ]]; then
  source "$DOTFILES_ROOT/bin/lib/colors.zsh"
else
  # Fallback colors
  COLOR_RESET='\033[0m'
  COLOR_BOLD='\033[1m'
  COLOR_GREEN='\033[32m'
  COLOR_BLUE='\033[34m'
  COLOR_YELLOW='\033[33m'
  COLOR_RED='\033[31m'
  COLOR_CYAN='\033[36m'
fi

# Default settings
OUTPUT_FILE=""
TITLE=""
COMMAND="$SHELL"
IDLE_TIME_LIMIT=""
UPLOAD=false

# Show help
show_help() {
  cat << EOF
${COLOR_BOLD}${COLOR_CYAN}record-demo${COLOR_RESET} - Record terminal sessions with asciinema

${COLOR_BOLD}Usage:${COLOR_RESET}
  record-demo [output-file] [options]
  record-demo demo.cast
  record-demo demo.cast --title "Dotfiles Setup"
  record-demo --upload

${COLOR_BOLD}Arguments:${COLOR_RESET}
  output-file           Output .cast file (default: demo-YYYYMMDD-HHMMSS.cast)

${COLOR_BOLD}Options:${COLOR_RESET}
  --title TITLE         Recording title for metadata
  --command CMD         Command to record (default: \$SHELL)
  --idle-time-limit N   Limit idle time to N seconds (removes long pauses)
  --upload              Upload to asciinema.org and get shareable URL
  --help                Show this help message

${COLOR_BOLD}Controls During Recording:${COLOR_RESET}
  ${COLOR_GREEN}Ctrl+D${COLOR_RESET} or ${COLOR_GREEN}exit${COLOR_RESET}  Stop recording

${COLOR_BOLD}After Recording:${COLOR_RESET}
  ${COLOR_BLUE}# Play the recording${COLOR_RESET}
  asciinema play demo.cast

  ${COLOR_BLUE}# Convert to GIF (requires agg)${COLOR_RESET}
  brew install agg
  agg demo.cast demo.gif

  ${COLOR_BLUE}# Convert to SVG (requires svg-term-cli)${COLOR_RESET}
  npm install -g svg-term-cli
  cat demo.cast | svg-term --out demo.svg

  ${COLOR_BLUE}# Upload to share${COLOR_RESET}
  asciinema upload demo.cast

${COLOR_BOLD}Examples:${COLOR_RESET}
  ${COLOR_BLUE}# Quick recording${COLOR_RESET}
  record-demo

  ${COLOR_BLUE}# Recording with title${COLOR_RESET}
  record-demo setup-demo.cast --title "Dotfiles Setup Process"

  ${COLOR_BLUE}# Remove long pauses${COLOR_RESET}
  record-demo demo.cast --idle-time-limit 2

  ${COLOR_BLUE}# Record specific command${COLOR_RESET}
  record-demo demo.cast --command "nvim"

  ${COLOR_BLUE}# Record and upload${COLOR_RESET}
  record-demo --upload --title "My Awesome Demo"

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      show_help
      exit 0
      ;;
    --title)
      TITLE="$2"
      shift 2
      ;;
    --command)
      COMMAND="$2"
      shift 2
      ;;
    --idle-time-limit)
      IDLE_TIME_LIMIT="$2"
      shift 2
      ;;
    --upload)
      UPLOAD=true
      shift
      ;;
    -*)
      echo "${COLOR_RED}Unknown option: $1${COLOR_RESET}"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      if [[ -z "$OUTPUT_FILE" ]]; then
        OUTPUT_FILE="$1"
      else
        echo "${COLOR_RED}Too many arguments${COLOR_RESET}"
        exit 1
      fi
      shift
      ;;
  esac
done

# Check if asciinema is installed
if ! command -v asciinema &> /dev/null; then
  echo "${COLOR_RED}Error: asciinema is not installed${COLOR_RESET}"
  echo "Install with: ${COLOR_CYAN}brew install asciinema${COLOR_RESET}"
  exit 1
fi

# Generate output filename if not specified and not uploading
if [[ -z "$OUTPUT_FILE" && "$UPLOAD" == "false" ]]; then
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  OUTPUT_FILE="demo-${TIMESTAMP}.cast"
fi

# Build asciinema command
CMD=(asciinema rec)

if [[ -n "$OUTPUT_FILE" ]]; then
  CMD+=("$OUTPUT_FILE")
fi

if [[ -n "$TITLE" ]]; then
  CMD+=(--title "$TITLE")
fi

if [[ -n "$COMMAND" && "$COMMAND" != "$SHELL" ]]; then
  CMD+=(--command "$COMMAND")
fi

if [[ -n "$IDLE_TIME_LIMIT" ]]; then
  CMD+=(--idle-time-limit "$IDLE_TIME_LIMIT")
fi

# Show info
echo "${COLOR_BOLD}${COLOR_CYAN}🎬 Asciinema Terminal Recorder${COLOR_RESET}"
echo ""
if [[ -n "$OUTPUT_FILE" ]]; then
  echo "${COLOR_BLUE}Output: ${COLOR_RESET}$OUTPUT_FILE"
fi
if [[ -n "$TITLE" ]]; then
  echo "${COLOR_BLUE}Title:  ${COLOR_RESET}$TITLE"
fi
echo "${COLOR_BLUE}Shell:  ${COLOR_RESET}$COMMAND"
if [[ -n "$IDLE_TIME_LIMIT" ]]; then
  echo "${COLOR_BLUE}Idle:   ${COLOR_RESET}${IDLE_TIME_LIMIT}s max"
fi
echo ""
echo "${COLOR_YELLOW}Recording will start now...${COLOR_RESET}"
echo "${COLOR_YELLOW}Press Ctrl+D or type 'exit' to stop recording${COLOR_RESET}"
echo ""

# Execute
"${CMD[@]}"

RESULT=$?

if [[ $RESULT -eq 0 ]]; then
  echo ""
  echo "${COLOR_GREEN}${COLOR_BOLD}✓ Recording complete!${COLOR_RESET}"

  if [[ -n "$OUTPUT_FILE" && -f "$OUTPUT_FILE" ]]; then
    FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    echo "${COLOR_BLUE}Location:${COLOR_RESET} $OUTPUT_FILE (${FILE_SIZE})"
    echo ""
    echo "${COLOR_CYAN}Next steps:${COLOR_RESET}"
    echo "  ${COLOR_BLUE}Play:${COLOR_RESET}   asciinema play $OUTPUT_FILE"
    echo "  ${COLOR_BLUE}Upload:${COLOR_RESET} asciinema upload $OUTPUT_FILE"
  fi
else
  echo "${COLOR_RED}Recording cancelled or failed${COLOR_RESET}"
  exit 1
fi
