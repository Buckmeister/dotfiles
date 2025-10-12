#!/usr/bin/env zsh

# This is a symlink file that points to generate_brew_install_script.zsh
# The actual implementation is in generate_brew_install_script.zsh in the same directory

script_dir=$(dirname "${BASH_SOURCE[0]}")
exec "$script_dir/generate_brew_install_script.zsh" "$@"