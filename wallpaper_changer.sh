#!/bin/bash

# ================================================================
# Description: This script asks the user to set a user-selected wallpaper, 
# a random wallpaper, or to have a random wallpaper set at a specific interval.
# Author: Chris Lee, ChatGPT
# Dependencies: sxiv, zenity, wmctrl, feh, dunst
# ================================================================

# Check to make sure dependencies are installed before running script
    dependencies=("sxiv" "zenity" "wmctrl" "feh" "dunst")
    missing=()

    # Check for missing dependencies
    for i in "${dependencies[@]}"; do
        if ! command -v "$i" &>/dev/null; then
            missing+=("$i")
        fi
    done

    # Only launch alacritty if there are missing dependencies
    if [[ ${#missing[@]} -gt 0 ]]; then
        alacritty -e bash -c '
        dependencies=("sxiv" "zenity" "wmctrl" "feh" "dunst")
        missing=()

        for i in "${dependencies[@]}"; do
            if ! command -v "$i" &>/dev/null; then
                missing+=("$i")
            fi
        done

        echo "The following packages are required but not installed:"
        echo "${missing[@]}"

        read -p "Would you like to install them now? (y/n) " yn
        if [[ $yn =~ ^[Yy]$ ]]; then
            sudo pacman --noconfirm -S "${missing[@]}"
        else
            echo "Please install them manually."
        fi
        echo "Press Enter to close..."
        read
        '
    fi

# Array of paths to wallpapers. Use "" around paths eg. "$HOME/Pictures"
    WALLPAPER_DIRS=("$HOME/.config/wallpapers")
# Create a temporary file for cycling wallpapers
    PID_FILE="/tmp/wallpaper_timer.pid"

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

# Checks if the /tmp/wallpaper_timer.pid file exists and if the process ID inside is running.
# If both conditions are met, it sets MENU_OPTION to "Stop Wallpaper Cycle"; otherwise, it sets it to "Start Wallpaper Cycle".
    MENU_OPTION=$( [[ -f "$PID_FILE" && $(pgrep -F "$PID_FILE") ]] && echo "Stop Wallpaper Cycle" || echo "Start Wallpaper Cycle" )

# Commandline Options
    if [[ -n "$1" ]]; then 
        if [[ ! $1 = select ]] && [[ ! $1 = random ]] && [[ ! $1 = cycle ]]; then
            echo "Invalid Input: Please use $0 select|random|cycle"
            exit 1
        fi
        case "$1" in
            select)
                Select_Wallpaper
                exit 0
                ;;
            random)
                Select_Random_Wallpaper
                exit 0
                ;;
            cycle)
                case "$2" in
                    start)
                        if [[ "$3" =~ ^[0-9]+[smSM]$ ]]; then
                            Start_Wallpaper_Cycle "$3"
                            exit 0
                        else
                            echo "Invalid Input: Please use $0 cycle start <interval> (e.g., 30s, 5m)"
                            exit 1
                        fi
                        ;;
                    stop)
                        Stop_Wallpaper_Cycle
                        exit 0
                        ;;
                    *)
                        echo "Invalid Input: Please use $0 cycle {start <interval>|stop}"
                        exit 1
                        ;;
                esac
                ;;
        esac
    fi

# GUI Menu using zenity
    CHOICE=$(zenity --list --title="Wallpaper Manager" --column="Options" "Select Wallpaper" "Select Random Wallpaper" "$MENU_OPTION")
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
        *) echo "No selection made.";;
    esac
