#!/bin/bash

# Set in Percentage when you get a notification when the battery is low
WARNING_PERCENT=31

# Set in Percentage when you get a notification and sound when the battery is low
HIBERNATE_PERCENT=16

# Set sound and notification time (in seconds)
PRE_HIBERNATE=10

# Set the countdown time before hibernation (in seconds)
HIBERNATE_WAIT=120

while true; do
    # Check if a battery is available
    BATTERY_DIR=$(ls /sys/class/power_supply/ | grep BAT || echo "")
    if [[ -z $BATTERY_DIR ]]; then
        echo "No battery detected. Exiting."
        exit 0
    fi

    STATUS=$(cat /sys/class/power_supply/$BATTERY_DIR/status)
    CAPACITY=$(cat /sys/class/power_supply/$BATTERY_DIR/capacity)

    # Skip checks if the charger is connected
    if [[ $STATUS == "Charging" ]]; then
        sleep 60  # Check again in 60 seconds
        continue
    fi

    # Hibernation condition
    if [[ $CAPACITY -lt $HIBERNATE_PERCENT ]] && [[ $STATUS != "Charging" ]]; then
        # Countdown with periodic status checks
        for ((i = $HIBERNATE_WAIT; i > 0; i--)); do
            STATUS=$(cat /sys/class/power_supply/$BATTERY_DIR/status)
            if [[ $STATUS == "Charging" ]]; then
                break
            fi

            # Play sound and send notification every 10 seconds
            if (( i % $PRE_HIBERNATE == 0 )); then
                mpv --no-video /home/chris/Downloads/error-83494.mp3 &
                dunstify -u critical -r 55452 "Battery is at $CAPACITY%" \
                    "System about to Hibernate in $i seconds! Please Charge the Battery."
            fi

            sleep 1
        done

        # If the loop wasn't interrupted by a charger connection, proceed to hibernate
        if [[ $STATUS != "Charging" ]]; then
            mpv --no-video /home/chris/Downloads/machine-error-by-prettysleepy-art-12669.mp3
            dunstify -u critical -r 55452 "Battery is at $CAPACITY%" "System is Hibernating Now!"
            sleep 2
            systemctl hibernate
        fi
    elif [[ $CAPACITY -lt $WARNING_PERCENT ]] && [[ $STATUS != "Charging" ]]; then
        dunstify -r 55452 "Battery is at $CAPACITY%" "Please Charge the Battery"
        sleep 10
    fi

    sleep 1  # Shorter delay for quicker responsiveness
done
