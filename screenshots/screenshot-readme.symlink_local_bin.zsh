#!/usr/bin/env zsh
# ============================================================================
# screenshot-readme
#
# Batch process multiple files for README documentation.
# Creates beautiful, consistent screenshots for all specified files.
#
# Usage:
#   screenshot-readme <file1> <file2> ... [options]
#   screenshot-readme *.lua --output-dir screenshots/
#   screenshot-readme --help
#
# Options:
#   --output-dir DIR      Output directory (default: current directory)
#   --theme THEME         Color theme (default: OneHalfDark)
#   --prefix PREFIX       Filename prefix for outputs
#   --transparent         Use transparent backgrounds
#   --no-window           Remove window chrome
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
  COLOR_MAGENTA='\033[35m'
fi

# Default settings
OUTPUT_DIR="."
THEME="OneHalfDark"
PREFIX=""
TRANSPARENT=false
WINDOW_CHROME=true
FILES=()

# Show help
show_help() {
  cat << EOF
${COLOR_BOLD}${COLOR_CYAN}screenshot-readme${COLOR_RESET} - Batch screenshot files for documentation

${COLOR_BOLD}Usage:${COLOR_RESET}
  screenshot-readme <file1> <file2> ... [options]
  screenshot-readme init.lua config.lua --output-dir docs/images/
  screenshot-readme *.sh --prefix "shell-" --transparent

${COLOR_BOLD}Arguments:${COLOR_RESET}
  files...              One or more files to screenshot

${COLOR_BOLD}Options:${COLOR_RESET}
  --output-dir DIR      Output directory (default: current directory)
  --theme THEME         Color theme (default: OneHalfDark)
  --prefix PREFIX       Filename prefix for outputs (e.g., "config-")
  --transparent         Use transparent backgrounds
  --no-window           Remove window chrome (macOS-style buttons)
  --help                Show this help message

${COLOR_BOLD}Output Format:${COLOR_RESET}
  Input:  lua/plugins/ui.lua
  Output: <output-dir>/<prefix>ui.png

${COLOR_BOLD}Examples:${COLOR_RESET}
  ${COLOR_BLUE}# Screenshot all Lua files${COLOR_RESET}
  screenshot-readme lua/**/*.lua --output-dir docs/screenshots/

  ${COLOR_BLUE}# Transparent backgrounds for dark mode${COLOR_RESET}
  screenshot-readme init.lua README.md --transparent

  ${COLOR_BLUE}# Custom prefix and directory${COLOR_RESET}
  screenshot-readme *.zsh --prefix "dotfiles-" --output-dir ~/Desktop/

  ${COLOR_BLUE}# Minimal style${COLOR_RESET}
  screenshot-readme *.lua --no-window --transparent

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      show_help
      exit 0
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --theme)
      THEME="$2"
      shift 2
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    --transparent)
      TRANSPARENT=true
      shift
      ;;
    --no-window)
      WINDOW_CHROME=false
      shift
      ;;
    -*)
      echo "${COLOR_RED}Unknown option: $1${COLOR_RESET}"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

# Validate input
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "${COLOR_RED}Error: No files specified${COLOR_RESET}"
  echo "Use --help for usage information"
  exit 1
fi

# Check if silicon is installed
if ! command -v silicon &> /dev/null; then
  echo "${COLOR_RED}Error: silicon is not installed${COLOR_RESET}"
  echo "Install with: ${COLOR_CYAN}brew install silicon${COLOR_RESET}"
  exit 1
fi

# Create output directory if it doesn't exist
if [[ ! -d "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
  echo "${COLOR_CYAN}Created directory: $OUTPUT_DIR${COLOR_RESET}"
fi

# Show summary
echo "${COLOR_BOLD}${COLOR_CYAN}📸 Batch Screenshot Generator${COLOR_RESET}"
echo ""
echo "${COLOR_BLUE}Files:  ${COLOR_RESET}${#FILES[@]}"
echo "${COLOR_BLUE}Output: ${COLOR_RESET}$OUTPUT_DIR"
echo "${COLOR_BLUE}Theme:  ${COLOR_RESET}$THEME"
if [[ -n "$PREFIX" ]]; then
  echo "${COLOR_BLUE}Prefix: ${COLOR_RESET}$PREFIX"
fi
if [[ "$TRANSPARENT" == "true" ]]; then
  echo "${COLOR_BLUE}Style:  ${COLOR_RESET}Transparent background"
fi
echo ""

# Counter for statistics
SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_FILES=()

# Process each file
for INPUT_FILE in "${FILES[@]}"; do
  # Check if file exists
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "${COLOR_YELLOW}⊘ Skip (not found): $INPUT_FILE${COLOR_RESET}"
    FAILED_COUNT=$((FAILED_COUNT + 1))
    FAILED_FILES+=("$INPUT_FILE")
    continue
  fi

  # Generate output filename
  BASENAME="${INPUT_FILE:t:r}"  # Remove path and extension
  OUTPUT_FILE="$OUTPUT_DIR/${PREFIX}${BASENAME}.png"

  # Build silicon command options
  OPTS=()
  OPTS+=(--theme "$THEME")

  if [[ "$TRANSPARENT" == "true" ]]; then
    OPTS+=(--background "#00000000")
  else
    OPTS+=(--background "#282c34")
  fi

  if [[ "$WINDOW_CHROME" == "false" ]]; then
    OPTS+=(--no-window-controls)
  fi

  OPTS+=(--shadow-color "#00000088")
  OPTS+=(--shadow-blur-radius 10)
  OPTS+=(--shadow-offset-x 4)
  OPTS+=(--shadow-offset-y 4)

  # Execute silicon
  echo -n "${COLOR_CYAN}Processing: ${COLOR_RESET}${INPUT_FILE}..."

  if silicon "$INPUT_FILE" --output "$OUTPUT_FILE" "${OPTS[@]}" 2>&1 | grep -v "No font found for character" > /dev/null; then
    if [[ -f "$OUTPUT_FILE" ]]; then
      FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
      echo " ${COLOR_GREEN}✓${COLOR_RESET} ($FILE_SIZE)"
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
      echo " ${COLOR_RED}✗${COLOR_RESET}"
      FAILED_COUNT=$((FAILED_COUNT + 1))
      FAILED_FILES+=("$INPUT_FILE")
    fi
  else
    echo " ${COLOR_RED}✗${COLOR_RESET}"
    FAILED_COUNT=$((FAILED_COUNT + 1))
    FAILED_FILES+=("$INPUT_FILE")
  fi
done

# Show summary
echo ""
echo "${COLOR_BOLD}Summary:${COLOR_RESET}"
echo "${COLOR_GREEN}  ✓ Success: $SUCCESS_COUNT${COLOR_RESET}"

if [[ $FAILED_COUNT -gt 0 ]]; then
  echo "${COLOR_RED}  ✗ Failed:  $FAILED_COUNT${COLOR_RESET}"
  if [[ ${#FAILED_FILES[@]} -gt 0 ]]; then
    echo ""
    echo "${COLOR_YELLOW}Failed files:${COLOR_RESET}"
    for FAILED in "${FAILED_FILES[@]}"; do
      echo "  - $FAILED"
    done
  fi
fi

echo ""
if [[ $SUCCESS_COUNT -gt 0 ]]; then
  echo "${COLOR_GREEN}${COLOR_BOLD}✓ Batch screenshot complete!${COLOR_RESET}"
  echo "${COLOR_BLUE}Output directory:${COLOR_RESET} $OUTPUT_DIR"
  exit 0
else
  echo "${COLOR_RED}All screenshots failed${COLOR_RESET}"
  exit 1
fi
