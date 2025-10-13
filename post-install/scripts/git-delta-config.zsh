#!/usr/bin/env zsh

# ============================================================================
# Git Delta Configuration (Diff-So-Fancy Replacement)
# ============================================================================
#
# Configures Git to use delta for beautiful diffs.
# Delta is a modern replacement for diff-so-fancy with better syntax highlighting.
#
# Uses shared libraries for consistent UI and validation.
#
# Repository: https://github.com/dandavison/delta
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

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Main Configuration
# ============================================================================

draw_header "Git Delta Configuration" "Beautiful Git diffs with syntax highlighting"
echo

# Validate git is available
if ! validate_command git "git"; then
    print_error "git not found - please install Git first"
    exit 1
fi

echo

# Check if delta is installed
if ! command_exists delta; then
    print_warning "delta not found - please install it first"
    print_info "macOS: brew install git-delta"
    print_info "Linux: See https://github.com/dandavison/delta#installation"
    echo
    print_info "Skipping delta configuration"
    exit 0
fi

print_success "delta is installed"
echo

# Configure Git to use delta
print_info "Configuring Git to use delta as pager..."
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
print_success "Delta configured as Git pager"

echo

# Configure improved colors
print_info "Configuring color settings..."
git config --global color.ui true
print_success "Color UI enabled"

echo

# Configure delta-specific settings
print_info "Configuring delta settings..."
git config --global delta.line-numbers true
git config --global delta.diff-so-fancy true
git config --global delta.syntax-theme gruvbox-material
print_success "Delta settings configured"
print_info "  - Line numbers: enabled"
print_info "  - Diff-so-fancy mode: enabled"
print_info "  - Syntax theme: gruvbox-material"

echo
print_success "Git delta configuration complete!"
print_info "💡 Try it out: git diff or git log -p"

echo
print_success "$(get_random_friend_greeting)"
