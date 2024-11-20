#!/bin/bash

volume_increase="+10%"
volume_decrease="-10%"
#### volume_mute="toggle"

if [ "$1" = "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$volume_increase"
    current_volume=$(pactl list sinks | grep -m 1 'Volume:' | awk -F'/' '{print $2}' | sed 's/[^0-9%]//g')
    dunstify -r 8763 "Volume Control" "$current_volume"
elif [ "$1" = "down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$volume_decrease"
    current_volume=$(pactl list sinks | grep -m 1 'Volume:' | awk -F'/' '{print $2}' | sed 's/[^0-9%]//g')
    dunstify -r 8763 "Volume Control" "$current_volume"
fi

current_volume=$(pactl list sinks | grep -m 1 'Volume:' | awk -F'/' '{print $2}' | sed 's/[^0-9%]//g')
echo " 󰕾 $current_volume"
