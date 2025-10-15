#!/usr/bin/env zsh

# ============================================================================
# Ruby Gems Installation
# ============================================================================
#
# Installs Ruby gems from a centralized package list.
# Uses shared libraries for package management, validation, and UI.
#
# Dependencies:
#   - ruby (Ruby interpreter) → system package (brew install ruby)
#   - gem (Ruby package manager) → installed with Ruby
#
# Package list: config/packages/ruby-gems.list
#
# Note: Some gems may require sudo for system-wide installation.
#       Solargraph (Ruby LSP) is installed via system package manager.
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
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"
source "$LIB_DIR/arguments.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_LIST="$CONFIG_DIR/packages/ruby-gems.list"
UPDATE_MODE=false

# ============================================================================
# Help Function
# ============================================================================

function show_help() {
    standard_help_header "ruby-gems.zsh" \
        "Installs Ruby gems from centralized list using gem"
    echo "  --update        Update installed gems instead of installing new ones"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "${COLOR_BOLD}EXAMPLES:${COLOR_RESET}"
    echo "  # Install gems from list"
    echo "  ./ruby-gems.zsh"
    echo ""
    echo "  # Update all installed gems"
    echo "  ./ruby-gems.zsh --update"
    exit 0
}

# ============================================================================
# Argument Parsing
# ============================================================================

# Parse arguments using shared library
parse_simple_flags "$@"
is_help_requested && show_help

# Set modes based on parsed flags
[[ "$ARG_UPDATE" == "true" ]] && UPDATE_MODE=true

# Validate no unknown arguments remain
validate_no_unknown_args "$@" || exit 1

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "ruby" "Ruby interpreter" ""
declare_dependency_command "gem" "Ruby package manager" ""

# ============================================================================
# Main Execution
# ============================================================================

if $UPDATE_MODE; then
    draw_header "Ruby Gems" "Updating Ruby gems"
else
    draw_header "Ruby Gems" "Installing Ruby gems"
fi
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show Ruby version
if command_exists ruby; then
    local ruby_version=$(ruby --version | cut -d' ' -f2)
    print_success "Ruby available (version: $ruby_version)"
fi

echo

if $UPDATE_MODE; then
    # ========================================================================
    # Update Mode: Update all installed gems
    # ========================================================================

    draw_section_header "Updating Installed Gems"

    gem update 2>&1 | grep -E "(Updating|Successfully)" | while IFS= read -r line; do
        echo "  $line"
    done

    if [[ $? -eq 0 ]]; then
        echo
        print_success "Gems updated successfully"
    else
        echo
        print_warning "Some gems may have failed to update"
    fi

    draw_section_header "Cleaning Up Old Versions"

    gem cleanup >/dev/null 2>&1
    print_success "Cleanup complete"

else
    # ========================================================================
    # Install Mode: Install gems from list
    # ========================================================================

    draw_section_header "Installing Gems from List"

    # Check if package list exists
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        print_error "Package list not found: $PACKAGE_LIST"
        exit 1
    fi

    # Install gems from list
    gem_install_from_list "$PACKAGE_LIST"

    echo
    print_success "Ruby gems installation complete!"
fi

# ============================================================================
# Summary
# ============================================================================

echo
draw_section_header "Installation Summary"

# Show installed gems
if command_exists gem; then
    print_info "📦 Installed Ruby gems:"
    echo
    gem list --local 2>/dev/null | head -20 | while read -r line; do
        # Extract gem name
        local gem_name=$(echo "$line" | cut -d' ' -f1)
        [[ -n "$gem_name" ]] && echo "   • $gem_name"
    done
fi

echo
print_info "📝 Note: Solargraph (Ruby LSP with linting/formatting) is installed via system package manager"

echo
print_success "$(get_random_friend_greeting)"
