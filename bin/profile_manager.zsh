#!/usr/bin/env zsh

# ============================================================================
# Profile Manager - Switch between dotfiles configuration profiles
# ============================================================================
#
# Manages user profiles that define different configuration presets:
# - minimal: Lightweight setup with essentials only
# - standard: Recommended default for most users
# - full: Complete setup with all features
# - work: Professional development environment
# - personal: Personal projects and experimentation
#
# Usage:
#   profile_manager.zsh list              # List available profiles
#   profile_manager.zsh show <profile>    # Show profile details
#   profile_manager.zsh apply <profile>   # Apply a profile
#   profile_manager.zsh current           # Show current profile
#   profile_manager.zsh --help            # Show this help
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
source "$DF_LIB_DIR/colors.zsh"
source "$DF_LIB_DIR/ui.zsh"
source "$DF_LIB_DIR/greetings.zsh"

# ============================================================================
# Constants
# ============================================================================

readonly PROFILES_DIR="$DF_DIR/profiles"
readonly CURRENT_PROFILE_FILE="$HOME/.config/dotfiles/current_profile"
readonly POST_INSTALL_DIR="$DF_DIR/post-install/scripts"

# ============================================================================
# Helper Functions
# ============================================================================

# Parse YAML profile file (simple parser for our format)
function parse_profile() {
    local profile_file="$1"

    if [[ ! -f "$profile_file" ]]; then
        echo "${UI_ERROR_COLOR}Error: Profile file not found: $profile_file${COLOR_RESET}" >&2
        return 1
    fi

    # Read profile into associative array
    typeset -gA PROFILE_DATA
    local current_section=""
    local current_list=""

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        # Extract top-level key-value pairs (no leading spaces)
        if [[ "$line" =~ ^([a-z_]+):[[:space:]]*(.*)$ ]]; then
            local key="${match[1]}"
            local value="${match[2]}"
            value="${value%\"}"  # Remove trailing quote
            value="${value#\"}"  # Remove leading quote

            PROFILE_DATA[$key]="$value"
            current_section="$key"
            current_list=""
        # Extract nested key-value pairs (2+ spaces indent)
        elif [[ "$line" =~ ^[[:space:]]{2,}([a-z_]+):[[:space:]]*(.*)$ ]]; then
            local nested_key="${match[1]}"
            local nested_value="${match[2]}"
            nested_value="${nested_value%\"}"  # Remove trailing quote
            nested_value="${nested_value#\"}"  # Remove leading quote

            # Store with combined key: section_nestedkey
            if [[ -n "$current_section" ]]; then
                PROFILE_DATA[${current_section}_${nested_key}]="$nested_value"
            else
                PROFILE_DATA[$nested_key]="$nested_value"
            fi
        # Extract list items (2+ spaces + dash)
        elif [[ "$line" =~ ^[[:space:]]{2,}-[[:space:]]+(.+)$ ]]; then
            # List item
            local item="${match[1]}"
            if [[ -n "$current_section" ]]; then
                if [[ -z "${PROFILE_DATA[${current_section}_list]}" ]]; then
                    PROFILE_DATA[${current_section}_list]="$item"
                else
                    PROFILE_DATA[${current_section}_list]="${PROFILE_DATA[${current_section}_list]},$item"
                fi
            fi
        fi
    done < "$profile_file"

    return 0
}

