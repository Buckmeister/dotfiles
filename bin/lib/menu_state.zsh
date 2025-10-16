#!/usr/bin/env zsh

# ============================================================================
# Menu State Management - Navigation Stack & Breadcrumbs
# ============================================================================
#
# Manages hierarchical menu navigation state including:
# - Navigation stack (for back/escape functionality)
# - Breadcrumb trail (visual navigation path)
# - Menu history and cursor position memory
# - State persistence across menu transitions
#
# Dependencies: None (standalone module)
# ============================================================================

# Note: emulate -LR zsh was removed because it prevents array modifications
# from persisting outside of functions (except for +=). This caused menu_state_pop
# to fail to modify the global arrays.

# ============================================================================
# State Storage Structures
# ============================================================================

# Navigation stack - stores menu IDs in order of navigation
# Example: ("main_menu" "post_install" "language_servers")
typeset -ga MENU_NAV_STACK=()

# Breadcrumb trail - stores display names for current path
# Example: ("Main Menu" "Post-Install Scripts" "Language Servers")
typeset -ga MENU_BREADCRUMB_TRAIL=()

# Cursor position memory - remembers cursor position for each menu
# Key: menu_id, Value: cursor_position (0-indexed)
typeset -gA MENU_CURSOR_MEMORY=()

# Selection state memory - remembers selections for each menu
# Key: menu_id, Value: comma-separated list of selected indices
typeset -gA MENU_SELECTION_MEMORY=()

# Current menu context
typeset -g MENU_CURRENT_ID=""
typeset -g MENU_CURRENT_TITLE=""

# ============================================================================
# Navigation Stack Functions
# ============================================================================

# Initialize the navigation stack with the root menu
# Args: menu_id (string), menu_title (string)
function menu_state_init() {
    local menu_id="$1"
    local menu_title="$2"

    MENU_NAV_STACK=("$menu_id")
    MENU_BREADCRUMB_TRAIL=("$menu_title")
    MENU_CURRENT_ID="$menu_id"
    MENU_CURRENT_TITLE="$menu_title"
    MENU_CURSOR_MEMORY=()
    MENU_SELECTION_MEMORY=()
}

# Push a new menu onto the navigation stack
# Args: menu_id (string), menu_title (string)
function menu_state_push() {
    local menu_id="$1"
    local menu_title="$2"

    if [[ -z "$menu_id" || -z "$menu_title" ]]; then
        return 1
    fi

    MENU_NAV_STACK+=("$menu_id")
    MENU_BREADCRUMB_TRAIL+=("$menu_title")
    MENU_CURRENT_ID="$menu_id"
    MENU_CURRENT_TITLE="$menu_title"
}

