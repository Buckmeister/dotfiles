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
# sudo add-apt-repository ppa:neovim-ppa/unstable
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
$dotfilesDir/apt/install_apt_packages.sh
sudo chown -R $USERNAME /usr/local

echo "Installing haskell toolchain"
curl -sSL https://get.haskellstack.org/ | sh
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
chmod go-w /home/thomas/.ghci

echo "Installing rust toolchain"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Installing starship shell prompt"
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

echo "Installing vim-plug"
if [[ ! -d "$installDir/.config/vim-plug" ]]; then
  echo "Creating vim-plug directory: '$installDir/.config/vim-plug'"
  mkdir -p "$installDir/.config/vim-plug"
  echo "Downloading vin-plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Installing vim plugins"
vim +'PlugInstall --sync' +qa! &>/dev/null

echo "Downloading Lombok"
if [[ ! -d "/usr/local/share/lombok" ]]; then
  echo "Lombok directory '/usr/local/share/lombok'"
  mkdir -p "/usr/local/share/lombok"
fi
curl https://projectlombok.org/downloads/lombok.jar > /usr/local/share/lombok/lombok.jar

echo "Downloading Bash PreExec"
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh

echo "Installing R packages"
"$dotfilesDir/R/install.R"

echo "Installing JDT.LS"
[ -d "/usr/local/share/jdt.ls" ] && rm -rf "/usr/local/share/jdt.ls/*"
curl -fLo "/usr/local/share/jdt.ls/jdt-language-server-latest.tar.gz" --create-dirs "https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"
tar xzf "/usr/local/share/jdt.ls/jdt-language-server-latest.tar.gz" --directory="/usr/local/share/jdt.ls"

curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.local/bin/rust-analyzer
chmod +x ~/.local/bin/rust-analyzer

cpan Neovim::Ext
cpan App::cpanminus
cpan Perl::LanguageServer

echo "Installing kitty"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo mv /usr/bin/kitty /usr/bin/kitty.0.19
echo "Creating kitty symlink"
sudo ln -s ~/.local/kitty.app/bin/kitty /usr/bin/

echo "Installing diff-so-fancy"
mkdir -p ~/.local/share/diff-so-fancy
git clone https://github.com/so-fancy/diff-so-fancy ~/.local/share/diff-so-fancy
ln -s $HOME/.local/share/diff-so-fancy/diff-so-fancy ~/.local/bin/

echo "Installing luarocks"
rm -rf ~/.tmp/luarocks*
cd ~/.tmp
wget https://luarocks.org/releases/luarocks-3.7.0.tar.gz
tar zxpf luarocks-3.7.0.tar.gz
cd luarocks-3.7.0
./configure && make && sudo make install

echo "Fixing permissions for compinit"
sudo chown -R $USERNAME /usr/local
sudo chown -R root:thomas /usr/local/zsh
sudo chmod -R 770 /usr/local/zsh


echo "Installing fonts"
cd ~/.tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip -o FiraCode.zip -d ~/.local/share/fonts
unzip -o Iosevka.zip -d ~/.local/share/fonts
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
rm FiraCode.zip
rm Iosevka.zip
rm JetBrainsMono.zip

echo "Installing Python 2 pip"
cd ~/.tmp
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
pip2 install pynvim
rm get-pip.py

echo "Applying Post-Install Scripts"
postInstallScripts=(${(0)"$(find "${dotfilesDir}/post-install" -perm /555 -name "*.zsh" -print0)"})

for piScript in $postInstallScripts; do
  echo "Executing: '$piScript'"
  [[ -e "$piScript" ]] && "$piScript"
done

# Manual steps for Zorin 16 so far
# Download: https://github.com/dandavison/delta/releases/latest
# Untar to: ~/.local/share/delta
# ln -s $HOME/.local/share/delta/delta ~/.local/bin/
#
#
# Download: https://github.com/latex-lsp/texlab/releases
# Unzip to: ~/.local/bin/
#
# Download: https://github.com/OmniSharp/omnisharp-roslyn/releases/latest
# Unzip to: /usr/local/share/omnisharp
#
# Download: https://github.com/microsoft/Git-Credential-Manager-Core/releases/latest
# Run: sudo dpkg -i <path-to-package>
# Run: git-credential-manager-core configure
#
# Clone: git clone https://github.com/thewtex/tmux-mem-cpu-load.git
# cd tmux-mem-cpu-load
# cmake .
# make
# sudo make install

