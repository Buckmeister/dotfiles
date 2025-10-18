#!/usr/bin/env zsh

# ============================================================================
# Git Hooks Setup - Install Pre-Commit Automation
# ============================================================================
#
# Installs and manages git hooks for automated workflow enhancement.
# The pre-commit hook automatically archives completed work before commits.
#
# Features:
#   - Installs pre-commit hook for automatic preparation
#   - Safely checks for existing hooks before overwriting
#   - Can cleanly uninstall hooks
#   - Validates git repository presence
#
# Usage:
#   setup_git_hooks.zsh                    # Install hooks
#   setup_git_hooks.zsh --uninstall        # Remove hooks
#
# What the Hook Does:
#   Before every commit, it automatically:
#   - Detects completed phases in ACTION_PLAN.md
#   - Archives them to Meetings.md (local-only)
#   - Checks CHANGELOG.md is up to date
#   - Stages Meetings.md for commit
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

# Initialize paths using shared utility
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../bin/lib/utils.zsh" 2>/dev/null || source "$SCRIPT_DIR/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)
init_dotfiles_paths

LIB_DIR="${DF_LIB_DIR}"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/arguments.zsh"
source "$LIB_DIR/greetings.zsh"

# ============================================================================
# Configuration
# ============================================================================

GIT_HOOKS_DIR="${DF_DIR}/.git/hooks"
PRE_COMMIT_HOOK="${GIT_HOOKS_DIR}/pre-commit"
PREPARE_COMMIT_SCRIPT="${DF_DIR}/bin/prepare_commit.zsh"
UNINSTALL=false

# ============================================================================
# Help Message
# ============================================================================

function show_help() {
    cat <<EOF
$(draw_header "Git Hooks Setup" "Automate your workflow")

USAGE:
    setup_git_hooks.zsh [OPTIONS]

OPTIONS:
    --uninstall      Remove installed git hooks
    -h, --help       Show this help message

DESCRIPTION:
    Installs a pre-commit hook that automatically prepares your
    repository for commit by managing completed work.

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Hook Behavior:${COLOR_RESET}

    ${UI_SUCCESS_COLOR}Before every commit:${COLOR_RESET}

    1. Detects completed phases in ACTION_PLAN.md (✅ markers)
    2. Archives them to Meetings.md (local-only file)
    3. Checks CHANGELOG.md is up to date
    4. Stages Meetings.md for commit

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Benefits:${COLOR_RESET}

    • ACTION_PLAN.md stays clean and focused
    • Historical context preserved automatically
    • CHANGELOG.md reminder ensures documentation
    • Runs silently when there's nothing to do
    • Fails commit safely if archiving fails

EXAMPLES:
    ${UI_INFO_COLOR}# Install the pre-commit hook${COLOR_RESET}
    ./bin/setup_git_hooks.zsh

    ${UI_INFO_COLOR}# Remove the pre-commit hook${COLOR_RESET}
    ./bin/setup_git_hooks.zsh --uninstall

FILES:
    .git/hooks/pre-commit  - Git pre-commit hook
    bin/prepare_commit.zsh - The actual archiving script

MANUAL USAGE:
    You can still run prepare_commit.zsh manually:

    ${UI_INFO_COLOR}./bin/prepare_commit.zsh --dry-run${COLOR_RESET}  # Preview
    ${UI_INFO_COLOR}./bin/prepare_commit.zsh${COLOR_RESET}             # Execute

NOTES:
    - The hook only modifies Meetings.md (local-only file)
    - Safe to install - checks for existing hooks
    - Can be uninstalled anytime without data loss

EOF
}

# ============================================================================
# Parse Command Line Arguments
# ============================================================================

function parse_args() {
    # Parse common flags using shared library
    parse_simple_flags "$@"
    is_help_requested && { show_help; exit 0; }

    # Parse script-specific flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            # Skip flags already handled by library
            --help|-h)
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# Uninstall Hook
# ============================================================================

