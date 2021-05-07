#!/usr/bin/env zsh

local script=$0
if [ -L $script ]; then
  script=$(readlink $script)
fi

local scriptPath=$(dirname $script)
echo "Post Generate: Output directory: ${scriptPath}"

local outputScript=${scriptPath}/install_packages.zsh
echo "Post Generate: Output script: ${outputScript}"

sed -i '' -e 's|cask install adopt|cask install AdoptOpenJDK/openjdk/adopt|g' ${outputScript}
sed -i '' -e 's|cask install font|cask install homebrew/cask-fonts/font|g' ${outputScript}
sed -i '' -e 's|emacs-mac-spacemacs-icon|railwaycat/emacsmacport/emacs-mac-spacemacs-icon|g' ${outputScript}