# Pop the current menu from the navigation stack (return to parent)
# Returns: previous menu ID on stdout, or empty if at root
function menu_state_pop() {
    local stack_depth=${#MENU_NAV_STACK[@]}

    # Can't pop if we're at the root (only one item in stack)
    if [[ $stack_depth -le 1 ]]; then
        return 1
    fi

    # Store parent menu info before removing (will become current after pop)
    local parent_id="${MENU_NAV_STACK[-2]}"
    local parent_title="${MENU_BREADCRUMB_TRAIL[-2]}"

    # Remove last element using zsh array pop syntax
    # This modifies the array in place rather than reassigning
    MENU_NAV_STACK[-1]=()
    MENU_BREADCRUMB_TRAIL[-1]=()

    # Update current context to parent menu
    MENU_CURRENT_ID="$parent_id"
    MENU_CURRENT_TITLE="$parent_title"

    echo "$MENU_CURRENT_ID"
}

# Get the current navigation depth
# Returns: depth (0 = root, 1 = first level, etc.)
function menu_state_get_depth() {
    echo $((${#MENU_NAV_STACK[@]} - 1))
}

# Check if we're at the root menu
# Returns: 0 if at root, 1 if not
function menu_state_is_root() {
    [[ ${#MENU_NAV_STACK[@]} -eq 1 ]]
}

# Get the parent menu ID
# Returns: parent menu ID on stdout, or empty if at root
function menu_state_get_parent_id() {
    local stack_depth=${#MENU_NAV_STACK[@]}

    if [[ $stack_depth -le 1 ]]; then
        return 1
    fi

    echo "${MENU_NAV_STACK[-2]}"
}

# Clear the entire navigation stack (reset to uninitialized state)
function menu_state_clear() {
    MENU_NAV_STACK=()
    MENU_BREADCRUMB_TRAIL=()
    MENU_CURRENT_ID=""
    MENU_CURRENT_TITLE=""
    MENU_CURSOR_MEMORY=()
    MENU_SELECTION_MEMORY=()
}

# ============================================================================
# Breadcrumb Functions
# ============================================================================

# Get the current breadcrumb trail as a formatted string
# Args: separator (string) - default: " → "
# Returns: formatted breadcrumb string (e.g., "Main Menu → Settings → Display")
function menu_state_get_breadcrumb() {
    local separator="${1:- → }"
    local breadcrumb=""
    local i

    for ((i=1; i<=${#MENU_BREADCRUMB_TRAIL[@]}; i++)); do
        if [[ $i -eq 1 ]]; then
            breadcrumb="${MENU_BREADCRUMB_TRAIL[$i]}"
        else
            breadcrumb="${breadcrumb}${separator}${MENU_BREADCRUMB_TRAIL[$i]}"
        fi
    done

    echo "$breadcrumb"
}

# Get the breadcrumb trail as an array
# Returns: array of breadcrumb titles
function menu_state_get_breadcrumb_array() {
    echo "${MENU_BREADCRUMB_TRAIL[@]}"
}

# Get the full navigation path as menu IDs
# Returns: array of menu IDs from root to current
function menu_state_get_navigation_path() {
    echo "${MENU_NAV_STACK[@]}"
}

# ============================================================================
# Cursor Position Memory Functions
# ============================================================================

# Save the current cursor position for the current menu
# Args: cursor_position (int) - 0-indexed cursor position
function menu_state_save_cursor() {
    local cursor_position=$1

    if [[ -z "$MENU_CURRENT_ID" ]]; then
        return 1
    fi

    MENU_CURSOR_MEMORY[$MENU_CURRENT_ID]=$cursor_position
}

# Restore the cursor position for a specific menu
# Args: menu_id (string)
# Returns: cursor position (int) or 0 if no saved position
function menu_state_restore_cursor() {
    local menu_id="${1:-$MENU_CURRENT_ID}"

    if [[ -n "${MENU_CURSOR_MEMORY[$menu_id]}" ]]; then
        echo "${MENU_CURSOR_MEMORY[$menu_id]}"
    else
        echo "0"
    fi
}

# Clear saved cursor position for a specific menu
# Args: menu_id (string)
function menu_state_clear_cursor() {
    local menu_id="${1:-$MENU_CURRENT_ID}"
    unset "MENU_CURSOR_MEMORY[$menu_id]"
}

# ============================================================================
# Selection State Memory Functions
# ============================================================================

# Save the current selection state for the current menu
# Args: selected_indices (array) - array of 1-based selected indices
function menu_state_save_selections() {
    local selected_indices=("$@")

    if [[ -z "$MENU_CURRENT_ID" ]]; then
        return 1
    fi

    # Convert array to comma-separated string
    local selections_str="${(j:,:)selected_indices}"
    MENU_SELECTION_MEMORY[$MENU_CURRENT_ID]="$selections_str"
}

# Restore the selection state for a specific menu
# Args: menu_id (string)
# Returns: array of selected indices (1-based)
function menu_state_restore_selections() {
    local menu_id="${1:-$MENU_CURRENT_ID}"

    if [[ -n "${MENU_SELECTION_MEMORY[$menu_id]}" ]]; then
        # Convert comma-separated string back to array
        local selections_str="${MENU_SELECTION_MEMORY[$menu_id]}"
        echo "${(s:,:)selections_str}"
    fi
}

# Clear saved selections for a specific menu
# Args: menu_id (string)
function menu_state_clear_selections() {
    local menu_id="${1:-$MENU_CURRENT_ID}"
    unset "MENU_SELECTION_MEMORY[$menu_id]"
}

# ============================================================================
# Context Functions
# ============================================================================

# Get the current menu ID
# Returns: current menu ID
function menu_state_get_current_id() {
    echo "$MENU_CURRENT_ID"
}

# Get the current menu title
# Returns: current menu title
function menu_state_get_current_title() {
    echo "$MENU_CURRENT_TITLE"
}

# Set the current menu context (without modifying the stack)
# Args: menu_id (string), menu_title (string)
# Note: This is useful for updating the context without navigation
function menu_state_set_current() {
    local menu_id="$1"
    local menu_title="$2"

    MENU_CURRENT_ID="$menu_id"
    MENU_CURRENT_TITLE="$menu_title"
}

# ============================================================================
# Debug & Utility Functions
# ============================================================================

# Print the current navigation stack (for debugging)
function menu_state_debug_print_stack() {
    echo "Navigation Stack (depth: $(menu_state_get_depth)):"
    local i
    for ((i=1; i<=${#MENU_NAV_STACK[@]}; i++)); do
        echo "  [$i] ${MENU_NAV_STACK[$i]} (${MENU_BREADCRUMB_TRAIL[$i]})"
    done
    echo "Current: $MENU_CURRENT_ID ($MENU_CURRENT_TITLE)"
}

# Get a summary of the current state
# Returns: multi-line state summary
function menu_state_get_summary() {
    local depth=$(menu_state_get_depth)
    local breadcrumb=$(menu_state_get_breadcrumb)
    local is_root="false"
    menu_state_is_root && is_root="true"

    cat <<-EOF
	Menu State Summary:
	  Current ID: $MENU_CURRENT_ID
	  Current Title: $MENU_CURRENT_TITLE
	  Navigation Depth: $depth
	  Is Root: $is_root
	  Breadcrumb: $breadcrumb
	  Stack Size: ${#MENU_NAV_STACK[@]}
	  Cursor Positions Saved: ${#MENU_CURSOR_MEMORY[@]}
	  Selection States Saved: ${#MENU_SELECTION_MEMORY[@]}
	EOF
}

# ============================================================================
# Export Functions
# ============================================================================

autoload -U menu_state_init
autoload -U menu_state_push
autoload -U menu_state_pop
autoload -U menu_state_get_depth
autoload -U menu_state_is_root
autoload -U menu_state_get_parent_id
autoload -U menu_state_clear
autoload -U menu_state_get_breadcrumb
autoload -U menu_state_get_breadcrumb_array
autoload -U menu_state_get_navigation_path
autoload -U menu_state_save_cursor
autoload -U menu_state_restore_cursor
autoload -U menu_state_clear_cursor
autoload -U menu_state_save_selections
autoload -U menu_state_restore_selections
autoload -U menu_state_clear_selections
autoload -U menu_state_get_current_id
autoload -U menu_state_get_current_title
autoload -U menu_state_set_current
autoload -U menu_state_debug_print_stack
autoload -U menu_state_get_summary
