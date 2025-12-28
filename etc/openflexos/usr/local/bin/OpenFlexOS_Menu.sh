#!/usr/bin/env bash
#
# OpenFlexOS_Menu.sh
# ------------------
# A launcher that uses rofi or dmenu to run executable scripts
# from ~/.config/qtile/scripts/menu
#

MENU_DIR="$HOME/.config/qtile/scripts/menu"
mkdir -p "$MENU_DIR"

# ------------------------------------------------
# Load configs
# ------------------------------------------------
source "$HOME/.config/dmenu_theme.conf"
source "$HOME/.config/qtile/scripts/OpenFlexOS_Sounds.sh"

echo "󰍜  $USER"

# ------------------------------------------------
# Detect window manager (for sound paths)
# ------------------------------------------------
if pgrep -x qtile >/dev/null; then
    WM="qtile"
elif pgrep -x openbox >/dev/null; then
    WM="openbox"
else
    WM="unknown"
fi

# ------------------------------------------------
# Background sound helper
# ------------------------------------------------
play_sound_bg() {
    [[ "$active_sounds" != yes ]] && return
    [[ ! -f "$1" ]] && return
    mpv --no-video --no-terminal "$1" >/dev/null 2>&1 &
}

# ------------------------------------------------
# Parse command-line arguments
# ------------------------------------------------
while getopts ":rdh" opt; do
  case $opt in
    r) MENU_TOOL="rofi" ;;
    d) MENU_TOOL="dmenu" ;;
    h)
      echo "Menu Launcher"
      echo "Usage: $(basename "$0") [OPTION]"
      echo ""
      printf "%-30s %s\n" " -r" "Use Rofi"
      printf "%-30s %s\n" " -d" "Use Dmenu"
      exit 0
      ;;
    *) echo "Usage: $0 [-r | -d | -h]" >&2; exit 1 ;;
  esac
done

# ------------------------------------------------
# Find executable scripts
# ------------------------------------------------
SCRIPTS=$(find -L "$MENU_DIR" -maxdepth 1 \
  \( -type f -o -type l \) -executable -printf "%f\n" | sort)

# ------------------------------------------------
# Define launchers
# ------------------------------------------------
ROFI_CONFIG="$HOME/.config/qtile/rofi/config.rasi"

if [[ "$MENU_TOOL" == "rofi" ]]; then
    LAUNCHER=(rofi -config "$ROFI_CONFIG" -dmenu -i -p "Run script:")
elif [[ "$MENU_TOOL" == "dmenu" ]]; then
    LAUNCHER=(dmenu $DMENU_OPTS -p "Run:")
fi

# ------------------------------------------------
# 🔊 Play sound + show menu AT THE SAME TIME
# ------------------------------------------------
if [[ "$MENU_TOOL" == "rofi" ]]; then
    play_sound_bg "${sounds_dir}${rofi_sound}"
elif [[ "$MENU_TOOL" == "dmenu" ]]; then
    play_sound_bg "${sounds_dir}${dmenu_sound}"
fi

# ------------------------------------------------
# Display menu (foreground – keeps shell alive)
# ------------------------------------------------
CHOICE=$(echo "$SCRIPTS" | "${LAUNCHER[@]}")

# ------------------------------------------------
# Run selected script
# ------------------------------------------------
if [[ -n "$CHOICE" ]]; then
    TARGET="$(readlink -f "$MENU_DIR/$CHOICE")"

    FLAG=""
    [[ "$MENU_TOOL" == "rofi" ]] && FLAG="-r"
    [[ "$MENU_TOOL" == "dmenu" ]] && FLAG="-d"

    MENU_TOOL="$MENU_TOOL" "$TARGET" "$FLAG" &
fi

