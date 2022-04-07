#!/usr/bin/env zsh
emulate -LR zsh
script_name=${0##*/}

function print_usage {
  echo
  echo "Retrieve GitHub URLs for a given..."
  echo "... Release (defaults to 'latest') of a project"
  echo "... Tag of a given project"
  echo
  echo "Usage:"
  echo
  echo "download_latest_release.zsh -u username -r repository"
  echo
  echo "Command line parameters:"
  echo "Required arguments"
  echo "  -u|--username   (=)ARG <=> set github username"
  echo "  -r|--repository (=)ARG <=> set github repository"
  echo
  echo "Get URL by release and optionally filter matching filenames"
  echo "  -l|--release    (=)ARG <=> set wanted release (e.g. 'nightly')"
  echo "  -p|--pattern    (=)ARG <=> set filter pattern for file name"
  echo
  echo "Get URL by tag"
  echo "  -t|--tag        (=)ARG <=> set wanted tag"
  echo
  echo "Output format"
  echo "  -s|--silent            <=> print url(s) only"
  echo
  echo "Documentation"
  echo "  -h|--help              <=> print usage information"
  echo
  echo "EXAMPLES:"
  echo
  echo "Get latest neovim stable download URLs"
  echo "  $script_name -u neovim -r neovim"
  echo
  echo "Get latest neovim nightly download URL for mac os"
  echo "  $script_name -u neovim -r neovim -l nightly -p '^.*mac.*z$'"
  echo
  echo "Get neovim source tarball download URL for tag 'v0.6.0'"
  echo "  $script_name -u neovim -r neovim -t v0.6.0"
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
  s=o_silent \
  -silent:=o_silent \
  h=o_help \
  -help=o_help

[[ $#o_username == 0 ]] && print_usage
[[ $#o_repository == 0 ]] && print_usage

[[ $#o_help > 0 ]] && print_usage

[[ $#o_silent > 0 ]] && IF_NOT_SILENT="true"

$IF_NOT_SILENT echo
$IF_NOT_SILENT echo "Output Format: Standard"
$IF_NOT_SILENT echo

arg_username=${o_username[@]: -1}
$IF_NOT_SILENT echo "Username: ${arg_username}"

arg_repository=${o_repository[@]: -1}
$IF_NOT_SILENT echo "Repository: ${arg_repository}"
$IF_NOT_SILENT echo

[[ $#o_release > 0 ]] && {
  arg_release=${o_release[@]: -1}
  $IF_NOT_SILENT echo "Release: ${arg_release}"
}

[[ $#o_pattern > 0 ]] && {
  arg_pattern=${o_pattern[@]: -1}
  $IF_NOT_SILENT echo "Pattern: ${arg_pattern}"
}

[[ $#o_release > 0 ]] || [[ $#o_pattern > 0 ]] && {
  $IF_NOT_SILENT echo
}

[[ $#o_tag > 0 ]] && {
  arg_tag=${o_tag[@]: -1}
  $IF_NOT_SILENT echo "Tag: ${arg_tag}"
  $IF_NOT_SILENT echo
}

if [ ! -z $arg_tag ]; then
  lookup_mode="tag"
elif [ ! -z $arg_release ]; then
  lookup_mode="release"
else # defaults
  arg_release="latest"
  lookup_mode="release"
fi

[ "$lookup_mode" = "tag" ] && {
  github_url="https://api.github.com/repos/${arg_username}/${arg_repository}/tags"

  parent_element="[]"
  target_attribute="tarball_url"
  test_criteria=$arg_tag
}

[ "$lookup_mode" = "release" ] && {
  github_url="https://api.github.com/repos/"
  github_url+="${arg_username}/${arg_repository}/releases/$arg_release"

  parent_element="assets[]"
  target_attribute="browser_download_url"
  test_criteria=$arg_pattern
  arg_tag=$(curl -s ${github_url} | sed -Ene '/^ *"tag_name": *"(v.+)",$/s//\1/p')
  $IF_NOT_SILENT echo "Release version tag: $arg_tag"
}

$IF_NOT_SILENT echo -n "API URL: "
$IF_NOT_SILENT echo "${github_url}"
$IF_NOT_SILENT echo
$IF_NOT_SILENT echo "Retrieved URL(s):"

curl -s ${github_url} |
  jq -r ".${parent_element} \
  | select(.name \
  | test(\"${test_criteria}\"))  \
  | .${target_attribute}"
