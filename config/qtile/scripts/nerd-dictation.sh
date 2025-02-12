#!/bin/bash

STATE_FILE="$HOME/.config/nerd-dictation-state"

# Read the last state
if [[ -f "$STATE_FILE" ]]; then
    LAST_STATE=$(cat "$STATE_FILE")
else
    LAST_STATE="stop"  # Default to "stop"
fi

case $1 in
    start )
        nd begin &
        echo "stop" > "$STATE_FILE"  # Save state
        ;;
    stop )
        nd end &
        echo "start" > "$STATE_FILE"  # Save state
        ;;
    * )
        # If no argument is given, print the last saved state
        echo "$LAST_STATE"
        ;;
esac
