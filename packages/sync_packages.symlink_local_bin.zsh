#!/usr/bin/env zsh

# ============================================================================
# Package Manifest Synchronization Script
# ============================================================================
#
# Keeps your package manifest synchronized with your system's actual state.
# Regenerates the manifest from currently installed packages and optionally
# commits changes to git.
#
# Usage:
#   sync_packages [options]
#
# Options:
#   --update      Regenerate manifest from current system
#   --push        Commit and push changes to git
#   --message MSG Custom commit message
#   -h, --help    Show help
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/.config/dotfiles}"
LIB_DIR="$DOTFILES_ROOT/bin/lib"

if [[ -f "$LIB_DIR/colors.zsh" ]]; then
  source "$LIB_DIR/colors.zsh"
  source "$LIB_DIR/ui.zsh"
  source "$LIB_DIR/utils.zsh"
  source "$LIB_DIR/greetings.zsh"
else
  print_error() { echo "ERROR: $*" >&2; }
  print_success() { echo "✓ $*"; }
  print_info() { echo "→ $*"; }
  print_warning() { echo "⚠ $*"; }
  command_exists() { command -v "$1" &>/dev/null; }
fi

# ============================================================================
# Configuration
# ============================================================================

MANIFEST_FILE="$HOME/.local/share/dotfiles/packages.yaml"
DO_UPDATE=true
DO_PUSH=false
CUSTOM_MESSAGE=""

# ============================================================================
# Functions
# ============================================================================

show_help() {
  cat <<EOF
${BOLD}Package Manifest Synchronization${RESET}

Keeps your package manifest synchronized with your system. Regenerates the
manifest from currently installed packages and optionally commits changes
to version control.

${BOLD}USAGE${RESET}
  sync_packages [options]

${BOLD}OPTIONS${RESET}
  --update             Regenerate manifest from current system (default)
  --push               Commit and push changes to git after update
  --message MSG        Custom commit message
  -h, --help           Show this help message

${BOLD}EXAMPLES${RESET}
  # Update manifest from current system
  sync_packages

  # Update and commit to git
  sync_packages --push

  # Update with custom commit message
  sync_packages --push --message "Add new development tools"

${BOLD}WHAT IT DOES${RESET}
  1. Scans all package managers on your system
  2. Regenerates package manifest
  3. Shows what changed
  4. Optionally commits and pushes to git

${BOLD}DOCUMENTATION${RESET}
  ~/.config/dotfiles/packages/README.md

EOF
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      --update)
        DO_UPDATE=true
        shift
        ;;
      --push)
        DO_PUSH=true
        shift
        ;;
      --message)
        CUSTOM_MESSAGE="$2"
        shift 2
        ;;
      *)
        print_error "Unknown option: $1"
        echo "Run with --help for usage information"
        exit 1
        ;;
    esac
  done
}

# ============================================================================
# Main Execution
# ============================================================================

parse_arguments "$@"

draw_header "Package Synchronization" "Keep your manifest up to date"
echo

# ============================================================================
# Backup existing manifest
# ============================================================================

if [[ -f "$MANIFEST_FILE" ]]; then
  draw_section_header "Backup"
  
  local backup_file="${MANIFEST_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$MANIFEST_FILE" "$backup_file"
  print_success "Backed up existing manifest to: $backup_file"
  echo
fi

# ============================================================================
# Regenerate manifest
# ============================================================================

draw_section_header "Regenerating Manifest"

if [[ "$DO_UPDATE" == true ]]; then
  print_info "Scanning system packages..."
  echo
  
  if command_exists generate_package_manifest; then
    generate_package_manifest -o "$MANIFEST_FILE" -f
  else
    print_error "generate_package_manifest command not found"
    print_info "Make sure it's in your PATH: ~/.local/bin"
    exit 1
  fi
else
  print_info "Skipping update (use --update to regenerate)"
fi

echo

# ============================================================================
# Show changes
# ============================================================================

if [[ -f "${MANIFEST_FILE}.backup."* ]]; then
  draw_section_header "Changes"
  
  local latest_backup=$(ls -t "${MANIFEST_FILE}.backup."* 2>/dev/null | head -1)
  if [[ -n "$latest_backup" ]]; then
    print_info "Comparing with previous version..."
    echo
    
    local added=$(diff "$latest_backup" "$MANIFEST_FILE" 2>/dev/null | grep "^>" | wc -l | tr -d ' ')
    local removed=$(diff "$latest_backup" "$MANIFEST_FILE" 2>/dev/null | grep "^<" | wc -l | tr -d ' ')
    
    if [[ $added -gt 0 ]] || [[ $removed -gt 0 ]]; then
      print_info "${GREEN}+${added}${RESET} lines added, ${RED}-${removed}${RESET} lines removed"
      
      if [[ $added -gt 0 ]]; then
        echo
        print_info "New packages added:"
        diff "$latest_backup" "$MANIFEST_FILE" 2>/dev/null | grep "^> .*id:" | sed 's/^> /  /' | head -10
      fi
      
      if [[ $removed -gt 0 ]]; then
        echo
        print_info "Packages removed:"
        diff "$latest_backup" "$MANIFEST_FILE" 2>/dev/null | grep "^< .*id:" | sed 's/^< /  /' | head -10
      fi
    else
      print_success "No changes detected"
    fi
  fi
  
  echo
fi

# ============================================================================
# Git integration
# ============================================================================

if [[ "$DO_PUSH" == true ]]; then
  draw_section_header "Git Integration"
  
  if ! command_exists git; then
    print_error "Git not found - cannot push changes"
    exit 1
  fi
  
  # Check if manifest is in a git repo
  if ! git -C "$(dirname "$MANIFEST_FILE")" rev-parse --git-dir &>/dev/null; then
    print_warning "Manifest file is not in a git repository"
    print_info "Consider moving it to your dotfiles repo for version control"
    exit 0
  fi
  
  # Commit changes
  local commit_msg="${CUSTOM_MESSAGE:-Update package manifest - $(date '+%Y-%m-%d')}"
  
  print_info "Staging changes..."
  git -C "$(dirname "$MANIFEST_FILE")" add "$MANIFEST_FILE"
  
  if git -C "$(dirname "$MANIFEST_FILE")" diff --cached --quiet; then
    print_info "No changes to commit"
  else
    print_info "Committing changes..."
    git -C "$(dirname "$MANIFEST_FILE")" commit -m "$commit_msg"
    print_success "Changes committed"
    
    print_info "Pushing to remote..."
    if git -C "$(dirname "$MANIFEST_FILE")" push; then
      print_success "Pushed to remote successfully"
    else
      print_warning "Failed to push - you may need to push manually"
    fi
  fi
  
  echo
fi

# ============================================================================
# Summary
# ============================================================================

draw_section_header "Summary"

print_success "Manifest synchronized: ${CYAN}$MANIFEST_FILE${RESET}"

echo
print_info "💡 Next steps:"
echo "   ${DIM}# View the manifest${RESET}"
echo "   cat \"$MANIFEST_FILE\""
echo
echo "   ${DIM}# Install on another system${RESET}"
echo "   install_from_manifest"
echo
echo "   ${DIM}# Commit to git${RESET}"
echo "   sync_packages --push"

echo
print_success "$(get_random_friend_greeting)"
