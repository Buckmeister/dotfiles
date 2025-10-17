# vim: set ft=fish:

set fish_greeting
set STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"

fish_vi_key_bindings
# Set the cursor shapes for the different vi modes.
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block

source ~/.aliases
source ("/usr/local/bin/starship" init fish --print-full-init | psub)
