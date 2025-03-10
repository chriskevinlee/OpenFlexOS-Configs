#!/bin/bash

# ================================================================
# Description: A Script that uses rofi or dmenu for an application launcher by commenting or uncommenting the appropriate variable
# Author: Chris Lee, ChatGPT
# Dependencies: rofi, dmenu
# Usage: ./applications.sh
# Notes:
# ================================================================

# Uncomment the desired launcher
#launcher=rofi
launcher=dmenu

if [ "$launcher" = "rofi" ]; then
    rofi -config /home/$USER/.config/qtile/rofi/config.rasi -show drun -display-drun "Apps "
    exit 0
fi

if [ "$launcher" = "dmenu" ]; then
    # Define directories containing .desktop files
    app_dirs=("/usr/share/applications" "$HOME/.local/share/applications")

    # Create an associative array to store names and paths
    declare -A app_map

    # Populate the associative array with application names and their .desktop paths
    for dir in "${app_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r desktop; do
                # Extract the application name from the Desktop Entry section
                name=$(grep -A1 '\[Desktop Entry\]' "$desktop" | grep -m1 "^Name=" | cut -d'=' -f2 | tr -d '\r')

                # Ensure the name is not empty before adding it to the array
                if [[ -n "$name" ]]; then
                    app_map["$name"]="$desktop"
                fi
            done < <(find "$dir" -name "*.desktop")
        fi
    done

    # Show only the application names in dmenu
    app=$(printf '%s\n' "${!app_map[@]}" | sort -u | dmenu -i -p "Launch Application")

    # Launch the selected application if it exists in the map
    if [[ -n "$app" && -n "${app_map[$app]}" ]]; then
        # Get the Exec command, remove %U, %u, %F, %f, etc.
        exec_command=$(grep -m 1 "^Exec=" "${app_map[$app]}" | cut -d'=' -f2 | sed 's/ *%[UuFfNn] *//g')

        # Run the application
        if [[ -n "$exec_command" ]]; then
            sh -c "$exec_command &"
        fi
    fi
fi
