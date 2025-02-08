#!/bin/bash

# ================================================================
# Description: This script ask the user to set a user selected wallpaper, a random wallpaper or to have a random wallpaper set at a specific interval set by the user
# Author: Chris Lee, ChatGPT
# Dependencies: sxiv, zenity, wmctrl, feh
# Usage:
# Notes:
# ================================================================

# Check if the timer is running
if [[ -f /tmp/wallpaper_timer.pid ]] && pgrep -F /tmp/wallpaper_timer.pid > /dev/null; then
    MENU_OPTION="Stop Random Wallpaper"
else
    MENU_OPTION="Start Random Wallpaper"
fi

CHOICE=$(zenity --list --title="Wallpaper Manager" --column="Options" \
    "Select Wallpaper" "Random Wallpaper" "$MENU_OPTION")

case "$CHOICE" in
    "Select Wallpaper")
        sxiv -t -r /home/chris/.config/wallpapers &
        sleep 1
        window_id=$(wmctrl -l | grep "sxiv" | awk '{print $1}')
        if [ -z "$window_id" ]; then
            zenity --error --text="sxiv window not found!"
            exit 1
        fi
        wmctrl -i -r $window_id -T "Select a Wallpaper...(ctrl+x+w)"
        ;;

    "Random Wallpaper")
        feh --bg-fill --randomize $(find $HOME/.config/wallpapers/ -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
        ;;

    "Start Random Wallpaper")
        # Ask the user for an interval in seconds
        INTERVAL=$(zenity --entry --title="Set Wallpaper Timer" \
            --text="Enter time interval in seconds (default: 30s):" --entry-text "30")

        # Validate input (check if it's a number greater than 0)
        if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [[ "$INTERVAL" -le 0 ]]; then
            INTERVAL=30  # Fallback to default if invalid input
        fi

        # Run the wallpaper changer in the background
        ( while true; do
            feh --bg-fill --randomize $(find $HOME/.config/wallpapers/ -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
            sleep "$INTERVAL"
        done ) &

        echo $! > /tmp/wallpaper_timer.pid
        zenity --info --text="Wallpaper timer started with an interval of $INTERVAL seconds!"
        exec "$0" # Restart script to update menu option
        ;;

    "Stop Random Wallpaper")
        if [[ -f /tmp/wallpaper_timer.pid ]]; then
            kill $(cat /tmp/wallpaper_timer.pid)
            rm /tmp/wallpaper_timer.pid
            zenity --info --text="Wallpaper timer stopped!"
        else
            zenity --info --text="No timer is running!"
        fi
        exec "$0" # Restart script to update menu option
        ;;

    *)
        echo "No selection made."
        ;;
esac
