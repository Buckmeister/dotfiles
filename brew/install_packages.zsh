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

brew install 1password
brew install adoptopenjdk11
brew install adoptopenjdk8
brew install amethyst
brew install balenaetcher
brew install boop
brew install brave-browser
brew install docker
brew install dotnet-sdk
brew install electrum
brew install --cask emacs
brew install firefox
brew install font-code-new-roman-nerd-font
brew install font-fira-code
brew install font-fira-code-nerd-font
brew install font-hack-nerd-font
brew install font-hasklug-nerd-font
brew install font-iosevka
brew install font-iosevka-nerd-font
brew install font-jetbrains-mono-nerd-font
brew install font-monoid-nerd-font
brew install font-powerline-symbols
brew install font-sauce-code-pro-nerd-font
brew install forklift
brew install google-chrome
brew install hammerspoon
brew install ibackup-viewer
brew install kitty
brew install macdown
brew install min
brew install postman
brew install sizeup
brew install skype
brew install visual-studio-code
brew install adns
brew install angular-cli
brew install bash-completion@2
brew install ccls
brew install clang-format
brew install cmake
brew install cowsay
brew install csvkit
brew install deno
brew install diff-so-fancy
brew install docker
brew install eth-p/software/bat-extras
brew install exa
brew install exercism
brew install fd
brew install figlet
brew install fish
brew install flow
brew install ghc
brew install gnupg
brew install gping
brew install grip
brew install haskell-stack
brew install hlint
brew install htop
brew install http-server
brew install jansson
brew install jq
brew install libtermkey
brew install libvterm
brew install lolcat
brew install luajit
brew install luajit-openresty
brew install luarocks
brew install luv
brew install lz4
brew install macvim
brew install maven
brew install maven-completion
brew install mmv
brew install msgpack
brew install neofetch
brew install noti
brew install openapi-generator
brew install perltidy
brew install ponysay
brew install python@3.8
brew install r
brew install ranger
brew install rust-analyzer
brew install rustup-init
brew install sbcl
brew install scipy
brew install sdl2
brew install shellcheck
brew install shellharden
brew install showkey
brew install starship
brew install texlab
brew install thefuck
brew install tldr
brew install tree-sitter
brew install unrar
brew install webkit2png
brew install wget
brew install zplug
brew install zsh-completions
