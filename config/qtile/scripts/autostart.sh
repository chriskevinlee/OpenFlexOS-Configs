#!/bin/bash
xrandr -s 1920x1080 &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

flameshot &

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


source /home/$USER/.config/qtile/scripts/sounds.sh
if [[ ! -z "$login_sound" && $active_sounds = yes ]]; then
    mpv --no-video "${sounds_dir}${login_sound}" &
fi

xscreensaver -no-splash &
conky -c ~/.config/qtile/conky/conky.conf &

picom &
