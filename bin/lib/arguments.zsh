#!/usr/bin/env zsh

# ============================================================================
# Argument Parsing Library - Standardized CLI Argument Handling
# ============================================================================
#
# This library provides reusable, DRY argument parsing functions for all
# scripts in the dotfiles system. It eliminates code duplication and ensures
# consistent argument handling across the entire codebase.
#
# Usage Patterns:
#
#   1. Simple Boolean Flags:
#      parse_simple_flags "$@"
#      [[ $ARG_HELP == "true" ]] && show_help && exit 0
#
#   2. Flags with Values:
#      parse_flag_with_value --output "$@"
#      OUTPUT_FILE="$ARG_VALUE"
#
#   3. Subcommand Style:
#      parse_subcommand "$@"
#      case "$ARG_SUBCOMMAND" in
#          list) do_list ;;
#          show) do_show "$1" ;;
#      esac
#
#   4. Unknown Option Validation:
#      validate_no_unknown_args "$@" || exit 1
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Global Argument Variables
# ============================================================================

typeset -g ARG_HELP="false"
typeset -g ARG_VERBOSE="false"
typeset -g ARG_DRY_RUN="false"
typeset -g ARG_FORCE="false"
typeset -g ARG_SILENT="false"
typeset -g ARG_UPDATE="false"
typeset -g ARG_RESUME="false"
typeset -g ARG_RESET="false"
typeset -g ARG_VALUE=""
typeset -g ARG_SUBCOMMAND=""
typeset -a ARG_POSITIONAL=()

# ============================================================================
# Core Parsing Functions
# ============================================================================

# Parse simple boolean flags (no values)
# Sets: ARG_HELP, ARG_VERBOSE, ARG_DRY_RUN, ARG_FORCE, ARG_SILENT
# Usage: parse_simple_flags "$@"
function parse_simple_flags() {
    local args=("$@")
    local -a remaining_args=()

    for arg in "${args[@]}"; do
        case "$arg" in
            -h|--help)
                ARG_HELP="true"
                ;;
            -v|--verbose)
                ARG_VERBOSE="true"
                ;;
            -n|--dry-run)
                ARG_DRY_RUN="true"
                ;;
            -f|--force)
                ARG_FORCE="true"
                ;;
            -s|--silent)
                ARG_SILENT="true"
                ;;
            --update)
                ARG_UPDATE="true"
                ;;
            --resume)
                ARG_RESUME="true"
                ;;
            --reset)
                ARG_RESET="true"
                ;;
            *)
                remaining_args+=("$arg")
                ;;
        esac
    done

    # Return remaining args for further processing
    set -- "${remaining_args[@]}"
    return 0
}

# Parse a single flag with value
# Usage: parse_flag_with_value "--output" "$@"
#        Result in $ARG_VALUE
function parse_flag_with_value() {
    local flag_name="$1"
    shift

    local found=false
    ARG_VALUE=""

    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "$flag_name" ]]; then
            if [[ -n "${2:-}" ]]; then
                ARG_VALUE="$2"
                found=true
                shift 2
                break
            else
                print_error "Option $flag_name requires a value"
                return 1
            fi
        else
            shift
        fi
    done

    if $found; then
        return 0
    else
        return 1
    fi
}

# Parse flags with values using zparseopts (advanced)
# Usage: parse_flags_with_zparseopts "$@"
#        Requires: Define VALID_FLAGS array before calling
# Example:
#   local -a VALID_FLAGS
#   VALID_FLAGS=(
#       "t: target-dir:"     # -t or --target-dir with value
#       "o: output:"         # -o or --output with value
#       "h help"             # -h or --help without value
#   )
#   parse_flags_with_zparseopts "$@"
function parse_flags_with_zparseopts() {
    # This is a placeholder - scripts using zparseopts should continue
    # doing so directly as it's already clean and powerful
    # We're documenting it here as a pattern
    :
}

# Extract subcommand from arguments
# Sets: ARG_SUBCOMMAND, ARG_POSITIONAL (remaining args)
# Usage: parse_subcommand "$@"
function parse_subcommand() {
    ARG_SUBCOMMAND="${1:-}"
    shift
    ARG_POSITIONAL=("$@")

    # Handle help flag in subcommand position
    if [[ "$ARG_SUBCOMMAND" == "-h" ]] || [[ "$ARG_SUBCOMMAND" == "--help" ]]; then
        ARG_HELP="true"
        ARG_SUBCOMMAND=""
    fi

    return 0
}

# ============================================================================
# Validation Functions
# ============================================================================

