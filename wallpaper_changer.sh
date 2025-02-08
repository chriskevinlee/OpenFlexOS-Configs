#!/bin/bash

# ================================================================
# Description: This script ask the user to set a user selected wallpaper, a random wallpaper or to have a random wallpaper set at a specific interval set by the user
# Author: Chris Lee, ChatGPT
# Dependencies: sxiv, zenity, wmctrl, feh
# Usage: ./wallpaper_changer.sh
# Notes:
# ================================================================

WALLPAPER_DIR="$HOME/.config/wallpapers"
PID_FILE="/tmp/wallpaper_timer.pid"

start_random_wallpaper() {
    local INTERVAL_INPUT="$1"

    # Validate input format (must be a number followed by 's' or 'm')
    if [[ "$INTERVAL_INPUT" =~ ^([0-9]+)([smSM])$ ]]; then
        VALUE="${BASH_REMATCH[1]}"
        UNIT="${BASH_REMATCH[2]}"

        # Convert to seconds
        if [[ "$UNIT" == "s" || "$UNIT" == "S" ]]; then
            INTERVAL=$VALUE
        elif [[ "$UNIT" == "m" || "$UNIT" == "M" ]]; then
            INTERVAL=$((VALUE * 60))
        else
            echo "Invalid unit. Use 's' for seconds or 'm' for minutes."
            exit 1
        fi
    else
        echo "Invalid format. Use a number followed by 's' (seconds) or 'm' (minutes)."
        exit 1
    fi

    # Kill any existing wallpaper changer
    stop_random_wallpaper

    # Start the wallpaper changer in the background
    ( while true; do
        feh --bg-fill --randomize $(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
        sleep "$INTERVAL"
    done ) &

    echo $! > "$PID_FILE"
    echo "Wallpaper timer started with a $INTERVAL_INPUT interval!"
}

stop_random_wallpaper() {
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")"
        rm "$PID_FILE"
        echo "Wallpaper timer stopped!"
    else
        echo "No wallpaper timer is running."
    fi
}

# Handle command-line arguments
if [[ "$1" == "random" && -n "$2" ]]; then
    start_random_wallpaper "$2"
    exit 0
elif [[ "$1" == "stop" ]]; then
    stop_random_wallpaper
    exit 0
fi

# Check if the timer is running
if [[ -f "$PID_FILE" ]] && pgrep -F "$PID_FILE" > /dev/null; then
    MENU_OPTION="Stop Random Wallpaper"
else
    MENU_OPTION="Start Random Wallpaper"
fi

CHOICE=$(zenity --list --title="Wallpaper Manager" --column="Options" \
    "Select Wallpaper" "Random Wallpaper" "$MENU_OPTION")

case "$CHOICE" in
    "Select Wallpaper")
        sxiv -t -r "$WALLPAPER_DIR" &
        sleep 1
        window_id=$(wmctrl -l | grep "sxiv" | awk '{print $1}')
        if [ -z "$window_id" ]; then
            zenity --error --text="sxiv window not found!"
            exit 1
        fi
        wmctrl -i -r "$window_id" -T "Select a Wallpaper...(ctrl+x+w)"
        ;;

    "Random Wallpaper")
        feh --bg-fill --randomize $(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
        ;;

    "Start Random Wallpaper")
        INTERVAL_MIN=$(zenity --list --title="Set Wallpaper Interval" --column="Options" \
            "5 minutes" "10 minutes" "20 minutes" "30 minutes" "60 minutes" "Custom" \
            --text="Choose a time interval:")

        case "$INTERVAL_MIN" in
            "5 minutes") INTERVAL="5m" ;;
            "10 minutes") INTERVAL="10m" ;;
            "20 minutes") INTERVAL="20m" ;;
            "30 minutes") INTERVAL="30m" ;;
            "60 minutes") INTERVAL="60m" ;;
            "Custom")
                INTERVAL=$(zenity --entry --title="Custom Interval" --text="Enter time (e.g., 30s for seconds, 10m for minutes):")
                if ! [[ "$INTERVAL" =~ ^[0-9]+[smSM]$ ]]; then
                    zenity --error --text="Invalid input. Use a number followed by 's' (seconds) or 'm' (minutes)."
                    exit 1
                fi
                ;;
            *)
                zenity --error --text="Invalid selection."
                exit 1
                ;;
        esac

        start_random_wallpaper "$INTERVAL"
        exec "$0" # Restart script to update menu option
        ;;

    "Stop Random Wallpaper")
        stop_random_wallpaper
        exec "$0" # Restart script to update menu option
        ;;

    *)
        echo "No selection made."
        ;;
esac
