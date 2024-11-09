#!/bin/bash

# Check if BAT1 exists
if [ -d "/sys/class/power_supply/BAT1" ]; then
    # Get battery status and percentage
    STATUS=$(cat /sys/class/power_supply/BAT1/status)
    CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity)

    # Set icons for charging, discharging, and full
    if [ "$STATUS" == "Charging" ]; then
        ICON= echo "/home/chris/.config/openbox/png_icons/battery-charging.png"
    elif [ "$CAPACITY" -ge 99 ]; then
        ICON= echo "/home/chris/.config/openbox/png_icons/battery-full.png"
    else
        ICON= echo "/home/chris/.config/openbox/png_icons/battery-discharging.png"
    fi

    # Output the result
    echo "$ICON $CAPACITY%"
else
    # No battery found, display nothing
    echo ""
fi
