#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Dotfiles Setup Script - Unified Cross-Platform Installation
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
}

source "$LIB_DIR/ui.zsh" 2>/dev/null || {
    # Fallback: basic UI functions if library not available
    function print_success() { echo "✅ $1"; }
    function print_warning() { echo "⚠️ $1"; }
    function print_error() { echo "❌ $1"; }
    function print_info() { echo "ℹ️ $1"; }
}

source "$LIB_DIR/utils.zsh" 2>/dev/null || {
    # Fallback: basic utility functions if library not available
    function get_os() {
        case "$(uname -s)" in
            Darwin*)  echo "macos" ;;
            Linux*)   echo "linux" ;;
            *)        echo "unknown" ;;
        esac
    }
    function command_exists() { command -v "$1" >/dev/null 2>&1; }
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

export DF_DEBUG=false
export DF_DIR=$(realpath "$(dirname $0)/..")
export DF_SETUP=$(basename $0)
export DF_LOGFILE="df_log.txt"

# ============================================================================
# OS Detection and Context Switching
# ============================================================================

# Detect operating system using shared utility
export DF_OS=$(get_os)

# Handle additional OS detection for Windows systems
case "$(uname -s)" in
  CYGWIN*)  export DF_OS="windows" ;;
  MINGW*)   export DF_OS="windows" ;;
esac

# Set OS-specific variables
case "$DF_OS" in
  macos)
    export DF_PKG_MANAGER="brew"
    export DF_PKG_INSTALL_CMD="brew install"
    ;;
  linux)
    export DF_PKG_MANAGER="apt"
    export DF_PKG_INSTALL_CMD="sudo apt install"
    ;;
  windows)
    export DF_PKG_MANAGER="choco"
    export DF_PKG_INSTALL_CMD="choco install"
    ;;
  *)
    print_warning "Unknown operating system. Some features may not work."
    ;;
esac

print_info "Detected OS: $DF_OS"
print_info "Package Manager: $DF_PKG_MANAGER"
print_info "Dotfiles Directory: $DF_DIR"

# ============================================================================
# Command Line Options
# ============================================================================

