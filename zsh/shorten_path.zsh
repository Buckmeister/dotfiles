#!/usr/bin/env zsh
#
# vim:ft=sh

if [ -z "$1" ]; then
    echo .
    echo Usage: $0 PATH
    echo .
    exit 1
else
    dir=$1
fi
dir=$(echo $dir | sed "s#$(echo $HOME)#~#")

function shorten_pwd {
  paths=(${(s:/:)dir})

  if [[ "${dir:0:1}" == "~" ]]; then
    cur_path="~/"
    cur_short_path="~/"
    shift paths
  else
    cur_path="/"
    cur_short_path="/"
  fi
  for directory in ${paths[@]}
  do
    if [[ "$directory" == "~" ]]; then
      break
    fi
    cur_dir=''
    for (( i=0; i<${#directory}; i++ )); do
      cur_dir+="${directory:$i:1}"
      matching=("$(echo ${cur_path} | sed "s#~#$(echo $HOME)#")""$cur_dir"*/)
      if [[ ${#matching[@]} -eq 1 ]]; then
        break
      fi
    done
    cur_path+="$directory/"
    cur_short_path+="$cur_dir/"
  done

  print "${cur_short_path: : -1}"
}
shorten_pwd
