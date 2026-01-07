#!/usr/bin/env bash
set -e

QTILE_CONFIG="$HOME/.config/qtile/config.py"
source "$HOME/.config/dmenu_theme.conf"

usage() {
    cat <<EOF
Usage: keybinds.sh [OPTION]

Options:
  -r    Show all keybindings in rofi
  -d    Show all keybindings in dmenu
  -z    Show all keybindings in zenity
  -c    Output ONLY [conky] tagged keybindings (for Conky)
  -h    Show this help message
EOF
    exit 0
}

[ $# -eq 0 ] && usage

MODE=""
menu_backend=""

while getopts "rdzch" opt; do
    case "$opt" in
        r)
            MODE="menu"
            menu_backend="rofi"
            menu_cmd=(
                rofi
                -config "$HOME/.config/qtile/rofi/config.rasi"
                -dmenu
                -i
                -p "Qtile Keybindings"
            )
            ;;
        d)
            MODE="menu"
            menu_backend="dmenu"
            menu_cmd=(
                dmenu
                -nb "$DMENU_NB"
                -nf "$DMENU_NF"
                -sb "$DMENU_SB"
                -sf "$DMENU_SF"
                -l 20
                -p "Qtile Keybindings"
            )
            ;;
        z)
            MODE="zenity"
            ;;
        c)
            MODE="conky"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

[ -z "$MODE" ] && usage

# ---------------------------
# Helpers
# ---------------------------
format_conky_columns() {
    awk -F'\t' '{ print $1 " ${tab 130}" $2 }'
}

clean() {
    sed '
        s/"//g
        s/\[conky\]//g
        s/\[[^]]*\]//g
        s/,/ +/g
        s/control/ctrl/g
        s/  \+/ /g
        s/^ //; s/ $//
    '
}

extract_all() {
    awk '
    /Key\(\[/ && /desc="/ {
        match($0,/Key\(\[([^]]*)\], *"([^"]*)".*desc="([^"]*)"/,k)
        print k[3] "\t" k[1] " + " k[2]
    }

    /KeyChord\(/ {
        match($0,/KeyChord\(\[([^]]*)\], *"([^"]*)"/,c)
        mods=c[1]; key=c[2]; in_chord=1
        next
    }

    in_chord && /Key\(\[\]/ {
        match($0,/Key\(\[\], *"([^"]*)"/,s)
        subkey=s[1]
        next
    }

    in_chord && /desc="/ {
        match($0,/desc="([^"]*)"/,d)
        print d[1] "\t" mods " + " key " -> " subkey
    }

    in_chord && /\], *mode=/ {
        in_chord=0
    }
    ' "$QTILE_CONFIG" | clean
}

extract_conky() {
    awk '
    /Key\(\[/ && /desc="/ {
        match($0,/Key\(\[([^]]*)\], *"([^"]*)".*desc="([^"]*)"/,k)
        if (k[3] ~ /\[conky\]/)
            print k[3] "\t" k[1] " + " k[2]
    }

    /KeyChord\(/ {
        match($0,/KeyChord\(\[([^]]*)\], *"([^"]*)"/,c)
        mods=c[1]; key=c[2]; in_chord=1
        next
    }

    in_chord && /Key\(\[\]/ {
        match($0,/Key\(\[\], *"([^"]*)"/,s)
        subkey=s[1]
        next
    }

    in_chord && /desc="/ {
        match($0,/desc="([^"]*)"/,d)
        if (d[1] ~ /\[conky\]/)
            print d[1] "\t" mods " + " key " -> " subkey
    }

    in_chord && /\], *mode=/ {
        in_chord=0
    }
    ' "$QTILE_CONFIG" | clean
}

format_columns() {
    awk -F'\t' '
    {
        labels[NR]=$1
        keys[NR]=$2
        if (length($1) > max) max=length($1)
    }
    END {
        for (i=1; i<=NR; i++)
            printf "%-*s  %s\n", max, labels[i], keys[i]
    }'
}

# ---------------------------
# Dispatch
# ---------------------------
case "$MODE" in
    menu)
        extract_all | format_columns | "${menu_cmd[@]}"
        ;;
    zenity)
        extract_all | format_columns | zenity --text-info \
            --title="Qtile Keybindings" \
            --width=800 --height=600 \
            --font="Monospace 10"
        ;;
    conky)
        extract_conky | format_conky_columns
        ;;
esac
