#!/bin/bash

# Paths
state_file="/tmp/prev_network_state"

# Force a Wi-Fi rescan
nmcli device wifi rescan

# Current network status
check_wifi="$(nmcli device status | grep -w wifi | grep -w connected | awk '{ print $2 }')"
check_ethernet="$(nmcli device status | grep -w ethernet | grep -w connected | awk '{ print $2 }')"
check_ethernet_wifi="$(nmcli device status | grep -e ethernet -e wifi | grep -w connected | awk '{ print $2 }' | sed 'N;s/\n/ /')"

connected_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

# Determine current state
if [[ $check_ethernet_wifi = "ethernet wifi" ]]; then
    current_state="  $connected_ssid"
elif [[ $check_wifi = "wifi" ]]; then
    current_state=" $connected_ssid"
elif [[ $check_ethernet = "ethernet" ]]; then
    current_state=""
else
    current_state=""
fi

# Check previous state
if [[ -f $state_file ]]; then
    previous_state=$(cat $state_file)
else
    previous_state=""
fi

# Notify if state has changed
if [[ $current_state != $previous_state ]]; then
    if [[ $current_state = "" ]]; then
        dunstify -u critical "Disconnected"
    elif [[ $current_state = "" ]]; then
        dunstify -u normal "Connected to Wi-Fi"
    elif [[ $current_state = "" ]]; then
        dunstify -u normal "Connected to Ethernet"
    elif [[ $current_state = " " ]]; then
        dunstify -u normal "Connected to Ethernet and Wi-Fi"
    fi
fi

# Update the state file
echo "$current_state" > $state_file

# Output the current state for the widget
echo "$current_state"
