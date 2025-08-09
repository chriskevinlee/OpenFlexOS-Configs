#!/bin/bash

power_icon="⏻"
echo $power_icon

power(){
    source /home/$USER/.config/openbox/scripts/OpenFlexOS_Sounds.sh

    # Use yes or no to enable or disable countdown
    enable_countdown=yes

    # Set the number of seconds before the action happens
    countdown=10

    chosen=$(printf " Lock\n󰍃 Logout\n󰜉 Reboot\n Suspend\n Hibernate\n⏻ PowerOff\n" | $launcher -p "Power")

    countdown_timer() {
        if [[ "$enable_countdown" != "yes" ]]; then
            return 0
        fi

        start=$(date +%s)
        end=$(( start + countdown ))

        (
        while [ $(date +%s) -lt $end ]; do
            remaining=$(( end - $(date +%s) ))
            percent=$(( 100 * (countdown - remaining) / countdown ))
            echo "$percent"
            echo "# $chosen in: $remaining"
            sleep 0.2
        done
        echo "100"
        ) | zenity --progress \
            --title="$chosen" \
            --text="$chosen will occur in $countdown seconds" \
            --percentage=0 \
            --auto-close --width=300

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
                            mpv --no-video "${sounds_dir}${logout_sound}" && openbox --exit
                        else
                            openbox --exit
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
}

    while getopts "drh" main 2>/dev/null; do
        case "${main}" in
            d)
                launcher="dmenu -y 20 -x 20 -z 1880 -i"
                power
                ;;
            r)
                launcher="rofi -config /home/$USER/.config/openbox/rofi/config.rasi -dmenu"
                power
                ;;
            h)
              echo "A script to manage power options such as lock,logout,reboot,poweroff, suspend and hibernate using either rofi or dmenu"
              echo "Usage: $(basename "$0") [ARGUMENT]"
              echo ""

              printf "%-30s %s\n" " -r" "Use Rofi for power menu"
              printf "%-30s %s\n" " -d" "Use Dmenu for power menu"
                ;;
            *)
                echo "Please See $(basename "$0") -h for help"
                ;;
        esac
        exit 0
    done
