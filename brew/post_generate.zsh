#!/usr/bin/env zsh

script=$0
if [ -L $script ]; then
  script=$(readlink $script)
fi

scriptPath=$(dirname $script)
echo "Post Generate: Output directory: ${scriptPath}"

outputScript=${scriptPath}/install_packages.zsh
echo "Post Generate: Output script: ${outputScript}"
