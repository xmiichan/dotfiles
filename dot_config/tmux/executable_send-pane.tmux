#!/usr/bin/env sh

set -eu

move() {
    local t="$1"
    if tmux list-windows -F '#I' | grep -qx "$t"; then
        tmux join-pane -d -s :. -t ":$t.{bottom-right}"
        tmux select-pane -t ":$t.0"
        tmux setw -t ":$t" main-pane-width \
            "$(tmux display-message -p -t ":$t.0" '#{pane_width}')"
        tmux select-layout -t ":$t" main-vertical
    else
        tmux break-pane -d -s :. -t "$t"
    fi

    tmux select-pane -t :.0
    tmux setw main-pane-width \
        "$(tmux display-message -p -t :.0 '#{pane_width}')"
    tmux select-layout main-vertical
}

move "$1"

