#!/bin/bash

# Path to JSON
THEME_JSON="$HOME/.config/MyThemes/MyThemes.json"

# Read current theme
CURRENT_THEME=$(jq -r '.Current_Theme' "$THEME_JSON")

# Extract color values
BG=$(jq -r ".Themes[\"$CURRENT_THEME\"].background" "$THEME_JSON")
FG=$(jq -r ".Themes[\"$CURRENT_THEME\"].foreground" "$THEME_JSON")
HIGHLIGHT=$(jq -r ".Themes[\"$CURRENT_THEME\"].highlight" "$THEME_JSON")
RED=$(jq -r ".Themes[\"$CURRENT_THEME\"].red" "$THEME_JSON")
GREEN=$(jq -r ".Themes[\"$CURRENT_THEME\"].green" "$THEME_JSON")
YELLOW=$(jq -r ".Themes[\"$CURRENT_THEME\"].yellow" "$THEME_JSON")
BLUE=$(jq -r ".Themes[\"$CURRENT_THEME\"].blue" "$THEME_JSON")
MAGENTA=$(jq -r ".Themes[\"$CURRENT_THEME\"].magenta" "$THEME_JSON")
GRAY=$(jq -r ".Themes[\"$CURRENT_THEME\"].gray" "$THEME_JSON")
TRANSPARENT=$(jq -r ".Themes[\"$CURRENT_THEME\"].transparent" "$THEME_JSON")

# GTK 2
cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Default"
gtk-icon-theme-name="Papirus"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-color-scheme = "bg_color:$BG\nfg_color:$RED\nbase_color:$BG\ntext_color:$RED\nselected_bg_color:$GREEN\nselected_fg_color:$RED"
EOF

# GTK 3
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/gtk.css
* {
  background-color: $BG;
  color: $RED;
  border-color: $BLUE;
}

*:hover,
*:selected,
*:active,
list row:selected,
list row:selected:hover,
treeview:selected,
treeview:selected:focus,
treeview:selected:hover,
menuitem:hover,
menuitem:selected {
  background-color: $GREEN;
  color: $RED;
}
EOF

# GTK 4
mkdir -p ~/.config/gtk-4.0
cat <<EOF > ~/.config/gtk-4.0/gtk.css
* {
  background-color: $BG;
  color: $RED;
  border-color: $BLUE;
}

*:hover,
*:selected,
*:active,
list row:selected,
menuitem:hover,
menuitem:selected {
  background-color: $GREEN;
  color: $RED;
}
EOF

echo "✅ GTK theme applied using '$CURRENT_THEME'. Restart apps or relog to fully apply it."

