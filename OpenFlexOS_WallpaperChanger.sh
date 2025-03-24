#!/bin/bash

# ================================================================
# Description: This script asks the user to set a user-selected wallpaper, 
# a random wallpaper, or to have a random wallpaper set at a specific interval.
# Author: Chris Lee, ChatGPT
# Dependencies: sxiv, zenity, wmctrl, feh, dunst
# ================================================================

# Array of paths to wallpapers. Use "" around paths eg. "$HOME/Pictures"
    WALLPAPER_DIRS=("$HOME/.config/wallpapers")
# Create a temporary file for cycling wallpapers
    PID_FILE="/tmp/wallpaper_timer.pid"

# Function: Set Mutli-Monitor Wallpapers
    Mutli_Monitor_Wallpapers(){
    # Path to the wallpaper config file
    wallpaper_file="$HOME/.config/$DESKTOP_SESSION/.selected_wallpaper"

    # Get the list of connected monitors and store them in an array
    monitors=($(xrandr --listmonitors | awk 'NR>1 {print $4}'))

    # Declare an associative array to store monitor wallpapers
    declare -A wallpapers

    # Load existing wallpapers from the config file
    if [[ -f "$wallpaper_file" ]]; then
        while IFS='=' read -r monitor wallpaper; do
            wallpapers["$monitor"]="$wallpaper"
        done < <(grep -v '^#' "$wallpaper_file")
    fi

    # Create a list of monitors for Zenity
    monitor_list=$(printf "%s\n" "${monitors[@]}")

    # Ask the user to select a monitor using Zenity
    selected_monitor=$(zenity --list --title="Select Monitor" --column="Monitors" $monitor_list)

    # If user cancels, exit
    if [[ -z "$selected_monitor" ]]; then
        exit 1
    fi

    # Ask user to select a new wallpaper
    new_wallpaper=$(zenity --file-selection --title="Select a wallpaper for $selected_monitor" --filename="$HOME/.config/wallpapers/")

    # If user cancels, exit
    if [[ -z "$new_wallpaper" ]]; then
        exit 1
    fi

    # Update the selected monitor's wallpaper in the array
    wallpapers["$selected_monitor"]="$new_wallpaper"

    # Automatically determine the first two monitors (based on the order they appear in xrandr)
    primary_monitor="${monitors[0]}"
    secondary_monitor="${monitors[1]}"

    # Save wallpapers in the correct order, dynamically assigning monitors
    {
        # Write primary monitor's wallpaper
        [[ -n "${wallpapers[$primary_monitor]}" ]] && echo "$primary_monitor=${wallpapers[$primary_monitor]}"

        # Write secondary monitor's wallpaper
        [[ -n "${wallpapers[$secondary_monitor]}" ]] && echo "$secondary_monitor=${wallpapers[$secondary_monitor]}"

        # Write any other monitors after that
        for monitor in "${!wallpapers[@]}"; do
            [[ "$monitor" != "$primary_monitor" && "$monitor" != "$secondary_monitor" ]] && echo "$monitor=${wallpapers[$monitor]}"
        done
    } > "$wallpaper_file"

    # Apply wallpapers in correct order
    feh --no-fehbg --bg-scale "${wallpapers[$primary_monitor]}" --bg-scale "${wallpapers[$secondary_monitor]}"
        }
    # Function: Set a static wallpaper
        Select_Wallpaper(){
            sxiv -t -r "${WALLPAPER_DIRS[@]}" &
            sleep 1
            window_id=$(wmctrl -l | grep "sxiv" | awk '{print $1}')
                if [ -z "$window_id" ]; then
                zenity --error --text="sxiv window not found!"
                exit 1
            fi
            wmctrl -i -r "$window_id" -T "Select a Wallpaper...(ctrl+x+w)"
            # See file /home/$USER/.config/sxiv/exec/key-handler that will run feh to applied the wallpaper, send notifcation and save /home/$USER/.config/$DESKTOP_SESSION/.selected_wallpaper
        }
