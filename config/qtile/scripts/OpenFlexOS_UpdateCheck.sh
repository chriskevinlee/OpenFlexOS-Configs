#!/bin/bash

# Get updates
pacman_updates=$(checkupdates 2>/dev/null)
aur_updates=$(yay -Qua 2>/dev/null)

# Count updates
count_pacman=$(echo "$pacman_updates" | grep -c '^[^[:space:]]')
count_aur=$(echo "$aur_updates" | grep -c '^[^[:space:]]')

# Total
total=$((count_pacman + count_aur))

# Print single number with no newline
printf "%d" "$total"
