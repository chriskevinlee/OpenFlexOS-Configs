#!/bin/bash

# ================================================================
# OpenFlexOS Universal Volume Script
# Author: Chris Lee, ChatGPT
# Description: Adjusts system volume and works with all output types (speakers, HDMI, headphones, etc.)
# ================================================================

volume_icon="󰕾"
volume_increase="+10%"
volume_decrease="-10%"
volume_mute="toggle"
notification_id=6534

# Get default, running, or fallback sink
get_active_sink() {
    # 1. Try default sink
    default_sink=$(pactl info | grep "Default Sink" | awk '{print $3}')
    if [ -n "$default_sink" ]; then
        echo "$default_sink"
        return
    fi

    # 2. Try sink that is RUNNING
    running_sink=$(pactl list short sinks | grep RUNNING | awk '{print $2}' | head -n 1)
    if [ -n "$running_sink" ]; then
        echo "$running_sink"
        return
    fi

    # 3. Fallback to first available sink
    fallback_sink=$(pactl list short sinks | awk '{print $2}' | head -n 1)
    echo "$fallback_sink"
}

# Get volume of active sink
get_current_volume() {
    pactl get-sink-volume "$1" | awk '{print $5}' | head -n1
}

# Get mute status of active sink
get_mute_status() {
    pactl get-sink-mute "$1" | awk '{print $2}'
}

# Detect active sink
sink=$(get_active_sink)

# Handle options
while getopts "udmh" opt 2>/dev/null; do
    case "${opt}" in
        u)
            pactl set-sink-volume "$sink" "$volume_increase"
            vol=$(get_current_volume "$sink")
            dunstify -r "$notification_id" "Volume Control" "$vol"
            ;;
        d)
            pactl set-sink-volume "$sink" "$volume_decrease"
            vol=$(get_current_volume "$sink")
            dunstify -r "$notification_id" "Volume Control" "$vol"
            ;;
        m)
            pactl set-sink-mute "$sink" "$volume_mute"
            mute=$(get_mute_status "$sink")
            if [ "$mute" = "yes" ]; then
                dunstify -r "$notification_id" "Volume Control" "Muted"
            else
                dunstify -r "$notification_id" "Volume Control" "Unmuted"
            fi
            ;;
        h)
            echo "Usage: $(basename "$0") [-u|-d|-m|-h]"
            echo "  -u  Volume Up"
            echo "  -d  Volume Down"
            echo "  -m  Mute/Unmute"
            echo "  -h  Help"
            ;;
        *)
            echo "Invalid option. Use -h for help."
            exit 1
            ;;
    esac
    exit 0
done

# No option: display current volume
mute=$(get_mute_status "$sink")
vol=$(get_current_volume "$sink")

if [ "$mute" = "yes" ]; then
    echo "$volume_icon Muted"
else
    echo "$volume_icon $vol"
fi
