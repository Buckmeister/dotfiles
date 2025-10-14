#!/usr/bin/env zsh

# ============================================================================
# Universal Package Installer - install_from_manifest
# ============================================================================
#
# Installs packages from a universal YAML manifest on the current platform.
# Supports multiple package managers and cross-platform installation.
#
# Usage:
#   install_from_manifest [options]
#
# Options:
#   -i, --input PATH         Input manifest (default: ~/.local/share/dotfiles/packages.yaml)
#   --dry-run                Show what would be installed without installing
#   --required-only          Install only required packages
#   --category CATEGORY      Install only specific category
#   -h, --help               Show help
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

DEFAULT_INPUT="$HOME/.local/share/dotfiles/packages.yaml"
INPUT_FILE=""
DRY_RUN=false
REQUIRED_ONLY=false
FILTER_CATEGORY=""

# ============================================================================
# Functions
# ============================================================================

show_help() {
  cat <<EOF
${BOLD}Universal Package Installer${RESET}

Installs packages from a universal YAML manifest on your current platform.
Automatically detects available package managers and installs packages using
the appropriate method for your system.

${BOLD}USAGE${RESET}
  install_from_manifest [options]

${BOLD}OPTIONS${RESET}
  -i, --input PATH         Input manifest (default: ~/.local/share/dotfiles/packages.yaml)
  --dry-run                Show what would be installed without actually installing
  --required-only          Install only packages marked as required
  --category CATEGORY      Install only packages in specific category
  -h, --help               Show this help message

${BOLD}EXAMPLES${RESET}
  # Install all packages from default manifest
  install_from_manifest

  # Dry run to see what would be installed
  install_from_manifest --dry-run

  # Install only required packages
  install_from_manifest --required-only

  # Install only editor packages
  install_from_manifest --category editor

  # Use custom manifest
  install_from_manifest -i ~/my-packages.yaml

${BOLD}SUPPORTED PACKAGE MANAGERS${RESET}
  • Homebrew (brew, brew_cask)
  • APT (Debian/Ubuntu)
  • Cargo (Rust packages)
  • NPM (Node.js global packages)
  • Pipx (Python applications)

${BOLD}DOCUMENTATION${RESET}
  ~/.config/dotfiles/packages/README.md
  ~/.config/dotfiles/packages/SCHEMA.md

EOF
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      -i|--input)
        INPUT_FILE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --required-only)
        REQUIRED_ONLY=true
        shift
        ;;
      --category)
        FILTER_CATEGORY="$2"
        shift 2
        ;;
      *)
        print_error "Unknown option: $1"
        echo "Run with --help for usage information"
        exit 1
        ;;
    esac
  done

  if [[ -z "$INPUT_FILE" ]]; then
    INPUT_FILE="$DEFAULT_INPUT"
  fi
}

install_with_brew() {
  local package=$1
  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would install: brew install $package"
    return 0
  fi

  if brew list "$package" &>/dev/null; then
    print_info "Already installed: $package"
    return 0
  fi

  print_info "Installing with brew: $package"
  if brew install "$package" 2>&1 | grep -v "^=="; then
    print_success "Installed: $package"
    return 0
  else
    print_error "Failed to install: $package"
    return 1
  fi
}

install_with_brew_cask() {
  local package=$1
  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would install: brew install --cask $package"
    return 0
  fi

  if brew list --cask "$package" &>/dev/null; then
    print_info "Already installed: $package"
    return 0
  fi

  print_info "Installing with brew cask: $package"
  if brew install --cask "$package" 2>&1 | grep -v "^=="; then
    print_success "Installed: $package"
    return 0
  else
    print_error "Failed to install: $package"
    return 1
  fi
}

install_with_apt() {
  local package=$1
  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would install: apt install $package"
    return 0
  fi

  if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
    print_info "Already installed: $package"
    return 0
  fi

  print_info "Installing with apt: $package"
  if sudo apt install -y "$package" 2>&1 | grep -E "(Setting up|Processing)"; then
    print_success "Installed: $package"
    return 0
  else
    print_error "Failed to install: $package"
    return 1
  fi
}

