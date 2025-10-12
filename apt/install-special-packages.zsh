#!/usr/bin/env zsh

# ============================================================================
# Special Package Installation Script for Linux
# Installs packages that aren't available in standard apt repositories
# ============================================================================

echo "Installing special packages that require alternative methods..."

# ============================================================================
# Package Managers and Runtime Installers
# ============================================================================

# Install Rust toolchain
if ! command -v rustup > /dev/null 2>&1; then
  echo "Installing Rust toolchain via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source ~/.cargo/env
  rustup component add rust-src rust-analyzer
fi

# Install Node.js via NodeSource
if ! command -v node > /dev/null 2>&1; then
  echo "Installing Node.js via NodeSource..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Install pipx for Python package management
if ! command -v pipx > /dev/null 2>&1; then
  echo "Installing pipx..."
  python3 -m pip install --user pipx
  python3 -m pipx ensurepath
fi

# ============================================================================
# Modern CLI Tools
# ============================================================================

# Install fzf
if ! command -v fzf > /dev/null 2>&1; then
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

# Install eza (modern ls replacement)
if ! command -v eza > /dev/null 2>&1; then
  echo "Installing eza via cargo..."
  cargo install eza
fi

# Install starship prompt
if ! command -v starship > /dev/null 2>&1; then
  echo "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install GitHub CLI (official method)
if ! command -v gh > /dev/null 2>&1; then
  echo "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh
fi

# ============================================================================
# Development Tools
# ============================================================================

# Install Docker
if ! command -v docker > /dev/null 2>&1; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
  rm get-docker.sh
  echo "Note: Log out and back in for Docker group membership to take effect"
fi

# Install httpie
if ! command -v http > /dev/null 2>&1; then
  echo "Installing HTTPie via pipx..."
  pipx install httpie
  pipx inject httpie httpie-jwt-auth
fi

# ============================================================================
# Language Servers and Development Tools
# ============================================================================

# Install modern Neovim (if not already installed)
if ! command -v nvim > /dev/null 2>&1; then
  echo "Installing Neovim..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x nvim.appimage
  sudo mv nvim.appimage /usr/local/bin/nvim
fi

# Install Node.js global packages
if command -v npm > /dev/null 2>&1; then
  echo "Installing Node.js global packages..."
  npm install -g @angular/cli
  npm install -g http-server
  npm install -g typescript
  npm install -g typescript-language-server
  npm install -g vscode-langservers-extracted
fi

# Install Python development tools via pipx
echo "Installing Python development tools..."
pipx install black
pipx install flake8
pipx install python-lsp-server

# Install Lua language server
if ! command -v lua-language-server > /dev/null 2>&1; then
  echo "Installing Lua Language Server..."
  # This requires building from source or downloading prebuilt binary
  echo "Note: Lua Language Server requires manual installation"
  echo "See: https://github.com/LuaLS/lua-language-server/releases"
fi

# Install Ruby gems
if command -v gem > /dev/null 2>&1; then
  echo "Installing Ruby gems..."
  gem install solargraph
fi

# ============================================================================
# Snap Packages (if snapd is available)
# ============================================================================

if command -v snap > /dev/null 2>&1; then
  echo "Installing snap packages..."

  # Development tools
  sudo snap install code --classic
  sudo snap install postman

  # Browsers
  sudo snap install brave
  # sudo snap install chromium  # Alternative to Google Chrome

  # Communication
  sudo snap install skype --classic

  # Multimedia
  sudo snap install blender --classic

  # Terminal emulator
  sudo snap install alacritty --classic

else
  echo "Snapd not available, skipping snap packages"
  echo "Install manually:"
  echo "  - Visual Studio Code: https://code.visualstudio.com/download"
  echo "  - Brave Browser: https://brave.com/download/"
  echo "  - Alacritty: https://github.com/alacritty/alacritty/releases"
fi

# ============================================================================
# Flatpak Packages (if flatpak is available)
# ============================================================================

if command -v flatpak > /dev/null 2>&1; then
  echo "Installing Flatpak packages..."

  # Add Flathub repository
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Install applications
  flatpak install -y flathub org.mozilla.firefox
  flatpak install -y flathub com.getpostman.Postman
  flatpak install -y flathub org.blender.Blender

else
  echo "Flatpak not available, skipping flatpak packages"
fi

# ============================================================================
# Nerd Fonts Installation
# ============================================================================

echo "Installing Nerd Fonts..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Install JetBrains Mono Nerd Font
if [ ! -f "$FONT_DIR/JetBrainsMono Nerd Font Complete.ttf" ]; then
  echo "Installing JetBrains Mono Nerd Font..."
  wget -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  rm /tmp/JetBrainsMono.zip
fi

# Install FiraCode Nerd Font
if [ ! -f "$FONT_DIR/Fira Code Nerd Font Complete.ttf" ]; then
  echo "Installing FiraCode Nerd Font..."
  wget -O /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  unzip -o /tmp/FiraCode.zip -d "$FONT_DIR"
  rm /tmp/FiraCode.zip
fi

# Refresh font cache
fc-cache -fv

echo "✅ Special package installation completed!"
echo ""
echo "Note: Some packages may require:"
echo "  - Logging out and back in (Docker group membership)"
echo "  - Restarting your terminal (PATH changes)"
echo "  - Manual configuration (language servers, etc.)"