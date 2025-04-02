#!/bin/bash

STATE_FILE="$HOME/.config/nerd-dictation-state"

# Read the last state
if [[ -f "$STATE_FILE" ]]; then
    LAST_STATE=$(cat "$STATE_FILE")
else
    LAST_STATE="!!Left click to start dictation!!"  # Default to "Left click to start dictation"
fi

case $1 in
    start )
        nd begin --vosk-model-dir /opt/nerd-dictation/model &
        echo "Right-Click: Stop" > "$STATE_FILE"  # Save state
        ;;
    stop )
        nd end &
        echo "Left-Click: Dictate" > "$STATE_FILE"  # Save state
        ;;
    * )
        echo "$LAST_STATE"
        ;;
esac
