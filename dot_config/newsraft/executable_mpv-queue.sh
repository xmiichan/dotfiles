#!/bin/sh

set -eu

sock="${MPV_NEWSRAFT_SOCK:-${XDG_RUNTIME_DIR:-/tmp}/mpv-newsraft.sock}"
conf="$HOME/.config/newsraft/mpv-queue.conf"
log="${TMPDIR:-/tmp}/mpv-newsraft.log"
mode="${1:?mode required}"
url="${2:?url required}"

command -v socat >/dev/null 2>&1 || {
    echo "$(date): socat not in PATH=$PATH" >>"$log"
    exit 3
}

send() {
    printf '%s\n' "$1" | socat -T2 - "UNIX-CONNECT:$sock" 2>>"$log"
}

is_live() {
    send '{ "command": ["get_property", "pid"] }' \
        | grep -q '"error":"success"'
}

case "$mode" in
    queue)   flag='append-play' ;;
    now)     flag='insert-next' ;;
    *) echo "unknown mode: $mode" >&2; exit 2 ;;
esac

detach() {
    if command -v setsid >/dev/null 2>&1; then
        setsid "$@" >/dev/null 2>&1 </dev/null &
    else
        nohup "$@" >/dev/null 2>&1 </dev/null &
    fi
}

if is_live; then
    send "{ \"command\": [\"loadfile\", \"$url\", \"$flag\"] }" >/dev/null
    if [ "$mode" = now ]; then
        send '{ "command": ["playlist-next"] }' >/dev/null
    fi
else
    if [ -S "$sock" ]; then
        rm -f "$sock"
    fi
    detach mpv --terminal=no --input-ipc-server="$sock" \
        --include="$conf" "$url"
fi
