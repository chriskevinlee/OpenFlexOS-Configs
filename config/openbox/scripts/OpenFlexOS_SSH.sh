#!/bin/bash

# ================================================================
# Description: This script uses rofi or dmenu to create a ssh menu to allow quick connections to a ssh server by adding a name and ssh comment to a text file
# Author: Chris Lee, ChatGPT
# Dependencies: rofi, dmenu, ssh
# Usage: Add to a panel or bar or run./ssh.sh
# Notes:
# ================================================================

ssh_icon="󰣀"
echo $ssh_icon

ssh_menu(){
    # Define the SSH directory and server list file paths
    # servers.txt formatting: Server Name | ssh user@ip_add
    SSH_DIR="$HOME/.ssh"
    SERVER_LIST="$SSH_DIR/servers.txt"

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
}

    while getopts "drh" main 2>/dev/null; do
        case "${main}" in
            d)
                launcher="dmenu -y 20 -x 20 -z 1880 -i"
                ssh_menu
                ;;
            r)
                launcher="rofi -config /home/$USER/.config/openbox/rofi/config.rasi -dmenu"
                ssh_menu
                ;;
            h)
              echo "A script to manage ssh connections, just add a ssh command to ~/config/servers.txt"
              echo "Usage: $(basename "$0") [ARGUMENT]"
              echo ""

              printf "%-30s %s\n" " -r" "Use Rofi to manage ssh connections"
              printf "%-30s %s\n" " -d" "Use Dmenu to manage ssh conections"
                ;;
            *)
                echo "Please See $0 -h for help"
                ;;
        esac
        exit 0
    done








