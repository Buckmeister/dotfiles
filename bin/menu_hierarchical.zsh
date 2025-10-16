#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Hierarchical Menu System for Dotfiles Management
# ============================================================================
#
# A sophisticated multi-level menu system that organizes dotfiles operations
# into intuitive categories with breadcrumb navigation and state management.
#
# Main Categories:
# - 📦 Post-Install Scripts
# - 👤 Profile Management
# - 🧙 Configuration Wizard
# - 📋 Package Management
# - 🔧 System Tools
#
# Navigation:
# - ↑/↓ or k/j: Navigate up/down
# - Enter: Select/drill down into submenu
# - ESC/h: Go back to parent menu
# - Space: Toggle selection (multi-select menus)
# - q: Quit
# ============================================================================

# ============================================================================
# Load Shared Libraries
# ============================================================================

# Get library directory
LIB_DIR="$(dirname "$(realpath "$0")")/lib"

# Load core libraries with fallback protection
source "$LIB_DIR/colors.zsh" 2>/dev/null || {
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
    function print_success() { echo "✅ $1"; }
    function print_error() { echo "❌ $1"; }
    function hide_cursor() { printf '\033[?25l'; }
    function show_cursor() { printf '\033[?25h'; }
    function clear_screen() { printf '\033[2J\033[H'; }
}

source "$LIB_DIR/utils.zsh" 2>/dev/null || {
    function get_timestamp() { date +"%Y%m%d-%H%M%S"; }
}

source "$LIB_DIR/greetings.zsh" 2>/dev/null || {
    function get_random_friend_greeting() { echo "Happy coding, friend!"; }
}

# Load menu system libraries
source "$LIB_DIR/menu_engine.zsh" || {
    echo "❌ Error: menu_engine.zsh not found" >&2
    exit 1
}

source "$LIB_DIR/menu_state.zsh" || {
    echo "❌ Error: menu_state.zsh not found" >&2
    exit 1
}

source "$LIB_DIR/menu_navigation.zsh" || {
    echo "❌ Error: menu_navigation.zsh not found" >&2
    exit 1
}

# ============================================================================
# Menu Color Assignments (using OneDark theme)
# ============================================================================

[[ -z "$UI_CURRENT_SELECTION" ]] && UI_CURRENT_SELECTION="$UI_INFO_COLOR$COLOR_BOLD"
[[ -z "$UI_SELECTION_BG" ]] && UI_SELECTION_BG="$ONEDARK_SELECTION"
[[ -z "$ITEM_SELECTED_COLOR" ]] && ITEM_SELECTED_COLOR="$UI_SUCCESS_COLOR"
[[ -z "$ITEM_DEFAULT_COLOR" ]] && ITEM_DEFAULT_COLOR="$ONEDARK_FG"
[[ -z "$ITEM_ACTION_COLOR" ]] && ITEM_ACTION_COLOR="$UI_SUCCESS_COLOR"
[[ -z "$ITEM_CONTROL_COLOR" ]] && ITEM_CONTROL_COLOR="$UI_WARNING_COLOR"

# ============================================================================
# Menu Builder Functions
# ============================================================================

# Build the main menu (root level)
function build_main_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "Post-Install Scripts" \
        "Configure system components and packages" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "📦" \
        "post_install_menu"

    menu_engine_add_item \
        "Profile Management" \
        "Manage configuration profiles" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "👤" \
        "profile_menu"

    menu_engine_add_item \
        "Configuration Wizard" \
        "Interactive setup and customization" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "🧙" \
        "wizard_menu"

    menu_engine_add_item \
        "Package Management" \
        "Universal package system" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "📋" \
        "package_menu"

    menu_engine_add_item \
        "System Tools" \
        "Update, backup, and health check" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "🔧" \
        "system_tools_menu"

    menu_engine_add_item \
        "" \
        "" \
        "$MENU_TYPE_SEPARATOR"

    menu_engine_add_item \
        "Quit" \
        "Exit the menu system" \
        "$MENU_TYPE_CONTROL" \
        "" \
        "🚪"
}

