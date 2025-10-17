#!/usr/bin/env zsh

brew tap railwaycat/emacsmacport
# brew install emacs-mac --with-rsvg --with-imagemagick --with-dbus --with-mac-metal --with-emacs-big-sur-icon --with-no-title-bars
brew install emacs-mac --with-librsvg --with-imagemagick --with-dbus --with-mac-metal --with-emacs-big-sur-icon
osascript -e 'tell application "Finder" to make alias file to POSIX file "/usr/local/opt/emacs-mac/Emacs.app" at POSIX file "/Applications"'
