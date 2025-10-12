#!/usr/bin/env bash

# Uncomment to enable debug messages
# DEBUG=true

SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT_PATH)
PACKAGE_LIST=$SCRIPT_DIR/packages.list

NEW_PACKAGE=$1

if [ "$DEBUG" = "true" ]; then
  echo
  echo Environment vars:
  echo SCRIPT_PATH:  $SCRIPT_PATH
  echo SCRIPT_DIR:   $SCRIPT_DIR
  echo PACKAGE_LIST: $PACKAGE_LIST
  echo
fi

echo Adding new Package: $NEW_PACKAGE
echo

if [ ! -f  "$PACKAGE_LIST" ]; then
  touch "$PACKAGE_LIST"
else
  perl -pi -e 's/^\s+$//;' "$PACKAGE_LIST"
fi

echo $NEW_PACKAGE >> "$PACKAGE_LIST"
cat "$PACKAGE_LIST" | sort | uniq > "${PACKAGE_LIST}.tmp" 
mv "${PACKAGE_LIST}.tmp" "$PACKAGE_LIST"
