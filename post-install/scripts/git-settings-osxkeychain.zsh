#!/usr/bin/env zsh

if [[ "$(uname)" == "Darwin" ]]; then
  git config --global credential.helper osxkeychain
else
  # git config --global credential.helper osxkeychain
fi
