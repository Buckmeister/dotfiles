#! /usr/bin/env bash

set -e

for bin in "cargo" "mktemp" "sed" "tmux"; do
    if ! command -v $bin &> /dev/null; then
        echo >&2 "\`$bin\` not found"
        exit 1
    fi
done

editor=${EDITOR:-nvim}
root_dir="$(mktemp --directory --tmpdir rustp-XXXXXX)/playground"

mkdir -p "$root_dir"
cargo init "$root_dir"
cd $root_dir

for crate in $@; do
    sed "/^\[dependencies\]/a $crate = \"*\"" -i Cargo.toml
done

if [ -n "$TMUX" ]; then
    tmux new-window \; \
        send-keys "$editor ./src/main.rs" C-m \; \
        split-window -h \; \
        send-keys "cargo watch -s 'clear && cargo run -q'" C-m \; \
        select-pane -L;
else
    tmux new-session \; \
        send-keys "$editor ./src/main.rs" C-m \; \
        split-window -h \; \
        send-keys "cargo watch -s 'clear && cargo run -q'" C-m \; \
        select-pane -L;
fi
