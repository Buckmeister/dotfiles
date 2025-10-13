#!/usr/bin/env zsh

# ============================================================================
# Project Lombok Installation
# ============================================================================
#
# Downloads Project Lombok for Java development.
# Uses shared libraries for consistent downloading and OS-aware operations.
#
# Website: https://projectlombok.org/
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
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
        linux)
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
        linux)
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
# Main Installation
# ============================================================================

draw_header "Project Lombok" "Java annotation processing"
echo

# Check if already installed
if [[ -f "$LOMBOK_JAR" ]]; then
    print_success "Project Lombok already installed"
    print_info "Location: $LOMBOK_JAR"
    echo
    print_success "$(get_random_friend_greeting)"
    exit 0
fi

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
    print_info "Location: $LOMBOK_JAR"
else
    print_error "Failed to install Project Lombok"
    exit 1
fi

echo
print_success "$(get_random_friend_greeting)"
