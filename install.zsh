#!/usr/bin/env zsh

emulate -LR zsh

zparseopts -D -E -- r=o_no_r -no-r=o_no_r b=o_no_brew -no-brew=o_no_brew h=o_help -help=o_help
[[ $#o_no_r == 0 ]] && INSTALL_R=true
[[ $#o_no_brew == 0 ]] && INSTALL_BREW=true
[[ $#o_help > 0 ]] && {
  echo
  echo "Usage: $0 [-r|--no-r] [-b|--no-brew] [-h|--help]"
  echo
  echo "  [-b|--no-brew]: Skip installation of brew packages"
  echo "  [-r|--no-r]:    Skip installation of R packages"
  echo "  [-h|--help]:    Print usage"
  echo
  exit 0
}

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

if [[ ! -d "$installDir/.config/vim-plug" ]]; then
  echo "Creating vim-plug directory: '$installDir/.config/vim-plug'"
  mkdir -p "$installDir/.config/vim-plug"
fi

if [[ ! -d "$HOME/.local/bin" ]]; then
  echo "Creating ''~/.local/bin' directory: '$HOME/.local/bin'"
  mkdir -p "$HOME/.local/bin"
fi

echo "Creating symlink to 'generate_brew_install_script.zsh' in '~/.local/bin'"
ln -sf "$dotfilesDir/brew/generate_brew_install_script.zsh" "$HOME/.local/bin/generate_brew_install_script"

echo "Creating symlink to 'install_maven_wrapper.sh' in '~/.local/bin'"
ln -sf "$dotfilesDir/maven/install_maven_wrapper.sh" "$HOME/.local/bin/install_maven_wrapper"

echo "Installing required brew packages"
brew install node
brew install vim
brew install zplug
brew cask install homebrew/cask-fonts/font-fira-code-nerd-font

if [[  "$INSTALL_BREW" == "true" ]]; then
  echo "Installing additional brew packages"
  "$dotfilesDir/brew/install_packages.zsh"
fi

if [[ "$INSTALL_R" == "true" ]]; then
  echo "Installing R packages"
  "$dotfilesDir/R/install.R"
fi

echo "Installing vim plugins"
vim +'PlugInstall --sync' +qa! &>/dev/null

echo "Copying Terminal template to Downloads folder"
cp "$dotfilesDir/osx-terminal/Gruvbox.terminal" "$HOME/Downloads"

echo "Fixing folder permission to comply to compinit's audit rules."
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions

echo "Linking brew package vim instead of mvim"
brew link --overwrite vim
