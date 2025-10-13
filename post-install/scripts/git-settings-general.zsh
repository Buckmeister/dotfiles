#!/usr/bin/env zsh

# ============================================================================
# Git General Settings Configuration
# ============================================================================
#
# Configures global Git settings for consistent behavior across repositories.
# Uses shared libraries for consistent UI and validation.
#
# Settings configured:
# - User name and email (from personal.env)
# - Default branch name
# - Log date format
# - Global gitignore
# - Pretty log format
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
# Configuration
# ============================================================================

# User configuration (can be overridden in personal.env)
: ${GIT_USER_NAME:="Thomas Burk"}
: ${GIT_USER_EMAIL:="t.burk@bckx.de"}

# ============================================================================
# Main Configuration
# ============================================================================

draw_header "Git General Settings" "Configuring global Git settings"
echo

# Validate git is available
if ! validate_command git "git"; then
    print_error "git not found - please install Git first"
    exit 1
fi

echo

# Configure user identity
print_info "Configuring user identity..."
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
print_success "User: $GIT_USER_NAME <$GIT_USER_EMAIL>"

echo

# Configure log settings
print_info "Configuring log settings..."
git config --global log.date "relative"
git config --global format.pretty "format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s"
print_success "Log format configured"

echo

# Configure default branch
print_info "Configuring default branch..."
git config --global init.defaultBranch main
print_success "Default branch: main"

echo

# Configure global gitignore
print_info "Configuring global gitignore..."
git config --global core.excludesfile "${HOME}/.gitignore"
print_success "Global gitignore: ~/.gitignore"

echo
print_success "Git general settings configured successfully!"
print_info "💡 Tip: Override user settings in config/personal.env with GIT_USER_NAME and GIT_USER_EMAIL"

echo
print_success "$(get_random_friend_greeting)"
