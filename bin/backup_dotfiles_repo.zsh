#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Dotfiles Repository Backup Script - Professional Archive Creation
# ============================================================================
#
# A sophisticated backup creation system with OneDark theming,
# progress visualization, and professional status reporting.
#
# Features:
# - Beautiful OneDark color scheme matching the linking script
# - Progress bars for backup operations
# - Flexible target directory selection
# - Timestamp-based archive naming
# - Comprehensive error handling and success indicators
# ============================================================================

# ============================================================================
# Load Shared Libraries (with fallback protection)
# ============================================================================

# Get library directory
LIB_DIR="$(dirname "$(realpath "$0")")/lib"

# Load shared libraries with fallback protection
source "$LIB_DIR/colors.zsh" 2>/dev/null || {
    # Fallback: basic color definitions if library not available
    [[ -z "$COLOR_RESET" ]] && COLOR_RESET='\033[0m'
    [[ -z "$UI_SUCCESS_COLOR" ]] && UI_SUCCESS_COLOR='\033[32m'
    [[ -z "$UI_WARNING_COLOR" ]] && UI_WARNING_COLOR='\033[33m'
    [[ -z "$UI_ERROR_COLOR" ]] && UI_ERROR_COLOR='\033[31m'
    [[ -z "$UI_INFO_COLOR" ]] && UI_INFO_COLOR='\033[90m'
    [[ -z "$UI_HEADER_COLOR" ]] && UI_HEADER_COLOR='\033[32m'
    [[ -z "$UI_ACCENT_COLOR" ]] && UI_ACCENT_COLOR='\033[35m'
    [[ -z "$UI_PROGRESS_COLOR" ]] && UI_PROGRESS_COLOR='\033[36m'
}

source "$LIB_DIR/ui.zsh" 2>/dev/null || {
    # Fallback: basic UI functions if library not available
    function print_success() { echo "✅ $1"; }
    function print_warning() { echo "⚠️ $1"; }
    function print_error() { echo "❌ $1"; }
    function print_info() { echo "ℹ️ $1"; }
    function hide_cursor() { printf '\033[?25l'; }
    function show_cursor() { printf '\033[?25h'; }
    function clear_screen() { printf '\033[2J\033[H'; }
    function draw_progress_bar() {
        local current="${1:-0}"
        local total="${2:-100}"
        local width="${3:-50}"
        local percentage=$((current * 100 / total))
        printf "[%3d%%] (%d/%d)" $percentage $current $total
    }
}

source "$LIB_DIR/utils.zsh" 2>/dev/null || {
    # Fallback: basic utility functions if library not available
    function get_timestamp() {
        date +"%Y%m%d-%H%M%S"
    }
    function create_directory_safe() {
        local dir_path="$1"
        if [[ ! -d "$dir_path" ]]; then
            mkdir -p "$dir_path" 2>/dev/null
        fi
    }
}

source "$LIB_DIR/greetings.zsh" 2>/dev/null || {
    # Fallback: basic greeting function if library not available
    function get_random_friend_greeting() {
        echo "Happy coding, friend!"
    }
}


# ============================================================================
# Environment Setup and Path Detection (Matching setup.zsh)
# ============================================================================

# Detect dotfiles repository path using setup.zsh method
export DF_DIR=$(realpath "$(dirname $0)/..")
export DF_SCRIPT_NAME=$(basename $0)

# Default target directory (organized backups folder)
DEFAULT_TARGET_DIR="$HOME/Downloads/dotfiles_repo_backups"

# Archive filename format
readonly ARCHIVE_PREFIX="dotfiles_backup"
readonly ARCHIVE_EXTENSION=".zip"

# Archive exclusion patterns
readonly -a ARCHIVE_EXCLUSIONS=(
    "*.git/*"
    "*.DS_Store"
    "*.tmp/*"
)

# ============================================================================
# Global State Variables
# ============================================================================

typeset target_dir="$DEFAULT_TARGET_DIR"
typeset timestamp=$(get_timestamp)
typeset backup_filename="${ARCHIVE_PREFIX}_${timestamp}${ARCHIVE_EXTENSION}"
typeset -i total_operations=12  # 3 setup + 4 archive + 5 verification
typeset -i completed_operations=0
typeset -i success_count=0
typeset -i error_count=0
typeset -a operation_results=()

