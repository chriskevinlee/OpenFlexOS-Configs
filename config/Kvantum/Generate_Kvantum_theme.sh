#!/bin/bash

THEME_JSON="$HOME/.config/MyThemes/MyThemes.json"
CURRENT_THEME=$(jq -r '.Current_Theme' "$THEME_JSON")

# Extract needed colors
BACKGROUND=$(jq -r ".Themes[\"$CURRENT_THEME\"].background" "$THEME_JSON")
FOREGROUND=$(jq -r ".Themes[\"$CURRENT_THEME\"].foreground" "$THEME_JSON")
HIGHLIGHT=$(jq -r ".Themes[\"$CURRENT_THEME\"].highlight" "$THEME_JSON")
RED=$(jq -r ".Themes[\"$CURRENT_THEME\"].red" "$THEME_JSON")
GREEN=$(jq -r ".Themes[\"$CURRENT_THEME\"].green" "$THEME_JSON")
YELLOW=$(jq -r ".Themes[\"$CURRENT_THEME\"].yellow" "$THEME_JSON")
BLUE=$(jq -r ".Themes[\"$CURRENT_THEME\"].blue" "$THEME_JSON")
MAGENTA=$(jq -r ".Themes[\"$CURRENT_THEME\"].magenta" "$THEME_JSON")
GRAY=$(jq -r ".Themes[\"$CURRENT_THEME\"].gray" "$THEME_JSON")
TRANSPARENT=$(jq -r ".Themes[\"$CURRENT_THEME\"].transparent" "$THEME_JSON")



# Output theme.rasi
cat <<EOF > "/home/chris/.config/Kvantum/MyThemes/MyThemes.kvconfig"

[%General]
author=Rokin
comment=Midnight
respect_DE=true
x11drag=menubar_and_primary_toolbar
alt_mnemonic=true
double_click=false
inline_spin_indicators=true
vertical_spin_indicators=false
spin_button_width=24
combo_as_lineedit=true
combo_menu=true
combo_focus_rect=false
square_combo_button=false
left_tabs=true
center_doc_tabs=false
attach_active_tab=false
embedded_tabs=false
joined_inactive_tabs=true
mirror_doc_tabs=true
no_active_tab_separator=false
active_tab_overlap=0
#no_inactive_tab_expansion=
tab_button_extra_margin=0
bold_active_tab=false
group_toolbar_buttons=false
toolbar_item_spacing=0
toolbar_interior_spacing=2
center_toolbar_handle=true
slim_toolbars=false
toolbutton_style=1
spread_progressbar=false
progressbar_thickness=16
menubar_mouse_tracking=true
merge_menubar_with_toolbar=true
composite=true
scrollable_menu=false
submenu_overlap=0
menu_shadow_depth=5
tooltip_shadow_depth=6
translucent_windows=false
reduce_window_opacity=0
opaque=kaffeine,kmplayer,subtitlecomposer,kdenlive,vlc,smplayer,smplayer2,avidemux,avidemux2_qt4,avidemux3_qt4,avidemux3_qt5,kamoso,QtCreator,VirtualBox,trojita,dragon,digikam
blurring=false
popup_blurring=false
animate_states=true
no_window_pattern=false
splitter_width=4
scroll_width=11
scroll_min_extent=60
scroll_arrows=false
scrollbar_in_view=true
transient_scrollbar=true
transient_groove=false
tree_branch_line=true
groupbox_top_label=true
button_contents_shift=false
slider_width=3
slider_handle_width=18
slider_handle_length=18
#tickless_slider_handle_size=
check_size=14
tooltip_delay=-1
submenu_delay=50
layout_spacing=6
layout_margin=9
small_icon_size=16
large_icon_size=32
button_icon_size=16
toolbar_icon_size=22
fill_rubberband=false
dark_titlebar=true

[GeneralColors]
window.color=$BACKGROUND
base.color=$BACKGROUND
alt.base.color=$HIGHLIGHT
mid.light.color=$TRANSPARENT
light.color=$RED
dark.color=$TRANSPARENT
mid.color=$GRAY
highlight.color=$HIGHLIGHT
button.color=$GRAY
tooltip.base.color=$GRAY
inactive.highlight.color=$GRAY
disabled.text.color=$GRAY
highlight.text.color=$YELLOW
text.color=$GRAY
window.text.color=$MAGENTA
tooltip.text.color=$GRAY
progress.indicator.text.color=$TRANSPARENT
progress.inactive.indicator.text.color=$TRANSPARENT
button.text.color=$GRAY
link.color=$BLUE
link.visited.color=$BLUE
#inactive.window.color=$RED
#inactive.base.color=$RED
#inactive.text.color=$RED
#inactive.window.text.color=$RED
#inactive.highlight.text.color=$RED
#shadow.color=$RED

