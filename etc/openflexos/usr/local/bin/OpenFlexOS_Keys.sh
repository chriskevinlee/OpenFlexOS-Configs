#!/usr/bin/env bash

QTILE_CONFIG="$HOME/.config/qtile/config.py"

usage() {
    cat <<EOF
Usage: test.sh [OPTION]

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
while getopts "rdzch" opt; do
    case "$opt" in
        r|d|z|c) MODE="$opt" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[ -z "$MODE" ] && usage

format_conky_columns() {
    awk -F'\t' '{ print $1 " ${tab 130}" $2 }'
}

# ---------------------------
# Cleanup helper (TAB SAFE)
# ---------------------------
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

# ---------------------------
# Extract ALL keys (label<TAB>keys)
# ---------------------------
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

# ---------------------------
# Extract CONKY-only keys
# ---------------------------
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

# ---------------------------
# Format columns (SPACE padded)
# ---------------------------
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
    r)
        extract_all | format_columns | rofi -dmenu -i -p "Qtile Keybindings"
        ;;
    d)
        extract_all | format_columns | dmenu -l 20 -p "Qtile Keybindings"
        ;;
    z)
        extract_all | format_columns | zenity --text-info \
            --title="Qtile Keybindings" \
            --width=800 --height=600 \
            --font="Monospace 10"
        ;;
    c)

    extract_conky | format_conky_columns
;;
esac

