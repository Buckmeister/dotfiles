#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Menu Rendering Test Harness
# ============================================================================
#
# Programmatic interface to render menu structures without TUI interaction.
# This allows automated testing of menu layouts, structure, and content.
#
# Usage:
#   menu_render_test.zsh [--menu-id <id>] [--format <format>]
#
# Options:
#   --menu-id <id>     Menu ID to render (default: main_menu)
#   --format <format>  Output format: text, json, structure (default: text)
#   --list-menus       List all available menu IDs
#   --validate-all     Validate all menus are buildable
#   --help             Show this help message
#
# Examples:
#   # Render main menu as text
#   menu_render_test.zsh
#
#   # Render specific submenu
#   menu_render_test.zsh --menu-id post_install_menu
#
#   # Output menu structure as JSON
#   menu_render_test.zsh --menu-id system_tools_menu --format json
#
#   # List all available menus
#   menu_render_test.zsh --list-menus
#
#   # Validate all menus can be built
#   menu_render_test.zsh --validate-all
#
# ============================================================================

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$DF_DIR/bin/lib"

# Default options
MENU_ID="main_menu"
OUTPUT_FORMAT="text"
LIST_MENUS=false
VALIDATE_ALL=false

# ============================================================================
# Load Required Libraries
# ============================================================================

# Set test mode to prevent menu_hierarchical.zsh from executing
export MENU_TEST_MODE=1
export DF_DIR

# Source menu_hierarchical.zsh which loads all necessary libraries and defines all menu builders
# The MENU_TEST_MODE=1 prevents the main loop from executing
MENU_HIERARCHICAL="$DF_DIR/bin/menu_hierarchical.zsh"
if [[ -f "$MENU_HIERARCHICAL" ]]; then
    source "$MENU_HIERARCHICAL"
else
    echo "❌ Error: menu_hierarchical.zsh not found" >&2
    exit 1
fi

# Now all libraries are loaded and all menu builder functions are defined

# ============================================================================
# Argument Parsing
# ============================================================================

show_help() {
    cat <<'EOF'
Menu Rendering Test Harness

Programmatic interface to render menu structures without TUI interaction.

USAGE:
    menu_render_test.zsh [OPTIONS]

OPTIONS:
    --menu-id <id>     Menu ID to render (default: main_menu)
    --format <format>  Output format: text, json, structure (default: text)
    --list-menus       List all available menu IDs
    --validate-all     Validate all menus are buildable
    -h, --help         Show this help message

AVAILABLE MENU IDS:
    main_menu             Main menu (root)
    post_install_menu     Post-install scripts submenu
    profile_menu          Profile management submenu
    wizard_menu           Configuration wizard submenu
    package_menu          Package management submenu
    system_tools_menu     System tools submenu

OUTPUT FORMATS:
    text        Human-readable text format (default)
    json        Structured JSON output
    structure   Tree structure view

EXAMPLES:
    # Render main menu
    menu_render_test.zsh

    # Render specific submenu
    menu_render_test.zsh --menu-id post_install_menu

    # Get JSON structure
    menu_render_test.zsh --menu-id system_tools_menu --format json

    # List all menus
    menu_render_test.zsh --list-menus

    # Validate all menus
    menu_render_test.zsh --validate-all

EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --menu-id)
            MENU_ID="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        --list-menus)
            LIST_MENUS=true
            shift
            ;;
        --validate-all)
            VALIDATE_ALL=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Error: Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# ============================================================================
# Menu Registry
# ============================================================================

# Define all available menus with their builder functions
declare -A MENU_REGISTRY
MENU_REGISTRY=(
    [main_menu]="build_main_menu"
    [post_install_menu]="build_post_install_menu"
    [profile_menu]="build_profile_menu"
    [wizard_menu]="build_wizard_menu"
    [package_menu]="build_package_menu"
    [system_tools_menu]="build_system_tools_menu"
)

