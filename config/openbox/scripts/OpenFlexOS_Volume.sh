#!/bin/bash

# ================================================================
# Description: Volume and media control (up/down/mute)
# Author: Chris Lee, ChatGPT
# Dependencies: pipewire-pulse, dunstify
# Usage: ./OpenFlexOS_Volume.sh -u | -d | -m | no args to show status
# ================================================================

volume_icon="󰕾"
volume_increase="+10%"
volume_decrease="-10%"
volume_mute="toggle"
notification_id=6534

# Get default sink name
get_default_sink() {
    pactl info | grep 'Default Sink' | cut -d ':' -f2 | xargs
}

# Get current volume of default sink
get_current_volume() {
    default_sink=$(get_default_sink)
    pactl list sinks | awk -v sink="$default_sink" '
        $0 ~ "Name: "sink {found=1}
        found && /Volume:/ {print $5; exit}
    '
}

# Get mute status of default sink
get_mute_status() {
    default_sink=$(get_default_sink)
    pactl list sinks | awk -v sink="$default_sink" '
        $0 ~ "Name: "sink {found=1}
        found && /Mute:/ {print $2; exit}
    '
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
                current_volume=$(get_current_volume)
                dunstify -r "$notification_id" "Volume Control" "$current_volume"
            fi
            ;;
        h)
            echo "A script to manage volume up, down and mute"
            echo "Usage: $(basename "$0") [ARGUMENT]"
            echo ""
            printf "%-30s %s\n" " -u" "Volume up"
            printf "%-30s %s\n" " -d" "Volume down"
            printf "%-30s %s\n" " -m" "Toggle mute"
            ;;
        *)
            echo "Please see $(basename "$0") -h for help"
            exit 1
            ;;
    esac
    exit 0
done

# If no args, show current volume or muted status
current_volume=$(get_current_volume)
mute_status=$(get_mute_status)

if [ "$mute_status" = "yes" ]; then
    echo "$volume_icon Muted"
else
    echo "$volume_icon $current_volume"
fi
