#!/bin/bash
# Requires dunst package(notify-send) for notifcations

# 5Minutes=300	10Minutes=600	15Minutes=900	
# 20Minutes=1200 25Minutes=1500 30Minutes=1800


# Use yes to activate or no to deactivate
active=no

# Directory path to Wallpapers, maybe to add * at the end of a path
path=/home/chris/.config/nitrogen/wallpapers/*

# Set the amount in seconds
time=3

# This allows for the user to edit the file and for the script to rerun
script_dir=$(dirname $BASH_SOURCE)
script_file=$(basename $BASH_SOURCE)
# This makes sure only a number is entered
num='^[0-9]+$'

# This checks to make sure the user have entered yes or no, if anything else is
# entered a noifcation will be displaced every 15 seconds will it corrected.
# See time variable above
while [[ $active != yes ]] && [[ $active != no ]]; do
	notify-send -u critical -t 10000 "Failed to apply feh wallpaper" "Error: Please Enter yes or no in "$script_dir"/"$script_file""
	sleep 15
	exec "$script_dir"/"$script_file"
done

# Checks to see if the variable is empty, if path variable is invaild see while [[ $active = yes ]];do
while [[ -z $path ]]; do
	notify-send -u critical -t 10000 "Failed to apply feh wallpaper" "Error: Please Enter a vaild path to wallpapers in "$script_dir"/"$script_file""
	sleep 15
	exec "$script_dir"/"$script_file"
done

# This checks to make sure the user have entered a number, if anything else is
# entered a noifcation will be displaced every 15 seconds will it corrected
# See num variable above
while ! [[ $time =~ $num ]]; do
	notify-send -u critical -t 10000 "Failed to apply feh wallpaper" "Error: Please Enter a number in "$script_dir"/"$script_file""
	sleep 15
	exec "$script_dir"/"$script_file"
done

# If active is set no then its will echo NOT RUNNING but send it to /dev/null
while [[ $active = no ]]; do
	echo "NOT RUNNING" > /dev/null
	sleep 3
	exec "$script_dir"/"$script_file"
done

# If active is set to yes then will wll randomly apply a wallpaper every X account
# of Seconds. See time variable above
while [[ $active = yes ]];do
	feh --bg-fill --randomize $path 2>/tmp/wallpaper_error || notify-send -u critical -t 10000 "$(cat /tmp/wallpaper_error)"
	sleep $time
	exec "$script_dir"/"$script_file"

done
