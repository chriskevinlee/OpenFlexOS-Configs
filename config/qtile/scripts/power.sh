#!/bin/bash

#launcher="rofi -config /home/$USER/.config/qtile/rofi/config.rasi -dmenu"
launcher="dmenu -i"

# Use yes or no to enable or disable countdown
enable_countdown=yes

# Set the number of seconds before the action happens
countdown=10

chosen=$(printf " Lock\n󰍃 Logout\n󰜉 Reboot\n Suspend\n Hibernate\n⏻ PowerOff\n" | $launcher -p "Power")

countdown_timer() {
        if [[ "$enable_countdown" != "yes" ]]; then
        return 0  # Skip countdown if disabled
        fi
    # Create a zenity countdown window with a "Cancel" button
    (
    for ((i = countdown; i > 0; i--)); do
        echo "# $chosen in: $i"
        sleep 1
    done

    ) | zenity --progress --title="$chosen" --text="$chosen will occur in 10 seconds" --percentage=0 --auto-close --width=300

    # Check if zenity was canceled by inspecting the exit status
    if [ $? -eq 1 ]; then
        zenity --info --text="$chosen canceled." --title="$chosen"
        return 1
    fi
    return 0
}

case "$chosen" in
    " Lock")
        yes_no=$(printf " no\n yes" | $launcher -p "Would You Like to $chosen")
        case $yes_no in
            [no]* ) exit;;
            [yes]* )
                if countdown_timer; then
                    if [[ "$active_sounds" = yes && ! -z "$lock_sound" && -f "${sounds_dir}${lock_sound}" ]]; then
                        mpv --no-video "${sounds_dir}${lock_sound}" && xscreensaver-command -lock
                    else
                        xscreensaver-command -lock
                    fi
                else
                    exit
                fi
                ;;
        esac
        ;;
    "󰍃 Logout")
        yes_no=$(printf " no\n yes" | $launcher -p "Would You Like to $chosen")
        case $yes_no in
            [no]* ) exit;;
            [yes]* )
                if countdown_timer; then
                    if [[ "$active_sounds" = yes && ! -z "$logout_sound" && -f "${sounds_dir}${logout_sound}" ]]; then
                        mpv --no-video "${sounds_dir}${logout_sound}" && qtile cmd-obj -o cmd -f shutdown
                    else
                        qtile cmd-obj -o cmd -f shutdown
                    fi
                else
                    exit
                fi
                ;;
        esac
        ;;
    "󰜉 Reboot")
        yes_no=$(printf " no\n yes" | $launcher -p "Would You Like to $chosen")
        case $yes_no in
            [no]* ) exit;;
            [yes]* )
                if countdown_timer; then
                    if [[ "$active_sounds" = yes && ! -z "$reboot_sound" && -f "${sounds_dir}${reboot_sound}" ]]; then
                        mpv --no-video "${sounds_dir}${reboot_sound}" && reboot
                    else
                        reboot
                    fi
                else
                    exit
                fi
                ;;
        esac
        ;;
    " Suspend")
        yes_no=$(printf " no\n yes" | $launcher -p "Would You Like to $chosen")
        case $yes_no in
            [no]* ) exit;;
            [yes]* )
                if countdown_timer; then
                    if [[ "$active_sounds" = yes && ! -z "$suspend_sound" && -f "${sounds_dir}${suspend_sound}" ]]; then
                        mpv --no-video "${sounds_dir}${suspend_sound}" && systemctl suspend
                    else
                        systemctl suspend
                    fi
                else
                    exit
                fi
                ;;
        esac
        ;;
    " Hibernate")
        yes_no=$(printf " no\n yes" | $launcher -p "Would You Like to $chosen")
        case $yes_no in
            [no]* ) exit;;
            [yes]* )
                if countdown_timer; then
                    if [[ "$active_sounds" = yes && ! -z "$hibernate_sound" && -f "${sounds_dir}${hibernate_sound}" ]]; then
                        mpv --no-video "${sounds_dir}${hibernate_sound}" && systemctl hibernate
                    else
                        systemctl hibernate
                    fi
                else
                    exit
                fi
                ;;
        esac
        ;;
    "⏻ PowerOff")
        yes_no=$(printf " no\n yes" | $launcher -p "Would You Like to $chosen")
        case $yes_no in
            [no]* ) exit;;
            [yes]* )
                if countdown_timer; then
                    if [[ "$active_sounds" = yes && ! -z "$poweroff_sound" && -f "${sounds_dir}${poweroff_sound}" ]]; then
                        mpv --no-video "${sounds_dir}${poweroff_sound}" && poweroff
                    else
                        poweroff
                    fi
                else
                    exit
                fi
                ;;
        esac
        ;;
esac
