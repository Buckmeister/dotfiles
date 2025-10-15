#!/usr/bin/env zsh

# ============================================================================
# JDT.LS Download URL Fetcher
# Specialized script for getting JDT.LS download URLs
# Handles the quirks of eclipse-jdtls/eclipse.jdt.ls repository
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries (for UI_SILENT mode)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Try to load shared libraries (with fallback)
if [[ -f "$HOME/.config/dotfiles/bin/lib/colors.zsh" ]]; then
    source "$HOME/.config/dotfiles/bin/lib/colors.zsh" 2>/dev/null || true
    source "$HOME/.config/dotfiles/bin/lib/ui.zsh" 2>/dev/null || true
fi

# ============================================================================
# Usage and Argument Parsing
# ============================================================================

function print_usage {
  echo
  echo "Get JDT.LS (Eclipse Java Language Server) download URL"
  echo
  echo "Usage:"
  echo
  echo "$(basename $0) [options]"
  echo
  echo "Options:"
  echo "  -v|--version (=)ARG  <=> specific version (e.g. '1.49.0', default: latest)"
  echo "  -s|--silent          <=> print URL only (no headers)"
  echo "  -h|--help            <=> print usage information"
  echo
  echo "Examples:"
  echo
  echo "Get latest JDT.LS download URL:"
  echo "  $(basename $0)"
  echo
  echo "Get specific version:"
  echo "  $(basename $0) -v 1.49.0"
  echo
  echo "Silent mode (URL only):"
  echo "  $(basename $0) -s"
  echo
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

# Set silent mode (use UI_SILENT from shared library if available)
if [[ $#o_silent > 0 ]]; then
    UI_SILENT="true"
    IS_SILENT="true"
fi

# Function to print if not silent (uses shared library if available)
function print_info() {
    if [[ "$IS_SILENT" == "true" ]]; then
        return 0
    fi

    # Use shared library function if available, otherwise echo
    if typeset -f print_info >/dev/null 2>&1 && [[ "$UI_SILENT" != "true" ]]; then
        # Avoid recursion - just echo
        echo "$@"
    else
        echo "$@"
    fi
}

# Get version parameter
if [[ $#o_version > 0 ]]; then
  target_version=${o_version[@]: -1}
else
  target_version="latest"
fi

print_info
print_info "JDT.LS Download URL Fetcher"
print_info "Target version: $target_version"
print_info

# Function to check if URL exists
function url_exists() {
  local url="$1"
  curl -s -f -I "$url" >/dev/null 2>&1
}

# Function to get latest version from GitHub API
function get_latest_version() {
  local api_response

  print_info "Fetching latest version from GitHub API..."

  # Try to get releases list (not latest endpoint as it fails)
  api_response=$(curl -s "https://api.github.com/repos/eclipse-jdtls/eclipse.jdt.ls/releases")

  if echo "$api_response" | jq empty 2>/dev/null; then
    # Find the most recent release that's not a prerelease
    local latest_tag=$(echo "$api_response" | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -1)

    if [[ -n "$latest_tag" && "$latest_tag" != "null" ]]; then
      # Remove 'v' prefix if present
      echo "$latest_tag" | sed 's/^v//'
      return 0
    fi
  fi

  # Fallback: try to parse from tags endpoint
  api_response=$(curl -s "https://api.github.com/repos/eclipse-jdtls/eclipse.jdt.ls/tags")

  if echo "$api_response" | jq empty 2>/dev/null; then
    local latest_tag=$(echo "$api_response" | jq -r '.[0].name' 2>/dev/null)

    if [[ -n "$latest_tag" && "$latest_tag" != "null" ]]; then
      echo "$latest_tag" | sed 's/^v//'
      return 0
    fi
  fi

  return 1
}

# Resolve version
if [[ "$target_version" == "latest" ]]; then
  resolved_version=$(get_latest_version)

  if [[ $? -ne 0 || -z "$resolved_version" ]]; then
    print_info "Warning: Could not determine latest version, falling back to 1.49.0"
    resolved_version="1.49.0"
  else
    print_info "Latest version detected: $resolved_version"
  fi
else
  resolved_version="$target_version"
fi

print_info "Using version: $resolved_version"
print_info

# Try different URL patterns for JDT.LS
urls_to_try=(
  "https://github.com/eclipse-jdtls/eclipse.jdt.ls/archive/refs/tags/v${resolved_version}.tar.gz"
  "https://github.com/eclipse-jdtls/eclipse.jdt.ls/archive/v${resolved_version}.tar.gz"
  "https://github.com/eclipse-jdtls/eclipse.jdt.ls/archive/${resolved_version}.tar.gz"
  "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-${resolved_version}.tar.gz"
  "https://download.eclipse.org/jdtls/releases/${resolved_version}/jdt-language-server-${resolved_version}.tar.gz"
)

print_info "Checking URL availability..."

for url in "${urls_to_try[@]}"; do
  print_info "Trying: $url"

  if url_exists "$url"; then
    print_info "✓ Found working URL"
    print_info
    [[ "$IS_SILENT" != "true" ]] && echo "Download URL:"
    echo "$url"
    exit 0
  fi
done

# Try version-independent fallback (ftp.fau.de)
print_info "Version-specific URLs failed, trying version-independent fallback..."
fallback_url="https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"

print_info "Trying: $fallback_url"
if url_exists "$fallback_url"; then
  print_info "✓ Found working fallback URL"
  print_info
  [[ "$IS_SILENT" != "true" ]] && echo "Download URL (version-independent):"
  echo "$fallback_url"
  exit 0
fi

# If even the fallback fails, provide manual options
print_info "All automatic options failed. Providing manual fallback URLs:"
print_info

if [[ "$IS_SILENT" != "true" ]]; then
  echo "Manual fallback URLs (verification required):"
  echo "https://github.com/eclipse-jdtls/eclipse.jdt.ls/releases"
  echo "https://download.eclipse.org/jdtls/snapshots/"
  echo "https://ftp.fau.de/eclipse/jdtls/snapshots/"
else
  # In silent mode, return the most likely working URL
  echo "$fallback_url"
fi

exit 1