install_with_cargo() {
  local package=$1
  if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would install: cargo install $package"
    return 0
  fi

  if cargo install --list | grep -q "^$package v"; then
    print_info "Already installed: $package"
    return 0
  fi

  print_info "Installing with cargo: $package"
  if cargo install "$package" 2>&1 | tail -5; then
    print_success "Installed: $package"
    return 0
  else
    print_error "Failed to install: $package"
    return 1
  fi
}

parse_and_install() {
  local manifest_file=$1
  local in_packages_section=false
  local current_id=""
  local install_method=""
  local install_package=""

  while IFS= read -r line; do
    # Detect packages section
    if [[ "$line" =~ ^packages: ]]; then
      in_packages_section=true
      continue
    fi

    if [[ ! "$in_packages_section" == true ]]; then
      continue
    fi

    # Parse package ID
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*id:[[:space:]]*(.+) ]]; then
      current_id="${match[1]}"
      install_method=""
      install_package=""
      continue
    fi

    # Parse install section
    if [[ "$line" =~ ^[[:space:]]*install: ]]; then
      # Next lines will be package manager mappings
      continue
    fi

    # Parse package manager mappings
    if [[ -n "$current_id" ]]; then
      if [[ "$line" =~ ^[[:space:]]*brew:[[:space:]]*(.+) ]]; then
        if command_exists brew; then
          install_method="brew"
          install_package="${match[1]}"
        fi
      elif [[ "$line" =~ ^[[:space:]]*brew_cask:[[:space:]]*(.+) ]]; then
        if command_exists brew; then
          install_method="brew_cask"
          install_package="${match[1]}"
        fi
      elif [[ "$line" =~ ^[[:space:]]*apt:[[:space:]]*(.+) ]]; then
        if command_exists apt; then
          install_method="apt"
          install_package="${match[1]}"
        fi
      elif [[ "$line" =~ ^[[:space:]]*cargo:[[:space:]]*(.+) ]]; then
        if command_exists cargo; then
          install_method="cargo"
          install_package="${match[1]}"
        fi
      fi

      # Install when we have both method and package
      if [[ -n "$install_method" ]] && [[ -n "$install_package" ]] && [[ "$install_package" != "null" ]]; then
        case "$install_method" in
          brew)
            install_with_brew "$install_package"
            ;;
          brew_cask)
            install_with_brew_cask "$install_package"
            ;;
          apt)
            install_with_apt "$install_package"
            ;;
          cargo)
            install_with_cargo "$install_package"
            ;;
        esac
        install_method=""
        install_package=""
      fi
    fi
  done < "$manifest_file"
}

# ============================================================================
# Main Execution
# ============================================================================

parse_arguments "$@"

draw_header "Package Installer" "Install from universal manifest"
echo

# Validation
if [[ ! -f "$INPUT_FILE" ]]; then
  print_error "Manifest file not found: $INPUT_FILE"
  echo
  print_info "Generate one with: generate_package_manifest"
  exit 1
fi

# Detect OS
draw_section_header "Checking Environment"
detect_os
print_success "Detected OS: ${CYAN}$DF_OS${RESET}"
echo

# Show manifest info
draw_section_header "Manifest Information"
print_info "Reading: ${CYAN}$INPUT_FILE${RESET}"

local package_count=$(grep -c "^  - id:" "$INPUT_FILE" 2>/dev/null || echo "0")
print_info "Packages in manifest: ${CYAN}$package_count${RESET}"

if [[ "$DRY_RUN" == true ]]; then
  print_warning "DRY RUN MODE - No packages will be installed"
fi

echo

# Installation
draw_section_header "Installing Packages"

if [[ "$DRY_RUN" == true ]]; then
  print_info "Preview of what would be installed:"
  echo
fi

parse_and_install "$INPUT_FILE"

echo

# Summary
draw_section_header "Summary"

if [[ "$DRY_RUN" == true ]]; then
  print_success "Dry run complete!"
  print_info "Run without --dry-run to actually install packages"
else
  print_success "Installation complete!"
fi

echo
print_success "$(get_random_friend_greeting)"
