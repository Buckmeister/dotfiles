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

  if [[ "$1" =~ "^[bB]" ]]; then
    exec /usr/bin/env bash -i
  fi

  if [[ "$1" =~ "^[fF]" ]]; then
    exec /usr/bin/env fish -i
  fi

  if [[ "$1" =~ "^[fF]" ]]; then
    exec /usr/bin/env zsh -i
  fi
}

_shell $*
