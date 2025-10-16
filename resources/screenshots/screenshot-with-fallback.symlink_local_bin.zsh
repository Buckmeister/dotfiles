#!/usr/bin/env zsh
# ============================================================================
# screenshot-with-fallback
#
# Create beautiful screenshots with ASCII fallback for markdown.
# Generates markdown with the code content as alt-text for graceful
# degradation and accessibility, then copies to clipboard.
#
# Usage:
#   screenshot-with-fallback <file> [output-image] [options]
#   screenshot-with-fallback init.lua docs/images/init.png
#   screenshot-with-fallback myfile.sh --relative-path docs/
#   screenshot-with-fallback --help
#
# Options:
#   --relative-path PATH  Image path relative to README location
#   --absolute-path PATH  Absolute image path
#   --alt-text TEXT       Custom alt text (default: file content)
#   --max-alt-lines N     Max lines in alt text (default: 50)
#   --no-clipboard        Don't copy to clipboard
#   --theme THEME         Silicon theme (default: OneHalfDark)
#   --transparent         Transparent background
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
INPUT_FILE=""
OUTPUT_IMAGE=""
RELATIVE_PATH=""
ABSOLUTE_PATH=""
CUSTOM_ALT_TEXT=""
MAX_ALT_LINES=50
NO_CLIPBOARD=false
SILICON_OPTS=()

# Show help
show_help() {
  cat << EOF
${COLOR_BOLD}${COLOR_CYAN}screenshot-with-fallback${COLOR_RESET} - Screenshots with markdown fallback

Create beautiful code screenshots and generate markdown with the code
content as alt-text. Perfect for READMEs with graceful degradation!

${COLOR_BOLD}Usage:${COLOR_RESET}
  screenshot-with-fallback <file> [output-image] [options]
  screenshot-with-fallback init.lua
  screenshot-with-fallback init.lua docs/images/init.png
  screenshot-with-fallback config.sh --relative-path images/

${COLOR_BOLD}Arguments:${COLOR_RESET}
  file                  File to screenshot (required)
  output-image          Output image path (default: <file>.png)

${COLOR_BOLD}Options:${COLOR_RESET}
  --relative-path PATH  Image path for markdown (e.g., "images/")
  --absolute-path PATH  Absolute path for markdown (e.g., "/docs/images/")
  --alt-text TEXT       Custom alt text (default: file content)
  --max-alt-lines N     Max lines in alt text (default: 50)
  --no-clipboard        Don't copy markdown to clipboard
  --theme THEME         Silicon theme (default: OneHalfDark)
  --transparent         Transparent background
  --no-window           No window chrome
  --help                Show this help message

${COLOR_BOLD}Output:${COLOR_RESET}
  1. Creates beautiful screenshot with screenshot-code
  2. Generates markdown with code as alt-text
  3. Copies markdown to clipboard (ready to paste!)

${COLOR_BOLD}Markdown Format:${COLOR_RESET}
  ![
  <file content as alt-text>
  ](path/to/image.png)

${COLOR_BOLD}Examples:${COLOR_RESET}
  ${COLOR_BLUE}# Simple screenshot${COLOR_RESET}
  screenshot-with-fallback init.lua

  ${COLOR_BLUE}# With relative path for README${COLOR_RESET}
  screenshot-with-fallback init.lua docs/images/init.png --relative-path images/

  ${COLOR_BLUE}# Custom styling${COLOR_RESET}
  screenshot-with-fallback config.sh --transparent --no-window

  ${COLOR_BLUE}# Just generate markdown, no clipboard${COLOR_RESET}
  screenshot-with-fallback init.lua --no-clipboard

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      show_help
      exit 0
      ;;
    --relative-path)
      RELATIVE_PATH="$2"
      shift 2
      ;;
    --absolute-path)
      ABSOLUTE_PATH="$2"
      shift 2
      ;;
    --alt-text)
      CUSTOM_ALT_TEXT="$2"
      shift 2
      ;;
    --max-alt-lines)
      MAX_ALT_LINES="$2"
      shift 2
      ;;
    --no-clipboard)
      NO_CLIPBOARD=true
      shift
      ;;
    --theme)
      SILICON_OPTS+=(--theme "$2")
      shift 2
      ;;
    --transparent)
      SILICON_OPTS+=(--transparent)
      shift
      ;;
    --no-window)
      SILICON_OPTS+=(--no-window)
      shift
      ;;
    -*)
      echo "${COLOR_RED}Unknown option: $1${COLOR_RESET}"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      if [[ -z "$INPUT_FILE" ]]; then
        INPUT_FILE="$1"
      elif [[ -z "$OUTPUT_IMAGE" ]]; then
        OUTPUT_IMAGE="$1"
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

# Check if screenshot-code is available
if ! command -v screenshot-code &> /dev/null; then
  echo "${COLOR_RED}Error: screenshot-code is not installed${COLOR_RESET}"
  echo "Run: ${COLOR_CYAN}./bin/link_dotfiles.zsh${COLOR_RESET} from dotfiles directory"
  exit 1
fi

