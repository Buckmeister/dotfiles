#!/usr/bin/env zsh

# ============================================================================
# Automated Path Detection Refactoring Script
# ============================================================================
#
# This script refactors all zsh scripts to use consistent path detection
# from our shared utils.zsh library functions.
#
# What it does:
# 1. Adds standardized path detection using init_dotfiles_paths()
# 2. Removes inconsistent SCRIPT_DIR/DF_DIR/DOTFILES_ROOT patterns
# 3. Updates all scripts in bin/, post-install/scripts/, and tests/
#
# Usage:
#   ./bin/refactor_path_detection.zsh [--dry-run]
#
# Options:
#   --dry-run    Show what would be changed without making changes
#   --help       Show this help message
# ============================================================================

emulate -LR zsh

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

# Initialize paths using shared utility
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)
init_dotfiles_paths

# Load shared libraries
source "$DF_LIB_DIR/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load colors.zsh" >&2
    exit 1
}

source "$DF_LIB_DIR/ui.zsh" 2>/dev/null || {
    echo "Error: Could not load ui.zsh" >&2
    exit 1
}

# ============================================================================
# Configuration
# ============================================================================

DOTFILES_ROOT="$DF_DIR"

# Directories to refactor
REFACTOR_DIRS=(
    "$DOTFILES_ROOT/bin"
    "$DOTFILES_ROOT/post-install/scripts"
    "$DOTFILES_ROOT/tests/unit"
    "$DOTFILES_ROOT/tests/integration"
)

# Skip these files (they need special handling or are already correct)
SKIP_FILES=(
    "refactor_path_detection.zsh"
    "test_framework.zsh"
    "test_helpers.zsh"
)

DRY_RUN=false
BACKUP_DIR="$DOTFILES_ROOT/.tmp/path_refactor_backup_$(date +%Y%m%d-%H%M%S)"

# Statistics
typeset -i FILES_CHECKED=0
typeset -i FILES_MODIFIED=0
typeset -i FILES_SKIPPED=0

# ============================================================================
# Helper Functions
# ============================================================================
# Note: print_success, print_error, print_info, print_warning now come from ui.zsh

function show_help() {
    cat << 'EOF'
Automated Path Detection Refactoring Script

Usage:
  ./bin/refactor_path_detection.zsh [OPTIONS]

Options:
  --dry-run    Show what would be changed without making changes
  --help       Show this help message

What it does:
  1. Adds standardized path detection using init_dotfiles_paths()
  2. Removes inconsistent SCRIPT_DIR/DF_DIR/DOTFILES_ROOT patterns
  3. Creates backups before modifying files
  4. Updates all scripts in bin/, post-install/, and tests/

The standardized pattern:
  # Initialize dotfiles paths
  init_dotfiles_paths
  # After this, you have:
  #   $DF_DIR - Dotfiles root directory
  #   $DF_SCRIPT_DIR - Current script directory
  #   $DF_LIB_DIR - Shared libraries directory

EOF
    exit 0
}

function should_skip_file() {
    local file="$1"
    local basename="$(basename "$file")"

    for skip in "${SKIP_FILES[@]}"; do
        [[ "$basename" == "$skip" ]] && return 0
    done

    return 1
}

function backup_file() {
    local file="$1"
    local relative_path="${file#$DOTFILES_ROOT/}"
    local backup_path="$BACKUP_DIR/$relative_path"

    mkdir -p "$(dirname "$backup_path")"
    cp "$file" "$backup_path"
}

function needs_refactoring() {
    local file="$1"

    # Check if file already uses init_dotfiles_paths
    grep -q "init_dotfiles_paths" "$file" && return 1

    # Check if file has old-style path detection
    grep -qE "SCRIPT_DIR=.*dirname|DF_DIR=.*realpath|DOTFILES_ROOT=" "$file" && return 0

    return 1
}

function refactor_file() {
    local file="$1"
    local temp_file="/tmp/refactor_$$_$(basename "$file")"

    # Create temporary file with refactored content
    awk '
    BEGIN {
        in_path_section = 0
        path_section_start = 0
        emitted_new_section = 0
        found_emulate = 0
        after_shebang = 0
    }

    # Track shebang
    /^#!/ {
        print
        after_shebang = 1
        next
    }

    # Track emulate line
    /^emulate -LR zsh/ {
        found_emulate = 1
        print
        next
    }

    # Skip old path detection lines
    /^SCRIPT_DIR=/ || /^DF_DIR=/ || /^DOTFILES_ROOT=/ || /^export DF_DIR=/ {
        if (!emitted_new_section) {
            # Emit new standardized section
            if (found_emulate) {
                print ""
            }
            print "# ============================================================================"
            print "# Path Detection and Library Loading"
            print "# ============================================================================"
            print ""
            print "# Initialize paths using shared utility"
            print "SCRIPT_DIR=\"$(cd \"$(dirname \"$0\")\" && pwd)\""
            print "source \"$SCRIPT_DIR/../bin/lib/utils.zsh\" 2>/dev/null || source \"$SCRIPT_DIR/lib/utils.zsh\" 2>/dev/null || {"
            print "    echo \"Error: Could not load utils.zsh\" >&2"
            print "    exit 1"
            print "}"
            print ""
            print "# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)"
            print "init_dotfiles_paths"
            print ""
            emitted_new_section = 1
        }
        next
    }

    # Print all other lines
    {
        print
    }
    ' "$file" > "$temp_file"

    # Replace original file with refactored version
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would update: $file"
        print_info "Preview of changes:"
        diff -u "$file" "$temp_file" | head -30 || true
        rm "$temp_file"
    else
        backup_file "$file"
        mv "$temp_file" "$file"
        print_success "Refactored: $file"
        ((FILES_MODIFIED++))
    fi
}

# ============================================================================
# Main Refactoring Logic
# ============================================================================

function main() {
    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --dry-run)
                DRY_RUN=true
                ;;
            --help|-h)
                show_help
                ;;
            *)
                print_error "Unknown option: $arg"
                show_help
                ;;
        esac
    done

    print_info "============================================"
    print_info "Path Detection Refactoring Script"
    print_info "============================================"
    print_info ""

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE - No files will be modified"
        print_info ""
    else
        print_info "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi

    # Process all zsh files in target directories
    for dir in "${REFACTOR_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_warning "Directory not found: $dir"
            continue
        fi

        print_info "Processing directory: $dir"

        for file in "$dir"/*.zsh; do
            [[ ! -f "$file" ]] && continue

            ((FILES_CHECKED++))

            if should_skip_file "$file"; then
                print_info "Skipped (in skip list): $(basename "$file")"
                ((FILES_SKIPPED++))
                continue
            fi

            if needs_refactoring "$file"; then
                refactor_file "$file"
            else
                print_info "No changes needed: $(basename "$file")"
                ((FILES_SKIPPED++))
            fi
        done
    done

    # Print summary
    print_info ""
    print_info "============================================"
    print_info "Refactoring Summary"
    print_info "============================================"
    print_info "Files checked:  $FILES_CHECKED"
    print_success "Files modified: $FILES_MODIFIED"
    print_info "Files skipped:  $FILES_SKIPPED"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info ""
        print_warning "This was a dry run. No files were actually modified."
        print_info "Run without --dry-run to apply changes."
    else
        print_info ""
        print_success "Backup location: $BACKUP_DIR"
        print_info "All files backed up before modification."
    fi
}

main "$@"
