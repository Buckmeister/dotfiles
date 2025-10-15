#!/usr/bin/env zsh

# ============================================================================
# Nerd Fonts Installation
# ============================================================================
#
# Downloads and installs Nerd Fonts (Linux only - macOS uses Homebrew).
# Uses shared libraries for consistent downloading and OS-aware operations.
#
# Dependencies:
#   - fc-cache (fontconfig) → system package (Linux only)
#
# Nerd Fonts: https://github.com/ryanoasis/nerd-fonts
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================


# ============================================================================
# Path Detection and Library Loading
# ============================================================================

# Initialize paths using shared utility
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../bin/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)
init_dotfiles_paths

LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/installers.zsh"
source "$LIB_DIR/os_operations.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

# Nerd Fonts version (can be overridden in config)
: ${NERD_FONTS_VERSION:="v3.1.1"}

# Fonts to install
NERD_FONTS=(
    "FiraCode"
    "Iosevka"
    "JetBrainsMono"
    "Hack"
    "Meslo"
)

# Base URL for downloads
NERD_FONTS_BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION"

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "fc-cache" "Font cache utility (fontconfig)" ""

# ============================================================================
# Main Installation
# ============================================================================

draw_header "Nerd Fonts Installation" "Installing patched fonts for terminals"
echo

# Check OS and skip if macOS
case "${DF_OS:-$(get_os)}" in
    macos)
        print_info "macOS detected - fonts should be installed via Homebrew"
        print_info "Use: brew install font-fira-code-nerd-font font-jetbrains-mono-nerd-font etc."
        print_info "Skipping manual font installation"
        echo
        print_success "$(get_random_friend_greeting)"
        exit 0
        ;;
    linux)
        print_success "Linux detected - proceeding with manual font installation"
        ;;
    *)
        print_warning "Unknown OS: ${DF_OS:-unknown}"
        print_info "Skipping font installation"
        exit 0
        ;;
esac

echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

echo

# Ensure fonts directory exists
print_info "Ensuring fonts directory exists..."
ensure_directory "$FONTS_DIR"
print_success "Fonts directory: $FONTS_DIR"

echo

# Create temporary directory for downloads
temp_dir=$(create_temp_dir "nerd-fonts")
print_info "Using temporary directory: $temp_dir"

echo

# Download and install each font
local installed_count=0
local failed_count=0

for font in "${NERD_FONTS[@]}"; do
    draw_section_header "Installing $font Nerd Font"

    local font_url="$NERD_FONTS_BASE_URL/${font}.zip"
    local font_archive="$temp_dir/${font}.zip"

    # Download font archive
    if download_file "$font_url" "$font_archive" "$font"; then
        # Extract to fonts directory
        if extract_archive "$font_archive" "$FONTS_DIR" "$font"; then
            ((installed_count++))
        else
            print_error "Failed to extract $font"
            ((failed_count++))
        fi
    else
        print_warning "Failed to download $font (may not exist in this version)"
        ((failed_count++))
    fi

    echo
done

# Refresh font cache
print_info "Refreshing font cache..."
if fc-cache -f -v >/dev/null 2>&1; then
    print_success "Font cache refreshed"
else
    print_warning "Failed to refresh font cache"
fi

# Clean up temporary directory
print_info "Cleaning up temporary files..."
rm -rf "$temp_dir"
print_success "Cleanup complete"

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Nerd Fonts installed:"
echo
for font in "${NERD_FONTS[@]}"; do
    echo "   • $font"
done

echo
print_info "📊 Installation results:"
echo "   • Successful: $installed_count fonts"
echo "   • Failed:     $failed_count fonts"
echo "   • Location:   $FONTS_DIR"

echo
print_success "$(get_random_friend_greeting)"
