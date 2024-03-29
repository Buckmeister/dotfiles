#!/usr/bin/env zsh

emulate -LR zsh

zparseopts -D -E -- r=o_no_r -no-r=o_no_r b=o_no_brew -no-brew=o_no_brew u=o_update_only -update-only=o_update_only h=o_help -help=o_help
[[ $#o_no_r == 0 ]] && INSTALL_R=true
[[ $#o_no_brew == 0 ]] && INSTALL_BREW=true
[[ $#o_update_only > 0 ]] && {
  INSTALL_BREW=false
  INSTALL_R=false
  UPDATE_ONLY=true
}

[[ $#o_help > 0 ]] && {
  echo
  echo "Usage: $0 [-r|--no-r] [-b|--no-brew] [-u|--update-only] [-h|--help]"
  echo
  echo "  [-b|--no-brew]:     Skip installation of optinal brew packages"
  echo "  [-r|--no-r]:        Skip installation of R packages"
  echo "  [-u|--update-only]: Skip r and brew package installation completely"
  echo "  [-h|--help]:        Print usage"
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

dotfilesDir=$(realpath "$(dirname ${0})")
echo "Dotfiles source directory: '$dotfilesDir'"

installDir="$HOME"
if [ ! -d "$installDir" ]; then
  echo "Installation target directory: '$installDir'"
  mkdir -p "$installDir"
fi

tmpDir="$HOME/.tmp"
if [[ ! -d "$tmpDir" ]]; then
  echo "Temp directory: '$tmpDir'"
  mkdir -p "$tmpDir"
fi

backupDir="$tmpDir/dotfilesBackup-"$(date +%s)
if [[ ! -d "$backupDir/.config" ]]; then
  echo "Backup directory: '$backupDir'"
  mkdir -p "$backupDir/.config"
fi

homeSymlinks=(${(0)"$(find $dotfilesDir -path "$dotfilesDir/.git" -prune -false -o -name "*.symlink" -print0)"})

for linkSource in $homeSymlinks; do
  linkTarget=$installDir/.$linkSource:t:r
  echo "Linking '$linkSource' to '$linkTarget'"
  [[ -e "$linkTarget" ]] && mv "$linkTarget" "$backupDir/"
  [[ -e "$linkTarget" ]] || ln -s "$linkSource" "$linkTarget"
done

configSymlinks=(${(0)"$(find $dotfilesDir -path "$dotfilesDir/.git" -prune -false -o -name "*.symlink_config" -print0)"})

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
  echo "Creating vim undo directory: '$tmpDir/vimbackup/undo'"
  mkdir -p "$tmpDir/vimbackup/undo"
  echo "Creating vim swapfile directory: '$tmpDir/vimbackup/swap'"
  mkdir -p "$tmpDir/vimbackup/swap"
fi

if [[ ! -d "$tmpDir/emacsbackup" ]]; then
  echo "Creating vim backup directory: '$tmpDir/emacsbackup'"
  mkdir -p "$tmpDir/emacsbackup"
fi

if [[ ! -d "$HOME/.local/bin" ]]; then
  echo "Creating ''~/.local/bin' directory: '$HOME/.local/bin'"
  mkdir -p "$HOME/.local/bin"
fi

echo "Creating symlink to 'generate_brew_install_script.zsh' in '~/.local/bin'"
ln -sf "$dotfilesDir/brew/generate_brew_install_script.zsh" "$HOME/.local/bin/generate_brew_install_script"

echo "Creating symlink to 'install_maven_wrapper.sh' in '~/.local/bin'"
ln -sf "$dotfilesDir/maven/install_maven_wrapper.sh" "$HOME/.local/bin/install_maven_wrapper"

echo "Creating symlink to 'shell.zsh' in '~/.local/bin'"
ln -sf "$dotfilesDir/zsh/shell.zsh" "$HOME/.local/bin/shell"

echo "Creating symlink to 'shorten_path.zsh' in '~/.local/bin'"
ln -sf "$dotfilesDir/zsh/shorten_path.zsh" "$HOME/.local/bin/shorten_path"

echo "Creating symlink to 'jdt.ls.sh' in '~/.local/bin'"
ln -sf "$dotfilesDir/jdt.ls/jdt.ls.mac.sh" "$HOME/.local/bin/jdt.ls"

echo "Creating symlink to 'create_hie.yaml' in '~/.local/bin'"
ln -sf "$dotfilesDir/stack/create_hie.yaml" "$HOME/.local/bin/"

if [[ ! "$UPDATE_ONLY" == "true" ]]; then
echo "Installing required brew packages"
  brew install node
  brew install macvim
  brew install zplug
  brew install kitty
fi

if [[ "$INSTALL_BREW" == "true" ]]; then
  echo "Installing additional brew packages"
  "$dotfilesDir/brew/install_packages.zsh"
fi

if [[ "$INSTALL_R" == "true" ]]; then
  echo "Installing R packages"
  "$dotfilesDir/R/install.R"
fi

if [[ ! -d "$installDir/.config/vim-plug" ]]; then
  echo "Creating vim-plug directory: '$installDir/.config/vim-plug'"
  mkdir -p "$installDir/.config/vim-plug"
  echo "Downloading vin-plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Installing vim plugins"
vim +'PlugInstall --sync' +qa! &>/dev/null

echo "Copying Terminal template to Downloads folder"
cp "$dotfilesDir/osx-terminal/Gruvbox.terminal" "$HOME/Downloads"
cp "$dotfilesDir/osx-terminal/OneDark.terminal" "$HOME/Downloads"

echo "Fixing folder permission to comply to compinit's audit rules."
chmod -R go-w /usr/local/share

echo "Downloading Lombok"
if [[ ! -d "/usr/local/share/lombok" ]]; then
  echo "Lombok directory '/usr/local/share/lombok'"
  mkdir -p "/usr/local/share/lombok"
fi
curl https://projectlombok.org/downloads/lombok.jar > /usr/local/share/lombok/lombok.jar

echo "Downloading Bash PreExec"
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh

echo "Installing Docker Completions"
[ -d /Applications/Docker.app/Contents/Resources/etc ] && {
  etc=/Applications/Docker.app/Contents/Resources/etc
  ln -sf $etc/docker.zsh-completion /usr/local/share/zsh/site-functions/_docker
}
echo

echo "Installing JDT.LS"
[ -d "/usr/local/share/jdt.ls" ] && rm -rf "/usr/local/share/jdt.ls/*"
curl -fLo "/usr/local/share/jdt.ls/jdt-language-server-latest.tar.gz" --create-dirs "https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"
tar xzf "/usr/local/share/jdt.ls/jdt-language-server-latest.tar.gz" --directory="/usr/local/share/jdt.ls"

echo "Installing OmniSharp"
[ -d "/usr/local/share/omnisharp" ] && rm -rf "/usr/local/share/omnisharp/*"
curl -fLo "/usr/local/share/omnisharp/omnisharp-osx.tar.gz" --create-dirs "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.37.6/omnisharp-osx.tar.gz"
tar xzf "/usr/local/share/omnisharp/omnisharp-osx.tar.gz" --directory="/usr/local/share/omnisharp"

echo "Installing GHCUP"
[ -d "/usr/local/share/ghcup" ] && rm -rf "/usr/local/share/ghcup/*"
curl -fLo "/usr/local/share/ghcup/ghcup" --create-dirs "https://downloads.haskell.org/~ghcup/x86_64-apple-darwin-ghcup"
chmod 755 "/usr/local/share/ghcup/ghcup"
ln -sf "/usr/local/share/ghcup/ghcup" ~/.local/bin/

echo "Applying Post-Install Scripts"
postInstallScripts=(${(0)"$(find "${dotfilesDir}/post-install" -perm 755 -name "*.zsh" -print0)"})

for piScript in $postInstallScripts; do
  echo "Executing: '$piScript'"
  [[ -e "$piScript" ]] && "$piScript"
done