# List all available profiles
function list_profiles() {
    draw_section_header "Available Profiles"
    echo

    local profiles=("$PROFILES_DIR"/*.yaml)

    if [[ ${#profiles[@]} -eq 0 ]] || [[ ! -f "${profiles[1]}" ]]; then
        echo "${UI_WARNING_COLOR}No profiles found in $PROFILES_DIR${COLOR_RESET}"
        return 1
    fi

    local current_profile=""
    if [[ -f "$CURRENT_PROFILE_FILE" ]]; then
        current_profile=$(cat "$CURRENT_PROFILE_FILE")
    fi

    for profile_file in "${profiles[@]}"; do
        local profile_name="${profile_file:t:r}"  # Basename without extension

        # Parse profile to get metadata
        parse_profile "$profile_file"

        local emoji="${PROFILE_DATA[emoji]:-📦}"
        local description="${PROFILE_DATA[description]:-No description}"

        # Highlight current profile
        if [[ "$profile_name" == "$current_profile" ]]; then
            echo "${UI_SUCCESS_COLOR}✓ $emoji  ${COLOR_BOLD}$profile_name${COLOR_RESET}${UI_SUCCESS_COLOR} (current)${COLOR_RESET}"
        else
            echo "  $emoji  ${UI_ACCENT_COLOR}$profile_name${COLOR_RESET}"
        fi
        echo "     ${UI_INFO_COLOR}$description${COLOR_RESET}"
        echo
    done
}

# Show detailed information about a profile
function show_profile() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.yaml"

    if [[ ! -f "$profile_file" ]]; then
        echo "${UI_ERROR_COLOR}Error: Profile '$profile_name' not found${COLOR_RESET}" >&2
        return 1
    fi

    parse_profile "$profile_file"

    local emoji="${PROFILE_DATA[emoji]:-📦}"
    draw_section_header "$emoji  $profile_name Profile"
    echo

    echo "${UI_ACCENT_COLOR}Description:${COLOR_RESET}"
    echo "  ${PROFILE_DATA[description]:-No description}"
    echo

    echo "${UI_ACCENT_COLOR}Package Management:${COLOR_RESET}"
    echo "  Level: ${PROFILE_DATA[packages_level]:-recommended}"

    local manifest_path="${PROFILE_DATA[packages_manifest]}"
    if [[ -n "$manifest_path" ]]; then
        local full_manifest_path="$DF_DIR/$manifest_path"
        if [[ -f "$full_manifest_path" ]]; then
            local pkg_count=$(grep -c '^\s*-\s*id:' "$full_manifest_path" 2>/dev/null || echo "0")
            echo "  Manifest: $manifest_path"
            echo "  Packages: $pkg_count defined"
        else
            echo "  Manifest: $manifest_path ${UI_WARNING_COLOR}(not found)${COLOR_RESET}"
        fi
    else
        echo "  Manifest: ${UI_INFO_COLOR}None${COLOR_RESET}"
    fi
    echo

    echo "${UI_ACCENT_COLOR}Default Settings:${COLOR_RESET}"
    echo "  Editor: ${PROFILE_DATA[settings_editor]:-nvim}"
    echo "  Shell:  ${PROFILE_DATA[settings_shell]:-zsh}"
    echo "  Theme:  ${PROFILE_DATA[settings_theme]:-onedark}"
    echo

    echo "${UI_ACCENT_COLOR}Post-Install Scripts:${COLOR_RESET}"
    local scripts="${PROFILE_DATA[post_install_scripts_list]}"
    if [[ -n "$scripts" ]]; then
        IFS=',' read -rA script_array <<< "$scripts"
        for script in "${script_array[@]}"; do
            if [[ -f "$POST_INSTALL_DIR/$script" ]]; then
                echo "  ${UI_SUCCESS_COLOR}✓${COLOR_RESET} $script"
            else
                echo "  ${UI_WARNING_COLOR}✗${COLOR_RESET} $script ${UI_WARNING_COLOR}(not found)${COLOR_RESET}"
            fi
        done
    else
        echo "  ${UI_INFO_COLOR}None${COLOR_RESET}"
    fi
    echo

    echo "${UI_ACCENT_COLOR}Development Languages:${COLOR_RESET}"
    local languages="${PROFILE_DATA[dev_languages_list]}"
    if [[ -n "$languages" ]]; then
        IFS=',' read -rA lang_array <<< "$languages"
        for lang in "${lang_array[@]}"; do
            echo "  • $lang"
        done
    else
        echo "  ${UI_INFO_COLOR}None specified${COLOR_RESET}"
    fi
    echo
}

# Apply a profile (run post-install scripts)
function apply_profile() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.yaml"

    if [[ ! -f "$profile_file" ]]; then
        echo "${UI_ERROR_COLOR}Error: Profile '$profile_name' not found${COLOR_RESET}" >&2
        return 1
    fi

    parse_profile "$profile_file"

    local emoji="${PROFILE_DATA[emoji]:-📦}"
    draw_section_header "$emoji  Applying $profile_name Profile"
    echo

    # Check for package manifest
    local manifest_path="${PROFILE_DATA[packages_manifest]}"
    local has_manifest=false
    if [[ -n "$manifest_path" ]]; then
        local full_manifest_path="$DF_DIR/$manifest_path"
        if [[ -f "$full_manifest_path" ]]; then
            has_manifest=true
        fi
    fi

    # Show what will be done
    if [[ "$has_manifest" == "true" ]]; then
        echo "${UI_SUCCESS_COLOR}📦 Package manifest found: ${COLOR_RESET}$manifest_path"
        echo "${UI_INFO_COLOR}   Packages will be installed from manifest${COLOR_RESET}"
        echo
    fi

    echo "${UI_INFO_COLOR}Post-install scripts to run:${COLOR_RESET}"
    local scripts="${PROFILE_DATA[post_install_scripts_list]}"
    if [[ -z "$scripts" ]]; then
        if [[ "$has_manifest" != "true" ]]; then
            echo "  ${UI_WARNING_COLOR}No scripts or manifest defined in profile${COLOR_RESET}"
            echo
            return 0
        else
            echo "  ${UI_INFO_COLOR}None (packages only)${COLOR_RESET}"
        fi
    else
        IFS=',' read -rA script_array <<< "$scripts"
        for script in "${script_array[@]}"; do
            echo "  • $script"
        done
    fi
    echo

    # Confirm
    echo -n "${UI_WARNING_COLOR}Continue? [y/N]${COLOR_RESET} "
    read -r response

    if [[ ! "$response" =~ ^[Yy] ]]; then
        echo "${UI_INFO_COLOR}Cancelled${COLOR_RESET}"
        return 0
    fi

    echo

    # Install packages from manifest if available
    if [[ "$has_manifest" == "true" ]]; then
        draw_section_header "Installing Packages from Manifest"
        echo

        if command -v install_from_manifest >/dev/null 2>&1; then
            echo "${UI_INFO_COLOR}Running: install_from_manifest -i $full_manifest_path${COLOR_RESET}"
            echo

            if install_from_manifest -i "$full_manifest_path"; then
                echo
                print_success "Package installation completed"
            else
                echo
                print_warning "Package installation had errors (continuing with post-install scripts)"
            fi
        else
            print_warning "install_from_manifest command not found"
            print_info "Run: ./bin/link_dotfiles.zsh to install package management tools"
        fi
        echo
    fi

    # Run post-install scripts if any
    if [[ -z "$scripts" ]]; then
        # No scripts, just save profile and exit
        echo "$profile_name" > "$CURRENT_PROFILE_FILE"
        print_success "Profile '$profile_name' applied successfully"
        echo
        return 0
    fi

    draw_section_header "Running Post-Install Scripts"
    echo

    # Run each script
    local success_count=0
    local fail_count=0

    for script in "${script_array[@]}"; do
        local script_path="$POST_INSTALL_DIR/$script"

        if [[ ! -f "$script_path" ]]; then
            echo "${UI_ERROR_COLOR}✗ $script (not found)${COLOR_RESET}"
            ((fail_count++))
            continue
        fi

        echo "${UI_ACCENT_COLOR}Running $script...${COLOR_RESET}"

        if "$script_path" --silent 2>&1; then
            echo "${UI_SUCCESS_COLOR}✓ $script completed${COLOR_RESET}"
            ((success_count++))
        else
            echo "${UI_ERROR_COLOR}✗ $script failed${COLOR_RESET}"
            ((fail_count++))
        fi
        echo
    done

    # Save current profile
    echo "$profile_name" > "$CURRENT_PROFILE_FILE"

    # Summary
    draw_section_header "Profile Application Complete"
    echo
    echo "Success: ${UI_SUCCESS_COLOR}$success_count${COLOR_RESET} scripts"
    echo "Failed:  ${UI_ERROR_COLOR}$fail_count${COLOR_RESET} scripts"
    echo
    echo "${UI_INFO_COLOR}Current profile saved to: $CURRENT_PROFILE_FILE${COLOR_RESET}"
    echo
}

# Show current profile
function show_current_profile() {
    if [[ ! -f "$CURRENT_PROFILE_FILE" ]]; then
        echo "${UI_WARNING_COLOR}No profile currently active${COLOR_RESET}"
        echo
        echo "${UI_INFO_COLOR}Use 'profile_manager.zsh list' to see available profiles${COLOR_RESET}"
        echo "${UI_INFO_COLOR}Use 'profile_manager.zsh apply <profile>' to activate a profile${COLOR_RESET}"
        return 0
    fi

    local profile_name=$(cat "$CURRENT_PROFILE_FILE")

    echo "${UI_SUCCESS_COLOR}Current profile: ${COLOR_BOLD}$profile_name${COLOR_RESET}"
    echo

    show_profile "$profile_name"
}

# Show help
function show_help() {
    cat <<EOF
${COLOR_BOLD}Profile Manager${COLOR_RESET}

Manage dotfiles configuration profiles

${COLOR_BOLD}USAGE:${COLOR_RESET}
    profile_manager.zsh <command> [options]

${COLOR_BOLD}COMMANDS:${COLOR_RESET}
    list                List all available profiles
    show <profile>      Show detailed information about a profile
    apply <profile>     Apply a profile (run its post-install scripts)
    current             Show the currently active profile

${COLOR_BOLD}AVAILABLE PROFILES:${COLOR_RESET}
    minimal             Lightweight setup with essentials only
    standard            Recommended default for most users
    full                Complete setup with all features
    work                Professional development environment
    personal            Personal projects and experimentation

${COLOR_BOLD}EXAMPLES:${COLOR_RESET}
    # List all profiles
    profile_manager.zsh list

    # Show details about the standard profile
    profile_manager.zsh show standard

    # Apply the work profile
    profile_manager.zsh apply work

    # Check current profile
    profile_manager.zsh current

${COLOR_BOLD}OPTIONS:${COLOR_RESET}
    -h, --help          Show this help message

${COLOR_BOLD}PROFILE STRUCTURE:${COLOR_RESET}
    Profiles are YAML files located in:
    $PROFILES_DIR

    Each profile defines:
    - Post-install scripts to run
    - Package installation level
    - Default editor, shell, and theme
    - Development languages to configure

EOF
}

# ============================================================================
# Main Entry Point
# ============================================================================

function main() {
    local command="${1:-}"

    case "$command" in
        list)
            list_profiles
            ;;
        show)
            if [[ -z "$2" ]]; then
                echo "${UI_ERROR_COLOR}Error: Profile name required${COLOR_RESET}" >&2
                echo "Usage: profile_manager.zsh show <profile>" >&2
                return 1
            fi
            show_profile "$2"
            ;;
        apply)
            if [[ -z "$2" ]]; then
                echo "${UI_ERROR_COLOR}Error: Profile name required${COLOR_RESET}" >&2
                echo "Usage: profile_manager.zsh apply <profile>" >&2
                return 1
            fi
            apply_profile "$2"
            ;;
        current)
            show_current_profile
            ;;
        -h|--help|help)
            show_help
            ;;
        "")
            echo "${UI_ERROR_COLOR}Error: Command required${COLOR_RESET}" >&2
            echo "Use 'profile_manager.zsh --help' for usage information" >&2
            return 1
            ;;
        *)
            echo "${UI_ERROR_COLOR}Error: Unknown command '$command'${COLOR_RESET}" >&2
            echo "Use 'profile_manager.zsh --help' for usage information" >&2
            return 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