# Build post-install scripts submenu (multi-select)
function build_post_install_menu() {
    menu_engine_clear_items

    # Add link dotfiles as first item
    menu_engine_add_item \
        "Link Dotfiles" \
        "Create symlinks for all dotfiles" \
        "$MENU_TYPE_MULTI_SELECT" \
        'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$DF_DIR/bin/link_dotfiles.zsh"' \
        "🔗"

    # Find and add post-install scripts
    local post_install_dir="$DF_DIR/post-install/scripts"
    local all_scripts=()

    if [[ -d "$post_install_dir" ]]; then
        all_scripts=(${(0)"$(find "$post_install_dir" -name "*.zsh" -print0 2>/dev/null)"})

        for script in "${all_scripts[@]}"; do
            # Check if script is enabled
            if ! is_post_install_script_enabled "$script"; then
                continue
            fi

            if [[ -x "$script" ]]; then
                local script_name="$(basename "$script" .zsh)"
                local script_desc="Install and configure $script_name"

                # Friendly descriptions
                case "$script_name" in
                    *package*|*brew*|*apt*)
                        script_desc="Install system packages via $script_name"
                        ;;
                    *npm*|*node*)
                        script_desc="Install Node.js packages and tools"
                        ;;
                    *python*|*pip*)
                        script_desc="Install Python packages and tools"
                        ;;
                    *cargo*|*rust*)
                        script_desc="Install Rust packages and tools"
                        ;;
                    *gem*|*ruby*)
                        script_desc="Install Ruby gems and tools"
                        ;;
                    *)
                        script_desc="Configure $script_name environment"
                        ;;
                esac

                menu_engine_add_item \
                    "$script_name" \
                    "$script_desc" \
                    "$MENU_TYPE_MULTI_SELECT" \
                    'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "'$script'"'
            fi
        done
    fi

    # Add control items
    menu_engine_add_item \
        "" \
        "" \
        "$MENU_TYPE_SEPARATOR"

    menu_engine_add_item \
        "Select All" \
        "Select all available items" \
        "$MENU_TYPE_CONTROL" \
        "" \
        "📋"

    menu_engine_add_item \
        "Execute Selected" \
        "Run all selected operations" \
        "$MENU_TYPE_CONTROL" \
        "" \
        "⚡"

    menu_engine_add_item \
        "Back" \
        "Return to main menu" \
        "$MENU_TYPE_BACK" \
        "" \
        "◂"
}

# Build profile management submenu
function build_profile_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "List Profiles" \
        "Show all available profiles" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/profile_manager.zsh" --list' \
        "📋"

    menu_engine_add_item \
        "Show Current Profile" \
        "Display currently active profile" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/profile_manager.zsh" --show-current' \
        "👁️"

    menu_engine_add_item \
        "Apply Profile" \
        "Apply a specific profile" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/profile_manager.zsh" --apply' \
        "✓"

    menu_engine_add_item \
        "Create Profile" \
        "Create a new profile" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/profile_manager.zsh" --create' \
        "➕"

    menu_engine_add_item \
        "Delete Profile" \
        "Remove an existing profile" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/profile_manager.zsh" --delete' \
        "➖"

    menu_engine_add_item \
        "" \
        "" \
        "$MENU_TYPE_SEPARATOR"

    menu_engine_add_item \
        "Back" \
        "Return to main menu" \
        "$MENU_TYPE_BACK" \
        "" \
        "◂"
}

# Build configuration wizard submenu
function build_wizard_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "Quick Setup" \
        "Fast automated configuration" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/wizard.zsh" --quick' \
        "⚡"

    menu_engine_add_item \
        "Custom Setup" \
        "Interactive step-by-step configuration" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/wizard.zsh" --interactive' \
        "🎯"

    menu_engine_add_item \
        "Troubleshooting Wizard" \
        "Diagnose and fix common issues" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/wizard.zsh" --troubleshoot' \
        "🔧"

    menu_engine_add_item \
        "" \
        "" \
        "$MENU_TYPE_SEPARATOR"

    menu_engine_add_item \
        "Back" \
        "Return to main menu" \
        "$MENU_TYPE_BACK" \
        "" \
        "◂"
}

# Build package management submenu
function build_package_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "Generate Manifest" \
        "Create package manifest from current system" \
        "$MENU_TYPE_ACTION" \
        '~/.local/bin/generate_package_manifest' \
        "📝"

    menu_engine_add_item \
        "Install from Manifest" \
        "Install packages from manifest file" \
        "$MENU_TYPE_ACTION" \
        '~/.local/bin/install_from_manifest' \
        "📥"

    menu_engine_add_item \
        "Sync Packages" \
        "Synchronize packages with manifest" \
        "$MENU_TYPE_ACTION" \
        '~/.local/bin/sync_packages' \
        "🔄"

    menu_engine_add_item \
        "" \
        "" \
        "$MENU_TYPE_SEPARATOR"

    menu_engine_add_item \
        "Back" \
        "Return to main menu" \
        "$MENU_TYPE_BACK" \
        "" \
        "◂"
}