[Hacks]
transparent_dolphin_view=false
transparent_pcmanfm_sidepane=true
transparent_pcmanfm_view=false
blur_konsole=false
transparent_ktitle_label=true
transparent_menutitle=true
kcapacitybar_as_progressbar=true
respect_darkness=false
force_size_grip=true
tint_on_mouseover=0
no_selection_tint=true
disabled_icon_opacity=50
normal_default_pushbutton=true
iconless_pushbutton=true
transparent_arrow_button=true
iconless_menu=false
single_top_toolbar=true
middle_click_scroll=false

[PanelButtonCommand]
frame=true
frame.element=button
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4
interior=true
interior.element=button
indicator.size=9
text.shadow=1
text.margin=1
text.iconspacing=3
indicator.element=arrow
text.margin.top=2
text.margin.bottom=4
text.margin.left=2
text.margin.right=2
text.shadow.xshift=0
text.shadow.yshift=1
text.shadow.color=$TRANSPARENT
text.shadow.alpha=127
text.shadow.depth=1
text.normal.color=$GRAY
text.press.color=$GRAY
text.toggle.color=$GRAY
text.focus.color=$GRAY
min_width=+0.3font
min_height=+0.3font

[PanelButtonTool]
inherits=PanelButtonCommand
text.normal.color=$GRAY
text.bold=true
text.shadow=1
text.shadow.xshift=0
text.shadow.yshift=1
text.shadow.color=$TRANSPARENT
text.shadow.alpha=127
text.shadow.depth=1

[Dock]
inherits=PanelButtonCommand
frame=false
interior=false
text.normal.color=$GRAY

[DockTitle]
inherits=PanelButtonCommand
frame=false
interior=true
interior.element=dock
text.margin.top=2
text.margin.bottom=2
text.margin.left=3
text.margin.right=3
text.normal.color=$SEMITRANSLUCENT_WHITE
text.focus.color=$WHITE
text.bold=false

[IndicatorSpinBox]
inherits=PanelButtonCommand
indicator.element=arrow
frame.element=spin
interior.element=spin
interior=false
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
indicator.size=9
text.margin.top=2
text.margin.bottom=2
text.margin.left=2
text.margin.right=2
text.normal.color=$GRAY

[RadioButton]
inherits=PanelButtonCommand
interior.element=radio
text.margin.top=2
text.margin.bottom=2
text.margin.left=3
text.margin.right=3
text.normal.color=$GRAY
text.focus.color=$GRAY
min_width=+0.3font
min_height=+0.3font

[CheckBox]
inherits=PanelButtonCommand
interior.element=checkbox
text.margin.top=2
text.margin.bottom=2
text.margin.left=3
text.margin.right=3
text.normal.color=$GRAY
text.focus.color=$GRAY
min_width=+0.3font
min_height=+0.3font

[Focus]
inherits=PanelButtonCommand
interior=false
frame=true
frame.element=focus
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1
frame.patternsize=20

[GenericFrame]
inherits=PanelButtonCommand
frame=true
interior=false
frame.element=common
interior.element=common
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3

[LineEdit]
inherits=PanelButtonCommand
frame.element=lineedit
interior.element=lineedit
interior=false
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
text.margin.top=2
text.margin.bottom=2
text.margin.left=2
text.margin.right=2
frame.expansion=0

[ToolbarLineEdit]
frame.element=lineedit

[DropDownButton]
inherits=PanelButtonCommand
indicator.element=arrow-down

[IndicatorArrow]
indicator.element=menu-arrow
indicator.size=9

[ToolboxTab]
inherits=PanelButtonCommand
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$YELLOW
text.toggle.color=$HIGHLIGHT

[Tab]
inherits=PanelButtonCommand
interior.element=tab
text.margin.left=8
text.margin.right=8
text.margin.top=2
text.margin.bottom=2
frame.element=tab
indicator.element=tab
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$YELLOW
text.toggle.color=$HIGHLIGHT
text.bold=false

[TabFrame]
inherits=PanelButtonCommand
frame.element=tabframe
interior.element=tabframe
frame.top=3
frame.left=3
frame.right=3
frame.bottom=3
    
[TreeExpander]
inherits=PanelButtonCommand
indicator.element=tree
indicator.size=11

[HeaderSection]
inherits=PanelButtonCommand
interior.element=table
frame.element=table
interior=true
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$YELLOW
text.toggle.color=$HIGHLIGHT
text.bold=false

