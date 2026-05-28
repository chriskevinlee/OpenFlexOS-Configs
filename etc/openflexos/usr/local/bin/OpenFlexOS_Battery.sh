#!/bin/bash

# ================================================================
# Description: This script is used for openbox to display the charging status
# Author: Chris Lee
# Dependencies:
# Usage:
# Notes:
# ================================================================

# Check if BAT1 exists
if [ -d "/sys/class/power_supply/BAT1" ]; then
    # Get battery status and percentage
    STATUS=$(cat /sys/class/power_supply/BAT1/status)
    CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity)

    # Set icons for charging, discharging, and full
    if [ "$STATUS" == "Charging" ]; then
        ICON= echo "󰂆"
    elif [ "$CAPACITY" -ge 99 ]; then
        ICON= echo "󱟢"
    else
        ICON= echo ""
    fi

    # Output the result
    echo "$ICON $CAPACITY%"
else
    # No battery found, display nothing
    echo ""
fi