# Build system tools submenu
function build_system_tools_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "Link Dotfiles" \
        "Create symlinks for configuration files" \
        "$MENU_TYPE_ACTION" \
        'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$DF_DIR/bin/link_dotfiles.zsh"' \
        "🔗"

    menu_engine_add_item \
        "Update All" \
        "Update packages, toolchains, and LSPs" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/update_all.zsh"' \
        "🔄"

    menu_engine_add_item \
        "Librarian" \
        "System health check and status report" \
        "$MENU_TYPE_ACTION" \
        'DF_OS="$DF_OS" DF_PKG_MANAGER="$DF_PKG_MANAGER" DF_PKG_INSTALL_CMD="$DF_PKG_INSTALL_CMD" "$DF_DIR/bin/librarian.zsh" --status' \
        "📚"

    menu_engine_add_item \
        "Backup Repository" \
        "Create repository backup archive" \
        "$MENU_TYPE_ACTION" \
        '"$DF_DIR/bin/backup_dotfiles_repo.zsh"' \
        "💾"

    menu_engine_add_item \
        "" \
        "" \
        "$MENU_TYPE_SEPARATOR"

    menu_engine_add_item \
        "Back" \
        "Return to main menu" \
        "$MENU_TYPE_BACK" \
        "" \
        "◂"
}

# ============================================================================
# Menu Dispatcher - Builds appropriate menu based on ID
# ============================================================================

function build_menu_by_id() {
    local menu_id="$1"

    case "$menu_id" in
        "main_menu")
            build_main_menu
            ;;
        "post_install_menu")
            build_post_install_menu
            ;;
        "profile_menu")
            build_profile_menu
            ;;
        "wizard_menu")
            build_wizard_menu
            ;;
        "package_menu")
            build_package_menu
            ;;
        "system_tools_menu")
            build_system_tools_menu
            ;;
        *)
            echo "Error: Unknown menu ID: $menu_id" >&2
            build_main_menu
            ;;
    esac
}

# ============================================================================
# Action Execution Functions
# ============================================================================

# Execute a single action item
function execute_action_item() {
    local index=$1
    local title=$(menu_engine_get_item_property $index "title")
    local command=$(menu_engine_get_item_property $index "command")

    clear_screen
    show_cursor

    print_status_message "$COLOR_BOLD$UI_SUCCESS_COLOR" "🚀" "Executing: $title"
    printf "   ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫\n\n"

    if [[ -n "$command" ]]; then
        eval "$command"
        printf "\n"
        print_status_message "$UI_SUCCESS_COLOR" "✅" "Completed: $title"
    else
        print_status_message "$UI_WARNING_COLOR" "⚠️" "No command defined for: $title"
    fi

    nav_wait_for_keypress
    hide_cursor
}

# Execute all selected items (for multi-select menus)
function execute_selected_items() {
    clear_screen
    show_cursor

    printf "${COLOR_BOLD}${UI_SUCCESS_COLOR}⚡ Executing selected items...${COLOR_RESET}\n\n"

    local selected_indices=($(menu_engine_get_selected_indices))
    local executed_count=0

    for index in "${selected_indices[@]}"; do
        local title=$(menu_engine_get_item_property $index "title")
        local command=$(menu_engine_get_item_property $index "command")

        printf "${UI_HEADER_COLOR}🎵 Executing: $title${COLOR_RESET}\n"
        printf "   ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫\n"

        if [[ -n "$command" ]]; then
            eval "$command"
            printf "${UI_SUCCESS_COLOR}   ✅ Completed: $title${COLOR_RESET}\n\n"
            ((executed_count++))
        else
            printf "${UI_WARNING_COLOR}   ⚠️  No command defined for: $title${COLOR_RESET}\n\n"
        fi
    done

    if [[ $executed_count -eq 0 ]]; then
        printf "${UI_WARNING_COLOR}🎼 No items were selected for execution.${COLOR_RESET}\n"
        printf "${UI_INFO_COLOR}Tip: Use Space to select items, then choose 'Execute Selected'${COLOR_RESET}\n"
    else
        printf "${UI_SUCCESS_COLOR}🎭 Successfully executed $executed_count item(s)!${COLOR_RESET}\n"
        menu_engine_deselect_all
    fi

    nav_wait_for_keypress
    hide_cursor
}