[SizeGrip]
indicator.element=sizegrip

[Toolbar]
inherits=PanelButtonCommand
frame=true
frame.element=toolbar
interior.element=toolbar
indicator.element=toolbar
frame.top=4
frame.left=0
frame.right=0
frame.bottom=4
frame.expansion=0
interior=true
indicator.size=5

[ToolbarButton]
frame.element=tbutton
interior.element=tbutton
indicator.element=toolbar-arrow
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$YELLOW
text.toggle.color=$HIGHLIGHT
text.bold=true

[Slider]
inherits=PanelButtonCommand
frame.element=slider
interior.element=slider
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1

[SliderCursor]
inherits=PanelButtonCommand
frame=false
interior.element=slidercursor

[Progressbar]
inherits=PanelButtonCommand
frame.element=progress
interior.element=progress
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1
text.normal.color=$GRAY
text.press.color=$GRAY
text.focus.color=$GRAY
text.toggle.color=$GRAY
text.bold=false

[ProgressbarContents]
inherits=PanelButtonCommand
frame=false
interior.element=progress-pattern

[ItemView]
inherits=PanelButtonCommand
text.margin=0
frame.element=itemview
interior.element=itemview
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.margin.top=2
text.margin.bottom=2
text.margin.left=4
text.margin.right=2
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$YELLOW
text.toggle.color=$HIGHLIGHT
min_width=+0.3font
min_height=+0.3font

[Splitter]
inherits=PanelButtonCommand
interior.element=splitter
frame.element=splitter
frame.top=0
frame.bottom=0
frame.left=1
frame.right=1
indicator.element=splitter-grip
indicator.size=16

[Scrollbar]
inherits=PanelButtonCommand
indicator.size=8

[ScrollbarSlider]
inherits=PanelButtonCommand
frame.element=scrollbarslider
interior.element=scrollbarslider
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1
indicator.element=grip
indicator.size=16

[ScrollbarGroove]
inherits=PanelButtonCommand
interior.element=slider
frame.element=slider
frame.top=0
frame.bottom=0
frame.left=4
frame.right=4

[MenuItem]
inherits=PanelButtonCommand
frame=false
interior.element=menuitem
indicator.element=menuitem
text.margin.top=1
text.margin.bottom=1
text.margin.left=8
text.margin.right=6
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$HIGHLIGHT
text.toggle.color=$HIGHLIGHT
text.bold=false
min_width=+0.5font
min_height=+0.5font

[MenuBar]
inherits=PanelButtonCommand
frame=true
frame.top=0
frame.bottom=0
frame.left=2
frame.right=2
frame.element=menuitem
interior.element=menuitem
text.normal.color=$GRAY_DIM

[MenuBarItem]
inherits=PanelButtonCommand
interior.element=menubaritem
frame.element=menubaritem
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.margin.top=0
text.margin.bottom=0
text.margin.left=4
text.margin.right=4
text.normal.color=$GRAY
text.focus.color=$YELLOW
text.press.color=$YELLOW
text.toggle.color=$HIGHLIGHT
text.bold=false
min_width=+0.3font
min_height=+0.3font

[TitleBar]
inherits=PanelButtonCommand
frame=false
interior.element=titlebar
indicator.size=12
indicator.element=mdi
text.margin.top=2
text.margin.bottom=2
text.margin.left=2
text.margin.right=2
text.normal.color=$WHITE_DIM
text.focus.color=$WHITE
text.bold=false

[ComboBox]
inherits=PanelButtonCommand
frame.element=combo
interior.element=combo
interior=false
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
text.margin.top=2
text.margin.bottom=2
text.margin.left=2
text.margin.right=2
text.focus.color=$GRAY
text.press.color=$GRAY
text.toggle.color=$GRAY
frame.expansion=0

[ToolbarComboBox]
frame.element=combo
indicator.element=toolbar-arrow-down

[Menu]
inherits=PanelButtonCommand
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1
frame.element=menu
interior.element=menu
text.normal.color=$GRAY
text.shadow=false

[GroupBox]
inherits=GenericFrame
frame=true
frame.element=group
interior=true
interior.element=group
text.shadow=0
text.margin=0
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.normal.color=$GRAY
text.focus.color=$GRAY

[TabBarFrame]
inherits=GenericFrame
frame=false
interior=false
text.shadow=0

[ToolTip]
inherits=GenericFrame
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
interior=true
text.shadow=0
text.margin=0
interior.element=tooltip
frame.element=tooltip

[Window]
interior=false
interior.element=window
text.bold=false










EOF