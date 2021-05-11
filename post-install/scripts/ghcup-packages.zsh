#/usr/bin/env zsh

echo "Installing GHCPUP Packages"
ghcup install hls
ghcup upgrade

[ -f "$HOME/.local/bin/ghcup" ] && rm "$HOME/.local/bin/ghcup"
