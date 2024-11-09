#!/bin/bash

# Paths
state_file="/tmp/prev_network_state"

# Current network status
check_wifi="$(nmcli device status | grep -w wifi | grep -w connected | awk '{ print $2 }')"
check_ethernet="$(nmcli device status | grep -w ethernet | grep -w connected | awk '{ print $2 }')"
check_ethernet_wifi="$(nmcli device status | grep -e ethernet -e wifi | grep -w connected | awk '{ print $2 }' | sed 'N;s/\n/ /')"

connected_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

# Determine current state and icon path
if [[ $check_ethernet_wifi = "ethernet wifi" ]]; then
    current_state="ethernet_wifi"
    icon_path="/home/chris/.config/openbox/png_icons/personal-computer.png"
elif [[ $check_wifi = "wifi" ]]; then
    current_state="wifi"
    icon_path="/home/chris/.config/openbox/png_icons/wifi.png"
elif [[ $check_ethernet = "ethernet" ]]; then
    current_state="ethernet"
    icon_path="/home/chris/.config/openbox/png_icons/computer.png"
else
    current_state="disconnected"
    icon_path="/home/chris/.config/openbox/png_icons/cancel.png"
fi

# Check previous state
if [[ -f $state_file ]]; then
    previous_state=$(cat $state_file)
else
    previous_state=""
fi

# Notify if state has changed
if [[ $current_state != $previous_state ]]; then
    case $current_state in
        "disconnected")
            dunstify -u critical "Disconnected"
            ;;
        "wifi")
            dunstify -u normal "Connected to Wi-Fi"
            ;;
        "ethernet")
            dunstify -u normal "Connected to Ethernet"
            ;;
        "ethernet_wifi")
            dunstify -u normal "Connected to Ethernet and Wi-Fi"
            ;;
    esac
fi

# Update the state file
echo "$current_state" > $state_file

# Output the current icon path and SSID for the widget
echo "$icon_path"
echo " $connected_ssid"
