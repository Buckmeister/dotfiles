#!/usr/bin/env zsh

# ============================================================================
# Git General Settings Configuration
# ============================================================================
#
# Configures global Git settings for consistent behavior across repositories.
# Uses shared libraries for consistent UI and validation.
#
# Dependencies:
#   - git → system package
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
source "$LIB_DIR/greetings.zsh"

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
# Dependency Declaration
# ============================================================================

declare_dependency_command "git" "Git version control" ""

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Git General Settings" "Configuring global Git settings"
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show git version
if command_exists git; then
    local git_version=$(git --version | awk '{print $3}')
    print_success "git available (version: $git_version)"
fi

echo

# ============================================================================
# Configuration
# ============================================================================

draw_section_header "Configuring Git Settings"

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

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Configuration Summary"

print_info "📦 Configured settings:"
echo
echo "   • User identity: $GIT_USER_NAME <$GIT_USER_EMAIL>"
echo "   • Default branch: main"
echo "   • Log format: pretty with colors"
echo "   • Global gitignore: ~/.gitignore"

echo
print_info "💡 Tip: Override user settings in env/personal.env with GIT_USER_NAME and GIT_USER_EMAIL"

echo
print_success "$(get_random_friend_greeting)"
