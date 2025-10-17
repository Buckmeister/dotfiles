#!/usr/bin/env zsh

# This is a symlink file that points to shorten_path.zsh
# The actual implementation is in shorten_path.zsh in the same directory

script_dir=$(dirname "${BASH_SOURCE[0]}")
exec "$script_dir/shorten_path.zsh" "$@"