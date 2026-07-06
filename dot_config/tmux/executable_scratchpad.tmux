#!/usr/bin/env sh

set -eu

dir="${1:-$HOME}"

id="$(tmux list-panes \
    -f '#{&&:#{pane_floating_flag},#{==:#{@scratch},1}}' \
    -F '#{pane_id}' | head -n 1)"

if [ -n "$id" ]; then
    tmux set-option -g @scratch-geometry "$(tmux display-message -p \
        -t "$id" '#{pane_width} #{pane_height} #{pane_x} #{pane_y}')"
    tmux kill-pane -t "$id"
    exit 0
fi

ww="$(tmux display-message -p '#{window_width}')"
wh="$(tmux display-message -p '#{window_height}')"

set -- $(tmux show-options -gqv @scratch-geometry)
if [ "$#" -eq 4 ]; then
    w="$1"; h="$2"; x="$3"; y="$4"
else
    w=$((ww * 8 / 10)); h=$((wh * 7 / 10))
    x=$(((ww - w) / 2)); y=$(((wh - h) / 2))
fi

[ "$w" -gt $((ww - 2)) ] && w=$((ww - 2))
[ "$h" -gt $((wh - 2)) ] && h=$((wh - 2))
[ "$x" -gt $((ww - w - 1)) ] && x=$((ww - w - 1))
[ "$y" -gt $((wh - h - 1)) ] && y=$((wh - h - 1))
[ "$x" -lt 0 ] && x=0
[ "$y" -lt 0 ] && y=0

tmux new-pane -x "$w" -y "$h" -X "$x" -Y "$y" -c "$dir" \
    "TMUX='' tmux new -As _scratch"
tmux set-option -p @scratch 1
