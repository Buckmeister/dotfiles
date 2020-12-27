# vim: set ft=fish:

set fish_greeting

fish_vi_key_bindings
theme_gruvbox dark hard

source ("/usr/local/bin/starship" init fish --print-full-init | psub)
