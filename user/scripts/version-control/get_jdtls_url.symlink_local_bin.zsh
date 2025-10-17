#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# JDT.LS Download URL Fetcher
# ============================================================================
#
# Specialized script for retrieving Eclipse JDT Language Server download URLs.
# Handles the quirks of the eclipse-jdtls/eclipse.jdt.ls repository where the
# 'latest' endpoint often fails, requiring fallback strategies.
#
# Features:
#   - Automatic version resolution (latest or specific version)
#   - Multiple URL pattern attempts for reliability
#   - Version-independent fallback URLs
#   - Silent mode for scripting
#   - OneDark color scheme
#
# Usage:
#   get_jdtls_url [options]
#
# Examples:
#   get_jdtls_url                 # Get latest version
#   get_jdtls_url -v 1.49.0       # Get specific version
#   get_jdtls_url -s              # Silent mode (URL only)
#
# ============================================================================

# ============================================================================
# Load Shared Libraries (with fallback protection)
# ============================================================================

# Resolve symlink to get actual script location
SCRIPT_PATH="${0:A}"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Determine DF_DIR from script location (user/scripts/version-control -> 3 levels up)
DF_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Try to load shared libraries
if [[ -f "$DF_DIR/bin/lib/colors.zsh" ]]; then
    source "$DF_DIR/bin/lib/colors.zsh" 2>/dev/null
    source "$DF_DIR/bin/lib/ui.zsh" 2>/dev/null
    source "$DF_DIR/bin/lib/utils.zsh" 2>/dev/null
    LIBRARIES_LOADED=true
else
    # Graceful fallback: define minimal functions if libraries unavailable
    LIBRARIES_LOADED=false
    print_error() { echo "Error: $1" >&2; }
    print_success() { echo "$1" >&2; }
    print_info() { echo "$1" >&2; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }
    draw_header() { echo "$1" >&2; }
    draw_section_header() { echo "$1" >&2; }

    # Basic color definitions for fallback
    readonly UI_SUCCESS_COLOR='\033[32m'
    readonly UI_INFO_COLOR='\033[34m'
    readonly UI_ERROR_COLOR='\033[31m'
    readonly UI_WARNING_COLOR='\033[33m'
    readonly UI_ACCENT_COLOR='\033[35m'
    readonly COLOR_RESET='\033[0m'
    readonly COLOR_BOLD='\033[1m'
    readonly COLOR_DIM='\033[2m'
fi

# ============================================================================
# Usage and Argument Parsing
# ============================================================================

function print_usage {
    cat <<EOF
${COLOR_BOLD}${UI_ACCENT_COLOR}JDT.LS Download URL Fetcher${COLOR_RESET}

Get Eclipse JDT Language Server download URLs with intelligent fallback
handling for the quirky eclipse-jdtls repository.

${COLOR_BOLD}${UI_ACCENT_COLOR}USAGE${COLOR_RESET}
    $(basename $0) [options]

${COLOR_BOLD}${UI_ACCENT_COLOR}OPTIONS${COLOR_RESET}
    -v, --version (=)ARG    Specific version (e.g. '1.49.0', default: latest)
    -s, --silent            Print URL only (no headers)
    -h, --help              Show this help message

${COLOR_BOLD}${UI_ACCENT_COLOR}EXAMPLES${COLOR_RESET}
    ${COLOR_DIM}# Get latest JDT.LS download URL${COLOR_RESET}
    $(basename $0)

    ${COLOR_DIM}# Get specific version${COLOR_RESET}
    $(basename $0) -v 1.49.0

    ${COLOR_DIM}# Silent mode (URL only)${COLOR_RESET}
    $(basename $0) -s

    ${COLOR_DIM}# Download latest JDT.LS${COLOR_RESET}
    curl -L -o jdtls.tar.gz \$($(basename $0) -s)

${COLOR_BOLD}${UI_ACCENT_COLOR}ABOUT JDT.LS${COLOR_RESET}
    Eclipse JDT Language Server (JDT.LS) is a Java language server
    implementing the Language Server Protocol. It provides features like
    auto-completion, code navigation, and refactoring for Java development.

${COLOR_BOLD}${UI_ACCENT_COLOR}WHY THIS SCRIPT?${COLOR_RESET}
    The eclipse-jdtls repository has quirky release patterns where the
    'latest' endpoint often fails. This script tries multiple URL patterns
    and fallback strategies to reliably find working download URLs.

${COLOR_BOLD}${UI_ACCENT_COLOR}FALLBACK STRATEGY${COLOR_RESET}
    1. Try GitHub tags API for version resolution
    2. Try multiple GitHub archive URL patterns
    3. Try Eclipse download server patterns
    4. Fallback to version-independent FAU mirror

EOF
    exit 1
}

zparseopts -D -E \
    -- \
    v:=o_version \
    -version:=o_version \
    s=o_silent \
    -silent=o_silent \
    h=o_help \
    -help=o_help

