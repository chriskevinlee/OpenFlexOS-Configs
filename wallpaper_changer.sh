#!/bin/bash

# Launch sxiv in the background
sxiv -t -r /home/chris/.config/wallpapers &

# Wait for a moment to ensure the window is created
sleep 1

# Find the window ID of the sxiv window using wmctrl
window_id=$(wmctrl -l | grep "sxiv" | awk '{print $1}')

# Check if window_id is found
if [ -z "$window_id" ]; then
    echo "Window ID not found. Ensure sxiv is running."
    exit 1
fi

# Set the window title
wmctrl -i -r $window_id -T "Select a Wallpaper...(ctrl+x+w)"
