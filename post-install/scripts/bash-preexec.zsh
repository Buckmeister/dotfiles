#!/usr/bin/env zsh

# ============================================================================
# Bash PreExec Installation
# ============================================================================
#
# Downloads bash-preexec for shell timing functionality.
# Uses shared libraries for consistent downloading and validation.
#
# Dependencies: NONE
#   Downloads bash-preexec script directly from GitHub.
#
# Repository: https://github.com/rcaloras/bash-preexec
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
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/installers.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

BASH_PREEXEC_URL="https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh"
BASH_PREEXEC_PATH="$HOME/.bash-preexec.sh"

# ============================================================================
# Main Execution
# ============================================================================

draw_header "bash-preexec" "Shell timing functionality"
echo

# ============================================================================
# Installation
# ============================================================================

draw_section_header "Installing bash-preexec"

# Check if already installed
if [[ -f "$BASH_PREEXEC_PATH" ]]; then
    print_success "bash-preexec already installed"
    print_info "Location: $BASH_PREEXEC_PATH"
else
    # Download bash-preexec
    if download_file "$BASH_PREEXEC_URL" "$BASH_PREEXEC_PATH" "bash-preexec"; then
        print_success "bash-preexec installed successfully!"
    else
        print_error "Failed to install bash-preexec"
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
echo "   • bash-preexec (shell timing functionality)"

echo
print_info "📍 Location: $BASH_PREEXEC_PATH"

echo
print_success "$(get_random_friend_greeting)"