[[ $#o_help > 0 ]] && print_usage

# Set silent mode
if [[ $#o_silent > 0 ]]; then
    IS_SILENT="true"
fi

# Function to print if not silent
function print_status() {
    if [[ "$IS_SILENT" != "true" ]]; then
        print_info "$@"
    fi
}

# ============================================================================
# Display Header (if not silent)
# ============================================================================

if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
    draw_header "JDT.LS Download URL Fetcher" "Eclipse Java Language Server URL retrieval"
    echo >&2
fi

# ============================================================================
# Get Version Parameter
# ============================================================================

if [[ $#o_version > 0 ]]; then
    target_version=${o_version[@]: -1}
else
    target_version="latest"
fi

print_status "Target version: ${UI_ACCENT_COLOR}$target_version${COLOR_RESET}"
[[ "$IS_SILENT" != "true" ]] && echo >&2

# ============================================================================
# Helper Functions
# ============================================================================

# Check if URL exists
function url_exists() {
    local url="$1"
    curl -s -f -I "$url" >/dev/null 2>&1
}

# Get latest version from GitHub API
function get_latest_version() {
    local api_response

    if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
        draw_section_header "Resolving Latest Version"
    fi

    print_status "Fetching version info from GitHub API..."

    # Try to get releases list (not latest endpoint as it fails)
    # Delete body field immediately to avoid jq parse errors with control characters
    api_response=$(curl -s "https://api.github.com/repos/eclipse-jdtls/eclipse.jdt.ls/releases" | jq 'del(.[].body) // .')

    if [[ -n "$api_response" ]]; then
        # Find the most recent release that's not a prerelease
        local latest_tag=$(echo "$api_response" | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -1)

        if [[ -n "$latest_tag" && "$latest_tag" != "null" ]]; then
            # Remove 'v' prefix if present
            echo "$latest_tag" | sed 's/^v//'
            return 0
        fi
    fi

    # Fallback: try to parse from tags endpoint
    # Tags don't have body field, but use consistent pattern for robustness
    api_response=$(curl -s "https://api.github.com/repos/eclipse-jdtls/eclipse.jdt.ls/tags" | jq '. // .')

    if [[ -n "$api_response" ]]; then
        local latest_tag=$(echo "$api_response" | jq -r '.[0].name' 2>/dev/null)

        if [[ -n "$latest_tag" && "$latest_tag" != "null" ]]; then
            echo "$latest_tag" | sed 's/^v//'
            return 0
        fi
    fi

    return 1
}

# ============================================================================
# Version Resolution
# ============================================================================

if [[ "$target_version" == "latest" ]]; then
    resolved_version=$(get_latest_version)

    if [[ $? -ne 0 || -z "$resolved_version" ]]; then
        print_status "${UI_WARNING_COLOR}Warning: Could not determine latest version, falling back to 1.49.0${COLOR_RESET}"
        resolved_version="1.49.0"
    else
        print_status "Latest version detected: ${UI_SUCCESS_COLOR}$resolved_version${COLOR_RESET}"
    fi
else
    resolved_version="$target_version"
fi

print_status "Using version: ${UI_ACCENT_COLOR}$resolved_version${COLOR_RESET}"
[[ "$IS_SILENT" != "true" ]] && echo >&2

# ============================================================================
# URL Pattern Attempts
# ============================================================================

# Try different URL patterns for JDT.LS
urls_to_try=(
    "https://github.com/eclipse-jdtls/eclipse.jdt.ls/archive/refs/tags/v${resolved_version}.tar.gz"
    "https://github.com/eclipse-jdtls/eclipse.jdt.ls/archive/v${resolved_version}.tar.gz"
    "https://github.com/eclipse-jdtls/eclipse.jdt.ls/archive/${resolved_version}.tar.gz"
    "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-${resolved_version}.tar.gz"
    "https://download.eclipse.org/jdtls/releases/${resolved_version}/jdt-language-server-${resolved_version}.tar.gz"
)

if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
    draw_section_header "Checking URL Availability"
fi

print_status "Testing multiple URL patterns..."

for url in "${urls_to_try[@]}"; do
    print_status "${COLOR_DIM}Trying: $url${COLOR_RESET}"

    if url_exists "$url"; then
        if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
            echo >&2
            draw_section_header "Success"
        fi

        if [[ "$IS_SILENT" != "true" ]]; then
            print_success "✓ Found working URL"
            echo >&2
            print_info "Download URL:"
        fi
        echo "$url"
        exit 0
    fi
done

# ============================================================================
# Version-Independent Fallback
# ============================================================================

print_status "${UI_WARNING_COLOR}Version-specific URLs failed, trying version-independent fallback...${COLOR_RESET}"

fallback_url="https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"

print_status "${COLOR_DIM}Trying: $fallback_url${COLOR_RESET}"

if url_exists "$fallback_url"; then
    if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
        echo >&2
        draw_section_header "Success (Fallback)"
    fi

    if [[ "$IS_SILENT" != "true" ]]; then
        print_success "✓ Found working fallback URL"
        echo >&2
        print_info "Download URL (version-independent):"
    fi
    echo "$fallback_url"
    exit 0
fi

# ============================================================================
# All Options Failed
# ============================================================================

if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
    echo >&2
    draw_section_header "Manual Fallback Required"
fi

print_error "All automatic options failed"
[[ "$IS_SILENT" != "true" ]] && echo >&2

if [[ "$IS_SILENT" != "true" ]]; then
    print_info "Manual fallback URLs (verification required):"
    echo "  https://github.com/eclipse-jdtls/eclipse.jdt.ls/releases" >&2
    echo "  https://download.eclipse.org/jdtls/snapshots/" >&2
    echo "  https://ftp.fau.de/eclipse/jdtls/snapshots/" >&2
else
    # In silent mode, return the most likely working URL
    echo "$fallback_url"
fi

exit 1
