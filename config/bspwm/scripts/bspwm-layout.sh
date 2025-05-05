#!/bin/bash

layout=$(bspc query -T -d | jq -r '.layout')
floating=$(bspc query -T -n | jq -r '.client.floating')

# Icons (optional - Nerd Fonts or Font Awesome)
case "$layout" in
    tiled) layout_icon="";;
    monocle) layout_icon="";;
    *) layout_icon="";;
esac

# Floating icon overlay
if [[ "$floating" == "true" ]]; then
    float_icon=""
else
    float_icon=""
fi

# Clickable: Left = cycle layout, Right = toggle floating
echo "%{A1:bspc desktop -l next:}%{A3:bspc node -t floating:}$layout_icon $layout $float_icon%{A}%{A}"
