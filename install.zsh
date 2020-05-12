#!/bin/zsh

emulate -LR zsh

dotfilesDir=$(pwd)
echo "Dotfiles source directory: '$dotfilesDir'"

installDir="$HOME"
echo "Installation target directory: '$installDir'"
[[ -d "$installDir" ]] || mkdir -p "$installDir"

tmpDir="$HOME/.tmp"
echo "Temp directory: '$tmpDir'"
[[ -d "$tmpDir" ]] || mkdir -p "$tmpDir"

backupDir="$tmpDir/dotfilesBackup-"$(date +%s)
echo "Backup directory: '$backupDir'"
[[ -d "$backupDir/.config" ]] || mkdir -p "$backupDir/.config"

homeSymlinks=(${(0)"$(find $dotfilesDir -name "*.symlink" -print0)"})

for linkSource in $homeSymlinks; do
  local linkTarget=$installDir/.$linkSource:t:r
  echo "Linking '$linkSource' to '$linkTarget'"
  [[ -e "$linkTarget" ]] && mv "$linkTarget" "$backupDir/"
  [[ -e "$linkTarget" ]] || ln -s "$linkSource" "$linkTarget" 
done

configSymlinks=(${(0)"$(find $dotfilesDir -name "*.symlink_config" -print0)"})

echo "Creating .config directory: '$installDir/.config'"
[[ -d "$installDir/.config" ]] || mkdir -p "$installDir/.config"

for linkSource in $configSymlinks; do
  local linkTarget=$installDir/.config/$linkSource:t:r
  echo "Linking '$linkSource' to '$linkTarget'"
  [[ -e "$linkTarget" ]] && mv "$linkTarget" "$backupDir/.config/"
  [[ -e "$linkTarget" ]] || ln -s "$linkSource" "$linkTarget" 
done

echo "Creating vim backup directory: '$tmpDir/vimbackup'"
[[ -d "$tmpDir/vimbackup" ]] || mkdir -p "$tmpDir/vimbackup"

echo "Creating vim-plug directory: '$installDir/.config/vim-plug'"
[[ -d "$installDir/.config/vim-plug" ]] || mkdir -p "$installDir/.config/vim-plug"

if [[ ! -d "$installDir/.config/zplug" ]]; then
  echo "Installing zplug to '$installDir/.config/zplug'"
  mkdir -p "$installDir/.config/zplug"
  git clone https://github.com/zplug/zplug "$installDir/.config/zplug"
fi

