#!/usr/bin/env sh

set -eu

battery() {
    case "$(uname)" in
    Darwin)
        pmset -g batt 2>/dev/null | awk '
            /InternalBattery/ {
                match($0, /[0-9]+%/)
                pct = substr($0, RSTART, RLENGTH - 1)
                ac = (index($0, "discharging") == 0 &&
                    index($0, "AC") > 0) ? "+" : ""
                print pct, ac
                exit
            }'
        ;;
    *)
        for bat in /sys/class/power_supply/BAT*; do
            [ -r "$bat/capacity" ] || continue
            read -r pct < "$bat/capacity"
            read -r state < "$bat/status" || state=Unknown
            [ "$state" = Discharging ] && ac="" || ac="+"
            printf '%s %s\n' "$pct" "$ac"
            return 0
        done
        ;;
    esac
}

link() {
    case "$(uname)" in
    Darwin)
        dev="$(route -n get default 2>/dev/null |
            awk '/interface:/ { print $2; exit }')"
        [ -n "${dev:-}" ] || return 0
        if networksetup -listallhardwareports 2>/dev/null |
            awk -v d="$dev" '
                /Hardware Port: Wi-Fi/ { getline; if ($2 == d) ok = 1 }
                END { exit !ok }'; then 
                echo wifi
            else 
                echo eth
        fi
        ;;
    *)
        dev="$(ip route show default 2>/dev/null | awk '{ print $5; exit }')"
        [ -n "${dev:-}" ] || return 0
        if [ -d "/sys/class/net/$dev/wireless" ]; then 
            echo wifi
        else
            echo eth
        fi
        ;;
    esac
}

out=""

case "$(link || true)" in
    wifi) out=" 󰖩  | " ;;
    eth)  out=" 󰈀  | " ;;
esac

set -- $(battery || true)
if [ "$#" -ge 1 ]; then
    pct="$1"
    ac="${2:-}"
    if [ "$pct" -le 20 ]; then
        color="red"
    elif [ "$pct" -le 50 ]; then
        color="yellow"
    else
        color="green"
    fi
    out="$out 󰁹 ${pct}%${ac} | "
fi

printf '%s' "$out"