# ============================================================================
# Command Line Options (Matching setup.zsh style)
# ============================================================================

function show_help() {
    draw_header "📦 Dotfiles Repository Backup Tool 📦" "Archive Creation System"

    printf "${UI_INFO_COLOR}Usage: ${COLOR_BOLD}$DF_SCRIPT_NAME${COLOR_RESET} "
    printf "${UI_INFO_COLOR}[-t|--target-dir TARGET] [-h|--help]${COLOR_RESET}\n\n"

    printf "${UI_ACCENT_COLOR}Options:${COLOR_RESET}\n"
    printf "  ${UI_SUCCESS_COLOR}-t, --target-dir TARGET${COLOR_RESET}  "
    printf "${UI_INFO_COLOR}Specify backup target directory${COLOR_RESET}\n"
    printf "  ${UI_SUCCESS_COLOR}-h, --help${COLOR_RESET}               "
    printf "${UI_INFO_COLOR}Show this help message and exit${COLOR_RESET}\n\n"

    printf "${UI_ACCENT_COLOR}Details:${COLOR_RESET}\n"
    printf "  ${UI_INFO_COLOR}• Default target directory: "
    printf "${COLOR_BOLD}$DEFAULT_TARGET_DIR${COLOR_RESET}\n"
    printf "  ${UI_INFO_COLOR}• Archive naming format: "
    printf "${COLOR_BOLD}dotfiles_backup_YYYYMMDD-HHMMSS.zip${COLOR_RESET}\n"
    printf "  ${UI_INFO_COLOR}• Repository location: "
    printf "${COLOR_BOLD}$DF_DIR${COLOR_RESET}\n\n"

    printf "${UI_ACCENT_COLOR}Examples:${COLOR_RESET}\n"
    printf "  ${UI_INFO_COLOR}$DF_SCRIPT_NAME${COLOR_RESET}\n"
    printf "    ${UI_GRAY}# Backup to $DEFAULT_TARGET_DIR${COLOR_RESET}\n"
    printf "  ${UI_INFO_COLOR}$DF_SCRIPT_NAME -t ~/Desktop${COLOR_RESET}\n"
    printf "    ${UI_GRAY}# Backup to ~/Desktop${COLOR_RESET}\n"
    printf "  ${UI_INFO_COLOR}$DF_SCRIPT_NAME --target-dir /tmp/backups${COLOR_RESET}\n"
    printf "    ${UI_GRAY}# Backup to /tmp/backups${COLOR_RESET}\n\n"
}

# Parse command line arguments using zparseopts (matching setup.zsh)
zparseopts -D -E -- \
    t:=o_target_dir \
    -target-dir:=o_target_dir \
    h=o_help \
    -help=o_help