# Function: Set a random wallpaper
    Select_Random_Wallpaper() {
        WALLPAPER=$(find "${WALLPAPER_DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
        feh --bg-fill "$WALLPAPER" && echo "$WALLPAPER" > /home/$USER/.config/$DESKTOP_SESSION/.selected_wallpaper
        dunstify -u normal "Wallpaper Appiled"
    }
# Function: Starts a Cycling wallpapers
    Start_Wallpaper_Cycle() {
        local INTERVAL_INPUT="$1"

        if [[ "$INTERVAL_INPUT" =~ ^([0-9]+)([smSM])$ ]]; then
            VALUE="${BASH_REMATCH[1]}"
            UNIT="${BASH_REMATCH[2]}"

            if [[ "$UNIT" =~ [mM] ]]; then
                INTERVAL=$((VALUE * 60))  # Convert minutes to seconds
            else
                INTERVAL=$VALUE  # Use seconds directly
            fi
        else
            echo "Invalid format. Use a number followed by 's' (seconds) or 'm' (minutes)."
            exit 1
        fi

        # Start the wallpaper changer in a background loop
        (
            while true; do
                WALLPAPER=$(find "${WALLPAPER_DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
                feh --bg-fill "$WALLPAPER"
                sleep "$INTERVAL"
            done
        ) > /dev/null 2>&1 &  

        echo $! > "$PID_FILE"
        echo "Wallpaper timer started with a $INTERVAL_INPUT interval!"
    }
# Function: Stops a Cycling wallpapers
    Stop_Wallpaper_Cycle() {
        if [[ -f "$PID_FILE" ]]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null
            rm "$PID_FILE"
            echo "Wallpaper timer stopped!"
        else
            echo "No wallpaper timer is running."
        fi
    }
# Function: Full Screen slideshow
    Slide_Show() {
        local INTERVAL_INPUT="$1"

        if [[ "$INTERVAL_INPUT" =~ ^([0-9]+)([smSM])$ ]]; then
            VALUE="${BASH_REMATCH[1]}"
            UNIT="${BASH_REMATCH[2]}"

            if [[ "$UNIT" =~ [mM] ]]; then
                INTERVAL=$((VALUE * 60))  # Convert minutes to seconds
            else
                INTERVAL=$VALUE  # Use seconds directly
            fi
        else
            echo "Invalid format. Use a number followed by 's' (seconds) or 'm' (minutes)."
            exit 1
        fi

        # Find only image files and pass them to feh
        IMAGE_FILES=$(find "${WALLPAPER_DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \))
        
        if [[ -z "$IMAGE_FILES" ]]; then
            echo "No images found in ${WALLPAPER_DIRS[@]}"
            exit 1
        fi

        feh -F -D "$INTERVAL" $IMAGE_FILES
    }

# Checks if the /tmp/wallpaper_timer.pid file exists and if the process ID inside is running.
# If both conditions are met, it sets MENU_OPTION to "Stop Wallpaper Cycle"; otherwise, it sets it to "Start Wallpaper Cycle".
    MENU_OPTION=$( [[ -f "$PID_FILE" && $(pgrep -F "$PID_FILE") ]] && echo "Stop Wallpaper Cycle" || echo "Start Wallpaper Cycle" )

# Commandline Options
    while getopts "srb:eS:h" main 2>/dev/null; do
        case "${main}" in
            s)
                Select_Wallpaper
                exit 0
                ;;
            r)
                Select_Random_Wallpaper
                exit 0
                ;;
            b)
                if [[ "${OPTARG}" =~ ^[0-9]+[smSM]$ ]]; then
                    Start_Wallpaper_Cycle "${OPTARG}"
                    dunstify -u normal "Wallpaper Appiled every: "${OPTARG}""
                    exit 0
                fi
                ;;
            e)
                Stop_Wallpaper_Cycle
                dunstify -u normal "Wallpaper Stopped"
                exit 0
                ;;
            S)
                if [[ "${OPTARG}" =~ ^[0-9]+[smSM]$ ]]; then
                    Slide_Show "${OPTARG}"
                    exit 0
                else
                    echo "Invalid Input: Please use $(basename "$0") slideshow <interval> (e.g., 30s, 5m)"
                    exit 1
                fi
                ;;
            h)
                echo "A Wallpaper Changer with a few features, such as static wallpaper, random wallpaper, cycling wallpapers, and a slideshow."
                echo "Usage: $(basename "$0") [OPTION] [ARGUMENT]"
                echo ""

                printf "%-30s %s\n" " $(basename "$0")" "Run Zenity GUI to select the the options below"
                printf "%-30s %s\n" " -s" "Select a static wallpaper with sxiv"

                printf "%-30s %s\n" " -r" "Apply a random wallpaper using feh"
                printf "%-30s %s\n" " -b" "Start cycling wallpapers with a given interval using feh"
                printf "%-30s %s\n" " -e" "Stop cycling wallpapers using feh"
                printf "%-30s %s\n" " -S" "Start a slideshow with a given interval using feh"
                echo ""

                echo " EXAMPLES:"
                echo""
                printf "%-30s %s\n" " $(basename "$0") -b 10s" "Start a wallpaper cycle every 10 seconds"
                printf "%-30s %s\n" " $(basename "$0") -b 5m" "Start a wallpaper cycle every 5 Minutes"
                printf "%-30s %s\n" " $(basename "$0") -e" "Stop the wallpaper cycle"
                echo ""
                printf "%-30s %s\n" " $(basename "$0") -S 10s" "Start a full screen slideshow every 10 seconds"
                printf "%-30s %s\n" " $(basename "$0") -S 5m" "Start a full screen slideshow every 5 Minutes"

                ;;
            *)
                echo "Invaild Option, Please use $(basename "$0") -h for help"
                ;;
        esac
        exit 0
    done

