# Hierarchical Menu Engine API Documentation

The hierarchical menu system provides a sophisticated, multi-level navigation interface for organizing dotfiles operations into intuitive categories with breadcrumb trails and state management.

## Architecture Overview

The menu system consists of three core modules:

1. **menu_engine.zsh** - Core rendering and data structures
2. **menu_state.zsh** - State management and navigation stack
3. **menu_navigation.zsh** - Keyboard input and navigation logic

## Menu Types

The system supports six menu item types:

| Type | Constant | Behavior | Use Case |
|------|----------|----------|----------|
| Category | `MENU_TYPE_CATEGORY` | Navigable submenu | Top-level categories |
| Submenu | `MENU_TYPE_SUBMENU` | Navigable submenu | Nested menus |
| Action | `MENU_TYPE_ACTION` | Executable command | Single-action items |
| Multi-Select | `MENU_TYPE_MULTI_SELECT` | Selectable + executable | Batch operations |
| Button | `MENU_TYPE_BUTTON` | Non-selectable action | Control buttons |
| Control | `MENU_TYPE_CONTROL` | Special control item | Menu controls |
| Back | `MENU_TYPE_BACK` | Navigate to parent | Return navigation |
| Separator | `MENU_TYPE_SEPARATOR` | Visual separator | Menu organization |

## Module 1: menu_engine.zsh

### Core Functions

#### menu_engine_add_item()
Add a menu item to the current menu.

**Signature:**
```zsh
menu_engine_add_item <title> <description> <type> [command] [icon] [id]
```

**Parameters:**
- `title` (string, required) - Display title of the menu item
- `description` (string, required) - Help text shown next to the item
- `type` (string, required) - Item type (use MENU_TYPE_* constants)
- `command` (string, optional) - Command to execute (for action types)
- `icon` (string, optional) - Emoji or icon to display
- `id` (string, optional) - Unique identifier (for submenus)

**Example:**
```zsh
menu_engine_add_item \
    "Post-Install Scripts" \
    "Configure system components" \
    "$MENU_TYPE_SUBMENU" \
    "" \
    "📦" \
    "post_install_menu"
```

#### menu_engine_clear_items()
Reset all menu items and state.

**Signature:**
```zsh
menu_engine_clear_items
```

**Example:**
```zsh
menu_engine_clear_items
# Now you can build a new menu from scratch
```

#### menu_engine_draw_complete_menu()
Render the complete menu with header and all items.

**Signature:**
```zsh
menu_engine_draw_complete_menu [title] [subtitle]
```

**Parameters:**
- `title` (string, optional) - Main menu title (default: "Dotfiles Management System")
- `subtitle` (string, optional) - Subtitle/breadcrumb (default: "Interactive Menu")

**Example:**
```zsh
local breadcrumb=$(menu_state_get_breadcrumb)
menu_engine_draw_complete_menu "Dotfiles Management System" "$breadcrumb"
```

### Navigation Functions

#### menu_engine_move_up()
Move cursor to previous item (with wrap-around).

**Signature:**
```zsh
menu_engine_move_up
```

#### menu_engine_move_down()
Move cursor to next item (with wrap-around).

**Signature:**
```zsh
menu_engine_move_down
```

### Query Functions

#### menu_engine_get_current_type()
Get the type of the currently selected item.

**Returns:** Type string (MENU_TYPE_*)

**Example:**
```zsh
local current_type=$(menu_engine_get_current_type)
if menu_engine_is_navigable "$current_type"; then
    # Enter submenu
fi
```

#### menu_engine_get_current_id()
Get the ID of the currently selected item.

**Returns:** Item ID string

#### menu_engine_get_current_command()
Get the command associated with the currently selected item.

**Returns:** Command string

### Selection Functions

#### menu_engine_toggle_selection()
Toggle selection state of a specific item (for multi-select menus).

**Signature:**
```zsh
menu_engine_toggle_selection <index>
```

**Parameters:**
- `index` (int, required) - 1-based item index

#### menu_engine_select_all()
Select all multi-selectable items.

```zsh
menu_engine_select_all
```

#### menu_engine_deselect_all()
Deselect all items.

```zsh
menu_engine_deselect_all
```

#### menu_engine_toggle_all()
Toggle all selections (select all if any unselected, deselect all if all selected).

```zsh
menu_engine_toggle_all
```

#### menu_engine_count_selected()
Count the number of currently selected items.

**Returns:** Integer count

**Example:**
```zsh
local count=$(menu_engine_count_selected)
echo "Selected: $count items"
```

#### menu_engine_get_selected_indices()
Get list of all selected item indices.

**Returns:** Space-separated list of 1-based indices

**Example:**
```zsh
local selected=($(menu_engine_get_selected_indices))
for index in "${selected[@]}"; do
    echo "Selected item $index"
done
```

### Type Checking Functions

#### menu_engine_is_navigable()
Check if a type is navigable (submenu or category).

**Returns:** Exit code 0 if navigable, 1 otherwise

**Example:**
```zsh
if menu_engine_is_navigable "$MENU_TYPE_SUBMENU"; then
    echo "This is navigable"
fi
```

