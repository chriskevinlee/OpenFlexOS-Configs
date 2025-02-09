#!/bin/bash

# ================================================================
# Description: This script ask the user to set a user selected wallpaper, a random wallpaper or to have a random wallpaper set at a specific interval set by the user
# Author: Chris Lee, ChatGPT
# Dependencies: sxiv, zenity, wmctrl, feh
# Usage: ./wallpaper_changer.sh or ./wallpaper_changer.sh select or ./wallpaper_changer.sh random or ./wallpaper_changer.sh stop or ./wallpaper_changer.sh random [30s,10m] seconds/minutes
# Notes:
# ================================================================

# Wallpaper directories (add as many directories as you want here)
WALLPAPER_DIRS=("$HOME/.config/wallpapers")

# Path to store the process ID of the wallpaper timer
PID_FILE="/tmp/wallpaper_timer.pid"

# Function to load saved wallpaper directories (if any)
load_wallpaper_dirs() {
    if [ -f "$HOME/.wallpaper_dirs" ]; then
        mapfile -t WALLPAPER_DIRS < "$HOME/.wallpaper_dirs"
    fi
}

# Function to save wallpaper directories
save_wallpaper_dirs() {
    echo "${WALLPAPER_DIRS[@]}" > "$HOME/.wallpaper_dirs"
}

# Function to start the random wallpaper changer with a given interval
start_random_wallpaper() {
    local INTERVAL_INPUT="$1"

    if [[ "$INTERVAL_INPUT" =~ ^([0-9]+)([smSM])$ ]]; then
        VALUE="${BASH_REMATCH[1]}"
        UNIT="${BASH_REMATCH[2]}"

        if [[ "$UNIT" =~ [mM] ]]; then
            INTERVAL=$((VALUE * 60))  # Convert minutes to seconds
        else
            INTERVAL=$VALUE  # Use seconds directly
        fi
    else
        echo "Invalid format. Use a number followed by 's' (seconds) or 'm' (minutes)."
        exit 1
    fi

    stop_random_wallpaper

    # Start the wallpaper changer in a background loop
    (
        while true; do
            feh --bg-fill --randomize $(find "${WALLPAPER_DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
            sleep "$INTERVAL"
        done
    ) > /dev/null 2>&1 &  # Redirect output to avoid clutter

    echo $! > "$PID_FILE"
    echo "Wallpaper timer started with a $INTERVAL_INPUT interval!"
}

# Function to stop the random wallpaper timer
stop_random_wallpaper() {
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm "$PID_FILE"
        echo "Wallpaper timer stopped!"
    else
        echo "No wallpaper timer is running."
    fi
}

# Function to select a wallpaper using sxiv
select_wallpaper() {
    sxiv -t -r "${WALLPAPER_DIRS[@]}" &
    sleep 1
    window_id=$(wmctrl -l | grep "sxiv" | awk '{print $1}')
    if [ -z "$window_id" ]; then
        zenity --error --text="sxiv window not found!"
        exit 1
    fi
    wmctrl -i -r "$window_id" -T "Select a Wallpaper...(ctrl+x+w)"
}

# Function to manually add a new wallpaper directory
# You can add directories by modifying the array below
add_wallpaper_directory() {
    # Example: Add a new directory to the list (just modify the array in the script)
    WALLPAPER_DIRS+=("/path/to/new/directory")
    echo "New directory added: /path/to/new/directory"
    save_wallpaper_dirs
}

# Load saved wallpaper directories at the start
load_wallpaper_dirs

# Command-line options
case "$1" in
    "random")
        if [[ "$2" == "stop" ]]; then
            stop_random_wallpaper
        elif [[ -n "$2" ]]; then
            start_random_wallpaper "$2"
        else
            feh --bg-fill --randomize $(find "${WALLPAPER_DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
        fi
        exit 0
        ;;
    "select")
        select_wallpaper
        exit 0
        ;;
esac

# GUI Menu
MENU_OPTION=$( [[ -f "$PID_FILE" && $(pgrep -F "$PID_FILE") ]] && echo "Stop Random Wallpaper" || echo "Start Random Wallpaper" )

CHOICE=$(zenity --list --title="Wallpaper Manager" --column="Options" \
    "Select Wallpaper" "Random Wallpaper" "$MENU_OPTION")

case "$CHOICE" in
    "Select Wallpaper") select_wallpaper ;;
    "Random Wallpaper") feh --bg-fill --randomize $(find "${WALLPAPER_DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \)) ;;
    "Start Random Wallpaper")
        INTERVAL=$(zenity --list --title="Set Wallpaper Interval" --column="Options" \
            "5m" "10m" "20m" "30m" "60m" "Custom" --text="Choose a time interval:")
        [[ "$INTERVAL" == "Custom" ]] && INTERVAL=$(zenity --entry --title="Custom Interval" --text="Enter time (e.g., 30s, 10m):")
        [[ ! "$INTERVAL" =~ ^[0-9]+[smSM]$ ]] && { zenity --error --text="Invalid input."; exit 1; }
        start_random_wallpaper "$INTERVAL"
        exec "$0"
        ;;
    "Stop Random Wallpaper")
        stop_random_wallpaper
        exec "$0"
        ;;
    *) echo "No selection made." ;;
esac
