#!/bin/bash

# ================================================================
# Description: This is a startup script for qtile window manager
# Author: Chris Lee
# Dependencies:
# Usage:
# Notes:
# ================================================================

# Create a config file if it dont exists, saves the wallpaper the user selected and applies the wallpaper at login
CONFIG_FILE="/home/$USER/.config/$DESKTOP_SESSION/.selected_wallpaper"
# Check if the configuration file exists and is not empty
if [ -s "$CONFIG_FILE" ]; then
  # Read the saved wallpaper path
  SELECTED_WALLPAPER=$(cat "$CONFIG_FILE")

  # Apply the wallpaper using feh
  feh --bg-scale "$SELECTED_WALLPAPER" &
elif [ ! -f "$CONFIG_FILE" ]; then
        echo /home/$USER/.config/wallpapers/default/6xVGpvY-arch-linux-wallpaper.png > /home/$USER/.config/$DESKTOP_SESSION/.selected_wallpaper
        SELECTED_WALLPAPER=$(cat "$CONFIG_FILE")
        feh --bg-scale "$SELECTED_WALLPAPER" &
fi


# Loads the login sound and plays a login sound at login
source /home/$USER/.config/qtile/scripts/sounds.sh
if [[ ! -z "$login_sound" && $active_sounds = yes ]]; then
    mpv --no-video "${sounds_dir}${login_sound}" &
fi


# Loads a authentication agent to allow applications that need sudo/authentication
if command -v /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1; then
        /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
elif command -v /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1; then
        /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi


# Start Applicatiosn at login
flameshot &
xscreensaver -no-splash &
conky -c ~/.config/qtile/conky/conky.conf &
picom &


# Start Scripts at Login
/home/$USER/.config/qtile/scripts/Battery_Hibernate.sh &
#/usr/local/bin/wallpaper_changer.sh random 30m
