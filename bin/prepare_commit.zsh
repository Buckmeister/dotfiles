#!/usr/bin/env zsh

# ============================================================================
# Pre-Commit Preparation - Clean and Archive Before Committing
# ============================================================================
#
# Automates repository cleanup before git commits by archiving completed
# work from ACTION_PLAN.md to Meetings.md and validating CHANGELOG.md.
#
# Features:
#   - Detects completed phases in ACTION_PLAN.md (marked with ✅)
#   - Archives them to Meetings.md (local-only file)
#   - Checks CHANGELOG.md for recent work documentation
#   - Stages Meetings.md for commit
#   - Can run manually or via git pre-commit hook
#
# Usage:
#   prepare_commit.zsh                     # Interactive mode with prompts
#   prepare_commit.zsh --auto              # Automatic (for git hooks)
#   prepare_commit.zsh --dry-run           # Preview without changes
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
MEETINGS="${DF_DIR}/Meetings.md"
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
$(draw_header "Prepare Commit" "Archive completed work before committing")

USAGE:
    prepare_commit.zsh [OPTIONS]

OPTIONS:
    --auto           Run automatically without prompts (for git hooks)
    --dry-run, -n    Show what would be done without making changes
    --skip-docs      Skip documentation consistency check
    -h, --help       Show this help message

DESCRIPTION:
    Prepares the repository for commit by automatically managing
    completed work, validating documentation consistency, and
    ensuring project documentation is up to date.

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Workflow:${COLOR_RESET}

    1. ${UI_SUCCESS_COLOR}Detect${COLOR_RESET} completed phases in ACTION_PLAN.md (marked with ✅)
    2. ${UI_SUCCESS_COLOR}Archive${COLOR_RESET} them to Meetings.md (local-only file)
    3. ${UI_SUCCESS_COLOR}Check${COLOR_RESET} CHANGELOG.md for recent updates
    4. ${UI_SUCCESS_COLOR}Validate${COLOR_RESET} documentation consistency (check_docs.zsh)
    5. ${UI_SUCCESS_COLOR}Stage${COLOR_RESET} Meetings.md for git commit

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Benefits:${COLOR_RESET}

    • ACTION_PLAN.md stays focused on active work
    • Historical context preserved in Meetings.md
    • CHANGELOG.md reminder ensures documentation
    • Automated via git pre-commit hook

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
    ACTION_PLAN.md  - Active project todo list
    Meetings.md     - Project history archive (local-only)
    CHANGELOG.md    - Public changelog

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

# Extract completed phases from ACTION_PLAN.md
function extract_completed_phases() {
    local action_plan="$1"
    local temp_file=$(mktemp)

    # Look for completed phases in "Completed Work" section
    # Format: "- Phase N: Name ✅ **(Date)**"
    grep -E "^- Phase [0-9]+.*✅.*\*\*.*\*\*" "$action_plan" > "$temp_file" 2>/dev/null

    if [[ -s "$temp_file" ]]; then
        cat "$temp_file"
        rm "$temp_file"
        return 0
    else
        rm "$temp_file"
        return 1
    fi
}

# Check if there's anything to archive
function check_for_work() {
    draw_section_header "Scanning for Completed Work"

    local completed_count=$(extract_completed_phases "$ACTION_PLAN" | wc -l)

    if [[ $completed_count -eq 0 ]]; then
        print_info "No completed phases found - nothing to archive"
        return 1
    fi

    print_success "Found $completed_count completed phase(s) to process"

    if ! $AUTO_MODE && ! $DRY_RUN; then
        echo
        print_info "Completed phases:"
        extract_completed_phases "$ACTION_PLAN" | while read -r line; do
            echo "  ${UI_ACCENT_COLOR}•${COLOR_RESET} $line"
        done
        echo
    fi

    return 0
}

# Archive completed phases to Meetings.md
function archive_to_meetings() {
    local dry_run=$1

    draw_section_header "Archiving to Meetings.md"

    if $dry_run; then
        print_info "Would append to Meetings.md:"
        echo
        echo "  ${UI_INFO_COLOR}---${COLOR_RESET}"
        echo
        echo "  ${UI_ACCENT_COLOR}## Archived Completed Phases - $(date +%Y-%m-%d)${COLOR_RESET}"
        echo
        extract_completed_phases "$ACTION_PLAN" | while read -r line; do
            echo "  ${UI_INFO_COLOR}$line${COLOR_RESET}"
        done
        echo
        return 0
    fi

    # Append to Meetings.md
    {
        echo
        echo "---"
        echo
        echo "## Archived Completed Phases - $(date +%Y-%m-%d)"
        echo
        extract_completed_phases "$ACTION_PLAN"
        echo
    } >> "$MEETINGS"

    print_success "Archived to Meetings.md"
}

# Update CHANGELOG.md
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

# Stage files for commit
function stage_files() {
    local dry_run=$1

    draw_section_header "Staging Files"

    if $dry_run; then
        print_info "Would stage: Meetings.md"
        return 0
    fi

    # Only stage Meetings.md (it's local-only)
    # ACTION_PLAN.md and CHANGELOG.md are already tracked
    if git add "$MEETINGS" 2>/dev/null; then
        print_success "Staged Meetings.md"
    else
        print_warning "Could not stage Meetings.md (may not have changes)"
    fi
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
    for file in "$ACTION_PLAN" "$MEETINGS" "$CHANGELOG"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            exit 1
        fi
    done

    # Show header in non-auto mode
    if ! $AUTO_MODE; then
        draw_header "Prepare Commit" "Archive completed work before committing"
        echo
    fi

    # Check if there's work to do
    if ! check_for_work; then
        if ! $AUTO_MODE; then
            echo
            print_success "Repository is ready for commit!"
            echo
            get_random_friend_greeting
        fi
        exit 0
    fi

    # Prompt for confirmation in manual mode
    if ! $AUTO_MODE && ! $DRY_RUN; then
        echo
        draw_separator
        echo
        print_info "This will:"
        echo "  ${UI_ACCENT_COLOR}1.${COLOR_RESET} Archive completed phases to Meetings.md"
        echo "  ${UI_ACCENT_COLOR}2.${COLOR_RESET} Check CHANGELOG.md for updates"
        if ! $SKIP_DOCS_CHECK; then
            echo "  ${UI_ACCENT_COLOR}3.${COLOR_RESET} Validate documentation consistency"
        fi
        echo "  ${UI_ACCENT_COLOR}4.${COLOR_RESET} Stage Meetings.md for commit"
        echo

        read "response?${COLOR_BOLD}Proceed?${COLOR_RESET} [y/N] "
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Cancelled by user"
            exit 0
        fi
        echo
    fi

    # Execute workflow
    archive_to_meetings $DRY_RUN
    echo
    update_changelog $DRY_RUN
    echo
    check_documentation $DRY_RUN
    echo

    if ! $DRY_RUN; then
        stage_files false

        if ! $AUTO_MODE; then
            echo
            draw_separator
            echo
            print_success "Repository prepared for commit!"
            print_info "You can now commit with: ${COLOR_BOLD}git commit${COLOR_RESET}"
            echo
            get_random_friend_greeting
        fi
    fi
}

# Run main function
main "$@"
