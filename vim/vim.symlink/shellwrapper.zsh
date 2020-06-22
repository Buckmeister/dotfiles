#!/usr/bin/env zsh

# add color support
autoload colors; colors;

# vim doesn't clear previous commands so clear previous output now:
clear

# strip the -c that vim adds to bash from arguments to this script
shift

# echo a nice blue header line because it's prettier this way :-)
echo $fg_bold[yellow] "\n== Command Output ==\n"

# run the command:
eval $@
