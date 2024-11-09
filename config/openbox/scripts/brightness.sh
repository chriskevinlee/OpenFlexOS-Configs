#!/bin/bash

# Define step percentage
STEP=10%

# Check if there is any backlight directory
if [ -d /sys/class/backlight ] && [ "$(ls -A /sys/class/backlight)" ]; then
    # Get the first available backlight directory
    BACKLIGHT_DIR=$(ls /sys/class/backlight | head -n 1)

    # Adjust brightness based on argument
    case $1 in
        up)
            brightnessctl set $STEP+
            current_brightness=$(brightnessctl get)
            max_brightness=$(brightnessctl max)
            percentage=$(( 100 * current_brightness / max_brightness ))
            dunstify -r "48457" "Brightness Control" "$percentage"
            ;;
        down)
            brightnessctl set $STEP-
            current_brightness=$(brightnessctl get)
            max_brightness=$(brightnessctl max)
            percentage=$(( 100 * current_brightness / max_brightness ))
            dunstify -r "48457" "Brightness Control" "$percentage"
            ;;
    esac

    # Display the current brightness level
    current_brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$(( 100 * current_brightness / max_brightness ))
    echo "$percentage%"
fi
