#!/bin/bash

# ================================================================
# Description: Application launcher using rofi or dmenu with sound
# Author: Chris Lee, ChatGPT
# Dependencies: rofi, dmenu, mpv
# Usage: ./OpenFlexOS_Applications.sh [-r | -d]
# ================================================================

# ------------------------------------------------
# Load configs
# ------------------------------------------------
source "$HOME/.config/dmenu_theme.conf"
source "$HOME/.config/qtile/scripts/OpenFlexOS_Sounds.sh"

applications_icon=""
echo "$applications_icon"

# ------------------------------------------------
# Detect window manager
# ------------------------------------------------
if qtile cmd-obj -o cmd -f info >/dev/null 2>&1; then
    WM="qtile"
elif pgrep -f qtile >/dev/null; then
    WM="qtile"
elif pgrep -f openbox >/dev/null; then
    WM="openbox"
else
    WM="unknown"
fi

# ------------------------------------------------
# Play sound in background (non-blocking)
# ------------------------------------------------
play_sound_bg() {
    [[ "$active_sounds" != yes ]] && return
    [[ ! -f "$1" ]] && return
    mpv --no-video --no-terminal "$1" >/dev/null 2>&1 &
}

# ------------------------------------------------
# Rofi launcher (foreground)
# ------------------------------------------------
rofi_cmd() {

    # Sound + launcher start together
    play_sound_bg "${sounds_dir}${rofi_sound}"

    if [[ "$WM" == "qtile" ]]; then
        rofi -config "/home/$USER/.config/qtile/rofi/config.rasi" \
             -show drun -display-drun "Apps "
    elif [[ "$WM" == "openbox" ]]; then
        rofi -config "/home/$USER/.config/openbox/rofi/config.rasi" \
             -show drun -display-drun "Apps "
    fi
}

# ------------------------------------------------
# Argument parsing
# ------------------------------------------------
while getopts "drh" main 2>/dev/null; do
  case "${main}" in

    # ------------------------------------------------
    # DMENU MODE
    # ------------------------------------------------
    d )
        package_list=(dmenu ttf-nerd-fonts-symbols)

        for pkg in "${package_list[@]}"; do
            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                script_name=$(basename "$0")
                dunstify -u normal "Installing missing package: $pkg"
                alacritty -e bash -c "sudo pacman -S --noconfirm $pkg; read -p 'Press Enter to close...'"
            fi
        done

        app_dirs=("/usr/share/applications" "$HOME/.local/share/applications")
        declare -A app_map

        for dir in "${app_dirs[@]}"; do
            if [ -d "$dir" ]; then
                while IFS= read -r desktop; do
                    name=$(grep -m 1 "^Name=" "$desktop" | cut -d'=' -f2)
                    app_map["$name"]="$desktop"
                done < <(find "$dir" -name "*.desktop")
            fi
        done

        # Sound + dmenu start together
        play_sound_bg "${sounds_dir}${dmenu_sound}"

        app=$(printf '%s\n' "${!app_map[@]}" | sort -u | \
              dmenu $DMENU_OPTS -p "Launch Application")

        if [[ -n "$app" && -n "${app_map[$app]}" ]]; then
            exec_command=$(grep -m 1 "^Exec=" "${app_map[$app]}" \
                | cut -d'=' -f2 | sed 's/ *%[UuFfNn] *//g')
            sh -c "$exec_command &"
        fi
        ;;

    # ------------------------------------------------
    # ROFI MODE
    # ------------------------------------------------
    r )
        package_list=(rofi ttf-nerd-fonts-symbols)

        for pkg in "${package_list[@]}"; do
            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                script_name=$(basename "$0")
                dunstify -u normal "Installing missing package: $pkg"
                alacritty -e bash -c "sudo pacman -S --noconfirm $pkg; read -p 'Press Enter to close...'"
            fi
        done

        rofi_cmd
        exit 0
        ;;

    # ------------------------------------------------
    # HELP
    # ------------------------------------------------
    h )
        echo "A basic Application Launcher"
        echo "Usage: $(basename "$0") [ARGUMENT]"
        echo ""
        printf "%-30s %s\n" " -r" "Use Rofi to Launch Applications"
        printf "%-30s %s\n" " -d" "Use Dmenu to Launch Applications"
        ;;

    * )
        echo "Please see $(basename "$0") -h for help"
        ;;
  esac
done

