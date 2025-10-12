#!/usr/bin/env zsh

git config --global user.name "Thomas Burk"
git config --global user.email "t.burk@bckx.de"

git config --global log.date "relative"

git config --global core.excludesfile "${HOME}/.gitignore"
git config --global format.pretty "format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s"

git config --global init.defaultBranch main
