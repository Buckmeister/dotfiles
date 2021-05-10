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

echo "Applying Post-Install Scripts"
postInstallScripts=(${(0)"$(find "${dotfilesDir}/post-install" -perm 755 -name "*.zsh" -print0)"})

for piScript in $postInstallScripts; do
  echo "Executing: '$piScript'"
  [[ -e "$piScript" ]] && echo "$piScript"
done

# Manual steps for Ubuntu Budgie 21.04
#
# Download: https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
# Download: https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
# Download: https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
# Unzip to: ~/.local/share/fonts
#
# sudo mkdir /usr/local/opt
# sudo chown thomas:thomas /usr/local/opt
# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
#
# sh -c "$(curl -fsSL https://starship.rs/install.sh)"
#
# curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# mv /usr/bin/kitty /usr/bin/kitty.0.19
# ln -s ~/.local/kitty.app/bin/kitty /usr/bin/
#
# ./post-install/scripts/pip3-packages.zsh
# pip3 install ueberzug
# pip install pynvim
#
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# ./post-install/scripts/cargo-packages.zsh
#
# mkdir -p ~/.local/share/diff-so-fancy
# https://github.com/so-fancy/diff-so-fancy ~/.local/share/diff-so-fancy
# ln -s $HOME/.local/share/diff-so-fancy/diff-so-fancy ~/.local/bin/
#
# Download: https://github.com/dandavison/delta/releases/download/0.6.0/delta-0.6.0-x86_64-unknown-linux-gnu.tar.gz
# Untar to ~/.local/share/delta
# ln -s $HOME/.local/share/delta/delta ./
#
