#!/usr/bin/env zsh

emulate -LR zsh

command -v brew > /dev/null 2>&1 || {
  echo >&2 "Executable 'brew' not found."
  echo >&2 ""
  echo >&2 "Use the following to install:"
  echo >&2 '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
  echo >&2 ""
  echo >&2 "Then re-run:"
  echo >&2 "$0"
  exit 1
}


dotfilesDir=$(pwd)
echo "Dotfiles source directory: '$dotfilesDir'"

installDir="$HOME"
if [[ ! -d "$installDir" ]]; then
  echo "Installation target directory: '$installDir'"
  mkdir -p "$installDir"
fi

tmpDir="$HOME/.tmp"
if [[ ! -d "$tmpDir" ]];then
  echo "Temp directory: '$tmpDir'"
  mkdir -p "$tmpDir"
fi

backupDir="$tmpDir/dotfilesBackup-"$(date +%s)
if [[ ! -d "$backupDir/.config" ]]; then
  echo "Backup directory: '$backupDir'"
  mkdir -p "$backupDir/.config"
fi

homeSymlinks=(${(0)"$(find $dotfilesDir -name "*.symlink" -print0)"})

for linkSource in $homeSymlinks; do
  local linkTarget=$installDir/.$linkSource:t:r
  echo "Linking '$linkSource' to '$linkTarget'"
  [[ -e "$linkTarget" ]] && mv "$linkTarget" "$backupDir/"
  [[ -e "$linkTarget" ]] || ln -s "$linkSource" "$linkTarget"
done

configSymlinks=(${(0)"$(find $dotfilesDir -name "*.symlink_config" -print0)"})

if [[ ! -d "$installDir/.config" ]]; then
  echo "Creating .config directory: '$installDir/.config'"
  mkdir -p "$installDir/.config"
fi

for linkSource in $configSymlinks; do
  local linkTarget=$installDir/.config/$linkSource:t:r
  echo "Linking '$linkSource' to '$linkTarget'"
  [[ -e "$linkTarget" ]] && mv "$linkTarget" "$backupDir/.config/"
  [[ -e "$linkTarget" ]] || ln -s "$linkSource" "$linkTarget"
done

if [[ ! -d "$tmpDir/vimbackup" ]]; then
  echo "Creating vim backup directory: '$tmpDir/vimbackup'"
  mkdir -p "$tmpDir/vimbackup"
fi

if [[ ! -d "$installDir/.config/vim-plug" ]]; then
  echo "Creating vim-plug directory: '$installDir/.config/vim-plug'"
  mkdir -p "$installDir/.config/vim-plug"
fi

if [[ ! -d "$HOME/.local/bin" ]]; then
  echo "Creating ''~/.local/bin' directory: '$installDir/.config/vim-plug'"
  mkdir -p "$HOME/.local/bin"
fi

echo "Creating symlink to 'generate_brew_install_script.zsh' in '~/.local/bin'"
ln -s "$dotfilesDir/brew/generate_brew_install_script.zsh" "$HOME/.local/bin/generate_brew_install_script"

echo "Installing brew packages"
"$dotfilesDir/brew/install_packages.zsh"

echo "Installing vim plugins"
vim +'PlugInstall --sync' +qa &>/dev/null

echo "Installing R packages"
"$dotfilesDir/R/install.R"
