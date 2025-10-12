#!/usr/bin/env bash

# OS-aware JDT.LS launcher
# Automatically selects the correct JDT.LS script based on operating system

script_dir=$(dirname "${BASH_SOURCE[0]}")

# Detect operating system
case "$(uname -s)" in
  Darwin*)  exec "$script_dir/jdt.ls.mac.sh" "$@" ;;
  Linux*)   exec "$script_dir/jdt.ls.linux.sh" "$@" ;;
  *)
    echo "Error: Unsupported operating system for JDT.LS" >&2
    exit 1
    ;;
esac