declare -A MENU_TITLES
MENU_TITLES=(
    [main_menu]="Main Menu"
    [post_install_menu]="Post-Install Scripts"
    [profile_menu]="Profile Management"
    [wizard_menu]="Configuration Wizard"
    [package_menu]="Package Management"
    [system_tools_menu]="System Tools"
)

# ============================================================================
# Rendering Functions
# ============================================================================

# Render menu as plain text
render_text() {
    local menu_id="$1"
    local title="${MENU_TITLES[$menu_id]}"

    echo "═══════════════════════════════════════════════"
    echo "  $title"
    echo "═══════════════════════════════════════════════"
    echo ""

    # Iterate through menu items
    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local item_title="${MENU_ITEMS[$i]}"
        local item_desc="${MENU_DESCRIPTIONS[$i]}"
        local item_type="${MENU_TYPES[$i]}"
        local item_icon="${MENU_ICONS[$i]}"
        local item_id="${MENU_IDS[$i]}"

        # Skip separators in text output
        if [[ "$item_type" == "$MENU_TYPE_SEPARATOR" ]]; then
            echo "  ─────────────────────────────────────────────"
            continue
        fi

        # Format based on type
        local type_indicator=""
        case "$item_type" in
            "$MENU_TYPE_SUBMENU"|"$MENU_TYPE_CATEGORY")
                type_indicator="[SUBMENU]"
                ;;
            "$MENU_TYPE_ACTION")
                type_indicator="[ACTION]"
                ;;
            "$MENU_TYPE_MULTI_SELECT")
                type_indicator="[MULTI]"
                ;;
            "$MENU_TYPE_CONTROL")
                type_indicator="[CONTROL]"
                ;;
            "$MENU_TYPE_BACK")
                type_indicator="[BACK]"
                ;;
        esac

        printf "  %s %-25s %s\n" "$item_icon" "$item_title" "$type_indicator"
        printf "      %s\n" "$item_desc"

        if [[ -n "$item_id" ]]; then
            printf "      [ID: %s]\n" "$item_id"
        fi
        echo ""
    done

    echo "Total Items: $MENU_TOTAL_ITEMS"
}

# Render menu as JSON
render_json() {
    local menu_id="$1"
    local title="${MENU_TITLES[$menu_id]}"

    echo "{"
    echo "  \"menu_id\": \"$menu_id\","
    echo "  \"title\": \"$title\","
    echo "  \"total_items\": $MENU_TOTAL_ITEMS,"
    echo "  \"items\": ["

    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local item_title="${MENU_ITEMS[$i]}"
        local item_desc="${MENU_DESCRIPTIONS[$i]}"
        local item_type="${MENU_TYPES[$i]}"
        local item_icon="${MENU_ICONS[$i]}"
        local item_id="${MENU_IDS[$i]}"
        local item_cmd="${MENU_COMMANDS[$i]}"

        echo "    {"
        echo "      \"index\": $i,"
        echo "      \"title\": \"$item_title\","
        echo "      \"description\": \"$item_desc\","
        echo "      \"type\": \"$item_type\","
        echo "      \"icon\": \"$item_icon\","
        echo "      \"id\": \"$item_id\","
        echo "      \"command\": \"${item_cmd:0:50}...\""

        if [[ $i -lt $MENU_TOTAL_ITEMS ]]; then
            echo "    },"
        else
            echo "    }"
        fi
    done

    echo "  ]"
    echo "}"
}

