#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Enhanced Dotfiles Symlink Manager - Beautiful Visual Linking Experience
# ============================================================================
#
# A sophisticated symlink creation system with progress visualization,
# OneDark theming, and professional status reporting.
#
# Features:
# - Progress bars for each linking phase
# - Beautiful OneDark color scheme
# - No-scroll fixed layout during operations
# - 3-second review timer for results
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
    readonly COLOR_RESET='\033[0m'
    readonly UI_SUCCESS_COLOR='\033[32m'
    readonly UI_WARNING_COLOR='\033[33m'
    readonly UI_ERROR_COLOR='\033[31m'
    readonly UI_INFO_COLOR='\033[90m'
    readonly UI_HEADER_COLOR='\033[32m'
    readonly UI_ACCENT_COLOR='\033[35m'
    readonly UI_PROGRESS_COLOR='\033[36m'
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
    function move_cursor_to_line() { printf "\033[${1};1H"; }
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
# Global State Variables
# ============================================================================

typeset -i total_operations=0
typeset -i completed_operations=0
typeset -i success_count=0
typeset -i error_count=0
typeset -a operation_results=()

# ============================================================================
# Environment Setup
# ============================================================================

# Ensure required environment variables are set
if [[ -z "$DF_DIR" ]]; then
    export DF_DIR=$(realpath "$(dirname $0)/..")
fi

if [[ -z "$DF_INSTALL_DIR" ]]; then
    export DF_INSTALL_DIR="$HOME"
fi

# NOTE: DF_BACKUP_DIR is regenerated in create_all_symlinks() for each invocation
# to ensure unique timestamps when running multiple times from the menu

if [[ -z "$DF_TMP_DIR" ]]; then
    export DF_TMP_DIR="$HOME/.tmp"
fi



# Draw a beautiful header for the linking process
function draw_linking_header() {
    draw_header "🔗 Dotfiles Symlink Manager 🔗" "Enhanced Visual Linking Experience"
}


# Display the current operation status
function update_status_display() {
    local phase_name="$1"
    local operation_name="$2"
    local line_offset=7

    # Clear the status area and redraw with proper line clearing
    move_cursor_to_line $line_offset

    # Clear each line by overwriting with spaces, then rewrite content
    printf "%-80s\r${COLOR_BOLD}${UI_ACCENT_COLOR}Phase: %-20s${COLOR_RESET}\n" "" "$phase_name"
    printf "%-80s\r${UI_INFO_COLOR}Current: %-40s${COLOR_RESET}\n\n" "" "$operation_name"

    # Draw progress bar with proper clearing
    printf "%-80s\r" ""
    print_colored_message "$UI_PROGRESS_COLOR" "Progress: "
    draw_progress_bar $completed_operations $total_operations
    printf "\n\n"

    # Show statistics with proper clearing
    printf "%-80s\r" ""
    printf "${UI_SUCCESS_COLOR}✅ Success: %d${COLOR_RESET}  " $success_count
    printf "${UI_ERROR_COLOR}❌ Errors: %d${COLOR_RESET}\n" $error_count
}

# ============================================================================
# Enhanced Utility Functions
# ============================================================================

function create_directory() {
    local dir="$1"
    local operation_name="Creating directory: $(basename "$dir")"

    update_status_display "Setup" "$operation_name"

    # Check if directory already exists BEFORE attempting creation
    if [[ -d "$dir" ]]; then
        operation_results+=("ℹ️  Directory already exists: $dir")
    elif create_directory_safe "$dir" "$dir"; then
        operation_results+=("✅ Created directory: $dir")
        ((success_count++))
    else
        operation_results+=("❌ Failed to create directory: $dir")
        ((error_count++))
    fi

    ((completed_operations++))
    sleep 0.1  # Brief pause for visual effect
}

function backup_file() {
    local file="$1"
    local backup_dir="$2"
    local operation_name="Backing up: $(basename "$file")"

    if [[ -e "$file" ]]; then
        update_status_display "Backup" "$operation_name"

        if mv "$file" "$backup_dir/" 2>/dev/null; then
            operation_results+=("📦 Backed up: $file")
            ((success_count++))
        else
            operation_results+=("❌ Failed to backup: $file")
            ((error_count++))
        fi

        ((completed_operations++))
        sleep 0.1
    fi
}

