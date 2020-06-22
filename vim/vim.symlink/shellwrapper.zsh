#!/usr/bin/env zsh

# add color support
autoload colors; colors;

# vim doesn't clear previous commands so clear previous output now:
clear

# strip the -c that vim adds to bash from arguments to this script
shift

# echo a nice header line because it's prettier this way :-)
echo -e "\e[33;1m\n== Command Output ==\n\e[m"

# run the command:
eval $@
