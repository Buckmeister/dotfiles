#!/usr/bin/env zsh

_shell(){
  _usage(){
    echo
    echo "shell [ b | f | z ]  => Spawn a new shell"
    echo
    echo "b : Bash"
    echo "f : Fish"
    echo "z :  Zsh"
  }
  if [ -z $1 ]; then
    _usage
  fi

  if [[ "$1" == "b" ]]; then
    /usr/bin/env bash -i
  fi

  if [[ "$1" == "f" ]]; then
    /usr/bin/env fish -i
  fi

  if [[ "$1" == "z" ]]; then
    /usr/bin/env zsh -i
  fi
}

_shell $*