function create_symlink() {
    local source="$1"
    local target="$2"
    local operation_name="Linking: $(basename "$source")"

    update_status_display "Linking" "$operation_name"

    # Handle existing symlinks intelligently
    if [[ -L "$target" ]]; then
        local link_dest="$(readlink "$target")"

        # Check if it's a broken symlink to old dotfiles location
        if [[ ! -e "$target" ]] && [[ "$link_dest" == *"/.config/dotfiles/"* ]]; then
            # Remove broken symlink to old dotfiles location
            if rm -f "$target" 2>/dev/null; then
                operation_results+=("🔄 Removed stale symlink: $(basename "$target") [was: ${link_dest:t:h:t}/${link_dest:t}]")
            fi
        elif [[ -e "$target" ]]; then
            # Valid symlink exists - nothing to do
            operation_results+=("ℹ️  Already exists: $target")
            ((completed_operations++))
            sleep 0.1
            return
        fi
    fi

    # Try to create symlink (target may have been removed above, or doesn't exist)
    if [[ -e "$target" ]]; then
        operation_results+=("ℹ️  Already exists: $target")
    elif ln -s "$source" "$target" 2>/dev/null; then
        operation_results+=("🔗 Created symlink: $(basename "$source") → $(basename "$target")")
        ((success_count++))
    else
        operation_results+=("❌ Failed to create symlink: $source → $target")
        ((error_count++))
    fi

    ((completed_operations++))
    sleep 0.1
}

# ============================================================================
# Enhanced Symlink Creation Functions
# ============================================================================

function setup_backup_directories() {
    local dirs=("$DF_TMP_DIR" "$DF_BACKUP_DIR" "$DF_BACKUP_DIR/.config" "$HOME/.local/bin")

    for dir in "${dirs[@]}"; do
        create_directory "$dir"
    done
}

