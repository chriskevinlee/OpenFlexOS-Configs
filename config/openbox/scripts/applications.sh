#!/bin/bash

#launcher=rofi
launcher=dmenu

if [ $launcher = rofi ]; then
	rofi rofi -config /home/$USER/.config/openbox/rofi/config.rasi -show drun -display-drun "Apps "

fi

if [ $launcher = dmenu ]; then

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
	app=$(printf '%s\n' "${!app_map[@]}" | sort -u | dmenu -i -p "Launch Application")

	# Launch the selected application if it exists in the map
	if [ -n "$app" ] && [ -n "${app_map[$app]}" ]; then
	  # Get the Exec command, remove %U, %u, %F, %f, etc.
	  exec_command=$(grep -m 1 "^Exec=" "${app_map[$app]}" | cut -d'=' -f2 | sed 's/ *%[UuFfNn] *//g')
	  sh -c "$exec_command &"
	fi

fi