# Render menu as tree structure
render_structure() {
    local menu_id="$1"
    local title="${MENU_TITLES[$menu_id]}"
    local indent="${2:-}"

    echo "${indent}${title} [$menu_id]"

    for ((i=1; i<=MENU_TOTAL_ITEMS; i++)); do
        local item_title="${MENU_ITEMS[$i]}"
        local item_type="${MENU_TYPES[$i]}"
        local item_id="${MENU_IDS[$i]}"
        local item_icon="${MENU_ICONS[$i]}"

        # Skip separators
        if [[ "$item_type" == "$MENU_TYPE_SEPARATOR" ]]; then
            continue
        fi

        local prefix="├─"
        if [[ $i -eq $MENU_TOTAL_ITEMS ]]; then
            prefix="└─"
        fi

        echo "${indent}${prefix} $item_icon $item_title"

        # Recursively render submenus
        if [[ "$item_type" == "$MENU_TYPE_SUBMENU" || "$item_type" == "$MENU_TYPE_CATEGORY" ]]; then
            if [[ -n "$item_id" ]] && [[ -n "${MENU_REGISTRY[$item_id]}" ]]; then
                # Build and render submenu
                local builder_func="${MENU_REGISTRY[$item_id]}"
                menu_engine_clear_items
                $builder_func

                local sub_indent="${indent}│  "
                if [[ $i -eq $MENU_TOTAL_ITEMS ]]; then
                    sub_indent="${indent}   "
                fi

                render_structure "$item_id" "$sub_indent"
            fi
        fi
    done
}

# ============================================================================
# Validation Functions
# ============================================================================

# List all available menu IDs
list_all_menus() {
    echo "Available Menu IDs:"
    echo ""

    for menu_id in "${(@k)MENU_REGISTRY}"; do
        local title="${MENU_TITLES[$menu_id]}"
        local builder="${MENU_REGISTRY[$menu_id]}"
        printf "  %-25s %s\n" "$menu_id" "$title"
    done
}

# Validate all menus can be built successfully
validate_all_menus() {
    local total=0
    local success=0
    local failed=()

    echo "Validating all menus..."
    echo ""

    for menu_id in "${(@k)MENU_REGISTRY}"; do
        ((total++))
        local title="${MENU_TITLES[$menu_id]}"
        local builder="${MENU_REGISTRY[$menu_id]}"

        printf "Testing %-25s ... " "$menu_id"

        # Try to build the menu
        menu_engine_clear_items
        if $builder 2>/dev/null; then
            if [[ $MENU_TOTAL_ITEMS -gt 0 ]]; then
                print_success "OK ($MENU_TOTAL_ITEMS items)"
                ((success++))
            else
                print_error "FAIL (no items)"
                failed+=("$menu_id")
            fi
        else
            print_error "FAIL (builder error)"
            failed+=("$menu_id")
        fi
    done

    echo ""
    echo "═══════════════════════════════════════════════"
    echo "Validation Results: $success/$total passed"

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo ""
        echo "Failed menus:"
        for menu_id in "${failed[@]}"; do
            echo "  - $menu_id"
        done
        return 1
    fi

    return 0
}

# ============================================================================
# Main Execution
# ============================================================================

# Handle special modes
if [[ "$LIST_MENUS" == "true" ]]; then
    list_all_menus
    exit 0
fi

if [[ "$VALIDATE_ALL" == "true" ]]; then
    validate_all_menus
    exit $?
fi

# Validate menu ID exists
if [[ -z "${MENU_REGISTRY[$MENU_ID]}" ]]; then
    echo "❌ Error: Unknown menu ID: $MENU_ID" >&2
    echo "Use --list-menus to see available menu IDs" >&2
    exit 1
fi

# Build the requested menu
builder_func="${MENU_REGISTRY[$MENU_ID]}"
menu_engine_clear_items

if ! $builder_func 2>/dev/null; then
    echo "❌ Error: Failed to build menu: $MENU_ID" >&2
    exit 1
fi

# Render in requested format
case "$OUTPUT_FORMAT" in
    text)
        render_text "$MENU_ID"
        ;;
    json)
        render_json "$MENU_ID"
        ;;
    structure)
        render_structure "$MENU_ID"
        ;;
    *)
        echo "❌ Error: Unknown format: $OUTPUT_FORMAT" >&2
        echo "Supported formats: text, json, structure" >&2
        exit 1
        ;;
esac

exit 0
