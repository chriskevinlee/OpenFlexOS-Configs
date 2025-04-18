#!/bin/bash

# ================================================================
# Description: This script uses rofi or dmenu to create a ssh menu to allow quick connections to a ssh server by adding a name and ssh comment to a text file
# Author: Chris Lee, ChatGPT
# Dependencies: rofi, dmenu, ssh
# Usage: Add to a panel or bar or run./ssh.sh
# Notes:
# ================================================================

# Define the SSH directory and server list file paths
# servers.txt formatting: Server Name | ssh user@ip_add
SSH_DIR="$HOME/.ssh"
SERVER_LIST="$SSH_DIR/servers.txt"

#launcher="rofi -config /home/$USER/.config/qtile/rofi/config.rasi -dmenu"
launcher="dmenu -y 20 -x 20 -z 1880 -i"

# Check if the SSH directory exists; if not, create it silently
if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -p "$SSH_DIR"
fi

# Check if the server list file exists; if not, create it silently
if [[ ! -f "$SERVER_LIST" ]]; then
    echo "# Add a name for a Server and the full SSH Command separated by a pipe |" >> "$SERVER_LIST"
    echo "#" >> "$SERVER_LIST"
    echo "# Server Name           # Pipe |                # Full SSH Command" >> "$SERVER_LIST"
fi

# Display the server names using rofi, ignoring commented lines
SELECTED_NAME=$(grep -v '^#' "$SERVER_LIST" | awk -F'|' '{print $1}' | $launcher -p "Please select a SSH Server")

# Trim any extra spaces from the selected name
SELECTED_NAME=$(echo "$SELECTED_NAME" | xargs)

# Find the corresponding connection string
if [[ -n "$SELECTED_NAME" ]]; then
    CONNECTION_STRING=$(grep -i "^$SELECTED_NAME[[:space:]]*|" "$SERVER_LIST" | awk -F'|' '{print $2}' | xargs)

    if [[ -n "$CONNECTION_STRING" ]]; then
        alacritty -e bash -c "$CONNECTION_STRING; echo 'Press any key to exit'; read -n 1"
    else
        echo "No connection string found for"
    fi
fi
