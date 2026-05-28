#!/bin/bash

# ================================================================
# Description: Uses brightnessctl and dunst to control screen brightness
# ================================================================

# Exit silently if no brightness control exists
if [ ! -d /sys/class/backlight ] || [ -z "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
    exit 0
fi

package_list=(
    brightnessctl
    dunst
    ttf-nerd-fonts-symbols
)

for pkg in "${package_list[@]}"; do
    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
        script_name=$(basename "$0")
        echo "Message from $script_name: $pkg is NOT installed, installing..."

        if command -v dunstify >/dev/null 2>&1; then
            dunstify -u normal "Message from $script_name" "$pkg is NOT installed, installing..."
        fi

        if command -v zenity >/dev/null 2>&1; then
            zenity --info --text="Message from $script_name: $pkg is NOT installed, installing..."
        fi

        alacritty -e bash -c "sudo pacman -S --noconfirm $pkg; read -p 'Press Enter to close...'"
    fi
done

brightness_icon="󰃝"

STEP=10%

while getopts "udh" main 2>/dev/null; do
    case "${main}" in
        u)
            brightnessctl set "$STEP"+
            ;;
        d)
            brightnessctl set "$STEP"-
            ;;
        h)
            echo "Usage: $(basename "$0") [-u | -d]"
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac

    current_brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$((100 * current_brightness / max_brightness))

    dunstify -r 48457 "Brightness Control" "$percentage%"
    exit 0
done

if [ "$OPTIND" -eq 1 ]; then
    current_brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$((100 * current_brightness / max_brightness))

    echo "$brightness_icon $percentage%"
fi
