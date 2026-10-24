#!/bin/bash

# Screenshot mode: f = fullscreen, r = region, a = active
MODE="${1:-r}"

# Screenshot directory
DIR="$HOME/Pictures"
mkdir -p "$DIR"

# Choose screenshot type
case "$MODE" in
    f)
        TYPE="full"
        ;;
    r)
        TYPE="region"
        ;;
    a)
        TYPE="active"
        ;;
    *)
        notify-send -u critical "Ksnip" "Invalid screenshot mode"
        exit 1
        ;;
esac

# Generate filename with date and time, including seconds
FILE="$DIR/screenshot_${TYPE}_$(date +%Y%m%d_%H%M%S).png"

# Capture screenshot
ksnip "-$MODE" -p "$FILE"
STATUS=$?

# Notify only if the screenshot was saved
if [ "$STATUS" -eq 0 ] && [ -s "$FILE" ]; then
    notify-send -i camera-photo \
        "Screenshot Saved" \
        "$(basename "$FILE")"
elif [ "$STATUS" -ne 0 ]; then
    notify-send -u critical \
        "Screenshot Failed" \
        "Ksnip could not save the screenshot."
fi
