#!/usr/bin/env zsh
emulate -LR zsh
script_name=${0##*/}

function print_usage {
  echo
  echo "Retrieve GitHub download URLs for a given project"
  echo "... Release (defaults to 'latest') of a project"
  echo "... Tag of a given project"
  echo "... Most recent release (when 'latest' endpoint fails)"
  echo
  echo "Usage:"
  echo
  echo "$script_name -u username -r repository [options]"
  echo
  echo "Command line parameters:"
  echo "Required arguments"
  echo "  -u|--username   (=)ARG <=> set github username"
  echo "  -r|--repository (=)ARG <=> set github repository"
  echo
  echo "Get URL by release and optionally filter matching filenames"
  echo "  -l|--release    (=)ARG <=> set wanted release (e.g. 'latest', 'nightly')"
  echo "  -p|--pattern    (=)ARG <=> set filter pattern for file name (regex)"
  echo
  echo "Get URL by tag"
  echo "  -t|--tag        (=)ARG <=> set wanted tag"
  echo
  echo "Fallback options"
  echo "  -f|--fallback-recent   <=> use most recent release if 'latest' fails"
  echo
  echo "Output format"
  echo "  -s|--silent            <=> print url(s) only (no headers)"
  echo "  -c|--count      (=)ARG <=> limit number of results (default: all)"
  echo
  echo "Documentation"
  echo "  -h|--help              <=> print usage information"
  echo
  echo "EXAMPLES:"
  echo
  echo "Get latest neovim stable download URLs"
  echo "  $script_name -u neovim -r neovim"
  echo
  echo "Get latest neovim nightly download URL for macOS"
  echo "  $script_name -u neovim -r neovim -l nightly -p 'macos.*\\.tar\\.gz$'"
  echo
  echo "Get neovim source tarball download URL for tag 'v0.6.0'"
  echo "  $script_name -u neovim -r neovim -t v0.6.0"
  echo
  echo "Get most recent release when 'latest' fails (for JDT.LS)"
  echo "  $script_name -u eclipse-jdtls -r eclipse.jdt.ls -f -p 'jdt-language-server.*\\.tar\\.gz$'"
  echo
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
[[ $#o_silent > 0 ]] && IS_SILENT="true"

# Function to print if not silent
function print_info() {
  [[ "$IS_SILENT" != "true" ]] && echo "$@"
}

print_info
print_info "GitHub URL Downloader"
print_info

arg_username=${o_username[@]: -1}
print_info "Username: ${arg_username}"

arg_repository=${o_repository[@]: -1}
print_info "Repository: ${arg_repository}"

[[ $#o_release > 0 ]] && {
  arg_release=${o_release[@]: -1}
  print_info "Release: ${arg_release}"
}

[[ $#o_pattern > 0 ]] && {
  arg_pattern=${o_pattern[@]: -1}
  print_info "Pattern: ${arg_pattern}"
}

[[ $#o_tag > 0 ]] && {
  arg_tag=${o_tag[@]: -1}
  print_info "Tag: ${arg_tag}"
}

[[ $#o_fallback > 0 ]] && {
  use_fallback="true"
  print_info "Fallback: Use most recent release if latest fails"
}

[[ $#o_count > 0 ]] && {
  result_count=${o_count[@]: -1}
  print_info "Limit results: ${result_count}"
}

print_info

# Determine lookup mode and set defaults
if [[ -n "$arg_tag" ]]; then
  lookup_mode="tag"
elif [[ -n "$arg_release" ]]; then
  lookup_mode="release"
else # defaults
  arg_release="latest"
  lookup_mode="release"
fi

# Function to fetch and parse GitHub API
function fetch_github_data() {
  local url="$1"
  local response

  print_info "API URL: ${url}"

  response=$(curl -s "$url")

  # Check if response is valid JSON and not an error
  if ! echo "$response" | jq empty 2>/dev/null; then
    print_info "Error: Invalid JSON response from GitHub API"
    return 1
  fi

  # Check for GitHub API errors
  local error_message=$(echo "$response" | jq -r '.message // empty' 2>/dev/null)
  if [[ -n "$error_message" && "$error_message" != "null" ]]; then
    print_info "GitHub API Error: $error_message"
    return 1
  fi

  echo "$response"
}

# Handle tag lookup
if [[ "$lookup_mode" = "tag" ]]; then
  github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/tags"

  print_info "Looking up tag: $arg_tag"

  api_response=$(fetch_github_data "$github_url")
  [[ $? -ne 0 ]] && exit 1

  print_info "Retrieved URL(s):"
  echo "$api_response" | jq -r ".[] | select(.name == \"$arg_tag\") | .tarball_url"

# Handle release lookup
elif [[ "$lookup_mode" = "release" ]]; then
  github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/releases/$arg_release"

  print_info "Looking up release: $arg_release"

  api_response=$(fetch_github_data "$github_url")

  # If latest fails and fallback is enabled, try most recent release
  if [[ $? -ne 0 && "$use_fallback" = "true" && "$arg_release" = "latest" ]]; then
    print_info "Latest release failed, trying most recent release..."
    github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/releases"

    api_response=$(fetch_github_data "$github_url")
    [[ $? -ne 0 ]] && exit 1

    # Get the first (most recent) non-prerelease release
    api_response=$(echo "$api_response" | jq '.[0]')
  fi

  [[ $? -ne 0 ]] && exit 1

  # Extract tag name
  tag_name=$(echo "$api_response" | jq -r '.tag_name // empty')
  [[ -n "$tag_name" ]] && print_info "Release version tag: $tag_name"

  print_info "Retrieved URL(s):"

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