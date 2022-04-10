#!/usr/bin/env zsh

emulate -LR zsh

zparseopts -D -E -- h=o_help -help=o_help

[[ $#o_help > 0 ]] && {
  echo
  echo "Usage: $0 [-h|--help]"
  echo
  echo "  [-h|--help]:        Print usage"
  echo
  exit 0
}

dotfilesDir=$(realpath "$(dirname ${0})")
echo "Dotfiles source directory: '$dotfilesDir'"

installDir="$HOME"
if [[ ! -d "$installDir" ]]; then
  mkdir -p "$installDir"
fi
echo "Installation target directory: '$installDir'"

tmpDir="$HOME/.tmp"
if [[ ! -d "$tmpDir" ]]; then
  mkdir -p "$tmpDir"
fi
echo "Temp directory: '$tmpDir'"

backupDir="$tmpDir/dotfilesBackup-"$(date +%s)
if [[ ! -d "$backupDir/.config" ]]; then
  mkdir -p "$backupDir/.config"
fi
echo "Backup directory: '$backupDir'"

homeSymlinks=(${(0)"$(find $dotfilesDir -name "*.symlink" -print0)"})

for linkSource in $homeSymlinks; do
  linkTarget=$installDir/.$linkSource:t:r
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
  linkTarget=$installDir/.config/$linkSource:t:r
  echo "Linking '$linkSource' to '$linkTarget'"
  [[ -e "$linkTarget" ]] && mv "$linkTarget" "$backupDir/.config/"
  [[ -e "$linkTarget" ]] || ln -s "$linkSource" "$linkTarget"
done

if [[ ! -d "$tmpDir/vimbackup" ]]; then
  echo "Creating vim backup directory: '$tmpDir/vimbackup'"
  mkdir -p "$tmpDir/vimbackup"
fi

if [[ ! -d "$tmpDir/emacsbackup" ]]; then
  echo "Creating vim backup directory: '$tmpDir/emacsbackup'"
  mkdir -p "$tmpDir/emacsbackup"
fi

if [[ ! -d "$HOME/.local/bin" ]]; then
  echo "Creating ''~/.local/bin' directory: '$HOME/.local/bin'"
  mkdir -p "$HOME/.local/bin"
fi

echo "Creating symlink to 'add_package_to_installation_list.sh' in '~/.local/bin'"
ln -sf "$dotfilesDir/apt/add_package_to_installation_list.sh" "$HOME/.local/bin/add_package_to_installation_list"

echo "Creating symlink to 'install_apt_packages.sh' in '~/.local/bin'"
ln -sf "$dotfilesDir/apt/install_apt_packages.sh" "$HOME/.local/bin/install_apt_packages"

echo "Creating symlink to 'shell.zsh' in '~/.local/bin'"
ln -sf "$dotfilesDir/zsh/shell.zsh" "$HOME/.local/bin/shell"

echo "Creating symlink to 'jdt.ls.sh' in '~/.local/bin'"
ln -sf "$dotfilesDir/jdt.ls/jdt.ls.linux.sh" "$HOME/.local/bin/jdt.ls"

echo "Creating symlink to 'create_hie.yaml' in '~/.local/bin'"
ln -sf "$dotfilesDir/stack/create_hie.yaml" "$HOME/.local/bin/"

echo "Installing apt packages"
$dotfilesDir/apt/install_apt_packages.sh
sudo chown -R $USERNAME /usr/local

echo "Fixing permissions for compinit"
sudo chown -R root:root /usr/local/zsh
sudo chmod -R 750 /usr/local/zsh

echo "Installing vim-plug"
if [[ ! -d "$installDir/.config/vim-plug" ]]; then
  echo "Creating vim-plug directory: '$installDir/.config/vim-plug'"
  mkdir -p "$installDir/.config/vim-plug"
  echo "Downloading vin-plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Installing vim plugins"
vim +'PlugInstall --sync' +qa! &>/dev/null

echo "Downloading Bash PreExec"
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
