#!/usr/bin/env zsh

# ============================================================================
# Git Delta Configuration (Diff-So-Fancy Replacement)
# ============================================================================
#
# Configures Git to use delta for beautiful diffs.
# Delta is a modern replacement for diff-so-fancy with better syntax highlighting.
#
# Dependencies:
#   - git → system package
#   - delta (optional) → system package
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
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "git" "Git version control" ""
declare_dependency_command "delta" "Git syntax-highlighting pager" "git-delta.zsh"

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Git Delta Configuration" "Beautiful Git diffs with syntax highlighting"
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show versions
if command_exists git; then
    local git_version=$(git --version | awk '{print $3}')
    print_success "git available (version: $git_version)"
fi

if command_exists delta; then
    local delta_version=$(delta --version | head -1)
    print_success "delta available: $delta_version"
fi

echo

# ============================================================================
# Configuration
# ============================================================================

draw_section_header "Configuring Delta Settings"

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

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Configuration Summary"

print_info "📦 Configured settings:"
echo
echo "   • Git pager: delta"
echo "   • Interactive diff filter: delta --color-only"
echo "   • Color UI: enabled"
echo "   • Line numbers: enabled"
echo "   • Diff-so-fancy mode: enabled"
echo "   • Syntax theme: gruvbox-material"

echo
print_info "💡 Try it out: git diff or git log -p"

echo
print_success "$(get_random_friend_greeting)"
