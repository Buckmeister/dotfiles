#!/usr/bin/env zsh

command -v rustup >/dev/null 2>&1 || {
  rustup-init
}

rustup update
cargo install viu
