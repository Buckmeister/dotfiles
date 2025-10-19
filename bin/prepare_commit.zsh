#!/usr/bin/env zsh

# ============================================================================
# Pre-Commit Preparation - Quality Checks Before Committing
# ============================================================================
#
# Automates quality checks before git commits by validating documentation
# consistency and reminding about CHANGELOG.md updates.
#
# Features:
#   - Validates documentation consistency (check_docs.zsh)
#   - Checks CHANGELOG.md for recent work documentation
#   - Reminds to update ACTION_PLAN.md with completed work
#   - Can run manually or via git pre-commit hook
#
# Usage:
#   prepare_commit.zsh                     # Interactive mode with prompts
#   prepare_commit.zsh --auto              # Automatic (for git hooks)
#   prepare_commit.zsh --dry-run           # Preview without changes
#   prepare_commit.zsh --skip-docs         # Skip documentation check
#
# Integration:
#   Use setup_git_hooks.zsh to install as a pre-commit hook
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

ACTION_PLAN="${DF_DIR}/ACTION_PLAN.md"
CHANGELOG="${DF_DIR}/CHANGELOG.md"
CHECK_DOCS_SCRIPT="${DF_DIR}/bin/check_docs.zsh"
AUTO_MODE=false
DRY_RUN=false
SKIP_DOCS_CHECK=false

# ============================================================================
# Help Message
# ============================================================================

function show_help() {
    cat <<EOF
$(draw_header "Prepare Commit" "Quality checks before committing")

USAGE:
    prepare_commit.zsh [OPTIONS]

OPTIONS:
    --auto           Run automatically without prompts (for git hooks)
    --dry-run, -n    Show what would be done without making changes
    --skip-docs      Skip documentation consistency check
    -h, --help       Show this help message

DESCRIPTION:
    Prepares the repository for commit by running quality checks and
    reminding about documentation updates.

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Workflow:${COLOR_RESET}

    1. ${UI_SUCCESS_COLOR}Validate${COLOR_RESET} documentation consistency (check_docs.zsh)
    2. ${UI_SUCCESS_COLOR}Check${COLOR_RESET} CHANGELOG.md for recent updates
    3. ${UI_SUCCESS_COLOR}Remind${COLOR_RESET} to update ACTION_PLAN.md with completed work

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Benefits:${COLOR_RESET}

    • Documentation examples stay synchronized with code
    • CHANGELOG.md reminder ensures public documentation
    • ACTION_PLAN.md reminder keeps todo list current
    • Automated quality enforcement via git pre-commit hook

EXAMPLES:
    ${UI_INFO_COLOR}# Manual run with review${COLOR_RESET}
    prepare_commit.zsh

    ${UI_INFO_COLOR}# Dry run to preview changes${COLOR_RESET}
    prepare_commit.zsh --dry-run

    ${UI_INFO_COLOR}# Auto mode (used by git pre-commit hook)${COLOR_RESET}
    prepare_commit.zsh --auto

INTEGRATION:
    To use as a git pre-commit hook:

    ${UI_INFO_COLOR}ln -s ../../bin/prepare_commit.zsh .git/hooks/pre-commit${COLOR_RESET}

    Or use the setup script:

    ${UI_INFO_COLOR}./bin/setup_git_hooks.zsh${COLOR_RESET}

FILES:
    ACTION_PLAN.md  - Active, pending, and recently completed work
    CHANGELOG.md    - Public-facing release history and changes

EOF
}

# ============================================================================
# Parse Command Line Arguments
# ============================================================================

function parse_args() {
    # Parse common flags using shared library
    parse_simple_flags "$@"
    is_help_requested && { show_help; exit 0; }

    # Set dry-run mode from library variable
    [[ "$ARG_DRY_RUN" == "true" ]] && DRY_RUN=true

    # Parse script-specific flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                AUTO_MODE=true
                shift
                ;;
            --skip-docs)
                SKIP_DOCS_CHECK=true
                shift
                ;;
            # Skip flags already handled by library
            --dry-run|-n|--help|-h)
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
# Core Functions
# ============================================================================

