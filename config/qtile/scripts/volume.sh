#!/bin/bash

volume_increase="+10%"
volume_decrease="-10%"
volume_mute="toggle"
notification_id=6534

# Function to get the active sink
get_active_sink() {
    pactl info | grep 'Default Sink:' | awk '{print $3}'
}

# Get current volume of the active sink
get_current_volume() {
    pactl list sinks | grep -A 10 "$(get_active_sink)" | grep -m 1 'Volume:' | awk '{print $5}'
}

# Get mute status of the active sink
get_mute_status() {
    pactl list sinks | grep -A 10 "$(get_active_sink)" | grep 'Mute:' | awk '{print $2}'
}

active_sink=$(get_active_sink)

if [ "$1" = "up" ]; then
    pactl set-sink-volume "$active_sink" "$volume_increase"
    current_volume=$(get_current_volume)
    dunstify -r "$notification_id" "Volume Control" "$current_volume"

elif [ "$1" = "down" ]; then
    pactl set-sink-volume "$active_sink" "$volume_decrease"
    current_volume=$(get_current_volume)
    dunstify -r "$notification_id" "Volume Control" "$current_volume"

elif [ "$1" = "mute" ]; then
    pactl set-sink-mute "$active_sink" "$volume_mute"
    mute_status=$(get_mute_status)
    if [ "$mute_status" = "yes" ]; then
        dunstify -r "$notification_id" "Volume Control" "Muted"
    else
        dunstify -r "$notification_id" "Volume Control" "UnMuted"
    fi

elif [ -z "$1" ]; then
    mute_status=$(get_mute_status)
    if [ "$mute_status" = "yes" ]; then
        echo " Muted"
    else
        current_volume=$(get_current_volume)
        echo " $current_volume"
    fi
else
    echo "Usage: $0 {up|down|mute}"
fi
