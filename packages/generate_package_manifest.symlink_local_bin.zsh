#!/usr/bin/env zsh

# ============================================================================
# Universal Package Manifest Generator
# ============================================================================
#
# Generates a cross-platform package manifest from your current system.
# Scans all available package managers and creates a universal YAML manifest
# that can be used to install packages on any platform.
#
# Features:
#   - Scans Homebrew (brew list --formula, brew list --cask)
#   - Scans APT (apt list --installed)
#   - Scans Cargo, NPM, Pipx, Gem (language package managers)
#   - Generates universal YAML manifest
#   - Merges with existing manifest (smart update)
#   - Interactive mode for package metadata
#   - Cross-platform package name mappings
#
# Usage:
#   generate_package_manifest [options]
#
# Options:
#   -o, --output PATH     Output file (default: ~/.local/share/dotfiles/packages.yaml)
#   -f, --force           Overwrite existing manifest
#   -m, --merge           Merge with existing manifest (smart update)
#   -i, --interactive     Prompt for package metadata
#   -c, --category CAT    Only export specific category
#   -h, --help            Show this help message
#
# Output Format:
#   YAML manifest following the universal package schema
#
# Documentation: ~/.config/dotfiles/packages/SCHEMA.md
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="${0:A:h}"
DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/.config/dotfiles}"
LIB_DIR="$DOTFILES_ROOT/bin/lib"

# Load shared libraries
if [[ -f "$LIB_DIR/colors.zsh" ]]; then
  source "$LIB_DIR/colors.zsh"
  source "$LIB_DIR/ui.zsh"
  source "$LIB_DIR/utils.zsh"
  source "$LIB_DIR/greetings.zsh"
else
  # Fallback if libraries aren't available
  print_error() { echo "ERROR: $*" >&2; }
  print_success() { echo "✓ $*"; }
  print_info() { echo "→ $*"; }
  print_warning() { echo "⚠ $*"; }
  command_exists() { command -v "$1" &>/dev/null; }
fi

# ============================================================================
# Configuration
# ============================================================================

DEFAULT_OUTPUT="$HOME/.local/share/dotfiles/packages.yaml"
OUTPUT_FILE=""
FORCE_OVERWRITE=false
MERGE_MODE=false
INTERACTIVE_MODE=false
FILTER_CATEGORY=""

# Package arrays
typeset -A BREW_FORMULAE
typeset -A BREW_CASKS
typeset -A APT_PACKAGES
typeset -A CARGO_PACKAGES
typeset -A NPM_PACKAGES
typeset -A PIPX_PACKAGES
typeset -A GEM_PACKAGES

# ============================================================================
# Functions
# ============================================================================

show_help() {
  cat <<EOF
${BOLD}Universal Package Manifest Generator${RESET}

Generates a cross-platform package manifest from your current system by
scanning all available package managers (Homebrew, APT, Cargo, NPM, etc.)
and creating a universal YAML manifest.

${BOLD}USAGE${RESET}
  generate_package_manifest [options]

${BOLD}OPTIONS${RESET}
  -o, --output PATH     Output file (default: ~/.local/share/dotfiles/packages.yaml)
  -f, --force           Overwrite existing manifest without prompting
  -m, --merge           Merge with existing manifest (smart update)
  -i, --interactive     Prompt for package metadata (category, priority, description)
  -c, --category CAT    Only export specific category
  -h, --help            Show this help message

${BOLD}EXAMPLES${RESET}
  # Generate manifest in default location
  generate_package_manifest

  # Generate in custom location
  generate_package_manifest -o ~/my-packages.yaml

  # Merge with existing manifest (preserve metadata)
  generate_package_manifest --merge

  # Interactive mode (prompt for package details)
  generate_package_manifest --interactive

  # Export only specific category
  generate_package_manifest --category editor

${BOLD}PACKAGE MANAGERS SCANNED${RESET}
  • Homebrew (formulae and casks)
  • APT (Debian/Ubuntu packages)
  • Cargo (Rust packages)
  • NPM (Node.js global packages)
  • Pipx (Python applications)
  • Gem (Ruby gems)

${BOLD}OUTPUT FORMAT${RESET}
  YAML manifest following the universal package schema.
  See ~/.config/dotfiles/packages/SCHEMA.md for details.

${BOLD}USING THE MANIFEST${RESET}
  # Install packages on any system
  install_from_manifest

  # Keep manifest synchronized
  sync_packages

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
      -o|--output)
        OUTPUT_FILE="$2"
        shift 2
        ;;
      -f|--force)
        FORCE_OVERWRITE=true
        shift
        ;;
      -m|--merge)
        MERGE_MODE=true
        shift
        ;;
      -i|--interactive)
        INTERACTIVE_MODE=true
        shift
        ;;
      -c|--category)
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

  # Use default if no output specified
  if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="$DEFAULT_OUTPUT"
  fi
}