#### menu_engine_is_selectable()
Check if a type is selectable (multi-select).

**Returns:** Exit code 0 if selectable, 1 otherwise

#### menu_engine_is_executable()
Check if a type is executable (action or button).

**Returns:** Exit code 0 if executable, 1 otherwise

## Module 2: menu_state.zsh

### Initialization

#### menu_state_init()
Initialize the navigation stack with a root menu.

**Signature:**
```zsh
menu_state_init <menu_id> <menu_title>
```

**Parameters:**
- `menu_id` (string, required) - Unique identifier for the menu
- `menu_title` (string, required) - Display title for breadcrumbs

**Example:**
```zsh
menu_state_init "main_menu" "Main Menu"
```

### Navigation Stack

#### menu_state_push()
Push a new menu onto the navigation stack.

**Signature:**
```zsh
menu_state_push <menu_id> <menu_title>
```

**Example:**
```zsh
menu_state_push "settings_menu" "Settings"
```

#### menu_state_pop()
Pop the current menu and return to parent.

**Returns:** Parent menu ID on stdout

**Example:**
```zsh
local parent_id=$(menu_state_pop)
if [[ $? -eq 0 ]]; then
    echo "Returned to: $parent_id"
else
    echo "Already at root"
fi
```

### Query Functions

#### menu_state_get_depth()
Get current navigation depth (0 = root, 1 = first level, etc.).

**Returns:** Integer depth

**Example:**
```zsh
local depth=$(menu_state_get_depth)
echo "You are $depth levels deep"
```

#### menu_state_is_root()
Check if currently at root menu.

**Returns:** Exit code 0 if at root, 1 otherwise

**Example:**
```zsh
if menu_state_is_root; then
    echo "At root - cannot go back"
fi
```

#### menu_state_get_parent_id()
Get the parent menu ID.

**Returns:** Parent ID on stdout (fails if at root)

#### menu_state_get_current_id()
Get the current menu ID.

**Returns:** Current menu ID

#### menu_state_get_current_title()
Get the current menu title.

**Returns:** Current menu title

### Breadcrumb Functions

#### menu_state_get_breadcrumb()
Get formatted breadcrumb trail.

**Signature:**
```zsh
menu_state_get_breadcrumb [separator]
```

**Parameters:**
- `separator` (string, optional) - Separator between levels (default: " → ")

**Returns:** Formatted breadcrumb string

**Example:**
```zsh
local breadcrumb=$(menu_state_get_breadcrumb)
echo "$breadcrumb"
# Output: "Main Menu → Settings → Display"
```

### Cursor Memory

#### menu_state_save_cursor()
Save current cursor position for the current menu.

**Signature:**
```zsh
menu_state_save_cursor <position>
```

**Parameters:**
- `position` (int, required) - 0-indexed cursor position

**Example:**
```zsh
menu_state_save_cursor $MENU_CURRENT_ITEM
```

#### menu_state_restore_cursor()
Restore saved cursor position for a menu.

**Signature:**
```zsh
menu_state_restore_cursor [menu_id]
```

**Parameters:**
- `menu_id` (string, optional) - Menu to restore (defaults to current)

**Returns:** Saved position or 0 if none saved

**Example:**
```zsh
local saved_pos=$(menu_state_restore_cursor "main_menu")
MENU_CURRENT_ITEM=$saved_pos
```

## Module 3: menu_navigation.zsh

### Navigation Return Codes

The `nav_handle_keypress()` function returns these codes:

| Code | Constant | Meaning |
|------|----------|---------|
| 0 | `NAV_CONTINUE` | Continue menu loop |
| 1 | `NAV_QUIT` | Quit menu system |
| 2 | `NAV_EXECUTE_SELECTED` | Execute all selected items |
| 3 | `NAV_EXECUTE_CURRENT` | Execute current item only |
| 4 | `NAV_NAVIGATE_SUBMENU` | Navigate into submenu |
| 5 | `NAV_NAVIGATE_BACK` | Navigate back to parent |
| 6 | `NAV_UPDATE_DONE` | Display already updated |
| 7 | `NAV_FULL_REDRAW` | Full screen redraw needed |
| 8 | `NAV_SHOW_HELP` | Show help screen |
| 9 | `NAV_RUN_LIBRARIAN` | Run librarian diagnostics |
| 10 | `NAV_RUN_BACKUP` | Run backup operation |
| 11 | `NAV_RUN_UPDATE_ALL` | Run update all |

### Keyboard Handling

#### nav_handle_keypress()
Process keyboard input and return appropriate navigation action.

**Signature:**
```zsh
nav_handle_keypress <key>
```

**Parameters:**
- `key` (string, required) - Key input from user

**Returns:** Navigation return code (see table above)

**Supported Keys:**
- `↑/k` - Move up
- `↓/j` - Move down
- `Enter` - Select/drill down/execute
- `ESC/h` - Go back
- `Space` - Toggle selection
- `q` - Quit
- `a` - Toggle select all
- `x` - Execute selected
- `l` - Launch librarian
- `b` - Backup
- `u` - Update all
- `?` - Show help

