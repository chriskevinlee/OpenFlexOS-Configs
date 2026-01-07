#!/usr/bin/env bash
# Colorizes Qtile keybindings for Conky using themes.json

KEY_SCRIPT="$HOME/.config/qtile/scripts/OpenFlexOS_Keys.sh"
THEMES_FILE="$HOME/.config/themes.json"

command -v jq >/dev/null || exit 1

CURRENT_THEME=$(jq -r '.current' "$THEMES_FILE")

COLOR1=$(jq -r ".themes.\"$CURRENT_THEME\".color1" "$THEMES_FILE")
COLOR2=$(jq -r ".themes.\"$CURRENT_THEME\".color3" "$THEMES_FILE")
FG=$(jq -r ".themes.\"$CURRENT_THEME\".fg" "$THEMES_FILE")

if [[ "$COLOR1" == "null" || "$COLOR2" == "null" ]]; then
    echo "Theme colors missing"
    exit 1
fi

"$KEY_SCRIPT" -c | awk -v c1="$COLOR1" -v c2="$COLOR2" -v fg="$FG" '
{
    if (NR % 2)
        print "${color " c1 "}" $0 "${color " fg "}"
    else
        print "${color " c2 "}" $0 "${color " fg "}"
}
'
