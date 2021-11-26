#!/usr/bin/env zsh

emulate -LR zsh

function print_usage {
  echo
  echo Download latest GitHub release of a given project
  echo
  echo Usage:
  echo
  echo download_latest_release.zsh -u username -r repository
  echo
  echo Command Line Parameters:
  echo "-u|--username  (=)ARG <=> set username"
  echo "-r|--repository(=)ARG <=> set repository"
  echo "-h|--help             <=> print usage information"
  echo
  exit 1
}

zparseopts -D -E \
  -- \
  u:=o_username \
  -username:=o_username \
  r:=o_repository \
  -repository:=o_repository \
  p:=o_pattern \
  -pattern:=o_pattern \
  h=o_help \
  -help=o_help

[[ $#o_username == 0 ]]   && print_usage
[[ $#o_repository == 0 ]] && print_usage
[[ $#o_help > 0 ]]        && print_usage

arg_username=${o_username[@]: -1}
echo Username: $arg_username

arg_repository=${o_repository[@]: -1}
echo Repository: $arg_repository

[[ $#o_pattern > 0 ]] && arg_pattern=${o_pattern[@]: -1}
echo Pattern: $arg_pattern

github_url=https://api.github.com/repos/${arg_username}/${arg_repository}/releases/latest
echo URL: $github_url

latest_tag=$(curl -s ${github_url} | sed -Ene '/^ *"tag_name": *"(v.+)",$/s//\1/p')
echo Latest online version: $latest_tag

curl -s ${github_url} | jq -r ".assets[] | select(.name | test(\"${arg_pattern}\"))  | .browser_download_url"


