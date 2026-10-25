#!/usr/bin/env bash

# Usage: OpenFlexOS_Ksnip-Screenshot.sh [f|r|a] [save|copy]
# f = fullscreen, r = rectangular region, a = active window
MODE="${1:-r}"
ACTION="${2:-save}"

case "$MODE" in
    f) TYPE="full" ;;
    r) TYPE="region" ;;
    a) TYPE="active" ;;
    *) notify-send -u critical "Ksnip" "Invalid screenshot mode: $MODE"; exit 1 ;;
esac

case "$ACTION" in
    save|copy) ;;
    *) notify-send -u critical "Ksnip" "Invalid action: $ACTION"; exit 1 ;;
esac

if [[ "$ACTION" == "copy" ]]; then
    if ! command -v xclip >/dev/null 2>&1; then
        notify-send -u critical "Ksnip" "xclip is required for clipboard screenshots."
        exit 1
    fi
    FILE="$(mktemp --suffix=.png)" || exit 1
    trap 'rm -f -- "$FILE"' EXIT
else
    DIR="$HOME/Pictures"
    mkdir -p -- "$DIR" || exit 1
    FILE="$DIR/screenshot_${TYPE}_$(date +%Y%m%d_%H%M%S).png"
fi

if ! ksnip "-$MODE" -p "$FILE" || [[ ! -s "$FILE" ]]; then
    notify-send -u critical "Screenshot Failed" "Ksnip could not capture the screenshot."
    exit 1
fi

if [[ "$ACTION" == "copy" ]]; then
    if xclip -selection clipboard -t image/png -i "$FILE"; then
        notify-send -i edit-copy "Screenshot Copied" "${TYPE^} screenshot copied to clipboard."
    else
        notify-send -u critical "Screenshot Failed" "Could not copy screenshot to clipboard."
        exit 1
    fi
else
    notify-send -i camera-photo "Screenshot Saved" "$(basename "$FILE")"
fi
