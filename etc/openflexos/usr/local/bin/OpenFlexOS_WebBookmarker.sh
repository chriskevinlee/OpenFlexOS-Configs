#!/bin/bash
# ================================================================
# Description: Website bookmark launcher using rofi or dmenu
# Author: Chris Lee, ChatGPT
# Dependencies: rofi or dmenu, xdg-open, alacritty, pacman (Arch)
# Usage:
#   ./web_bookmarks.sh -r   (for rofi)
#   ./web_bookmarks.sh -d   (for dmenu)
# ================================================================

source "$HOME/.config/dmenu_theme.conf"

CONFIG_DIR="$HOME/.config/web_bookmarks"
SITE_LIST="$CONFIG_DIR/sites.txt"

# -----------------------------
# Detect current window manager
# -----------------------------
if pgrep -x qtile >/dev/null; then
    WM="qtile"
elif pgrep -x openbox >/dev/null; then
    WM="openbox"
else
    WM="unknown"
fi

# -----------------------------
# Load sound configuration
# -----------------------------
[[ "$WM" == "qtile" ]] && source "$HOME/.config/qtile/scripts/OpenFlexOS_Sounds.sh"
[[ "$WM" == "openbox" ]] && source "$HOME/.config/openbox/scripts/OpenFlexOS_Sounds.sh"

# -----------------------------------------------------------------
# Function: install_missing
# -----------------------------------------------------------------
install_missing() {
    local packages=("$@")
    local script_name
    script_name=$(basename "$0")

    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            echo "Message from $script_name: $pkg is NOT installed, installing..."
            dunstify -u normal "Installing $pkg..."
            zenity --info --text="Installing $pkg..."
            alacritty -e bash -c "sudo pacman -S --noconfirm $pkg; read -p 'Press Enter to close...'"
        fi
    done
}

# -----------------------------------------------------------------
# Function: rofi_cmd
# -----------------------------------------------------------------
rofi_cmd() {
    local prompt="${1:-Select Website}"

    # 🔊 sound + rofi at same time
    [[ "$active_sounds" == yes && -f "${sounds_dir}${rofi_sound}" ]] \
        && mpv --no-video --no-terminal "${sounds_dir}${rofi_sound}" >/dev/null 2>&1 &

    case "$WM" in
        qtile)
            rofi -config "$HOME/.config/qtile/rofi/config.rasi" -dmenu -i -p "$prompt"
            ;;
        openbox)
            rofi -config "$HOME/.config/openbox/rofi/config.rasi" -dmenu -i -p "$prompt"
            ;;
        *)
            rofi -dmenu -i -p "$prompt"
            ;;
    esac
}

# -----------------------------------------------------------------
# Function: web_menu
# -----------------------------------------------------------------
web_menu() {
    local launcher=("$@")

    mkdir -p "$CONFIG_DIR"
    [[ ! -f "$SITE_LIST" ]] && echo "# Website Name | https://example.com" > "$SITE_LIST"

    local SELECTED_NAME
    SELECTED_NAME=$(grep -v '^#' "$SITE_LIST" | awk -F'|' '{print $1}' | "${launcher[@]}")
    SELECTED_NAME=$(echo "$SELECTED_NAME" | xargs)

    if [[ -n "$SELECTED_NAME" ]]; then
        local URL
        URL=$(grep -i "^$SELECTED_NAME[[:space:]]*|" "$SITE_LIST" | awk -F'|' '{print $2}' | xargs)
        if [[ -n "$URL" ]]; then
            xdg-open "$URL" >/dev/null 2>&1 &
        else
            echo "No URL found for $SELECTED_NAME"
        fi
    fi
}

# -----------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------
if [[ $# -eq 0 ]]; then
    echo "󰖟 Please see $(basename "$0") -h for help"
    exit 0
fi

while getopts "drh" opt 2>/dev/null; do
    case "$opt" in
        d)
            install_missing dmenu xdg-utils alacritty

            # 🔊 sound + dmenu at same time
            [[ "$active_sounds" == yes && -f "${sounds_dir}${dmenu_sound}" ]] \
                && mpv --no-video --no-terminal "${sounds_dir}${dmenu_sound}" >/dev/null 2>&1 &

            dmenu_launcher=(
                dmenu
                -nb "$DMENU_NB"
                -nf "$DMENU_NF"
                -sb "$DMENU_SB"
                -sf "$DMENU_SF"
                -l 15
                -i
                -p "Select Website:"
            )

            web_menu "${dmenu_launcher[@]}"
            ;;
        r)
            install_missing rofi xdg-utils alacritty
            web_menu rofi_cmd
            ;;
        h)
            echo "Website Bookmark Launcher"
            echo "Usage: $(basename "$0") [ARGUMENT]"
            echo ""
            printf "%-30s %s\n" " -r" "Use Rofi menu (themed per WM)"
            printf "%-30s %s\n" " -d" "Use Dmenu menu"
            printf "%-30s %s\n" " -h" "Show this help message"
            ;;
        *)
            echo "Please see $(basename "$0") -h for help"
            ;;
    esac
    exit 0
done

echo "Usage: $(basename "$0") [-r | -d | -h]"
exit 1