# Validate that no unknown arguments remain
# Usage: validate_no_unknown_args "$@"
function validate_no_unknown_args() {
    if [[ $# -gt 0 ]]; then
        [[ -n "${print_error}" ]] && print_error "Unknown option: $1" || \
            echo "Error: Unknown option: $1" >&2
        [[ -n "${print_info}" ]] && print_info "Use --help for usage information" || \
            echo "Use --help for usage information" >&2
        return 1
    fi
    return 0
}

# Check if help flag was set
# Usage: if is_help_requested; then show_help; exit 0; fi
function is_help_requested() {
    [[ "$ARG_HELP" == "true" ]]
}

# Check if verbose flag was set
# Usage: if is_verbose; then print_info "Verbose output enabled"; fi
function is_verbose() {
    [[ "$ARG_VERBOSE" == "true" ]]
}

# Check if dry-run flag was set
# Usage: if is_dry_run; then print_info "[DRY RUN] ..."; fi
function is_dry_run() {
    [[ "$ARG_DRY_RUN" == "true" ]]
}

# ============================================================================
# Helper Functions
# ============================================================================

# Reset all argument variables to defaults
# Usage: reset_arg_flags
function reset_arg_flags() {
    ARG_HELP="false"
    ARG_VERBOSE="false"
    ARG_DRY_RUN="false"
    ARG_FORCE="false"
    ARG_SILENT="false"
    ARG_UPDATE="false"
    ARG_RESUME="false"
    ARG_RESET="false"
    ARG_VALUE=""
    ARG_SUBCOMMAND=""
    ARG_POSITIONAL=()
}

# Show standard help message structure (template)
# Usage: standard_help_header "Script Name" "Brief description"
function standard_help_header() {
    local script_name="${1:-$(basename $0)}"
    local description="$2"

    cat << EOF
${COLOR_BOLD}${script_name}${COLOR_RESET}

${description}

${COLOR_BOLD}USAGE:${COLOR_RESET}
    $script_name [OPTIONS]

${COLOR_BOLD}OPTIONS:${COLOR_RESET}
EOF
}

# Show common options (for consistency)
# Usage: standard_common_options
function standard_common_options() {
    cat << EOF
    -h, --help          Show this help message and exit
    -v, --verbose       Show detailed output
    -n, --dry-run       Preview actions without making changes
    -f, --force         Force operation without confirmation
EOF
}

# ============================================================================
# Pattern Examples & Templates
# ============================================================================

# Example 1: Simple script with boolean flags
#
#   source "$DF_LIB_DIR/arguments.zsh"
#
#   parse_simple_flags "$@"
#   is_help_requested && show_help && exit 0
#   is_dry_run && DRY_RUN=true

# Example 2: Script with flag that takes a value
#
#   source "$DF_LIB_DIR/arguments.zsh"
#
#   parse_simple_flags "$@"
#   is_help_requested && show_help && exit 0
#
#   if parse_flag_with_value "--output" "$@"; then
#       OUTPUT_FILE="$ARG_VALUE"
#   fi

# Example 3: Subcommand-based script (git-like)
#
#   source "$DF_LIB_DIR/arguments.zsh"
#
#   parse_subcommand "$@"
#   is_help_requested && show_help && exit 0
#
#   case "$ARG_SUBCOMMAND" in
#       list) do_list "${ARG_POSITIONAL[@]}" ;;
#       show) do_show "${ARG_POSITIONAL[@]}" ;;
#       *) print_error "Unknown command: $ARG_SUBCOMMAND" ;;
#   esac

# Example 4: Complex script with multiple flag types
#
#   source "$DF_LIB_DIR/arguments.zsh"
#
#   # Parse boolean flags first
#   parse_simple_flags "$@"
#   is_help_requested && show_help && exit 0
#
#   # Parse flags with values
#   parse_flag_with_value "--output" "$@" && OUTPUT="$ARG_VALUE"
#   parse_flag_with_value "--target-dir" "$@" && TARGET="$ARG_VALUE"
#
#   # Validate
#   validate_no_unknown_args "$@" || exit 1

# ============================================================================
# Export Functions
# ============================================================================

# Make functions available to calling scripts
typeset -fx parse_simple_flags
typeset -fx parse_flag_with_value
typeset -fx parse_subcommand
typeset -fx validate_no_unknown_args
typeset -fx is_help_requested
typeset -fx is_verbose
typeset -fx is_dry_run
typeset -fx reset_arg_flags
typeset -fx standard_help_header
typeset -fx standard_common_options
