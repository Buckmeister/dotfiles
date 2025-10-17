#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# GitHub URL Downloader
# ============================================================================
#
# A beautiful utility for retrieving GitHub download URLs from releases and tags.
# Supports filtering by pattern, fallback to recent releases, and silent mode.
#
# Features:
#   - Get URLs from latest release or specific release
#   - Get URLs from specific tags
#   - Filter results by filename pattern (regex)
#   - Fallback to most recent release when 'latest' fails
#   - Silent mode for scripting
#   - OneDark color scheme
#
# Usage:
#   get_github_url -u username -r repository [options]
#
# Examples:
#   get_github_url -u neovim -r neovim
#   get_github_url -u neovim -r neovim -l nightly -p 'macos.*\.tar\.gz$'
#   get_github_url -u neovim -r neovim -t v0.6.0
#
# ============================================================================

script_name=${0##*/}

# ============================================================================
# Load Shared Libraries (with fallback protection)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DF_DIR="${HOME}/.config/dotfiles"

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
    print_success() { echo "$1"; }
    print_info() { echo "$1"; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }

    # Basic color definitions for fallback
    readonly UI_SUCCESS_COLOR='\033[32m'
    readonly UI_INFO_COLOR='\033[34m'
    readonly UI_ERROR_COLOR='\033[31m'
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
${COLOR_BOLD}${UI_ACCENT_COLOR}GitHub URL Downloader${COLOR_RESET}

Retrieve GitHub download URLs for releases, tags, and assets with
beautiful OneDark-themed output and flexible filtering.

${COLOR_BOLD}${UI_ACCENT_COLOR}USAGE${COLOR_RESET}
    $script_name -u username -r repository [options]

${COLOR_BOLD}${UI_ACCENT_COLOR}REQUIRED ARGUMENTS${COLOR_RESET}
    -u, --username  (=)ARG    GitHub username/organization
    -r, --repository (=)ARG   GitHub repository name

${COLOR_BOLD}${UI_ACCENT_COLOR}RELEASE OPTIONS${COLOR_RESET}
    -l, --release   (=)ARG    Release name (default: 'latest')
    -p, --pattern   (=)ARG    Filter assets by filename pattern (regex)

${COLOR_BOLD}${UI_ACCENT_COLOR}TAG OPTIONS${COLOR_RESET}
    -t, --tag       (=)ARG    Tag name to download

${COLOR_BOLD}${UI_ACCENT_COLOR}FALLBACK OPTIONS${COLOR_RESET}
    -f, --fallback-recent     Use most recent release if 'latest' fails

${COLOR_BOLD}${UI_ACCENT_COLOR}OUTPUT OPTIONS${COLOR_RESET}
    -s, --silent              Print URL(s) only (no headers)
    -c, --count     (=)ARG    Limit number of results (default: all)

${COLOR_BOLD}${UI_ACCENT_COLOR}DOCUMENTATION${COLOR_RESET}
    -h, --help                Show this help message

${COLOR_BOLD}${UI_ACCENT_COLOR}EXAMPLES${COLOR_RESET}
    ${COLOR_DIM}# Get latest neovim stable download URLs${COLOR_RESET}
    $script_name -u neovim -r neovim

    ${COLOR_DIM}# Get latest neovim nightly download URL for macOS${COLOR_RESET}
    $script_name -u neovim -r neovim -l nightly -p 'macos.*\\.tar\\.gz\$'

    ${COLOR_DIM}# Get neovim source tarball download URL for tag 'v0.6.0'${COLOR_RESET}
    $script_name -u neovim -r neovim -t v0.6.0

    ${COLOR_DIM}# Get most recent release when 'latest' fails (for JDT.LS)${COLOR_RESET}
    $script_name -u eclipse-jdtls -r eclipse.jdt.ls -f -p 'jdt-language-server.*\\.tar\\.gz\$'

    ${COLOR_DIM}# Silent mode (for scripting)${COLOR_RESET}
    $script_name -u neovim -r neovim -s

${COLOR_BOLD}${UI_ACCENT_COLOR}USE CASES${COLOR_RESET}
    • Download latest release assets for installation scripts
    • Get specific version downloads for reproducible builds
    • Filter assets by platform (linux, macos, windows)
    • Integrate with CI/CD pipelines

EOF
    exit 1
}

zparseopts -D -E \
    -- \
    u:=o_username \
    -username:=o_username \
    r:=o_repository \
    -repository:=o_repository \
    l:=o_release \
    -release:=o_release \
    t:=o_tag \
    -tag:=o_tag \
    p:=o_pattern \
    -pattern:=o_pattern \
    f=o_fallback \
    -fallback-recent=o_fallback \
    s=o_silent \
    -silent=o_silent \
    c:=o_count \
    -count:=o_count \
    h=o_help \
    -help=o_help

