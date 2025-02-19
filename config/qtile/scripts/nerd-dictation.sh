#!/bin/bash

STATE_FILE="$HOME/.config/nerd-dictation-state"

# Read the last state
if [[ -f "$STATE_FILE" ]]; then
    LAST_STATE=$(cat "$STATE_FILE")
else
    LAST_STATE="Left-click: Dictate"  # Default to "Right-click: Stop"
fi

case $1 in
    start )
        nd begin &
        echo "Right-click: Stop" > "$STATE_FILE"  # Save state
        ;;
    stop )
        nd end &
        echo "Left-click: Dictate" > "$STATE_FILE"  # Save state
        ;;
    * )
        # If no argument is given, print the last saved state
        echo "$LAST_STATE"
        ;;
esac