# Show menu help
function show_menu_help() {
    clear_screen
    show_cursor

    draw_header "Menu Help" "Keyboard Shortcuts & Navigation"

    printf "${UI_INFO_COLOR}═══ Navigation ═══${COLOR_RESET}\n"
    printf "  ${UI_ACCENT_COLOR}↑ / k${COLOR_RESET}      Move up\n"
    printf "  ${UI_ACCENT_COLOR}↓ / j${COLOR_RESET}      Move down\n"
    printf "  ${UI_ACCENT_COLOR}Enter${COLOR_RESET}      Select/drill down into submenu\n"
    printf "  ${UI_ACCENT_COLOR}ESC / h${COLOR_RESET}    Go back to parent menu\n"
    printf "  ${UI_ACCENT_COLOR}Space${COLOR_RESET}      Toggle selection (multi-select menus)\n"
    printf "  ${UI_ACCENT_COLOR}q${COLOR_RESET}          Quit menu system\n\n"

    printf "${UI_INFO_COLOR}═══ Global Shortcuts ═══${COLOR_RESET}\n"
    printf "  ${UI_ACCENT_COLOR}a${COLOR_RESET}          Toggle Select/Deselect All\n"
    printf "  ${UI_ACCENT_COLOR}x${COLOR_RESET}          Execute selected items\n"
    printf "  ${UI_ACCENT_COLOR}l${COLOR_RESET}          Launch Librarian\n"
    printf "  ${UI_ACCENT_COLOR}b${COLOR_RESET}          Backup repository\n"
    printf "  ${UI_ACCENT_COLOR}u${COLOR_RESET}          Update all\n"
    printf "  ${UI_ACCENT_COLOR}?${COLOR_RESET}          Show this help screen\n\n"

    printf "${UI_SUCCESS_COLOR}💡 Tip: ${COLOR_RESET}${UI_INFO_COLOR}Use breadcrumb trail at top to see your current location!${COLOR_RESET}\n\n"

    printf "${UI_HEADER_COLOR}Press any key to return to menu...${COLOR_RESET}"
    read -k1
    hide_cursor
}

# ============================================================================
# Main Menu Loop
# ============================================================================

function run_hierarchical_menu() {
    # Initialize menu state with main menu
    menu_state_init "main_menu" "Main Menu"
    build_main_menu

    # Setup terminal
    hide_cursor
    trap 'show_cursor; exit 0' INT TERM EXIT

    # Initial draw
    local breadcrumb=$(menu_state_get_breadcrumb)
    menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
    nav_reset_display_state

    while true; do
        # Read keyboard input
        local key=$(nav_read_key)

        # Handle navigation
        nav_handle_keypress "$key"
        local nav_result=$?

        case $nav_result in
            $NAV_CONTINUE)
                # Just update the display
                nav_update_display
                ;;

            $NAV_UPDATE_DONE)
                # Display already updated, no further action
                ;;

            $NAV_QUIT)
                # Quit menu system
                break
                ;;

            $NAV_NAVIGATE_SUBMENU)
                # Enter submenu
                if nav_enter_submenu; then
                    local new_menu_id=$(menu_state_get_current_id)
                    build_menu_by_id "$new_menu_id"

                    # Redraw with new breadcrumb
                    breadcrumb=$(menu_state_get_breadcrumb)
                    menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                    nav_reset_display_state
                fi
                ;;

            $NAV_NAVIGATE_BACK)
                # Return to parent menu
                if nav_return_to_parent; then
                    local parent_menu_id=$(menu_state_get_current_id)
                    build_menu_by_id "$parent_menu_id"

                    # Redraw with updated breadcrumb
                    breadcrumb=$(menu_state_get_breadcrumb)
                    menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                    nav_reset_display_state
                fi
                ;;

            $NAV_EXECUTE_CURRENT)
                # Execute current item
                local current_index=$((MENU_CURRENT_ITEM + 1))
                execute_action_item $current_index

                # Redraw menu
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;

            $NAV_EXECUTE_SELECTED)
                # Execute all selected items
                execute_selected_items

                # Redraw menu
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;

            $NAV_SHOW_HELP)
                show_menu_help
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;

            $NAV_RUN_LIBRARIAN)
                execute_action_item 0  # Placeholder - will be improved
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;

            $NAV_RUN_BACKUP)
                execute_action_item 0  # Placeholder - will be improved
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;

            $NAV_RUN_UPDATE_ALL)
                execute_action_item 0  # Placeholder - will be improved
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;

            $NAV_FULL_REDRAW)
                breadcrumb=$(menu_state_get_breadcrumb)
                menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
                nav_reset_display_state
                ;;
        esac
    done

    show_cursor
    clear_screen
    printf "${UI_SUCCESS_COLOR}📚 The work is complete. $(get_random_friend_greeting) 💙${COLOR_RESET}\n\n"
}

# ============================================================================
# Main Execution
# ============================================================================

if [[ -z "$MENU_TEST_MODE" && ( "${BASH_SOURCE[0]}" == "${0}" || "${(%):-%N}" == "$0" ) ]]; then
    # Ensure required environment
    if [[ -z "$DF_DIR" ]]; then
        export DF_DIR=$(realpath "$(dirname $0)/..")
    fi

    run_hierarchical_menu
fi
