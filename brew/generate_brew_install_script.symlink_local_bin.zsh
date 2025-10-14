#!/usr/bin/env zsh

# ============================================================================
# Homebrew Brewfile Generator
# ============================================================================
#
# Generates a Brewfile from your current Homebrew installation.
# A Brewfile is the official way to backup and restore Homebrew packages.
#
# Features:
#   - Captures all taps (third-party repositories)
#   - Captures all formulae (CLI tools)
#   - Captures all casks (GUI applications)
#   - Captures Mac App Store apps (if `mas` is installed)
#   - Uses official `brew bundle` commands for idempotent operations
#
# Usage:
#   generate_brew_install_script [options]
#
# Options:
#   -o, --output PATH    Output file path (default: ~/.local/share/Brewfile)
#   -f, --force          Overwrite existing Brewfile
#   -h, --help           Show this help message
#
# Generated Brewfile can be used with:
#   brew bundle install --file=/path/to/Brewfile
#
# Documentation: https://github.com/Homebrew/homebrew-bundle
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="${0:A:h}"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/greetings.zsh"

# ============================================================================
# Configuration
# ============================================================================

DEFAULT_OUTPUT="$HOME/.local/share/Brewfile"
OUTPUT_FILE=""
FORCE_OVERWRITE=false

# ============================================================================
# Functions
# ============================================================================

show_help() {
  cat <<EOF
${BOLD}Homebrew Brewfile Generator${RESET}

Generates a Brewfile from your current Homebrew installation using the
official 'brew bundle dump' command. A Brewfile is the recommended way
to backup and restore your Homebrew packages, including taps, formulae,
casks, and Mac App Store apps.

${BOLD}USAGE${RESET}
  generate_brew_install_script [options]

${BOLD}OPTIONS${RESET}
  -o, --output PATH    Output file path (default: ~/.local/share/Brewfile)
  -f, --force          Overwrite existing Brewfile without prompting
  -h, --help           Show this help message

${BOLD}EXAMPLES${RESET}
  # Generate Brewfile in default location
  generate_brew_install_script

  # Generate in custom location
  generate_brew_install_script -o ~/Desktop/Brewfile

  # Force overwrite existing file
  generate_brew_install_script -f

${BOLD}USING THE BREWFILE${RESET}
  # Install all packages from Brewfile
  brew bundle install --file=~/.local/share/Brewfile

  # Check what would be installed (dry run)
  brew bundle install --file=~/.local/share/Brewfile --dry-run

  # Cleanup packages not in Brewfile
  brew bundle cleanup --file=~/.local/share/Brewfile

${BOLD}DOCUMENTATION${RESET}
  https://github.com/Homebrew/homebrew-bundle

EOF
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      -o|--output)
        OUTPUT_FILE="$2"
        shift 2
        ;;
      -f|--force)
        FORCE_OVERWRITE=true
        shift
        ;;
      *)
        print_error "Unknown option: $1"
        echo "Run with --help for usage information"
        exit 1
        ;;
    esac
  done

  # Use default if no output specified
  if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="$DEFAULT_OUTPUT"
  fi
}

check_homebrew() {
  if ! command_exists brew; then
    print_error "Homebrew is not installed!"
    echo
    print_info "Install Homebrew with:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo
    exit 1
  fi
}

# ============================================================================
# Main Execution
# ============================================================================

parse_arguments "$@"

draw_header "Homebrew Brewfile Generator" "Backup your Homebrew installation"
echo

# ============================================================================
# Validation
# ============================================================================

draw_section_header "Checking Requirements"

check_homebrew

local brew_version=$(brew --version | head -1 | awk '{print $2}')
print_success "Homebrew $brew_version detected"

# Check for brew bundle
if ! brew bundle --help &>/dev/null; then
  print_warning "'brew bundle' command not found"
  print_info "This is usually bundled with Homebrew. Trying to continue anyway..."
fi

echo

# ============================================================================
# File Handling
# ============================================================================

draw_section_header "Output Configuration"

print_info "Output file: ${CYAN}$OUTPUT_FILE${RESET}"

# Create output directory if needed
local output_dir="${OUTPUT_FILE:h}"
if [[ ! -d "$output_dir" ]]; then
  print_info "Creating directory: $output_dir"
  mkdir -p "$output_dir" || {
    print_error "Failed to create directory: $output_dir"
    exit 1
  }
fi

# Check if file exists
if [[ -f "$OUTPUT_FILE" ]] && [[ "$FORCE_OVERWRITE" != true ]]; then
  echo
  print_warning "File already exists: $OUTPUT_FILE"
  print_info "Use --force to overwrite without prompting"
  echo
  echo -n "Overwrite existing file? [y/N] "
  read -r response
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_info "Cancelled"
    exit 0
  fi
fi

echo

# ============================================================================
# Generate Brewfile
# ============================================================================

draw_section_header "Generating Brewfile"

print_info "Analyzing Homebrew installation..."

# Count items before generation
local tap_count=$(brew tap | wc -l | tr -d ' ')
local formula_count=$(brew list --formula | wc -l | tr -d ' ')
local cask_count=$(brew list --cask | wc -l | tr -d ' ')
local mas_count=0

if command_exists mas; then
  mas_count=$(mas list | wc -l | tr -d ' ')
  print_info "Found: ${CYAN}$tap_count${RESET} taps, ${CYAN}$formula_count${RESET} formulae, ${CYAN}$cask_count${RESET} casks, ${CYAN}$mas_count${RESET} Mac App Store apps"
else
  print_info "Found: ${CYAN}$tap_count${RESET} taps, ${CYAN}$formula_count${RESET} formulae, ${CYAN}$cask_count${RESET} casks"
  print_info "Install 'mas' to backup Mac App Store apps: brew install mas"
fi

echo

# Generate Brewfile using official command
print_info "Generating Brewfile..."

if brew bundle dump --file="$OUTPUT_FILE" --force 2>&1 | grep -q "error"; then
  print_error "Failed to generate Brewfile"
  exit 1
fi

print_success "Brewfile generated successfully!"

echo

# ============================================================================
# Summary
# ============================================================================

draw_section_header "Summary"

print_success "Brewfile created: ${CYAN}$OUTPUT_FILE${RESET}"

local file_size=$(du -h "$OUTPUT_FILE" | awk '{print $1}')
print_info "File size: $file_size"

echo
print_info "📦 Contents:"
echo "   • ${CYAN}$tap_count${RESET} taps (third-party repositories)"
echo "   • ${CYAN}$formula_count${RESET} formulae (CLI tools)"
echo "   • ${CYAN}$cask_count${RESET} casks (GUI applications)"
if [[ $mas_count -gt 0 ]]; then
  echo "   • ${CYAN}$mas_count${RESET} Mac App Store apps"
fi

echo
print_info "💡 Usage:"
echo "   ${DIM}# Install all packages from this Brewfile${RESET}"
echo "   brew bundle install --file=\"$OUTPUT_FILE\""
echo
echo "   ${DIM}# Preview what would be installed (dry run)${RESET}"
echo "   brew bundle install --file=\"$OUTPUT_FILE\" --dry-run"
echo
echo "   ${DIM}# Remove packages not in Brewfile (cleanup)${RESET}"
echo "   brew bundle cleanup --file=\"$OUTPUT_FILE\""

echo
print_success "$(get_random_friend_greeting)"
