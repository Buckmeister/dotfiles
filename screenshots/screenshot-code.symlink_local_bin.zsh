#!/usr/bin/env zsh
# ============================================================================
# screenshot-code
#
# Create beautiful code screenshots using silicon with OneDark theme.
# Automatically detects language from file extension.
#
# Usage:
#   screenshot-code <input-file> [output-file]
#   screenshot-code myfile.lua
#   screenshot-code myfile.sh screenshot.png
#   screenshot-code --help
#
# Options:
#   --theme THEME         Color theme (default: OneHalfDark)
#   --no-line-numbers     Hide line numbers
#   --no-window           Remove window chrome
#   --transparent         Transparent background
#   --lines START:END     Only screenshot specific lines
#   --help                Show this help message
# ============================================================================

# Resolve script directory for shared libraries
SCRIPT_DIR="${0:a:h}"
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
THEME="OneHalfDark"
BACKGROUND="#282c34"  # OneDark darker background
SHADOW_COLOR="#00000088"
SHADOW_BLUR=10
SHADOW_OFFSET_X=4
SHADOW_OFFSET_Y=4
LINE_NUMBERS=true
WINDOW_CHROME=true
LINE_RANGE=""

# Show help
show_help() {
  cat << EOF
${COLOR_BOLD}${COLOR_CYAN}screenshot-code${COLOR_RESET} - Create beautiful code screenshots

${COLOR_BOLD}Usage:${COLOR_RESET}
  screenshot-code <input-file> [output-file]
  screenshot-code myfile.lua
  screenshot-code myfile.sh output.png
  screenshot-code myfile.py --no-line-numbers --transparent

${COLOR_BOLD}Arguments:${COLOR_RESET}
  input-file            File to screenshot (required)
  output-file           Output PNG path (default: <input>.png)

${COLOR_BOLD}Options:${COLOR_RESET}
  --theme THEME         Color theme (default: OneHalfDark)
  --no-line-numbers     Hide line numbers
  --no-window           Remove window chrome (macOS-style buttons)
  --transparent         Use transparent background
  --lines START:END     Only screenshot specific lines (e.g., --lines 10:20)
  --help                Show this help message

${COLOR_BOLD}Themes:${COLOR_RESET}
  Run 'silicon --list-themes' to see all available themes.
  Recommended for OneDark aesthetic: OneHalfDark, Nord, Monokai Extended

${COLOR_BOLD}Examples:${COLOR_RESET}
  ${COLOR_BLUE}# Basic screenshot${COLOR_RESET}
  screenshot-code init.lua

  ${COLOR_BLUE}# Custom output path${COLOR_RESET}
  screenshot-code init.lua ~/Desktop/config.png

  ${COLOR_BLUE}# Transparent background for dark mode docs${COLOR_RESET}
  screenshot-code init.lua --transparent

  ${COLOR_BLUE}# Minimal style${COLOR_RESET}
  screenshot-code init.lua --no-line-numbers --no-window

  ${COLOR_BLUE}# Screenshot specific lines${COLOR_RESET}
  screenshot-code init.lua --lines 10:30

EOF
}

# Parse arguments
INPUT_FILE=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      show_help
      exit 0
      ;;
    --theme)
      THEME="$2"
      shift 2
      ;;
    --no-line-numbers)
      LINE_NUMBERS=false
      shift
      ;;
    --no-window)
      WINDOW_CHROME=false
      shift
      ;;
    --transparent)
      BACKGROUND="#00000000"
      shift
      ;;
    --lines)
      LINE_RANGE="$2"
      shift 2
      ;;
    -*)
      echo "${COLOR_RED}Unknown option: $1${COLOR_RESET}"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      if [[ -z "$INPUT_FILE" ]]; then
        INPUT_FILE="$1"
      elif [[ -z "$OUTPUT_FILE" ]]; then
        OUTPUT_FILE="$1"
      else
        echo "${COLOR_RED}Too many arguments${COLOR_RESET}"
        exit 1
      fi
      shift
      ;;
  esac
done

# Validate input
if [[ -z "$INPUT_FILE" ]]; then
  echo "${COLOR_RED}Error: No input file specified${COLOR_RESET}"
  echo "Use --help for usage information"
  exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "${COLOR_RED}Error: File not found: $INPUT_FILE${COLOR_RESET}"
  exit 1
fi

# Check if silicon is installed
if ! command -v silicon &> /dev/null; then
  echo "${COLOR_RED}Error: silicon is not installed${COLOR_RESET}"
  echo "Install with: ${COLOR_CYAN}brew install silicon${COLOR_RESET}"
  exit 1
fi

# Generate output filename if not specified
if [[ -z "$OUTPUT_FILE" ]]; then
  OUTPUT_FILE="${INPUT_FILE:r}.png"
fi

# Build silicon command
CMD=(silicon "$INPUT_FILE" --output "$OUTPUT_FILE")
CMD+=(--theme "$THEME")
CMD+=(--background "$BACKGROUND")
CMD+=(--shadow-color "$SHADOW_COLOR")
CMD+=(--shadow-blur-radius "$SHADOW_BLUR")
CMD+=(--shadow-offset-x "$SHADOW_OFFSET_X")
CMD+=(--shadow-offset-y "$SHADOW_OFFSET_Y")

if [[ "$LINE_NUMBERS" == "false" ]]; then
  CMD+=(--no-line-number)
fi

if [[ "$WINDOW_CHROME" == "false" ]]; then
  CMD+=(--no-window-controls)
fi

if [[ -n "$LINE_RANGE" ]]; then
  CMD+=(--line-range "$LINE_RANGE")
fi

# Execute
echo "${COLOR_CYAN}Creating screenshot...${COLOR_RESET}"
echo "${COLOR_BLUE}Input:  ${COLOR_RESET}$INPUT_FILE"
echo "${COLOR_BLUE}Output: ${COLOR_RESET}$OUTPUT_FILE"
echo "${COLOR_BLUE}Theme:  ${COLOR_RESET}$THEME"

"${CMD[@]}" 2>&1 | grep -v "No font found for character" || true

if [[ $? -eq 0 && -f "$OUTPUT_FILE" ]]; then
  FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
  echo "${COLOR_GREEN}${COLOR_BOLD}✓ Screenshot created!${COLOR_RESET} (${FILE_SIZE})"
  echo "${COLOR_BLUE}Location:${COLOR_RESET} $OUTPUT_FILE"
else
  echo "${COLOR_RED}Error creating screenshot${COLOR_RESET}"
  exit 1
fi
