#!/bin/bash

# ================================================================
# Description: A Script that uses rofi or dmenu for an application launcher by commenting or uncommenting the appropriate variable
# Author: Chris Lee, ChatGPT
# Dependencies: rofi, dmenu
# Usage: ./applications.sh
# Notes:
# ================================================================

applications_icon=""
echo $applications_icon

while getopts "drh" main 2>/dev/null; do
  case "${main}" in
    d )
      # Define directories containing .desktop files
      app_dirs=("/usr/share/applications" "$HOME/.local/share/applications")

      # Create an associative array to store names and paths
      declare -A app_map

      # Populate the associative array with application names and their .desktop paths
      for dir in "${app_dirs[@]}"; do
        if [ -d "$dir" ]; then
          while IFS= read -r desktop; do
            # Extract the application name
            name=$(grep -m 1 "^Name=" "$desktop" | cut -d'=' -f2)

            # Store the desktop path in the associative array
            app_map["$name"]="$desktop"
          done < <(find "$dir" -name "*.desktop")
        fi
      done

      # Show only the application names in dmenu
      app=$(printf '%s\n' "${!app_map[@]}" | sort -u | dmenu -y 20 -x 20 -z 1880 -i -p "Launch Application")

      # Launch the selected application if it exists in the map
      if [ -n "$app" ] && [ -n "${app_map[$app]}" ]; then
        # Get the Exec command, remove %U, %u, %F, %f, etc.
        exec_command=$(grep -m 1 "^Exec=" "${app_map[$app]}" | cut -d'=' -f2 | sed 's/ *%[UuFfNn] *//g')
        sh -c "$exec_command &"
      fi
      ;;
    r )
        rofi -config /home/$USER/.config/openbox/rofi/config.rasi -show drun -display-drun "Apps "
        exit 0
      ;;
    h )
      echo "A basic Application Launcher"
      echo "Usage: $(basename "$0") [ARGUMENT]"
      echo ""

      printf "%-30s %s\n" " -r" "Use Rofi to Launch Applications"
      printf "%-30s %s\n" " -d" "Use Dmenu to Launch Applications"
      ;;
    * )
        echo "Please see $(basename "$0") -h for help"
        ;;
  esac
done
