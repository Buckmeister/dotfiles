#!/usr/bin/env zsh

# ============================================================================
# Bash PreExec Installation
# ============================================================================
#
# Downloads bash-preexec for shell timing functionality.
# Uses shared libraries for consistent downloading and validation.
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
# Main Installation
# ============================================================================

draw_header "bash-preexec" "Shell timing functionality"
echo

# Check if already installed
if [[ -f "$BASH_PREEXEC_PATH" ]]; then
    print_success "bash-preexec already installed"
    print_info "Location: $BASH_PREEXEC_PATH"
    echo
    print_success "$(get_random_friend_greeting)"
    exit 0
fi

# Download bash-preexec
if download_file "$BASH_PREEXEC_URL" "$BASH_PREEXEC_PATH" "bash-preexec"; then
    print_success "bash-preexec installed successfully!"
    print_info "Location: $BASH_PREEXEC_PATH"
else
    print_error "Failed to install bash-preexec"
    exit 1
fi

echo
print_success "$(get_random_friend_greeting)"
