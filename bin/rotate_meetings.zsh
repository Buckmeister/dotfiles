#!/usr/bin/env zsh

# ============================================================================
# Meetings.md Log Rotation - Keep Project History Manageable
# ============================================================================
#
# Rotates the Meetings.md file in logrotate style to prevent it from
# growing too large. Archives older entries while keeping a fresh file
# for ongoing work.
#
# Features:
#   - Logrotate-style rotation (rename → compress → create fresh file)
#   - Configurable retention (keep last N rotated files)
#   - Dry-run mode for safe testing
#   - Automatic cleanup of old archives
#   - Preserves file header and structure
#
# Usage:
#   rotate_meetings.zsh                    # Rotate with defaults (keep 5)
#   rotate_meetings.zsh --keep 3           # Keep only last 3 archives
#   rotate_meetings.zsh --dry-run          # Preview without changes
#
# Files:
#   Meetings.md                  # Current meeting notes (local-only)
#   Meetings-YYYY-MM-DD.md.gz    # Archived rotated files
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

MEETINGS_FILE="${DF_DIR}/Meetings.md"
KEEP_COUNT=5
DRY_RUN=false

# ============================================================================
# Help Message
# ============================================================================

function show_help() {
    cat <<EOF
$(draw_header "Meetings.md Log Rotation")

USAGE:
    rotate_meetings.zsh [OPTIONS]

OPTIONS:
    --keep N         Keep last N rotated files (default: 5)
    --dry-run, -n    Show what would be done without making changes
    -h, --help       Show this help message

DESCRIPTION:
    Rotates Meetings.md in logrotate style to keep project history
    manageable while preserving all content in compressed archives.

    ${COLOR_BOLD}${UI_ACCENT_COLOR}Rotation Process:${COLOR_RESET}

    1. Renames Meetings.md to Meetings-YYYY-MM-DD.md
    2. Compresses to Meetings-YYYY-MM-DD.md.gz
    3. Creates new empty Meetings.md with header
    4. Removes old rotated files (keeps last N)

EXAMPLES:
    ${UI_INFO_COLOR}# Rotate with defaults (keep 5)${COLOR_RESET}
    rotate_meetings.zsh

    ${UI_INFO_COLOR}# Keep only last 3 rotated files${COLOR_RESET}
    rotate_meetings.zsh --keep 3

    ${UI_INFO_COLOR}# Dry run to preview${COLOR_RESET}
    rotate_meetings.zsh --dry-run

FILES:
    Meetings.md                  - Current meeting notes
    Meetings-YYYY-MM-DD.md.gz    - Archived rotated files

LOCATION:
    All files in \$DOTFILES_ROOT/ directory

NOTE:
    Meetings.md is local-only (not tracked in git) to preserve privacy
    and reduce repository size. Archives are also local-only.

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
            --keep)
                if [[ -z "$2" || "$2" =~ ^- ]]; then
                    print_error "--keep requires a number argument"
                    exit 1
                fi
                KEEP_COUNT="$2"
                shift 2
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
# Main Rotation Logic
# ============================================================================

function rotate_meetings() {
    local timestamp=$(date +%Y-%m-%d)
    local rotated_name="Meetings-${timestamp}.md"
    local compressed_name="${rotated_name}.gz"

    # Check if Meetings.md exists
    if [[ ! -f "$MEETINGS_FILE" ]]; then
        print_error "Meetings.md not found at: $MEETINGS_FILE"
        return 1
    fi

    # Get current file size for reporting
    local size=$(du -h "$MEETINGS_FILE" | cut -f1)
    local lines=$(wc -l < "$MEETINGS_FILE")

    print_info "Current Meetings.md: $lines lines, $size"

    if $DRY_RUN; then
        draw_section_header "Dry Run - Preview Mode"
        echo
        print_info "Would perform the following actions:"
        print_info "  1. Rename: Meetings.md → ${rotated_name}"
        print_info "  2. Compress: ${rotated_name} → ${compressed_name}"
        print_info "  3. Create new empty Meetings.md with header"
        print_info "  4. Keep last $KEEP_COUNT rotated files"
        echo

        # Show what would be cleaned up
        local old_files=(${DF_DIR}/Meetings-*.md.gz(N))
        if [[ ${#old_files[@]} -gt $KEEP_COUNT ]]; then
            local to_remove=$((${#old_files[@]} - $KEEP_COUNT))
            print_info "  5. Would remove $to_remove old archive(s)"
        fi
        return 0
    fi

    # Step 1: Rename current file
    draw_section_header "Step 1: Renaming Meetings.md"
    if ! mv "$MEETINGS_FILE" "${DF_DIR}/${rotated_name}"; then
        print_error "Failed to rename file"
        return 1
    fi
    print_success "Renamed to ${rotated_name}"

    # Step 2: Compress the rotated file
    draw_section_header "Step 2: Compressing Archive"
    if ! gzip "${DF_DIR}/${rotated_name}"; then
        print_error "Failed to compress file"
        # Try to restore original
        mv "${DF_DIR}/${rotated_name}" "$MEETINGS_FILE"
        return 1
    fi
    print_success "Compressed to ${compressed_name}"

    # Step 3: Create new empty Meetings.md with header
    draw_section_header "Step 3: Creating Fresh Meetings.md"
    cat > "$MEETINGS_FILE" <<'EOF'
# Projekt Meetings - Dotfiles Repository

*Diese Datei ist privat und wird nicht in Git eingecheckt (.gitignore)*

---

## Archive

Previous meeting notes have been rotated and compressed:
- Check `Meetings-*.md.gz` files for historical records
- Use `gunzip -c Meetings-YYYY-MM-DD.md.gz` to read archived notes

---

EOF

    print_success "Created fresh Meetings.md"

    # Step 4: Clean up old rotated files (keep last N)
    draw_section_header "Step 4: Cleaning Old Archives"
    local rotated_files=(${DF_DIR}/Meetings-*.md.gz(N))
    local num_rotated=${#rotated_files[@]}

    if [[ $num_rotated -gt $KEEP_COUNT ]]; then
        local num_to_remove=$((num_rotated - $KEEP_COUNT))
        print_info "Removing $num_to_remove old archive(s) (keeping last $KEEP_COUNT)..."

        # Sort by modification time and remove oldest
        local sorted_files=(${(f)"$(ls -t ${DF_DIR}/Meetings-*.md.gz 2>/dev/null)"})
        local files_to_remove=(${sorted_files:$KEEP_COUNT})

        for file in "${files_to_remove[@]}"; do
            print_info "  Removing: $(basename "$file")"
            rm "$file"
        done
        print_success "Cleanup complete"
    else
        print_info "No cleanup needed (${num_rotated} archive(s) ≤ ${KEEP_COUNT} limit)"
    fi
}

# ============================================================================
# Main Entry Point
# ============================================================================

function main() {
    # Parse arguments
    parse_args "$@"

    # Show header in interactive mode
    if ! $DRY_RUN; then
        draw_header "Meetings.md Log Rotation"
        echo
    fi

    # Perform rotation
    if rotate_meetings; then
        echo
        print_success "Meetings.md rotated successfully!"

        # Show archive stats
        local archives=(${DF_DIR}/Meetings-*.md.gz(N))
        print_info "Current archives: ${#archives[@]} file(s)"

        # Friendly greeting
        echo
        get_random_friend_greeting
    else
        echo
        print_error "Rotation failed"
        return 1
    fi
}

# Run main function
main "$@"
