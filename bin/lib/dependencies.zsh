#!/usr/bin/env zsh

# ============================================================================
# Dependency Management Library for Post-Install Scripts
# ============================================================================
#
# A comprehensive dependency management system that provides:
# - Declarative dependency specification
# - Automatic dependency resolution
# - Clear, consistent error messages
# - Interactive and non-interactive modes
# - Circular dependency detection
#
# Usage:
#   source "$LIB_DIR/dependencies.zsh"
#
#   declare_dependency_command "cargo" "Rust toolchain" "toolchains.zsh"
#   declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"
#
#   check_and_resolve_dependencies || exit 1
#
# ============================================================================

# Prevent multiple loading
[[ -n "$DOTFILES_DEPENDENCIES_LOADED" ]] && return 0
readonly DOTFILES_DEPENDENCIES_LOADED=1

# Ensure required libraries are loaded
if [[ -z "$DOTFILES_COLORS_LOADED" ]]; then
    local lib_dir="$(dirname "${(%):-%N}")"
    source "$lib_dir/colors.zsh" 2>/dev/null || {
        echo "Warning: Could not load colors.zsh library" >&2
        return 1
    }
fi

if [[ -z "$DOTFILES_UI_LOADED" ]]; then
    local lib_dir="$(dirname "${(%):-%N}")"
    source "$lib_dir/ui.zsh" 2>/dev/null || {
        echo "Warning: Could not load ui.zsh library" >&2
        return 1
    }
fi

if [[ -z "$DOTFILES_VALIDATORS_LOADED" ]]; then
    local lib_dir="$(dirname "${(%):-%N}")"
    source "$lib_dir/validators.zsh" 2>/dev/null || {
        echo "Warning: Could not load validators.zsh library" >&2
        return 1
    }
fi

# ============================================================================
# Global State
# ============================================================================

# Arrays to store declared dependencies
typeset -g -a DECLARED_COMMAND_DEPS=()
typeset -g -a DECLARED_COMMAND_NAMES=()
typeset -g -a DECLARED_COMMAND_PROVIDERS=()

typeset -g -a DECLARED_SCRIPT_DEPS=()
typeset -g -a DECLARED_SCRIPT_DESCRIPTIONS=()

# Configuration
typeset -g DEPENDENCY_AUTO_RESOLVE=${DEPENDENCY_AUTO_RESOLVE:-true}
typeset -g DEPENDENCY_INTERACTIVE=${DEPENDENCY_INTERACTIVE:-true}

# ============================================================================
# Dependency Declaration Functions
# ============================================================================

# Declare a command dependency
# Args:
#   $1 - command name (e.g., "cargo")
#   $2 - human-readable name (e.g., "Rust toolchain")
#   $3 - provider script (e.g., "toolchains.zsh") - optional
function declare_dependency_command() {
    local command="$1"
    local name="$2"
    local provider="${3:-}"

    [[ -z "$command" ]] && { print_error "declare_dependency_command: command is required"; return 1; }
    [[ -z "$name" ]] && { print_error "declare_dependency_command: name is required"; return 1; }

    DECLARED_COMMAND_DEPS+=("$command")
    DECLARED_COMMAND_NAMES+=("$name")
    DECLARED_COMMAND_PROVIDERS+=("$provider")
}

# Declare a script dependency (another post-install script that must run first)
# Args:
#   $1 - script name (e.g., "toolchains.zsh")
#   $2 - description (e.g., "Core development toolchains")
function declare_dependency_script() {
    local script="$1"
    local description="$2"

    [[ -z "$script" ]] && { print_error "declare_dependency_script: script is required"; return 1; }
    [[ -z "$description" ]] && { print_error "declare_dependency_script: description is required"; return 1; }

    DECLARED_SCRIPT_DEPS+=("$script")
    DECLARED_SCRIPT_DESCRIPTIONS+=("$description")
}