zparseopts -D -E -- s=o_skip_pi -skip-pi-scripts=o_skip_pi a=o_all_modules -all-modules=o_all_modules l=o_logfile -logfile=o_logfile h=o_help -help=o_help
# Set execution mode
[[ $#o_skip_pi == 0 && $#o_all_modules == 0 ]] && DF_INTERACTIVE_MODE=true
[[ $#o_skip_pi > 0 ]] && DF_SKIP_PI_SCRIPTS=true
[[ $#o_all_modules > 0 ]] && DF_ALL_MODULES=true

[[ $#o_help  >  0 ]] && {
  echo
  echo "Usage: $0 [-s|--skip-pi-scripts] [-a|--all-modules] [-l|--logfile] [-h|--help]"
  echo
  echo "  [-s|--skip-pi-scripts]:  Silent mode: Link dotfiles only, skip post-install scripts"
  echo "  [-a|--all-modules]:      Silent mode: Link dotfiles AND run all post-install scripts"
  echo "  [-l|--logfile]:          Set path to log file"
  echo "  [-h|--help]:             Print usage and exit"
  echo
  echo "Without flags: Interactive menu mode (recommended)"
  echo
  echo "Supported OS: macOS (Darwin), Linux, Windows"
  echo "Current OS: $DF_OS"
  echo
  exit 0
}

# ============================================================================
# Utility Functions
# ============================================================================

function log_if_debug() {
  [[ $DF_DEBUG == true ]] && echo "__DEBUG_MSG: $1 { $2 }"
}

function create_directory() {
  local dir="$1"
  create_directory_safe "$dir" "$dir"
  [[ -d "$dir" ]] && print_success "Directory ready: '$dir'"
}

function backup_file() {
  local file="$1"
  local backup_dir="$2"
  if [[ -e "$file" ]]; then
    print_info "Backing up: '$file'"
    if mv "$file" "$backup_dir/" 2>/dev/null; then
      print_success "Backup completed: '$file'"
    else
      print_error "Backup failed: '$file'"
    fi
  fi
}

# ============================================================================
# Core Setup Functions
# ============================================================================

function setup_directories() {
  print_info "Setting up directory structure..."

  local install_dir="$HOME"
  local tmp_dir="$HOME/.tmp"
  local backup_dir="$tmp_dir/dotfilesBackup-$(get_timestamp)"

  create_directory "$install_dir"
  create_directory "$tmp_dir"
  create_directory "$backup_dir/.config"
  create_directory "$tmp_dir/vimbackup"
  create_directory "$tmp_dir/vimbackup/undo"
  create_directory "$tmp_dir/vimbackup/swap"
  create_directory "$tmp_dir/emacsbackup"
  create_directory "$HOME/.local/bin"

  export DF_INSTALL_DIR="$install_dir"
  export DF_TMP_DIR="$tmp_dir"
  export DF_BACKUP_DIR="$backup_dir"

  print_success "Backup directory ready: '$backup_dir'"
}

function create_symlinks() {
  print_info "🔗 Launching Enhanced Dotfiles Symlink Manager..."
  echo

  # Use the beautiful new link_dotfiles.zsh script
  "$DF_DIR/bin/link_dotfiles.zsh"
}

function run_post_install_scripts() {
  print_info "Running post-install scripts..."

  local post_install_scripts=(${(0)"$(find "${DF_DIR}/post-install" -perm 755 -name "*.zsh" -print0)"})

  for pi_script in $post_install_scripts; do
    print_info "Executing: '$pi_script'"
    if [[ -e "$pi_script" ]]; then
      # Export OS context for post-install scripts
      if DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$pi_script"; then
        print_success "Completed: '$pi_script'"
      else
        print_error "Failed: '$pi_script'"
      fi
    fi
  done
}

# ============================================================================
# Main Execution
# ============================================================================

log_if_debug "GLOBALS: DF_LOGFILE" "$DF_LOGFILE"
log_if_debug "GLOBALS: DF_OS" "$DF_OS"
log_if_debug "OPTIONS: help" "$#o_help"
log_if_debug "OPTIONS: skip-pi-scripts" "$#o_skip_pi"
log_if_debug "OPTIONS: all-modules" "$#o_all_modules"
log_if_debug "MODE: interactive" "$DF_INTERACTIVE_MODE"
log_if_debug "MODE: skip-pi" "$DF_SKIP_PI_SCRIPTS"
log_if_debug "MODE: all-modules" "$DF_ALL_MODULES"

print_info "Starting dotfiles setup for $DF_OS..."

# Core setup phases - Always create directories (users might skip dotfile linking)
setup_directories

# ============================================================================
# Execution Mode Handling
# ============================================================================

if [[ $DF_ALL_MODULES == true ]]; then
    # Silent mode: Do everything without user interaction
    print_info "🔄 Silent mode: Executing all modules..."
    echo

    # Link dotfiles
    print_info "📎 Linking dotfiles..."
    "$DF_DIR/bin/link_dotfiles.zsh"

    # Run all post-install scripts
    print_info "🎵 Running all post-install scripts..."
    librarian_script="$DF_DIR/bin/librarian.zsh"
    if [[ -x "$librarian_script" ]]; then
        DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$librarian_script" --all-pi
    else
        print_warning "Librarian script not found, skipping post-install scripts."
    fi

    print_success "All modules completed successfully!"

elif [[ $DF_SKIP_PI_SCRIPTS == true ]]; then
    # Silent mode: Link dotfiles only, skip post-install scripts
    print_info "🔗 Silent mode: Linking dotfiles only..."
    echo

    "$DF_DIR/bin/link_dotfiles.zsh"

    print_success "Dotfiles linking completed successfully!"
    print_info "💡 Post-install scripts were skipped (use --all-modules to include them)"

else
    # Interactive mode: Launch the TUI menu
    print_info "🎮 Launching interactive menu system..."
    print_info "   Choose exactly what you want to install and configure!"
    echo
    sleep 1

    # Launch the TUI menu with environment context
    menu_script="$DF_DIR/bin/menu_tui.zsh"
    if [[ -x "$menu_script" ]]; then
        DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$menu_script"
    else
        print_error "Menu system not found at: $menu_script"
        print_info "💡 Falling back to librarian..."
        librarian_script="$DF_DIR/bin/librarian.zsh"
        if [[ -x "$librarian_script" ]]; then
            DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$librarian_script"
        else
            print_error "Neither menu nor librarian found. Setup incomplete."
            exit 1
        fi
    fi
fi