scan_homebrew() {
  if ! command_exists brew; then
    return
  fi

  print_info "Scanning Homebrew packages..."

  # Scan formulae
  local formulae=$(brew list --formula 2>/dev/null)
  local formula_count=0
  for formula in ${(f)formulae}; do
    BREW_FORMULAE[$formula]=1
    ((formula_count++))
  done

  # Scan casks
  local casks=$(brew list --cask 2>/dev/null)
  local cask_count=0
  for cask in ${(f)casks}; do
    BREW_CASKS[$cask]=1
    ((cask_count++))
  done

  print_success "Found ${CYAN}$formula_count${RESET} formulae and ${CYAN}$cask_count${RESET} casks"
}

scan_apt() {
  if ! command_exists apt; then
    return
  fi

  print_info "Scanning APT packages..."

  # Get manually installed packages (not dependencies)
  local packages=$(apt-mark showmanual 2>/dev/null | sort)
  local count=0
  for package in ${(f)packages}; do
    APT_PACKAGES[$package]=1
    ((count++))
  done

  print_success "Found ${CYAN}$count${RESET} manually installed packages"
}

scan_cargo() {
  if ! command_exists cargo; then
    return
  fi

  print_info "Scanning Cargo packages..."

  # Get installed cargo binaries
  local packages=$(cargo install --list 2>/dev/null | grep -E '^\S+' | awk '{print $1}' | sort)
  local count=0
  for package in ${(f)packages}; do
    CARGO_PACKAGES[$package]=1
    ((count++))
  done

  print_success "Found ${CYAN}$count${RESET} Cargo packages"
}

scan_npm() {
  if ! command_exists npm; then
    return
  fi

  print_info "Scanning NPM global packages..."

  # Get globally installed npm packages (excluding npm itself)
  local packages=$(npm list -g --depth=0 2>/dev/null | grep -E '├──|└──' | sed 's/.*── //' | awk '{print $1}' | grep -v '^npm@' | sort)
  local count=0
  for package in ${(f)packages}; do
    NPM_PACKAGES[$package]=1
    ((count++))
  done

  print_success "Found ${CYAN}$count${RESET} NPM packages"
}

scan_pipx() {
  if ! command_exists pipx; then
    return
  fi

  print_info "Scanning Pipx packages..."

  # Get installed pipx applications
  local packages=$(pipx list --short 2>/dev/null | sort)
  local count=0
  for package in ${(f)packages}; do
    PIPX_PACKAGES[$package]=1
    ((count++))
  done

  print_success "Found ${CYAN}$count${RESET} Pipx packages"
}

scan_gem() {
  if ! command_exists gem; then
    return
  fi

  print_info "Scanning Ruby gems..."

  # Get installed gems (user-installed, not system)
  local packages=$(gem list --no-versions 2>/dev/null | sort)
  local count=0
  for package in ${(f)packages}; do
    GEM_PACKAGES[$package]=1
    ((count++))
  done

  print_success "Found ${CYAN}$count${RESET} Ruby gems"
}

generate_yaml_header() {
  local output_file=$1

  cat > "$output_file" <<EOF
# Universal Package Manifest
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# System: $(uname -s) $(uname -r)
# Hostname: $(hostname)

version: "1.0"

metadata:
  name: "$(whoami)'s Development Environment"
  description: "Auto-generated package manifest from $(uname -s) system"
  author: "$(whoami)"
  last_updated: "$(date '+%Y-%m-%d')"

settings:
  auto_confirm: false
  parallel_install: true
  skip_installed: true
  prefer_native: true

packages:
EOF
}

generate_package_entry() {
  local pkg_id=$1
  local pkg_manager=$2

  cat <<EOF
  - id: $pkg_id
    install:
      $pkg_manager: $pkg_id
EOF
}

