#!/usr/bin/env zsh

command -v gem >/dev/null 2>&1 && {
  echo "Installing Ruby gems..."

  # Core gems
  sudo gem install vcardigan plist

  echo "✅ Ruby gems installed successfully!"
  echo "Note: Solargraph (Ruby LSP with linting/formatting) is installed via brew"
}
