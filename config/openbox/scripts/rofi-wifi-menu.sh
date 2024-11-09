#!/bin/bash

#launcher="rofi -config /home/$USER/.config/openbox/rofi/config.rasi -dmenu"
launcher="dmenu -i"

main_message=$(echo -e "WiFi Manager:\nWhat would you like to do?")
main_menu=$(echo -e "󱚽 Connect to a Wifi Network\n󰖪 Enable Or Disable Wifi\n󱛅 Forget a Wifi Network" | $launcher -p "$main_message")










if [[ $main_menu = "󱚽 Connect to a Wifi Network" ]]; then
    # List all available Wi-Fi networks and mark the active one
    wifi_list=$(nmcli --fields SSID,ACTIVE device wifi list | sed '/^$/d' | grep -v -e '^--' -e '^SSID' | awk -F'  +' '{if ($2 == "yes") print $1 " (active)"; else print $1}' | sort -u)
    connect_wifi=$(echo -e "WiFi Manager:\nChoose a Wifi Network")
    wifi_ssid=$(echo "$wifi_list" | $launcher -p "$connect_wifi")

    if [[ -z $wifi_ssid ]]; then
        exit 0  # Exit if no SSID is selected
    fi

    # Remove "(active)" marker if present
    wifi_ssid=$(echo $wifi_ssid | sed 's/ (active)//')

    # Check if the selected Wi-Fi network is already a saved connection
    saved_connection=$(nmcli -g NAME connection show --active | grep -F "$wifi_ssid")

    if [[ -n $saved_connection ]]; then
        # Attempt to connect using the saved profile
        nmcli connection up "$wifi_ssid"
        status=$?
    else
        # Prompt for the password using zenity and attempt to connect
        password=$(zenity --password --title="WiFi Manager: Enter password for $wifi_ssid")
        nmcli device wifi connect "$wifi_ssid" password "$password"
        status=$?
    fi

    # Check the connection status
    if [[ $status -eq 0 ]] && nmcli -t -f active,ssid dev wifi | grep '^yes' | grep -q "$wifi_ssid"; then
        dunstify -u Normal "Connected to $wifi_ssid"
    else
        # If connection fails, delete the saved profile and notify the user
        nmcli connection delete "$wifi_ssid" >/dev/null 2>&1
        dunstify -u Critical "Failed to connect to $wifi_ssid. Please run the script again to retry."
        exit 1
    fi

elif [[ $main_menu = "󰖪 Enable Or Disable Wifi" ]]; then
    # Toggle Wi-Fi status
    wifi_status=$(nmcli radio wifi)
    if [[ $wifi_status == "enabled" ]]; then
        nmcli radio wifi off
        dunstify -u Normal "WiFi Radio Off"
    else
        nmcli radio wifi on
        dunstify -u Normal "WiFi Radio On"
    fi

elif [[ $main_menu = "󱛅 Forget a Wifi Network" ]]; then
    # List all saved Wi-Fi connections
    saved_wifi_connections=$(nmcli -f NAME,TYPE connection show | grep wifi | awk '{$NF=""; sub(/[ \t]+$/, ""); print}' | sort -u)
    wifi_forget=$(echo -e "WiFi Manager:\nChoose a Wifi Network to Forget")
    forget_ssid=$(echo "$saved_wifi_connections" | rofi -config /home/$USER/.config/openbox/rofi/config.rasi -dmenu -p "$wifi_forget")
    if [[ ! -z $forget_ssid ]]; then
        nmcli connection delete "$forget_ssid"
        dunstify -u Normal "$forget_ssid Deleted"
    fi
fi
