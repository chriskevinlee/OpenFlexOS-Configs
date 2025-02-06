#!/bin/bash

# ================================================================
# Description: This script allows media control includes volume up,down or mute. Also allows play next prev
# Author: Chris Lee, ChatGPT
# Dependencies: pipewire-pulse, dunstify
# Usage: Add to a panel or bar or run./volume.sh or ./volume.sh up|down|mute|play|next|prev
# Notes:
# ================================================================

volume_increase="+10%"
volume_decrease="-10%"
volume_mute="toggle"
notification_id=6534

# Get current mute and volume status
get_current_volume() {
    pactl list sinks | grep -m 1 'Volume:' | awk '{print $5}'
}

get_mute_status() {
    pactl list sinks | grep -m 1 'Mute:' | awk '{print $2}'
}

if [ "$1" = "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$volume_increase"
    current_volume=$(get_current_volume)
    dunstify -r "$notification_id" "Volume Control" "$current_volume"

elif [ "$1" = "down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$volume_decrease"
    current_volume=$(get_current_volume)
    dunstify -r "$notification_id" "Volume Control" "$current_volume"

elif [ "$1" = "mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ "$volume_mute"
    mute_status=$(get_mute_status)
    if [ "$mute_status" = "yes" ]; then
        dunstify -r "$notification_id" "Volume Control" "Muted"
    else
        dunstify -r "$notification_id" "Volume Control" "UnMuted"
    fi

elif [ "$1" = "play" ]; then
    playerctl play-pause
    dunstify -r "$notification_id" "Media Control" "Play/Pause toggled"

elif [ "$1" = "next" ]; then
    playerctl next
    dunstify -r "$notification_id" "Media Control" "Skipped to Next"

elif [ "$1" = "prev" ]; then
    playerctl previous
    dunstify -r "$notification_id" "Media Control" "Went to Previous"

elif [ -z "$1" ]; then
    mute_status=$(get_mute_status)
    if [ "$mute_status" = "yes" ]; then
        echo " Muted"
    else
        current_volume=$(get_current_volume)
        echo " $current_volume"
    fi
else
    echo "Usage: $0 {up|down|mute|play|next|prev}"
fi
