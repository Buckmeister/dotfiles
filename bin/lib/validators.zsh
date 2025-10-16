#!/usr/bin/env zsh

# ============================================================================
# Validators Library - Dependency Checking and Validation
# ============================================================================
#
# This library provides comprehensive validation functions for checking
# dependencies, prerequisites, versions, paths, and configurations.
#
# Features:
# - Command and package existence checking
# - Version comparison and validation
# - Path and directory validation
# - Environment variable checking
# - Permission validation
# - Comprehensive prerequisite checking
# ============================================================================

# Note: emulate -LR zsh removed - this library is sourced by scripts that already have it.
# The caller's emulate directive applies to the entire execution context, making it
# redundant here. Removing it prevents potential array scoping issues in subshells.

# ============================================================================
# Dependency: Load other shared libraries
# ============================================================================

if [[ -z "$COLOR_RESET" ]]; then
    local LIB_DIR="${0:a:h}"
    source "$LIB_DIR/colors.zsh" 2>/dev/null || true
    source "$LIB_DIR/ui.zsh" 2>/dev/null || true
    source "$LIB_DIR/utils.zsh" 2>/dev/null || true
fi

# ============================================================================
# Command and Package Validation
# ============================================================================

# Check if a command exists and is executable
# Usage: validate_command <command_name> [description]
function validate_command() {
    local command_name="$1"
    local description="${2:-$command_name}"

    if command_exists "$command_name"; then
        print_success "$description is available"
        return 0
    else
        print_error "$description not found"
        return 1
    fi
}

# Check multiple commands and report results
# Usage: validate_commands <command1> <command2> ...
function validate_commands() {
    local commands=("$@")
    local missing=()

    for cmd in "${commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "All required commands available"
        return 0
    else
        print_error "Missing commands: ${missing[*]}"
        return 1
    fi
}

# Check if any one of multiple commands exists (OR logic)
# Usage: validate_command_any <command1> <command2> ... [description]
function validate_command_any() {
    local description="${@[-1]}"
    local commands=("${@[1,-2]}")

    # If last argument doesn't look like a command, treat it as description
    if [[ "$description" == *" "* ]] || [[ ! "$description" =~ ^[a-z0-9_-]+$ ]]; then
        # Last arg is description, remove it from commands array
        commands=("${@[1,-2]}")
    else
        # Last arg is also a command
        commands=("$@")
        description="${commands[*]}"
    fi

    for cmd in "${commands[@]}"; do
        if command_exists "$cmd"; then
            print_success "$cmd is available"
            return 0
        fi
    done

    print_error "None of the required commands found: ${commands[*]}"
    return 1
}

# ============================================================================
# Version Validation
# ============================================================================

# Compare two version strings (uses sort -V for version comparison)
# Returns: 0 if version1 >= version2, 1 otherwise
# Usage: version_ge <version1> <version2>
function version_ge() {
    local version1="$1"
    local version2="$2"

    # Use sort -V (version sort) to compare
    local sorted=$(printf "%s\n%s\n" "$version1" "$version2" | sort -V | head -1)

    if [[ "$sorted" == "$version2" ]]; then
        return 0  # version1 >= version2
    else
        return 1  # version1 < version2
    fi
}

# Extract version number from a command's output
# Usage: get_command_version <command> [version_flag]
function get_command_version() {
    local command_name="$1"
    local version_flag="${2:---version}"

    if ! command_exists "$command_name"; then
        echo ""
        return 1
    fi

    # Try to extract version number from command output
    local version_output=$("$command_name" "$version_flag" 2>&1 | head -1)

    # Extract version number (matches patterns like 1.2.3, v1.2.3, etc.)
    local version=$(echo "$version_output" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)

    echo "$version"
    [[ -n "$version" ]]
}

# Validate that a command meets minimum version requirement
# Usage: validate_version <command> <min_version> [description]
function validate_version() {
    local command_name="$1"
    local min_version="$2"
    local description="${3:-$command_name}"

    if ! command_exists "$command_name"; then
        print_error "$description not found"
        return 1
    fi

    local current_version=$(get_command_version "$command_name")

    if [[ -z "$current_version" ]]; then
        print_warning "$description version could not be determined"
        return 1
    fi

    if version_ge "$current_version" "$min_version"; then
        print_success "$description $current_version (>= $min_version required)"
        return 0
    else
        print_error "$description $current_version (>= $min_version required)"
        return 1
    fi
}