[[ $#o_username == 0 ]] && print_usage
[[ $#o_repository == 0 ]] && print_usage
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
    draw_header "GitHub URL Downloader" "Retrieve download URLs from GitHub releases and tags"
    echo
fi

# ============================================================================
# Parse and Display Arguments
# ============================================================================

arg_username=${o_username[@]: -1}
print_status "Username: ${UI_ACCENT_COLOR}${arg_username}${COLOR_RESET}"

arg_repository=${o_repository[@]: -1}
print_status "Repository: ${UI_ACCENT_COLOR}${arg_repository}${COLOR_RESET}"

[[ $#o_release > 0 ]] && {
    arg_release=${o_release[@]: -1}
    print_status "Release: ${UI_ACCENT_COLOR}${arg_release}${COLOR_RESET}"
}

[[ $#o_pattern > 0 ]] && {
    arg_pattern=${o_pattern[@]: -1}
    print_status "Pattern: ${UI_ACCENT_COLOR}${arg_pattern}${COLOR_RESET}"
}

[[ $#o_tag > 0 ]] && {
    arg_tag=${o_tag[@]: -1}
    print_status "Tag: ${UI_ACCENT_COLOR}${arg_tag}${COLOR_RESET}"
}

[[ $#o_fallback > 0 ]] && {
    use_fallback="true"
    print_status "Fallback: ${UI_ACCENT_COLOR}Use most recent release if latest fails${COLOR_RESET}"
}

[[ $#o_count > 0 ]] && {
    result_count=${o_count[@]: -1}
    print_status "Limit results: ${UI_ACCENT_COLOR}${result_count}${COLOR_RESET}"
}

[[ "$IS_SILENT" != "true" ]] && echo

# ============================================================================
# Determine Lookup Mode
# ============================================================================

if [[ -n "$arg_tag" ]]; then
    lookup_mode="tag"
elif [[ -n "$arg_release" ]]; then
    lookup_mode="release"
else
    # defaults
    arg_release="latest"
    lookup_mode="release"
fi

# ============================================================================
# GitHub API Functions
# ============================================================================

# Fetch and parse GitHub API with error handling
function fetch_github_data() {
    local url="$1"
    local response

    if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
        draw_section_header "Fetching Data"
    fi

    print_status "API URL: ${COLOR_DIM}${url}${COLOR_RESET}"

    response=$(curl -s "$url")

    # Check if response is valid JSON and not an error
    if ! echo "$response" | jq empty 2>/dev/null; then
        print_error "Invalid JSON response from GitHub API"
        return 1
    fi

    # Check for GitHub API errors
    local error_message=$(echo "$response" | jq -r '.message // empty' 2>/dev/null)
    if [[ -n "$error_message" && "$error_message" != "null" ]]; then
        print_error "GitHub API Error: $error_message"
        return 1
    fi

    echo "$response"
}

# ============================================================================
# Tag Lookup
# ============================================================================

if [[ "$lookup_mode" = "tag" ]]; then
    github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/tags"

    print_status "Looking up tag: ${UI_ACCENT_COLOR}$arg_tag${COLOR_RESET}"

    api_response=$(fetch_github_data "$github_url")
    [[ $? -ne 0 ]] && exit 1

    if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
        echo
        draw_section_header "Results"
    fi

    [[ "$IS_SILENT" != "true" ]] && print_success "Retrieved URL(s):"

    echo "$api_response" | jq -r ".[] | select(.name == \"$arg_tag\") | .tarball_url"

# ============================================================================
# Release Lookup
# ============================================================================

elif [[ "$lookup_mode" = "release" ]]; then
    github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/releases/$arg_release"

    print_status "Looking up release: ${UI_ACCENT_COLOR}$arg_release${COLOR_RESET}"

    api_response=$(fetch_github_data "$github_url")

    # If latest fails and fallback is enabled, try most recent release
    if [[ $? -ne 0 && "$use_fallback" = "true" && "$arg_release" = "latest" ]]; then
        print_status "${UI_WARNING_COLOR}Latest release failed, trying most recent release...${COLOR_RESET}"
        github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/releases"

        api_response=$(fetch_github_data "$github_url")
        [[ $? -ne 0 ]] && exit 1

        # Get the first (most recent) non-prerelease release
        api_response=$(echo "$api_response" | jq '.[0]')
    fi

    [[ $? -ne 0 ]] && exit 1

    # Extract tag name
    tag_name=$(echo "$api_response" | jq -r '.tag_name // empty')
    [[ -n "$tag_name" ]] && print_status "Release version tag: ${UI_ACCENT_COLOR}$tag_name${COLOR_RESET}"

    if [[ "$IS_SILENT" != "true" ]] && [[ "$LIBRARIES_LOADED" == "true" ]]; then
        echo
        draw_section_header "Results"
    fi

    [[ "$IS_SILENT" != "true" ]] && print_success "Retrieved URL(s):"

    # Filter by pattern if provided
    if [[ -n "$arg_pattern" ]]; then
        urls=$(echo "$api_response" | jq -r ".assets[] | select(.name | test(\"$arg_pattern\")) | .browser_download_url")
    else
        urls=$(echo "$api_response" | jq -r ".assets[] | .browser_download_url")
    fi

    # Limit results if count specified
    if [[ -n "$result_count" ]]; then
        echo "$urls" | head -n "$result_count"
    else
        echo "$urls"
    fi
fi
