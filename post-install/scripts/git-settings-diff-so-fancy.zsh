#!/usr/bin/env zsh

# Diff-So-Fancy Settings
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"

# Improved colors for the highlighted bits
# The default Git colors are not optimal.
# The colors used for the screenshot above were:
git config --global color.ui true

git config --global delta.line-numbers true
git config --global delta.diff-so-fancy true
git config --global delta.syntax-theme gruvbox-material
