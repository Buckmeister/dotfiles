#!/usr/bin/env zsh

local script=$0
if [ -L  $script ]; then
  script=$(readlink $script)
fi

local scriptPath=$(dirname $script)
echo "Output directory: ${scriptPath}"

local outputScript=${scriptPath}/install_packages.zsh
echo "Output script: ${outputScript}"

command -v brew > /dev/null 2>&1 || {
  echo >&2 "Executable 'brew' not found.. Exiting."
  exit 1
}

cat << END_OF_HEADER > $outputScript
#!/usr/bin/env zsh

command -v brew > /dev/null 2>&1 || {
  echo >&2 ""
  echo >&2 "ERROR: Executable 'brew' not found."
  echo >&2 ""
  echo >&2 "Use use the following command to install it:"
  echo >&2 '/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
  echo >&2 ""
  echo >&2 "Then re-run:"
  echo >&2 "\$0"
  exit 1
}

END_OF_HEADER

brew cask list | awk '{print "brew cask install "$0}' >> $outputScript
brew leaves | awk '{print "brew install "$0}' >> $outputScript
