#!/bin/bash

volume_increase="+10%"
volume_decrease="-10%"
#### volume_mute="toggle"

if [ "$1" = "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$volume_increase"
    current_volume=$(pactl list sinks | awk '/^\s*Volume:/ {print $5}')
    dunstify -r 6534 "Volume Control" "$current_volume"
elif [ "$1" = "down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$volume_decrease"
    current_volume=$(pactl list sinks | awk '/^\s*Volume:/ {print $5}')
    dunstify -r 6534 "Volume Control" "$current_volume"
fi

current_volume=$(pactl list sinks | awk '/^\s*Volume:/ {print $5}')
echo " $current_volume"
