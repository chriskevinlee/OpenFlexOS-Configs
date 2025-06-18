#!/bin/bash

# ================================================================
# Description: This script allows media control includes volume up,down or mute. Also allows play next prev
# Author: Chris Lee, ChatGPT
# Dependencies: pipewire-pulse, dunstify
# Usage: Add to a panel or bar or run./volume.sh or ./volume.sh up|down|mute|play|next|prev
# Notes:
# ================================================================
volume_icon="󰕾"
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


    while getopts "udmh" main 2>/dev/null; do
        case "${main}" in
            u)
                pactl set-sink-volume @DEFAULT_SINK@ "$volume_increase"
                current_volume=$(get_current_volume)
                dunstify -r "$notification_id" "Volume Control" "$current_volume"
                ;;
            d)
                pactl set-sink-volume @DEFAULT_SINK@ "$volume_decrease"
                current_volume=$(get_current_volume)
                dunstify -r "$notification_id" "Volume Control" "$current_volume"
                ;;
            m)
                pactl set-sink-mute @DEFAULT_SINK@ "$volume_mute"
                mute_status=$(get_mute_status)
                if [ "$mute_status" = "yes" ]; then
                    dunstify -r "$notification_id" "Volume Control" "Muted"
                else
                    dunstify -r "$notification_id" "Volume Control" "UnMuted"
                fi
                ;;
            h)
              echo "A script to manage volume up,down and mute"
              echo "Usage: $(basename "$0") [ARGUMENT]"
              echo ""

              printf "%-30s %s\n" " -u" "Volume up"
              printf "%-30s %s\n" " -d" "Volume down"
              printf "%-30s %s\n" " -m" "Volume Mute"
                ;;
            *)
            echo "Please see $(basename "$0") -h for help"
            exit 1
            ;;
        esac
        exit 0
    done

    current_volume=$(get_current_volume)
    mute_status=$(get_mute_status)

    if [ "$mute_status" = "yes" ]; then
        echo "$volume_icon Muted"
    else
        echo "$volume_icon $current_volume"
    fi