**Example:**
```zsh
local key=$(nav_read_key)
nav_handle_keypress "$key"
local result=$?

case $result in
    $NAV_QUIT)
        break
        ;;
    $NAV_NAVIGATE_SUBMENU)
        nav_enter_submenu
        ;;
esac
```

### Display Updates

#### nav_update_display()
Update only changed menu items (anti-flicker).

```zsh
nav_update_display
```

#### nav_reset_display_state()
Reset display state tracking (call after full redraw).

```zsh
menu_engine_draw_complete_menu
nav_reset_display_state
```

### Navigation Actions

#### nav_enter_submenu()
Navigate into the currently selected submenu.

**Returns:** Exit code 0 on success, 1 on error

**Example:**
```zsh
if nav_enter_submenu; then
    local new_menu_id=$(menu_state_get_current_id)
    build_menu_by_id "$new_menu_id"
    menu_engine_draw_complete_menu
fi
```

#### nav_return_to_parent()
Navigate back to parent menu.

**Returns:** Exit code 0 on success, 1 if at root

**Example:**
```zsh
if nav_return_to_parent; then
    local parent_id=$(menu_state_get_current_id)
    build_menu_by_id "$parent_id"
    menu_engine_draw_complete_menu
fi
```

## Complete Example: Building a Hierarchical Menu

```zsh
#!/usr/bin/env zsh

# Load libraries
source "bin/lib/colors.zsh"
source "bin/lib/ui.zsh"
source "bin/lib/menu_engine.zsh"
source "bin/lib/menu_state.zsh"
source "bin/lib/menu_navigation.zsh"

# Build main menu
function build_main_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "Settings" \
        "Configure application settings" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "⚙️" \
        "settings_menu"

    menu_engine_add_item \
        "Tools" \
        "System tools and utilities" \
        "$MENU_TYPE_SUBMENU" \
        "" \
        "🔧" \
        "tools_menu"

    menu_engine_add_item \
        "Quit" \
        "Exit the menu" \
        "$MENU_TYPE_CONTROL" \
        "" \
        "🚪"
}

# Build settings submenu
function build_settings_menu() {
    menu_engine_clear_items

    menu_engine_add_item \
        "Change Theme" \
        "Select color theme" \
        "$MENU_TYPE_ACTION" \
        'echo "Changing theme..."' \
        "🎨"

    menu_engine_add_item \
        "Back" \
        "Return to main menu" \
        "$MENU_TYPE_BACK" \
        "" \
        "◂"
}

# Menu dispatcher
function build_menu_by_id() {
    case "$1" in
        "main_menu") build_main_menu ;;
        "settings_menu") build_settings_menu ;;
    esac
}

# Main menu loop
function run_menu() {
    menu_state_init "main_menu" "Main Menu"
    build_main_menu

    hide_cursor
    trap 'show_cursor; exit 0' INT TERM EXIT

    local breadcrumb=$(menu_state_get_breadcrumb)
    menu_engine_draw_complete_menu "My Application" "$breadcrumb"
    nav_reset_display_state

    while true; do
        local key=$(nav_read_key)
        nav_handle_keypress "$key"
        local result=$?

        case $result in
            $NAV_CONTINUE)
                nav_update_display
                ;;
            $NAV_QUIT)
                break
                ;;
            $NAV_NAVIGATE_SUBMENU)
                if nav_enter_submenu; then
                    build_menu_by_id "$(menu_state_get_current_id)"
                    breadcrumb=$(menu_state_get_breadcrumb)
                    menu_engine_draw_complete_menu "My Application" "$breadcrumb"
                    nav_reset_display_state
                fi
                ;;
            $NAV_NAVIGATE_BACK)
                if nav_return_to_parent; then
                    build_menu_by_id "$(menu_state_get_current_id)"
                    breadcrumb=$(menu_state_get_breadcrumb)
                    menu_engine_draw_complete_menu "My Application" "$breadcrumb"
                    nav_reset_display_state
                fi
                ;;
        esac
    done

    show_cursor
    clear_screen
}

run_menu
```

## Best Practices

1. **Always clear before building** - Call `menu_engine_clear_items()` at the start of each menu builder
2. **Save cursor positions** - Use `menu_state_save_cursor()` before navigating to submenus
3. **Reset display state** - Call `nav_reset_display_state()` after full redraws
4. **Use breadcrumbs** - Display breadcrumb trail in subtitle for user context
5. **Consistent menu IDs** - Use descriptive, unique IDs for all navigable menus
6. **Handle all return codes** - Check and handle all navigation return codes appropriately

## Testing

Run the unit tests to verify functionality:

```bash
./tests/unit/test_menu_engine.zsh
```

Expected result: 14/15 tests passing (93% success rate).

## Performance Considerations

- **Anti-flicker rendering** - Only changed items are redrawn
- **Lazy loading** - Submenus are built only when navigated to
- **Efficient state management** - Minimal memory footprint with stack-based navigation
- **Terminal optimization** - Direct cursor positioning for fast updates

## License

This menu engine is part of the dotfiles project and follows the same license.
