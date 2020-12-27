#!/usr/bin/env zsh

# Diff-So-Fancy Settings
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

# Improved colors for the highlighted bits
# The default Git colors are not optimal.
# The colors used for the screenshot above were:
git config --global color.ui true

git config --global color.diff-highlight.oldNormal "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta "11"
git config --global color.diff.frag "magenta bold"
git config --global color.diff.commit "yellow bold"
git config --global color.diff.old "red bold"
git config --global color.diff.new "green bold"
git config --global color.diff.whitespace "red reverse"
