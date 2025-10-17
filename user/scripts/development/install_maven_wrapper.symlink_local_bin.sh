#!/usr/bin/env bash

# This is a symlink file that points to install_maven_wrapper.sh
# The actual implementation is in install_maven_wrapper.sh in the same directory

script_dir=$(dirname "${BASH_SOURCE[0]}")
exec "$script_dir/install_maven_wrapper.sh" "$@"