function create_home_symlinks() {
    local home_symlinks=(${(0)"$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink" -print0)"})

    for link_source in $home_symlinks; do
        local link_target="$DF_INSTALL_DIR/.$link_source:t:r"
        backup_file "$link_target" "$DF_BACKUP_DIR"
        create_symlink "$link_source" "$link_target"
    done
}

function create_config_symlinks() {
    create_directory "$DF_INSTALL_DIR/.config"

    local config_symlinks=(${(0)"$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink_config" -print0)"})

    for link_source in $config_symlinks; do
        local link_target="$DF_INSTALL_DIR/.config/$link_source:t:r"
        backup_file "$link_target" "$DF_BACKUP_DIR/.config"
        create_symlink "$link_source" "$link_target"
    done
}

function create_local_bin_symlinks() {
    local local_bin_symlinks=(${(0)"$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink_local_bin.*" -print0)"})

    for link_source in $local_bin_symlinks; do
        local basename="$(basename "$link_source" | sed 's/\.symlink_local_bin\..*//')"
        local link_target="$HOME/.local/bin/$basename"
        backup_file "$link_target" "$DF_BACKUP_DIR"
        create_symlink "$link_source" "$link_target"
    done
}

# ============================================================================
# Operation Counting and Planning
# ============================================================================

function count_operations() {
    # Count directories to create
    local dir_operations=4

    # Count symlink files
    local home_count=$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink" -print | wc -l)
    local config_count=$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink_config" -print | wc -l)
    local bin_count=$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink_local_bin.*" -print | wc -l)

    # Count actual backup operations needed
    local backup_operations=0

    # Check home symlinks
    local home_symlinks=(${(0)"$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink" -print0)"})
    for link_source in $home_symlinks; do
        local link_target="$DF_INSTALL_DIR/.$link_source:t:r"
        [[ -e "$link_target" ]] && ((backup_operations++))
    done

    # Check config symlinks
    local config_symlinks=(${(0)"$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink_config" -print0)"})
    for link_source in $config_symlinks; do
        local link_target="$DF_INSTALL_DIR/.config/$link_source:t:r"
        [[ -e "$link_target" ]] && ((backup_operations++))
    done

    # Check local bin symlinks
    local local_bin_symlinks=(${(0)"$(find $DF_DIR -path "$DF_DIR/.git" -prune -o -name "*.symlink_local_bin.*" -print0)"})
    for link_source in $local_bin_symlinks; do
        local basename="$(basename "$link_source" | sed 's/\.symlink_local_bin\..*//')"
        local link_target="$HOME/.local/bin/$basename"
        [[ -e "$link_target" ]] && ((backup_operations++))
    done

    # Total: directories + backup operations + symlink operations
    total_operations=$((dir_operations + backup_operations + home_count + config_count + bin_count))
}

# ============================================================================
# Results Display and Review
# ============================================================================

function display_results() {
    clear_screen
    draw_linking_header

    print_success "🎉 Dotfile Linking Complete! 🎉"
    echo

    # Summary statistics
    print_info "📊 Operation Summary:"
    printf "   "
    print_success "Successful operations: $success_count"
    printf "   "
    print_error "Failed operations: $error_count"
    printf "   "
    print_info "Backup directory: $DF_BACKUP_DIR"
    echo

    # Detailed results (limited to screen space)
    print_info "📋 Operation Details:"
    local max_results=15
    local result_count=${#operation_results[@]}

    if [[ $result_count -le $max_results ]]; then
        for result in "${operation_results[@]}"; do
            printf "   %s\n" "$result"
        done
    else
        for ((i=1; i<=10; i++)); do
            printf "   %s\n" "${operation_results[$i]}"
        done
        printf "   "
        print_info "... and $((result_count - 10)) more operations"
    fi

    printf "\n"

    # Status message
    if [[ $error_count -eq 0 ]]; then
        print_success "🌟 All operations completed successfully!"
    else
        print_warning "⚠️ Completed with $error_count error(s). Check details above."
    fi

    printf "\n"
    print_success "$(get_random_friend_greeting)"
}

# Removed three_second_review - clean, immediate results display

# ============================================================================
# Main Enhanced Linking Function
# ============================================================================

function create_all_symlinks() {
    # Setup
    hide_cursor
    clear_screen

    # CRITICAL: Regenerate timestamp for each invocation
    # This ensures multiple runs from the menu get unique backup directories
    export DF_BACKUP_DIR="$HOME/.tmp/dotfilesBackup-$(get_timestamp)"

    # Initialize
    count_operations
    completed_operations=0
    success_count=0
    error_count=0
    operation_results=()

    # Display initial header
    draw_linking_header
    print_info "📁 Dotfiles Directory: $DF_DIR"
    print_info "🏠 Install Directory: $DF_INSTALL_DIR"
    print_info "💾 Backup Directory: $DF_BACKUP_DIR"
    echo

    # Execute all phases
    setup_backup_directories
    create_home_symlinks
    create_config_symlinks
    create_local_bin_symlinks

    # Display results
    display_results

    show_cursor

    # Return appropriate exit code
    return $error_count
}

# ============================================================================
# Help Function
# ============================================================================

function show_help() {
    cat << EOF
${COLOR_BOLD}Dotfiles Symlink Manager${COLOR_RESET}

${UI_ACCENT_COLOR}DESCRIPTION:${COLOR_RESET}
    Creates symbolic links for dotfiles using a convention-based system.
    Automatically backs up existing files before creating symlinks.

${UI_ACCENT_COLOR}USAGE:${COLOR_RESET}
    $0 [OPTIONS]

${UI_ACCENT_COLOR}SYMLINK PATTERNS:${COLOR_RESET}
    *.symlink            → ~/.{basename}
    *.symlink_config     → ~/.config/{basename}
    *.symlink_local_bin.* → ~/.local/bin/{basename}

${UI_ACCENT_COLOR}EXAMPLES:${COLOR_RESET}
    zsh/zshrc.symlink               → ~/.zshrc
    nvim/nvim.symlink_config/       → ~/.config/nvim/
    github/get_github_url.symlink_local_bin.zsh → ~/.local/bin/get_github_url

${UI_ACCENT_COLOR}OPTIONS:${COLOR_RESET}
    --help, -h          Show this help message

${UI_ACCENT_COLOR}FEATURES:${COLOR_RESET}
    • Beautiful OneDark color scheme
    • Progress bars for visual feedback
    • Automatic backup of existing files
    • Comprehensive error handling
    • Success/error statistics

${UI_ACCENT_COLOR}BACKUP:${COLOR_RESET}
    Existing files are backed up to: ~/.tmp/dotfilesBackup-{timestamp}/

EOF
}

# ============================================================================
# Main Execution
# ============================================================================

# If script is run directly (not sourced), execute the main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%N}" == "$0" ]]; then
    # Check for help flag
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi

    create_all_symlinks
fi