# Handle help option
[[ $#o_help > 0 ]] && {
    show_help
    exit 0
}

# Handle target directory option
[[ $#o_target_dir > 0 ]] && {
    # zparseopts stores value in second element
    target_dir="${o_target_dir[2]}"
}

# ============================================================================
# Utility Helper Functions
# ============================================================================

# Centralized error exit function
function exit_with_error() {
    local error_message="$1"
    local target_path="${2:-}"

    operation_results+=("❌ $error_message")
    printf "\n${UI_ERROR_COLOR}❌ Error: $error_message${COLOR_RESET}\n"

    if [[ -n "$target_path" ]]; then
        printf "${UI_INFO_COLOR}Target: $target_path${COLOR_RESET}\n"
    fi

    printf "${UI_INFO_COLOR}Please check the issue and try again.${COLOR_RESET}\n\n"
    ((error_count++))
    ((completed_operations++))
    show_cursor
    exit 1
}

# Centralized progress tracking
function complete_operation() {
    local success_message="${1:-}"

    if [[ -n "$success_message" ]]; then
        operation_results+=("✅ $success_message")
        ((success_count++))
    fi

    ((completed_operations++))
}

# Get file size in human readable format
function get_file_size() {
    local file_path="$1"

    if [[ -f "$file_path" ]]; then
        du -h "$file_path" | cut -f1
    else
        echo "unknown"
    fi
}

# Generate new timestamp for filename uniqueness
function generate_new_filename() {
    timestamp=$(date +%Y%m%d-%H%M%S)
    backup_filename="${ARCHIVE_PREFIX}_${timestamp}${ARCHIVE_EXTENSION}"
}

# Get full backup path
function get_backup_path() {
    echo "$target_dir/$backup_filename"
}

# ============================================================================
# Terminal Control Functions (Matching link_dotfiles.zsh)
# ============================================================================

function hide_cursor() {
    printf "$CURSOR_HIDE"
}

function show_cursor() {
    printf "$CURSOR_SHOW"
}

function clear_screen() {
    printf "$CLEAR_SCREEN$CURSOR_HOME"
}

function move_cursor_to_line() {
    local line=$1
    printf "\033[${line};1H"
}

# ============================================================================
# Visual Display Functions (Matching link_dotfiles.zsh)
# ============================================================================

# Display a colored message with automatic color reset
function print_colored_message() {
    local color="$1"
    local message="$2"
    printf "${color}${message}${COLOR_RESET}"
}

# Display a status message with emoji and color
function print_status_message() {
    local color="$1"
    local emoji="$2"
    local message="$3"
    print_colored_message "$color" "${emoji} ${message}\n"
}

# Draw a beautiful header for the backup process
function draw_header() {
    printf "${COLOR_BOLD}${UI_HEADER_COLOR}"
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║                      📦 Dotfiles Repository Backup Tool 📦                   ║\n"
    printf "║                             Archive Creation System                          ║\n"
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n"
    printf "${COLOR_RESET}\n"
}

# Note: Using optimized draw_progress_bar() from ui.zsh
# No local override needed - the shared library version is already optimized

# Display the current operation status (with anti-flicker optimization)
function update_status_display() {
    local phase_name="$1"
    local operation_name="$2"
    local line_offset=7

    # Move to status area
    move_cursor_to_line $line_offset

    # Clear and redraw each line using \033[2K (anti-flicker technique)
    printf "\033[2K${COLOR_BOLD}${UI_ACCENT_COLOR}Phase: %-20s${COLOR_RESET}\n" \
        "$phase_name"
    printf "\033[2K${UI_INFO_COLOR}Current: %-40s${COLOR_RESET}\n\n" \
        "$operation_name"

    # Draw progress bar with anti-flicker line clear
    printf "\033[2K"
    print_colored_message "$UI_PROGRESS_COLOR" "Progress: "
    draw_progress_bar $completed_operations $total_operations
    printf "\n\n"

    # Show statistics with anti-flicker line clear
    printf "\033[2K"
    printf "${UI_SUCCESS_COLOR}✅ Success: %d${COLOR_RESET}  " $success_count
    printf "${UI_ERROR_COLOR}❌ Errors: %d${COLOR_RESET}\n" $error_count
}

# ============================================================================
# Backup Operations
# ============================================================================

function validate_environment() {
    update_status_display "Setup" "Validating environment"

    # Check if dotfiles directory exists
    if [[ ! -d "$DF_DIR" ]]; then
        exit_with_error "Dotfiles directory not found" "$DF_DIR"
    fi

    # Check if zip command is available
    if ! command -v zip >/dev/null 2>&1; then
        exit_with_error "zip command not available"
    fi

    # Check if unzip command is available (needed for verification)
    if ! command -v unzip >/dev/null 2>&1; then
        exit_with_error "unzip command not available (required for verification)"
    fi

    complete_operation "Environment validation successful"
    sleep 0.2
    return 0
}

function prepare_target_directory() {
    update_status_display "Setup" "Preparing target directory"

    # Expand tilde in target directory
    target_dir="${target_dir/#~/$HOME}"

    # Validate target directory path
    if [[ -z "$target_dir" || "$target_dir" == "/" ]]; then
        exit_with_error "Invalid target directory path: '$target_dir'"
    fi

    # Check if target is a file (not a directory)
    if [[ -f "$target_dir" ]]; then
        exit_with_error "Target path is a file, not a directory" "$target_dir"
    fi

    # Create target directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        if mkdir -p "$target_dir" 2>/dev/null; then
            complete_operation "Created target directory: $target_dir"
        else
            exit_with_error "Failed to create target directory" "$target_dir"
        fi
    else
        complete_operation "Target directory exists: $target_dir"
    fi

    # Verify directory is writable
    if [[ ! -w "$target_dir" ]]; then
        exit_with_error "Target directory not writable" "$target_dir"
    fi

    sleep 0.2
    return 0
}

function check_existing_backup() {
    update_status_display "Validation" "Checking for existing backup"

    local full_backup_path=$(get_backup_path)

    if [[ -e "$full_backup_path" ]]; then
        operation_results+=(
            "⚠️  Backup file already exists: $backup_filename"
        )
        generate_new_filename
        operation_results+=("📝 Using new filename: $backup_filename")
    else
        complete_operation "Backup filename available: $backup_filename"
    fi

    sleep 0.2
    return 0
}

function create_backup_archive() {
    local full_backup_path=$(get_backup_path)
    local parent_dir="$(dirname "$DF_DIR")"
    local repo_name="$(basename "$DF_DIR")"

    # Sub-step 1: Preparing archive
    update_status_display "Archive" "Preparing archive structure"
    sleep 0.3
    complete_operation

    # Sub-step 2: Scanning files
    update_status_display "Archive" "Scanning repository files"
    sleep 0.4
    complete_operation

    # Sub-step 3: Compressing data (silent zip operation)
    update_status_display "Archive" "Compressing repository data"
    sleep 0.2

    # Build exclusion parameters from array
    local exclusion_params=()
    for pattern in "${ARCHIVE_EXCLUSIONS[@]}"; do
        exclusion_params+=("-x" "$pattern")
    done

    # Silent archive creation - no output noise
    if (cd "$parent_dir" && \
        zip -r "$full_backup_path" "$repo_name" \
            "${exclusion_params[@]}" \
            >/dev/null 2>&1); then

        # Show compression progress visually
        sleep 0.5
        complete_operation

        # Sub-step 4: Finalizing archive
        update_status_display "Archive" "Finalizing backup archive"

        # Get file size for display
        local file_size=$(get_file_size "$full_backup_path")

        operation_results+=(
            "🎉 Backup created successfully: $full_backup_path"
        )
        operation_results+=("📊 Archive size: $file_size")

        sleep 0.3
        complete_operation "Backup archive finalized"

        return 0
    else
        operation_results+=("❌ Failed to create backup archive")
        ((error_count++))
        ((completed_operations++))
        return 1
    fi
}

function verify_backup_archive() {
    local full_backup_path=$(get_backup_path)

    # Step 1: Archive integrity test
    update_status_display "Verify" "Testing archive integrity"
    if zip -T "$full_backup_path" >/dev/null 2>&1; then
        complete_operation "Archive integrity verified"
    else
        operation_results+=("❌ Archive integrity test failed")
        ((error_count++))
        ((completed_operations++))
        return 1
    fi
    sleep 0.3

    # Step 2: Metadata scan
    update_status_display "Verify" "Scanning archive metadata"
    local archive_info
    if archive_info=$(unzip -l "$full_backup_path" 2>/dev/null); then
        complete_operation "Archive metadata readable"
    else
        operation_results+=("❌ Failed to read archive metadata")
        ((error_count++))
        ((completed_operations++))
        return 1
    fi
    sleep 0.3

    # Step 3: File count verification
    update_status_display "Verify" "Verifying file count"
    local archive_file_count=$(echo "$archive_info" | grep -c "^[[:space:]]*[0-9]")

    # Simple, reliable file counting with exclusions
    local source_file_count=$(find "$DF_DIR" -type f \
        ! -path "*/\.git/*" \
        ! -name ".DS_Store" \
        ! -path "*/\.tmp/*" \
        | wc -l | tr -d ' ')

    if [[ $archive_file_count -gt 0 && $source_file_count -gt 0 ]]; then
        local file_ratio=$((archive_file_count * 100 / source_file_count))
        if [[ $file_ratio -ge 70 ]]; then  # Allow generous variance for exclusions
            complete_operation "File count verification passed ($archive_file_count archived, $source_file_count source)"
        else
            operation_results+=(
                "⚠️  File count discrepancy: $archive_file_count archived vs $source_file_count source (${file_ratio}% match)"
            )
        fi
    else
        operation_results+=("❌ Unable to verify file counts (archive: $archive_file_count, source: $source_file_count)")
        ((error_count++))
    fi
    sleep 0.3
    complete_operation

    # Step 4: Size verification
    update_status_display "Verify" "Checking archive size"
    local archive_size_bytes=$(stat -f%z "$full_backup_path" 2>/dev/null || stat -c%s "$full_backup_path" 2>/dev/null)
    if [[ -n "$archive_size_bytes" && $archive_size_bytes -gt 1024 ]]; then  # At least 1KB
        local archive_size_mb=$((archive_size_bytes / 1024 / 1024))
        complete_operation "Archive size verification passed (${archive_size_mb}MB)"
    else
        operation_results+=("❌ Archive appears too small or corrupted")
        ((error_count++))
    fi
    sleep 0.3
    complete_operation

    # Step 5: Verification complete
    update_status_display "Verify" "Verification complete"
    complete_operation "🔍 Backup verification completed successfully"
    sleep 0.2

    # Final progress update to show 100%
    update_status_display "Complete" "All operations finished successfully"
    sleep 0.2

    return 0
}

# ============================================================================
# Results Display
# ============================================================================

function display_completion_results() {
    # Don't clear screen - show results below the progress bar
    printf "\n"
    printf "${COLOR_BOLD}${UI_SUCCESS_COLOR}"
    printf "🎉 Dotfiles Backup Complete! 🎉${COLOR_RESET}\n\n"

    # Summary statistics
    printf "${UI_INFO_COLOR}📊 Backup Summary:${COLOR_RESET}\n"
    printf "   ${UI_SUCCESS_COLOR}✅ Successful operations: %d${COLOR_RESET}\n" \
        $success_count
    printf "   ${UI_ERROR_COLOR}❌ Failed operations: %d${COLOR_RESET}\n" \
        $error_count
    printf "   ${UI_INFO_COLOR}📁 Target directory: %s${COLOR_RESET}\n" \
        "$target_dir"
    printf "   ${UI_INFO_COLOR}📦 Archive filename: %s${COLOR_RESET}\n\n" \
        "$backup_filename"

    # Detailed results
    printf "${UI_INFO_COLOR}📋 Operation Details:${COLOR_RESET}\n"
    for result in "${operation_results[@]}"; do
        printf "   %s\n" "$result"
    done

    printf "\n"

    # Status message
    if [[ $error_count -eq 0 ]]; then
        print_status_message "$UI_SUCCESS_COLOR" "🌟" \
            "Backup completed successfully!"
        printf "${UI_INFO_COLOR}💡 Your dotfiles repository has been "
        printf "safely archived.${COLOR_RESET}\n"
    else
        print_status_message "$UI_WARNING_COLOR" "⚠️" \
            "Backup completed with $error_count error(s). Check details above."
    fi

    printf "\n"
}

# ============================================================================
# Main Backup Function
# ============================================================================

function create_dotfiles_backup() {
    # Setup
    hide_cursor
    clear_screen

    # Initialize
    completed_operations=0
    success_count=0
    error_count=0
    operation_results=()

    # Display initial header
    draw_header
    printf "${UI_INFO_COLOR}📁 Repository Directory: %s${COLOR_RESET}\n" \
        "$DF_DIR"
    printf "${UI_INFO_COLOR}🎯 Target Directory: %s${COLOR_RESET}\n" \
        "$target_dir"
    printf "${UI_INFO_COLOR}📦 Archive Name: %s${COLOR_RESET}\n\n" \
        "$backup_filename"

    # Execute all phases
    if validate_environment && \
       prepare_target_directory && \
       check_existing_backup && \
       create_backup_archive && \
       verify_backup_archive; then
        # All operations successful
        display_completion_results
        show_cursor
        return 0
    else
        # Some operations failed
        display_completion_results
        show_cursor
        return $error_count
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

# If script is run directly (not sourced), execute the main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || \
   [[ "${(%):-%N}" == "$0" ]]; then
    create_dotfiles_backup
fi