function uninstall_hook() {
    draw_header "Uninstall Git Hooks"
    echo

    if [[ ! -f "$PRE_COMMIT_HOOK" ]]; then
        print_info "No pre-commit hook installed"
        return 0
    fi

    # Check if it's our hook
    if ! grep -q "prepare_commit.zsh" "$PRE_COMMIT_HOOK" 2>/dev/null; then
        print_warning "Pre-commit hook exists but doesn't appear to be ours"
        print_info "Located at: $PRE_COMMIT_HOOK"
        echo
        read "response?${COLOR_BOLD}Remove anyway?${COLOR_RESET} [y/N] "
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Cancelled"
            return 0
        fi
    fi

    draw_section_header "Removing Hook"
    rm "$PRE_COMMIT_HOOK"
    print_success "Pre-commit hook removed"
    echo
    get_random_friend_greeting
}

# ============================================================================
# Install Hook
# ============================================================================

function install_hook() {
    draw_header "Git Hooks Setup" "Automate your workflow"
    echo

    draw_section_header "What This Does"
    print_info "Installs a pre-commit hook that automatically:"
    echo "  ${UI_ACCENT_COLOR}1.${COLOR_RESET} Archives completed phases from ACTION_PLAN.md to Meetings.md"
    echo "  ${UI_ACCENT_COLOR}2.${COLOR_RESET} Checks CHANGELOG.md is up to date"
    echo "  ${UI_ACCENT_COLOR}3.${COLOR_RESET} Stages Meetings.md for commit"
    echo

    # Check if hook already exists
    if [[ -f "$PRE_COMMIT_HOOK" ]]; then
        if grep -q "prepare_commit.zsh" "$PRE_COMMIT_HOOK" 2>/dev/null; then
            print_warning "Pre-commit hook already installed"
            echo
            read "response?${COLOR_BOLD}Reinstall?${COLOR_RESET} [y/N] "
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_info "Cancelled"
                return 0
            fi
        else
            print_warning "A different pre-commit hook already exists"
            print_info "Located at: $PRE_COMMIT_HOOK"
            echo
            read "response?${COLOR_BOLD}Overwrite?${COLOR_RESET} [y/N] "
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_info "Cancelled"
                print_info "You can manually integrate by editing: $PRE_COMMIT_HOOK"
                return 0
            fi
        fi
        echo
    fi

    # Create the pre-commit hook
    draw_section_header "Installing Hook"

    cat > "$PRE_COMMIT_HOOK" <<'HOOK_EOF'
#!/usr/bin/env zsh
# Pre-commit hook - Prepare repository for commit
# Generated by setup_git_hooks.zsh

# Get the dotfiles root (2 levels up from .git/hooks)
DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PREPARE_SCRIPT="${DOTFILES_ROOT}/bin/prepare_commit.zsh"

# Check if prepare_commit.zsh exists
if [[ ! -f "$PREPARE_SCRIPT" ]]; then
    echo "WARNING: prepare_commit.zsh not found at: $PREPARE_SCRIPT"
    echo "Skipping automatic preparation"
    exit 0
fi

# Run prepare_commit in auto mode
"$PREPARE_SCRIPT" --auto

# Exit with the script's exit code
exit $?
HOOK_EOF

    # Make hook executable
    chmod +x "$PRE_COMMIT_HOOK"

    print_success "Pre-commit hook installed!"
    echo

    draw_section_header "Next Steps"
    print_info "The hook will run automatically before every commit"
    print_info "To test it, try: ${COLOR_BOLD}./bin/prepare_commit.zsh --dry-run${COLOR_RESET}"
    echo
    print_info "To uninstall: ${COLOR_BOLD}./bin/setup_git_hooks.zsh --uninstall${COLOR_RESET}"
    echo

    get_random_friend_greeting
}

# ============================================================================
# Main Entry Point
# ============================================================================

function main() {
    # Parse arguments
    parse_args "$@"

    # Check if we're in a git repository
    if [[ ! -d "$GIT_HOOKS_DIR" ]]; then
        print_error "Not in a git repository or .git/hooks directory not found"
        exit 1
    fi

    # Execute based on mode
    if $UNINSTALL; then
        uninstall_hook
    else
        install_hook
    fi
}

# Run main function
main "$@"