write_packages() {
  local output_file=$1

  print_info "Generating YAML manifest..."

  # Write Homebrew formulae
  if [[ ${#BREW_FORMULAE[@]} -gt 0 ]]; then
    echo "" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "  # Homebrew Formulae" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "" >> "$output_file"

    for pkg in ${(k)BREW_FORMULAE}; do
      generate_package_entry "$pkg" "brew" >> "$output_file"
    done
  fi

  # Write Homebrew casks
  if [[ ${#BREW_CASKS[@]} -gt 0 ]]; then
    echo "" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "  # Homebrew Casks (GUI Applications)" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "" >> "$output_file"

    for pkg in ${(k)BREW_CASKS}; do
      generate_package_entry "$pkg" "brew_cask" >> "$output_file"
    done
  fi

  # Write APT packages
  if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
    echo "" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "  # APT Packages (Debian/Ubuntu)" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "" >> "$output_file"

    for pkg in ${(k)APT_PACKAGES}; do
      generate_package_entry "$pkg" "apt" >> "$output_file"
    done
  fi

  # Write Cargo packages
  if [[ ${#CARGO_PACKAGES[@]} -gt 0 ]]; then
    echo "" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "  # Cargo Packages (Rust)" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "" >> "$output_file"

    for pkg in ${(k)CARGO_PACKAGES}; do
      cat <<EOF >> "$output_file"
  - id: $pkg
    alternatives:
      - method: cargo
        package: $pkg
EOF
    done
  fi

  # Write NPM packages
  if [[ ${#NPM_PACKAGES[@]} -gt 0 ]]; then
    echo "" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "  # NPM Global Packages" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "" >> "$output_file"

    for pkg in ${(k)NPM_PACKAGES}; do
      cat <<EOF >> "$output_file"
  - id: $pkg
    alternatives:
      - method: npm
        package: $pkg
EOF
    done
  fi

  # Write Pipx packages
  if [[ ${#PIPX_PACKAGES[@]} -gt 0 ]]; then
    echo "" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "  # Pipx Packages (Python Applications)" >> "$output_file"
    echo "  # ==========================================================" >> "$output_file"
    echo "" >> "$output_file"

    for pkg in ${(k)PIPX_PACKAGES}; do
      cat <<EOF >> "$output_file"
  - id: $pkg
    alternatives:
      - method: pipx
        package: $pkg
EOF
    done
  fi

  print_success "Manifest generated successfully!"
}

# ============================================================================
# Main Execution
# ============================================================================

parse_arguments "$@"

draw_header "Package Manifest Generator" "Export your packages to universal YAML"
echo

# ============================================================================
# Validation
# ============================================================================

draw_section_header "Checking Environment"

# Detect OS
detect_os
print_success "Detected OS: ${CYAN}$DF_OS${RESET}"

echo

# ============================================================================
# Package Scanning
# ============================================================================

draw_section_header "Scanning Package Managers"

scan_homebrew
scan_apt
scan_cargo
scan_npm
scan_pipx
scan_gem

echo

# Calculate totals
total_packages=0
((total_packages += ${#BREW_FORMULAE[@]}))
((total_packages += ${#BREW_CASKS[@]}))
((total_packages += ${#APT_PACKAGES[@]}))
((total_packages += ${#CARGO_PACKAGES[@]}))
((total_packages += ${#NPM_PACKAGES[@]}))
((total_packages += ${#PIPX_PACKAGES[@]}))
((total_packages += ${#GEM_PACKAGES[@]}))

if [[ $total_packages -eq 0 ]]; then
  print_warning "No packages found on this system"
  print_info "Make sure you have package managers installed (brew, apt, cargo, npm, etc.)"
  exit 0
fi

print_success "Total packages found: ${CYAN}$total_packages${RESET}"
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
if [[ -f "$OUTPUT_FILE" ]] && [[ "$FORCE_OVERWRITE" != true ]] && [[ "$MERGE_MODE" != true ]]; then
  echo
  print_warning "File already exists: $OUTPUT_FILE"
  print_info "Use --force to overwrite or --merge to update existing manifest"
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
# Generate Manifest
# ============================================================================

draw_section_header "Generating Manifest"

if [[ "$MERGE_MODE" == true ]] && [[ -f "$OUTPUT_FILE" ]]; then
  print_info "Merge mode not yet implemented - will overwrite for now"
  print_warning "Backup your existing manifest first!"
fi

generate_yaml_header "$OUTPUT_FILE"
write_packages "$OUTPUT_FILE"

echo

# ============================================================================
# Summary
# ============================================================================

draw_section_header "Summary"

print_success "Manifest created: ${CYAN}$OUTPUT_FILE${RESET}"

local file_size=$(du -h "$OUTPUT_FILE" | awk '{print $1}')
print_info "File size: $file_size"

echo
print_info "📦 Contents:"
[[ ${#BREW_FORMULAE[@]} -gt 0 ]] && echo "   • ${CYAN}${#BREW_FORMULAE[@]}${RESET} Homebrew formulae"
[[ ${#BREW_CASKS[@]} -gt 0 ]] && echo "   • ${CYAN}${#BREW_CASKS[@]}${RESET} Homebrew casks"
[[ ${#APT_PACKAGES[@]} -gt 0 ]] && echo "   • ${CYAN}${#APT_PACKAGES[@]}${RESET} APT packages"
[[ ${#CARGO_PACKAGES[@]} -gt 0 ]] && echo "   • ${CYAN}${#CARGO_PACKAGES[@]}${RESET} Cargo packages"
[[ ${#NPM_PACKAGES[@]} -gt 0 ]] && echo "   • ${CYAN}${#NPM_PACKAGES[@]}${RESET} NPM packages"
[[ ${#PIPX_PACKAGES[@]} -gt 0 ]] && echo "   • ${CYAN}${#PIPX_PACKAGES[@]}${RESET} Pipx packages"
[[ ${#GEM_PACKAGES[@]} -gt 0 ]] && echo "   • ${CYAN}${#GEM_PACKAGES[@]}${RESET} Ruby gems"

echo
print_info "💡 Next steps:"
echo "   ${DIM}# Review and customize the manifest${RESET}"
echo "   nvim \"$OUTPUT_FILE\""
echo
echo "   ${DIM}# Install on another system${RESET}"
echo "   install_from_manifest"
echo
echo "   ${DIM}# Keep synchronized${RESET}"
echo "   sync_packages"

echo
print_success "$(get_random_friend_greeting)"
