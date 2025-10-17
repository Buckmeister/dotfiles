#!/usr/bin/env zsh

# ============================================================================
# Project Lombok Installation
# ============================================================================
#
# Downloads Project Lombok for Java development.
# Uses shared libraries for consistent downloading and OS-aware operations.
#
# Dependencies: NONE
#   Downloads Lombok JAR file directly from official website.
#
# Website: https://projectlombok.org/
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

LOMBOK_URL="https://projectlombok.org/downloads/lombok.jar"
LOMBOK_DIR="/usr/local/share/lombok"
LOMBOK_JAR="$LOMBOK_DIR/lombok.jar"

# ============================================================================
# Helper Functions
# ============================================================================

# OS-aware directory creation
function create_lombok_dir() {
    case "${DF_OS:-$(get_os)}" in
        macos)
            mkdir -p "$LOMBOK_DIR"
            ;;
        linux|wsl)
            sudo mkdir -p "$LOMBOK_DIR"
            ;;
        *)
            print_warning "Unknown OS, attempting standard directory creation..."
            mkdir -p "$LOMBOK_DIR" 2>/dev/null || sudo mkdir -p "$LOMBOK_DIR"
            ;;
    esac
}

# OS-aware file download
function download_lombok() {
    local temp_file="$DOWNLOAD_TEMP_DIR/lombok.jar"

    if ! download_file "$LOMBOK_URL" "$temp_file" "Project Lombok"; then
        return 1
    fi

    case "${DF_OS:-$(get_os)}" in
        macos)
            if mv "$temp_file" "$LOMBOK_JAR"; then
                return 0
            fi
            ;;
        linux|wsl)
            if sudo mv "$temp_file" "$LOMBOK_JAR"; then
                return 0
            fi
            ;;
        *)
            print_warning "Unknown OS, attempting standard file move..."
            if mv "$temp_file" "$LOMBOK_JAR" 2>/dev/null || sudo mv "$temp_file" "$LOMBOK_JAR"; then
                return 0
            fi
            ;;
    esac

    return 1
}

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Project Lombok" "Java annotation processing"
echo

# ============================================================================
# Installation
# ============================================================================

draw_section_header "Installing Project Lombok"

# Check if already installed
if [[ -f "$LOMBOK_JAR" ]]; then
    print_success "Project Lombok already installed"
    print_info "Location: $LOMBOK_JAR"
else
    # Create Lombok directory
    print_info "Creating Lombok directory..."
    if create_lombok_dir; then
        print_success "Directory created: $LOMBOK_DIR"
    else
        print_error "Failed to create Lombok directory"
        exit 1
    fi

    echo

    # Download Lombok
    if download_lombok; then
        print_success "Project Lombok installed successfully!"
    else
        print_error "Failed to install Project Lombok"
        exit 1
    fi
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

print_info "📦 Installed components:"
echo
echo "   • Project Lombok (Java annotation processing)"

echo
print_info "📍 Location: $LOMBOK_JAR"

echo
print_success "$(get_random_friend_greeting)"