# ============================================================================
# Path and Directory Validation
# ============================================================================

# Validate that a path exists
# Usage: validate_path <path> [description]
function validate_path() {
    local path="$1"
    local description="${2:-$path}"

    if [[ -e "$path" ]]; then
        print_success "$description exists"
        return 0
    else
        print_error "$description not found: $path"
        return 1
    fi
}

# Validate that a directory exists and is writable
# Usage: validate_writable_directory <path> [description]
function validate_writable_directory() {
    local path="$1"
    local description="${2:-$path}"

    if [[ ! -d "$path" ]]; then
        print_error "$description is not a directory: $path"
        return 1
    fi

    if [[ ! -w "$path" ]]; then
        print_error "$description is not writable: $path"
        return 1
    fi

    print_success "$description is writable"
    return 0
}

# Validate that a file exists and is readable
# Usage: validate_readable_file <path> [description]
function validate_readable_file() {
    local path="$1"
    local description="${2:-$path}"

    if [[ ! -f "$path" ]]; then
        print_error "$description is not a file: $path"
        return 1
    fi

    if [[ ! -r "$path" ]]; then
        print_error "$description is not readable: $path"
        return 1
    fi

    print_success "$description is readable"
    return 0
}

# Validate that a file is executable
# Usage: validate_executable <path> [description]
function validate_executable() {
    local path="$1"
    local description="${2:-$path}"

    if [[ ! -f "$path" ]]; then
        print_error "$description not found: $path"
        return 1
    fi

    if [[ ! -x "$path" ]]; then
        print_error "$description is not executable: $path"
        return 1
    fi

    print_success "$description is executable"
    return 0
}

# Create directory if it doesn't exist and validate it's writable
# Usage: ensure_writable_directory <path> [description]
function ensure_writable_directory() {
    local path="$1"
    local description="${2:-$path}"

    if [[ ! -d "$path" ]]; then
        if mkdir -p "$path" 2>/dev/null; then
            print_success "Created $description directory"
        else
            print_error "Failed to create $description directory: $path"
            return 1
        fi
    fi

    validate_writable_directory "$path" "$description"
}

# ============================================================================
# Environment Variable Validation
# ============================================================================

# Validate that an environment variable is set and non-empty
# Usage: validate_env_var <var_name> [description]
function validate_env_var() {
    local var_name="$1"
    local description="${2:-$var_name}"
    local var_value="${(P)var_name}"  # Indirect parameter expansion

    if [[ -z "$var_value" ]]; then
        print_error "$description environment variable not set: $var_name"
        return 1
    fi

    print_success "$description is set"
    return 0
}

# Validate multiple environment variables
# Usage: validate_env_vars <var1> <var2> ...
function validate_env_vars() {
    local vars=("$@")
    local missing=()

    for var in "${vars[@]}"; do
        local var_value="${(P)var}"
        if [[ -z "$var_value" ]]; then
            missing+=("$var")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "All required environment variables set"
        return 0
    else
        print_error "Missing environment variables: ${missing[*]}"
        return 1
    fi
}

# ============================================================================
# Operating System Validation
# ============================================================================

# Validate that we're running on a specific OS
# Usage: validate_os <expected_os> [description]
function validate_os() {
    local expected_os="$1"
    local description="${2:-Operating system check}"
    local current_os="${DF_OS:-$(get_os)}"

    if [[ "$current_os" == "$expected_os" ]]; then
        print_success "$description: $current_os"
        return 0
    else
        print_error "$description: expected $expected_os, got $current_os"
        return 1
    fi
}

# Validate that we're running on one of multiple supported OSes
# Usage: validate_os_any <os1> <os2> ... [description]
function validate_os_any() {
    local description="${@[-1]}"
    local supported_oses=("${@[1,-2]}")

    # If last argument doesn't look like an OS name, treat it as description
    if [[ "$description" == *" "* ]]; then
        # Last arg is description, remove it from OS array
        supported_oses=("${@[1,-2]}")
    else
        # Last arg is also an OS
        supported_oses=("$@")
        description="Operating system check"
    fi

    local current_os="${DF_OS:-$(get_os)}"

    for os in "${supported_oses[@]}"; do
        if [[ "$current_os" == "$os" ]]; then
            print_success "$description: $current_os"
            return 0
        fi
    done

    print_error "$description: $current_os not supported (supported: ${supported_oses[*]})"
    return 1
}

# ============================================================================
# Permission Validation
# ============================================================================