# Generate output image path if not specified
if [[ -z "$OUTPUT_IMAGE" ]]; then
  OUTPUT_IMAGE="${INPUT_FILE:r}.png"
fi

# Show info
echo "${COLOR_BOLD}${COLOR_CYAN}📸 Screenshot with Fallback Generator${COLOR_RESET}"
echo ""
echo "${COLOR_BLUE}Input:  ${COLOR_RESET}$INPUT_FILE"
echo "${COLOR_BLUE}Output: ${COLOR_RESET}$OUTPUT_IMAGE"
echo ""

# Step 1: Create screenshot
echo "${COLOR_CYAN}Step 1: Creating screenshot...${COLOR_RESET}"
if screenshot-code "$INPUT_FILE" "$OUTPUT_IMAGE" "${SILICON_OPTS[@]}"; then
  echo "${COLOR_GREEN}✓ Screenshot created${COLOR_RESET}"
else
  echo "${COLOR_RED}✗ Screenshot failed${COLOR_RESET}"
  exit 1
fi

echo ""

# Step 2: Generate alt text
echo "${COLOR_CYAN}Step 2: Generating alt text...${COLOR_RESET}"

if [[ -n "$CUSTOM_ALT_TEXT" ]]; then
  ALT_TEXT="$CUSTOM_ALT_TEXT"
else
  # Read file content for alt text
  ALT_TEXT=$(head -n "$MAX_ALT_LINES" "$INPUT_FILE")

  # Check if file was truncated
  TOTAL_LINES=$(wc -l < "$INPUT_FILE")
  if [[ $TOTAL_LINES -gt $MAX_ALT_LINES ]]; then
    ALT_TEXT="$ALT_TEXT
... (${TOTAL_LINES} total lines, showing first ${MAX_ALT_LINES})"
  fi
fi

echo "${COLOR_GREEN}✓ Alt text generated ($( echo "$ALT_TEXT" | wc -l | xargs ) lines)${COLOR_RESET}"
echo ""

# Step 3: Determine image path for markdown
echo "${COLOR_CYAN}Step 3: Generating markdown...${COLOR_RESET}"

if [[ -n "$ABSOLUTE_PATH" ]]; then
  IMAGE_PATH="$ABSOLUTE_PATH/$(basename "$OUTPUT_IMAGE")"
elif [[ -n "$RELATIVE_PATH" ]]; then
  IMAGE_PATH="$RELATIVE_PATH/$(basename "$OUTPUT_IMAGE")"
else
  IMAGE_PATH="$OUTPUT_IMAGE"
fi

# Generate markdown
MARKDOWN="![
$ALT_TEXT
]($IMAGE_PATH)"

echo "${COLOR_GREEN}✓ Markdown generated${COLOR_RESET}"
echo ""

# Step 4: Copy to clipboard
if [[ "$NO_CLIPBOARD" == "false" ]]; then
  echo "${COLOR_CYAN}Step 4: Copying to clipboard...${COLOR_RESET}"

  # Detect clipboard command
  if command -v pbcopy &> /dev/null; then
    # macOS
    echo "$MARKDOWN" | pbcopy
    echo "${COLOR_GREEN}✓ Copied to clipboard (macOS)${COLOR_RESET}"
  elif command -v xclip &> /dev/null; then
    # Linux with xclip
    echo "$MARKDOWN" | xclip -selection clipboard
    echo "${COLOR_GREEN}✓ Copied to clipboard (xclip)${COLOR_RESET}"
  elif command -v xsel &> /dev/null; then
    # Linux with xsel
    echo "$MARKDOWN" | xsel --clipboard
    echo "${COLOR_GREEN}✓ Copied to clipboard (xsel)${COLOR_RESET}"
  else
    echo "${COLOR_YELLOW}⚠ Clipboard not available (install pbcopy/xclip/xsel)${COLOR_RESET}"
    NO_CLIPBOARD=true
  fi
  echo ""
fi

# Show preview
echo "${COLOR_BOLD}${COLOR_MAGENTA}Preview:${COLOR_RESET}"
echo "${COLOR_BLUE}────────────────────────────────────────${COLOR_RESET}"
echo "$MARKDOWN" | head -20
if [[ $(echo "$MARKDOWN" | wc -l) -gt 20 ]]; then
  echo "${COLOR_BLUE}... (truncated for preview)${COLOR_RESET}"
fi
echo "${COLOR_BLUE}────────────────────────────────────────${COLOR_RESET}"
echo ""

# Summary
echo "${COLOR_GREEN}${COLOR_BOLD}✓ Complete!${COLOR_RESET}"
echo ""
echo "${COLOR_BLUE}Screenshot:${COLOR_RESET} $OUTPUT_IMAGE"
echo "${COLOR_BLUE}Image path:${COLOR_RESET} $IMAGE_PATH"
if [[ "$NO_CLIPBOARD" == "false" ]]; then
  echo "${COLOR_GREEN}Ready to paste into your README! 📋${COLOR_RESET}"
else
  echo "${COLOR_YELLOW}Markdown available above (clipboard not used)${COLOR_RESET}"
fi
