#!/usr/bin/env bash
# Reads the current theme from themes.json and generates alacritty.toml

if [ -L /home/$USER/.config/conky/conky.conf ]; then
    rm /home/$USER/.config/conky/conky.conf
    cp  /etc/openflexos/home/user/config/conky/conky.conf /home/$USER/.config/conky/conky.conf
fi

# Path to your themes.json file
THEMES_FILE="$HOME/.config/themes.json"

# Path to output alacritty.toml
CONKY_CONFIG="$HOME/.config/conky/conky.conf"

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required (install with: sudo apt install jq)"
  exit 1
fi

# Read current theme name
CURRENT_THEME=$(jq -r '.current' "$THEMES_FILE")

# Extract colors
BG=$(jq -r ".themes.\"$CURRENT_THEME\".bg" "$THEMES_FILE")

# Check for missing theme
if [[ "$BG" == "null" || -z "$BG" ]]; then
  echo "Error: Theme '$CURRENT_THEME' not found in $THEMES_FILE"
  exit 1
fi

# Create conky.conf
cat > "$CONKY_CONFIG" <<EOF
conky.config = {
    update_interval = 1,
    double_buffer = true,

    own_window = true,
    own_window_type = 'override',
    own_window_transparent = false,

    own_window_colour = "$BG",

    out_to_x = true,

    use_xft = true,
    font = 'JetBrains Mono:size=12',

    alignment = 'top_right',
    gap_x = 15,
    gap_y = 60,
    minimum_width = 380,
    maximum_width = 800,
}

conky.text = [[
\${execpi 5 /home/chris/.config/qtile/scripts/OpenFlexOS_ConkyColorizeKeybindings.sh}
]]
EOF
echo "✅ Conky theme updated to '$CURRENT_THEME' at: $CONKY_CONFIG"

