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
brew cask install amethyst
brew cask install balenaetcher
brew cask install boop
brew cask install brave-browser
brew cask install docker
brew cask install dotnet-sdk
brew cask install electrum
brew cask install firefox
brew cask install homebrew/cask-fonts/font-fira-code
brew cask install homebrew/cask-fonts/font-fira-code-nerd-font
brew cask install homebrew/cask-fonts/font-powerline-symbols
brew cask install forklift
brew cask install google-chrome
brew cask install hammerspoon
brew cask install ibackup-viewer
brew cask install kitty
brew cask install macdown
brew cask install macvim
brew cask install min
brew cask install postman
brew cask install sizeup
brew cask install skype
brew cask install visual-studio-code
brew install angular-cli
brew install bash-completion@2
brew install bat
brew install cmake
brew install cowsay
brew install csvkit
brew install deno
brew install diff-so-fancy
brew install exa
brew install exercism
brew install fd
brew install figlet
brew install fish
brew install ghc
brew install gnupg
brew install grip
brew install haskell-stack
brew install hlint
brew install http-server
brew install jansson
brew install jq
brew install llvm
brew install luajit
brew install luarocks
brew install lz4
brew install maven
brew install maven-completion
brew install mmv
brew install neovim
brew install noti
brew install openapi-generator
brew install perltidy
brew install ponysay
brew install prettier
brew install python@3.8
brew install r
brew install ranger
brew install ripgrep
brew install rust-analyzer
brew install rustup-init
brew install sbcl
brew install scipy
brew install shellcheck
brew install shellharden
brew install shfmt
brew install starship
brew install texlab
brew install tldr
brew install tree-sitter
brew install unrar
brew install vim
brew install webkit2png
brew install wget
brew install zplug
brew install zsh-completions
