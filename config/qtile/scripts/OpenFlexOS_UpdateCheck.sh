#!/bin/bash

# Detect package manager
if command -v checkupdates >/dev/null 2>&1 && command -v yay >/dev/null 2>&1; then
    # Arch-based system
    pacman_updates=$(checkupdates 2>/dev/null)
    aur_updates=$(yay -Qua 2>/dev/null)
    count_pacman=$(echo "$pacman_updates" | grep -c '^[^[:space:]]')
    count_aur=$(echo "$aur_updates" | grep -c '^[^[:space:]]')
    total=$((count_pacman + count_aur))
elif command -v apt >/dev/null 2>&1; then
    # Debian-based system
    apt update -qq >/dev/null 2>&1
    total=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | grep -c '^\S' || echo 0)
else
    total=0
fi

# Output total number of updates
printf "%d" "$total"

exit 0

