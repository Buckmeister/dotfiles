#!/usr/bin/env zsh

# This is a symlink file that points to shell.zsh
# The actual implementation is in shell.zsh in the same directory

script_dir=$(dirname "${BASH_SOURCE[0]}")
exec "$script_dir/shell.zsh" "$@"