# Check if user has sudo privileges (without requiring password entry)
# Usage: has_sudo_privileges
function has_sudo_privileges() {
    sudo -n true 2>/dev/null
}

# Validate that sudo is available and user can use it
# Usage: validate_sudo [description]
function validate_sudo() {
    local description="${1:-sudo access}"

    if ! command_exists sudo; then
        print_error "sudo command not found"
        return 1
    fi

    if has_sudo_privileges; then
        print_success "$description available"
        return 0
    else
        print_warning "$description may require password (cached or password will be prompted)"
        return 0  # Not a hard failure, just a warning
    fi
}

# ============================================================================
# Network Validation
# ============================================================================

# Check if we have network connectivity
# Usage: validate_network [test_host]
function validate_network() {
    local test_host="${1:-github.com}"

    if command_exists ping; then
        if ping -c 1 -W 2 "$test_host" >/dev/null 2>&1; then
            print_success "Network connectivity available"
            return 0
        else
            print_error "No network connectivity to $test_host"
            return 1
        fi
    elif command_exists curl; then
        if curl -s --max-time 2 --head "https://$test_host" >/dev/null 2>&1; then
            print_success "Network connectivity available"
            return 0
        else
            print_error "No network connectivity to $test_host"
            return 1
        fi
    else
        print_warning "Cannot verify network connectivity (no ping or curl)"
        return 0  # Assume network is available
    fi
}

# ============================================================================
# Comprehensive Prerequisite Checking
# ============================================================================

# Run multiple validation checks and report overall success/failure
# Usage: validate_prerequisites <check_function1> <check_function2> ...
#   Each check_function should return 0 for success, 1 for failure
function validate_prerequisites() {
    local checks=("$@")
    local failed=()

    print_info "🔍 Checking prerequisites..."
    echo

    for check in "${checks[@]}"; do
        if ! eval "$check"; then
            failed+=("$check")
        fi
    done

    echo

    if [[ ${#failed[@]} -eq 0 ]]; then
        print_success "✅ All prerequisites met!"
        return 0
    else
        print_error "❌ ${#failed[@]} prerequisite check(s) failed"
        return 1
    fi
}

# ============================================================================
# Script-Specific Validation Helpers
# ============================================================================

# Validate that a package manager and required packages are available
# Usage: validate_package_manager_setup <pkg_manager> <package1> <package2> ...
function validate_package_manager_setup() {
    local pkg_manager="$1"
    shift
    local required_packages=("$@")

    if ! command_exists "$pkg_manager"; then
        print_error "$pkg_manager not found"
        return 1
    fi

    print_success "$pkg_manager is available"

    if [[ ${#required_packages[@]} -gt 0 ]]; then
        validate_commands "${required_packages[@]}"
    else
        return 0
    fi
}

# Validate prerequisites for language-specific package installation
# Usage: validate_language_setup <language> <package_manager> [compiler]
function validate_language_setup() {
    local language="$1"
    local pkg_manager="$2"
    local compiler="$3"

    print_info "Validating $language setup..."

    local failed=0

    if ! command_exists "$pkg_manager"; then
        print_error "$language package manager ($pkg_manager) not found"
        ((failed++))
    else
        print_success "$pkg_manager available"
    fi

    if [[ -n "$compiler" ]] && ! command_exists "$compiler"; then
        print_error "$language compiler ($compiler) not found"
        ((failed++))
    elif [[ -n "$compiler" ]]; then
        print_success "$compiler available"
    fi

    if [[ $failed -eq 0 ]]; then
        print_success "$language environment ready"
        return 0
    else
        print_error "$language environment not ready"
        return 1
    fi
}

# ============================================================================
# Summary and Reporting
# ============================================================================

# Print a validation summary header
# Usage: print_validation_header <script_name> <description>
function print_validation_header() {
    local script_name="$1"
    local description="$2"

    draw_header "$script_name" "$description"
    echo
}

# Print validation results with counts
# Usage: print_validation_summary <total_checks> <passed_checks> <failed_checks>
function print_validation_summary() {
    local total="$1"
    local passed="$2"
    local failed="$3"

    echo
    print_info "📊 Validation Summary:"
    echo "   Total checks:  $total"
    echo "   Passed:        $passed"
    echo "   Failed:        $failed"
    echo

    if [[ $failed -eq 0 ]]; then
        print_success "All validations passed! 🎉"
        return 0
    else
        print_error "Some validations failed"
        return 1
    fi
}
