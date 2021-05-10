#!/usr/bin/env bash

# Uncomment to enable debug messages
# DEBUG=true

SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT_PATH)

if [ "$DEBUG" = "true" ]; then
  echo
  echo Environment vars:
  echo SCRIPT_PATH: $SCRIPT_PATH
  echo SCRIPT_DIR:  $SCRIPT_DIR
  echo
fi

echo Installing apt packages:
xargs -a "$SCRIPT_DIR/packages.list" echo
echo

read -p "Are you sure? (y/n): " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

xargs -a "$SCRIPT_DIR/packages.list" sudo apt install 