# GUI Menu using zenity
    CHOICE=$(zenity --list --title="Wallpaper Manager" --column="Options" "Select Wallpaper" "Select Random Wallpaper" "$MENU_OPTION" "SlideShow" "Mutli-Monitor Wallpapers")
    case "$CHOICE" in
        "Select Wallpaper")
            Select_Wallpaper
        ;; 
        "Select Random Wallpaper")
            Select_Random_Wallpaper
            dunstify -u normal "Wallpaper Appiled"
        ;;
        "Start Wallpaper Cycle")
            INTERVAL=$(zenity --list --title="Set Wallpaper Interval" --column="Options" \
                "5m" "10m" "20m" "30m" "60m" "Custom" --text="Choose a time interval:")
            [[ "$INTERVAL" == "Custom" ]] && INTERVAL=$(zenity --entry --title="Custom Interval" --text="Enter time (e.g., 30s, 10m):")
            [[ ! "$INTERVAL" =~ ^[0-9]+[smSM]$ ]] && { zenity --error --text="Invalid input."; exit 1; }
            Start_Wallpaper_Cycle "$INTERVAL"
            dunstify -u normal "Wallpaper Cycle Started"
        ;;
        "Stop Wallpaper Cycle")
            Stop_Wallpaper_Cycle
            dunstify -u normal "Wallpaper Cycle Stopped"
        ;;
        "SlideShow")
            INTERVAL=$(zenity --list --title="Set Wallpaper Interval" --column="Options" \
                "5s" "10s" "20s" "30s" "60m" "Custom" --text="Choose a time interval:")
            [[ "$INTERVAL" == "Custom" ]] && INTERVAL=$(zenity --entry --title="Custom Interval" --text="Enter time (e.g., 30s, 10m):")
            [[ ! "$INTERVAL" =~ ^[0-9]+[smSM]$ ]] && { zenity --error --text="Invalid input."; exit 1; }
            Slide_Show "$INTERVAL"
            #dunstify -u normal "SlideShow Started"
        ;;
        "Mutli-Monitor Wallpapers")
            Mutli_Monitor_Wallpapers
        ;;
        *) echo "No selection made.";;
    esac
