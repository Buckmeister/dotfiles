#!/usr/bin/env zsh

command -v brew > /dev/null 2>&1 || {
  echo >&2 ""
  echo >&2 "ERROR: Executable 'brew' not found."
  echo >&2 ""
  echo >&2 "Use use the following command to install it:"
  echo >&2 '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
  echo >&2 ""
  echo >&2 "Then re-run:"
  echo >&2 "$0"
  exit 1
}

brew cask install 1password
brew cask install AdoptOpenJDK/openjdk/adoptopenjdk11
brew cask install AdoptOpenJDK/openjdk/adoptopenjdk8
brew cask install alacritty
brew cask install amethyst
brew cask install balenaetcher
brew cask install boop
brew cask install brave-browser
brew cask install docker
brew cask install dotnet-sdk
brew cask install firefox
brew cask install homebrew/cask-fonts/font-fira-code-nerd-font
brew cask install homebrew/cask-fonts/font-hack-nerd-font
brew cask install forklift
brew cask install google-chrome
brew cask install ibackup-viewer
brew cask install macdown
brew cask install macvim
brew cask install min
brew cask install postman
brew cask install sizeup
brew cask install visual-studio-code
brew install angular-cli
brew install exercism
brew install ghc
brew install haskell-stack
brew install hlint
brew install http-server
brew install llvm
brew install mmv
brew install neovim
brew install prettier
brew install r
brew install rustup-init
brew install scipy
brew install vifm
brew install vim
brew install zplug