# Check CHANGELOG.md for recent updates
function update_changelog() {
    local dry_run=$1

    draw_section_header "Checking CHANGELOG.md"

    # Check if there are recent git commits not in CHANGELOG
    local recent_commits=$(git log --since="7 days ago" --format="%s" --no-merges 2>/dev/null | head -5)

    if [[ -z "$recent_commits" ]]; then
        print_info "No recent commits to document"
        return 0
    fi

    if $dry_run; then
        print_info "Recent commits found:"
        echo "$recent_commits" | head -3 | while read -r line; do
            echo "  ${UI_ACCENT_COLOR}•${COLOR_RESET} $line"
        done
        return 0
    fi

    # Check if CHANGELOG has [Unreleased] section
    if ! grep -q "## \[Unreleased\]" "$CHANGELOG" 2>/dev/null; then
        print_warning "CHANGELOG.md has no [Unreleased] section"
        print_info "Consider adding recent work to CHANGELOG.md manually"
    else
        print_success "CHANGELOG.md has [Unreleased] section"
    fi
}

# Check documentation consistency
function check_documentation() {
    local dry_run=$1

    # Skip if flag is set
    if $SKIP_DOCS_CHECK; then
        if $AUTO_MODE; then
            # Silent in auto mode
            return 0
        else
            print_info "Skipping documentation consistency check (--skip-docs)"
            return 0
        fi
    fi

    draw_section_header "Checking Documentation Consistency"

    # Check if check_docs script exists
    if [[ ! -x "$CHECK_DOCS_SCRIPT" ]]; then
        print_warning "check_docs.zsh not found or not executable"
        print_info "Skipping documentation validation"
        return 0
    fi

    if $dry_run; then
        print_info "Would run: $CHECK_DOCS_SCRIPT"
        return 0
    fi

    # Run check_docs.zsh and capture output
    local output
    local exit_code
    output=$("$CHECK_DOCS_SCRIPT" 2>&1)
    exit_code=$?

    # Parse output for summary
    local issues_found=$(echo "$output" | grep -o "Found [0-9]* potential issue" | head -1)

    if [[ $exit_code -eq 0 ]]; then
        print_success "No documentation issues found"
    else
        # Show warning but don't block commit
        print_warning "Documentation consistency issues detected"

        if [[ -n "$issues_found" ]]; then
            print_info "$issues_found"
        fi

        if ! $AUTO_MODE; then
            echo
            print_info "Run ${COLOR_BOLD}./bin/check_docs.zsh --verbose${COLOR_RESET} for details"
            echo
            print_info "These are warnings only - commit will proceed"
        fi
    fi

    # Always return 0 (non-blocking)
    return 0
}

# ============================================================================
# Main Workflow
# ============================================================================

function main() {
    # Parse arguments
    parse_args "$@"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi

    # Check required files exist
    for file in "$ACTION_PLAN" "$CHANGELOG"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            exit 1
        fi
    done

    # Show header in non-auto mode
    if ! $AUTO_MODE; then
        draw_header "Prepare Commit" "Quality checks before committing"
        echo
    fi

    # Execute workflow
    check_documentation $DRY_RUN
    echo
    update_changelog $DRY_RUN

    # Show completion message in non-auto mode
    if ! $AUTO_MODE && ! $DRY_RUN; then
        echo
        draw_separator
        echo
        print_success "Pre-commit checks complete!"
        echo
        print_info "Remember to:"
        echo "  ${UI_ACCENT_COLOR}•${COLOR_RESET} Update ${COLOR_BOLD}ACTION_PLAN.md${COLOR_RESET} with completed/pending work"
        echo "  ${UI_ACCENT_COLOR}•${COLOR_RESET} Add entries to ${COLOR_BOLD}CHANGELOG.md${COLOR_RESET} for significant changes"
        echo
        get_random_friend_greeting
    fi
}

# Run main function
main "$@"