# Clear all declared dependencies (useful for testing or multi-stage scripts)
function clear_declared_dependencies() {
    DECLARED_COMMAND_DEPS=()
    DECLARED_COMMAND_NAMES=()
    DECLARED_COMMAND_PROVIDERS=()
    DECLARED_SCRIPT_DEPS=()
    DECLARED_SCRIPT_DESCRIPTIONS=()
}

# ============================================================================
# Dependency Resolution Functions
# ============================================================================

# Check if a command dependency is satisfied
# Args:
#   $1 - command name
# Returns: 0 if satisfied, 1 if missing
function is_command_dependency_satisfied() {
    local command="$1"
    command_exists "$command"
}

# Check if a script dependency is satisfied
# Note: This is a placeholder - in a real implementation, we might track
# which scripts have been run in this session
# Args:
#   $1 - script name
# Returns: 0 if satisfied (commands it provides exist), 1 if missing
function is_script_dependency_satisfied() {
    local script="$1"

    # For now, we assume script deps are informational
    # Real implementation could track execution or check output files
    return 0
}

# Get the provider script path for a command
# Args:
#   $1 - command name
# Returns: provider script path or empty string
function get_command_provider() {
    local command="$1"
    local i

    for ((i=1; i<=${#DECLARED_COMMAND_DEPS[@]}; i++)); do
        if [[ "${DECLARED_COMMAND_DEPS[$i]}" == "$command" ]]; then
            echo "${DECLARED_COMMAND_PROVIDERS[$i]}"
            return 0
        fi
    done

    echo ""
}

# Get the human-readable name for a command
# Args:
#   $1 - command name
# Returns: human-readable name or the command itself
function get_command_name() {
    local command="$1"
    local i

    for ((i=1; i<=${#DECLARED_COMMAND_DEPS[@]}; i++)); do
        if [[ "${DECLARED_COMMAND_DEPS[$i]}" == "$command" ]]; then
            echo "${DECLARED_COMMAND_NAMES[$i]}"
            return 0
        fi
    done

    echo "$command"
}

# Offer to run a provider script for a missing dependency
# Args:
#   $1 - command name
#   $2 - provider script
# Returns: 0 if user agrees or script succeeds, 1 otherwise
function offer_to_resolve_dependency() {
    local command="$1"
    local provider="$2"
    local name="$(get_command_name "$command")"

    if [[ -z "$provider" ]]; then
        print_error "$name not found"
        print_info "Please install $name manually"
        return 1
    fi

    local provider_path="$DOTFILES_ROOT/post-install/scripts/$provider"

    if [[ ! -f "$provider_path" ]]; then
        print_error "$name not found"
        print_warning "Provider script not found: $provider"
        print_info "Please install $name manually"
        return 1
    fi

    if [[ "$DEPENDENCY_INTERACTIVE" == "true" ]]; then
        echo
        print_warning "$name is required but not found"
        print_info "Provider: $provider"
        echo

        if ask_confirmation "Would you like to run $provider now?" "y"; then
            echo
            draw_section_header "Running Prerequisite: $provider"

            if "$provider_path"; then
                echo
                print_success "Prerequisite installed successfully"

                # Verify the command is now available
                if command_exists "$command"; then
                    return 0
                else
                    print_warning "$command still not found after running $provider"
                    print_info "You may need to restart your shell"
                    return 1
                fi
            else
                echo
                print_error "Failed to run $provider"
                return 1
            fi
        else
            print_info "Skipping $name installation"
            print_info "Run manually: $provider_path"
            return 1
        fi
    else
        # Non-interactive mode
        print_error "$name not found"
        print_info "Run: $provider_path"
        return 1
    fi
}

# Check all declared dependencies and attempt to resolve them
# Returns: 0 if all satisfied, 1 if any are missing
function check_and_resolve_dependencies() {
    local all_satisfied=true
    local missing_commands=()
    local i

    # Skip if no dependencies declared
    if [[ ${#DECLARED_COMMAND_DEPS[@]} -eq 0 && ${#DECLARED_SCRIPT_DEPS[@]} -eq 0 ]]; then
        return 0
    fi

    # Check command dependencies
    for ((i=1; i<=${#DECLARED_COMMAND_DEPS[@]}; i++)); do
        local command="${DECLARED_COMMAND_DEPS[$i]}"
        local name="${DECLARED_COMMAND_NAMES[$i]}"
        local provider="${DECLARED_COMMAND_PROVIDERS[$i]}"

        if ! is_command_dependency_satisfied "$command"; then
            missing_commands+=("$command")
            all_satisfied=false

            if [[ "$DEPENDENCY_AUTO_RESOLVE" == "true" ]]; then
                if offer_to_resolve_dependency "$command" "$provider"; then
                    # Dependency was resolved
                    all_satisfied=true
                fi
            else
                print_error "$name not found: $command"
                if [[ -n "$provider" ]]; then
                    print_info "Install with: ./post-install/scripts/$provider"
                fi
            fi
        fi
    done

    # Check script dependencies (informational for now)
    for ((i=1; i<=${#DECLARED_SCRIPT_DEPS[@]}; i++)); do
        local script="${DECLARED_SCRIPT_DEPS[$i]}"
        local description="${DECLARED_SCRIPT_DESCRIPTIONS[$i]}"

        # For now, script dependencies are just informational
        # Future: could track execution state
    done

    if [[ "$all_satisfied" == "false" ]]; then
        echo
        print_error "Missing required dependencies"
        print_info "Please install the missing dependencies and try again"
        return 1
    fi

    return 0
}

# Show all declared dependencies (useful for debugging)
function show_declared_dependencies() {
    echo
    print_info "📦 Declared Dependencies:"
    echo

    if [[ ${#DECLARED_COMMAND_DEPS[@]} -gt 0 ]]; then
        echo "${UI_ACCENT_COLOR}Commands:${COLOR_RESET}"
        local i
        for ((i=1; i<=${#DECLARED_COMMAND_DEPS[@]}; i++)); do
            local command="${DECLARED_COMMAND_DEPS[$i]}"
            local name="${DECLARED_COMMAND_NAMES[$i]}"
            local provider="${DECLARED_COMMAND_PROVIDERS[$i]}"

            if command_exists "$command"; then
                printf "  ${UI_SUCCESS_COLOR}✅${COLOR_RESET} %-20s %s\n" "$command" "$name"
            else
                printf "  ${UI_ERROR_COLOR}❌${COLOR_RESET} %-20s %s" "$command" "$name"
                if [[ -n "$provider" ]]; then
                    printf " ${UI_INFO_COLOR}(provider: %s)${COLOR_RESET}" "$provider"
                fi
                printf "\n"
            fi
        done
    fi

    if [[ ${#DECLARED_SCRIPT_DEPS[@]} -gt 0 ]]; then
        echo
        echo "${UI_ACCENT_COLOR}Scripts:${COLOR_RESET}"
        local i
        for ((i=1; i<=${#DECLARED_SCRIPT_DEPS[@]}; i++)); do
            local script="${DECLARED_SCRIPT_DEPS[$i]}"
            local description="${DECLARED_SCRIPT_DESCRIPTIONS[$i]}"
            printf "  ${UI_INFO_COLOR}📄${COLOR_RESET} %-30s %s\n" "$script" "$description"
        done
    fi

    echo
}

# ============================================================================
# Export Functions
# ============================================================================

# Export all dependency functions for use in sourcing scripts (suppress output)
{
    typeset -fx declare_dependency_command declare_dependency_script
    typeset -fx clear_declared_dependencies
    typeset -fx is_command_dependency_satisfied is_script_dependency_satisfied
    typeset -fx get_command_provider get_command_name
    typeset -fx offer_to_resolve_dependency
    typeset -fx check_and_resolve_dependencies
    typeset -fx show_declared_dependencies
} >/dev/null 2>&1
