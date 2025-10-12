#!/usr/bin/env zsh

# ============================================================================
# Vim Setup Post-Install Script
# Sets up vim-plug, creates directories, and installs plugins
# ============================================================================

echo "Setting up Vim environment..."

# Check OS context
[[ -z "$DF_OS" ]] && {
  echo "Warning: DF_OS not set, detecting OS..."
  case "$(uname -s)" in
    Darwin*)  DF_OS="macos" ;;
    Linux*)   DF_OS="linux" ;;
    *)        DF_OS="unknown" ;;
  esac
}

# Create vim-plug directory and download vim-plug
if [[ ! -d "$HOME/.config/vim-plug" ]]; then
  echo "Creating vim-plug directory: '$HOME/.config/vim-plug'"
  mkdir -p "$HOME/.config/vim-plug"
fi

if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  echo "Downloading vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug already installed"
fi

# Install vim plugins
echo "Installing vim plugins..."
vim +'PlugInstall --sync' +qa! &>/dev/null

echo "Vim setup completed successfully!"