#############################################################
############### Import/from Modules #########################
#############################################################
import os
import subprocess
import threading
import time
from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
from libqtile.widget import TextBox

from qtile_extras import widget
from qtile_extras.widget.decorations import PowerLineDecoration

#############################################################
############### PowerLine for bar ###########################
#############################################################
powerline = {
    "decorations": [
        PowerLineDecoration()
    ]
}

powerlineright = {
    "decorations": [
        PowerLineDecoration(path="arrow_right")
    ]
}

powerlineroundedleft = {
    "decorations": [
        PowerLineDecoration(path="rounded_left")
    ]
}

powerlineroundedright = {
    "decorations": [
        PowerLineDecoration(path="rounded_right")
    ]
}

#############################################################
############### Functions ###################################
#############################################################

# Function to get script's Path to then call on later
def get_script_path(script_name):
    home_dir = os.path.expanduser("~")
    return os.path.join(home_dir, ".config", "qtile", "scripts", script_name)

# Function to auto-start applicaions/proesses at login
@hook.subscribe.startup_once
def autostart():
    script = get_script_path('OpenFlexOS_AutoStart.sh')
    subprocess.Popen([script])

def battery_widget():
    if os.path.exists("/sys/class/power_supply/BAT1"):
        return widget.Battery(
            battery="BAT1",
            charge_char="󰂄",
            discharge_char="",
            full_char="",
            format="{char} {percent:2.0%}",  # Ensure "Full" text is removed
            show_short_text=False,  # Prevents Qtile from displaying "Full"
            update_interval=1,
            foreground='000000',
            background="#7F849C",
            **powerlineright,
        )
    else:
        return widget.TextBox(text="", width=0)

# Function to display a icon for network status. x icon disconnected, wifi for connected to wifi, Desktop pc for ethernet. see OpenFlexOS_NerdDictation.sh
def get_nmcli_output():
    return subprocess.check_output([get_script_path("OpenFlexOS_Network.sh")]).decode("utf-8").strip()

# Function for Resize Floating Windows, See "keys =" for seting Keybindings
@lazy.function
def resize_floating_window(qtile, width: int = 0, height: int = 0):
    w = qtile.current_window
    w.cmd_set_size_floating(w.width + width, w.height + height)


#############################################################
############### Class #######################################
#############################################################

# Function to display Screen brightnless and allow left click and right click
class BrightnessWidget(TextBox):
    def __init__(self):
        super().__init__(foreground="000000", background="#F9E2AF", **powerlineright,)
        self.brightness()
        # Add callbacks to the widget
        self.add_callbacks({'Button1': self.on_left_click, 'Button3': self.on_right_click})
    def brightness(self):
        # Run your OpenFlexOS_Brightness.sh script to get the volume level or mute state
        result = subprocess.run([get_script_path("OpenFlexOS_Brightness.sh")], capture_output=True, text=True)
        self.text = result.stdout.strip()
        self.draw()
    def on_left_click(self):
        subprocess.run([get_script_path("OpenFlexOS_Brightness.sh"), "-u"])
        self.brightness()
    def on_right_click(self):
        subprocess.run([get_script_path("OpenFlexOS_Brightness.sh"), "-d"])
        self.brightness()

# Function to display volume percentage and to allow left click, right click and middle click
class VolumeWidget(TextBox):
    def __init__(self):
        super().__init__(foreground="000000",background="#CBA6F7", **powerlineright,)
        self.update_volume()
        # Add callbacks for mouse clicks
        self.add_callbacks({
            'Button1': self.on_left_click,  # Left click: Increase volume
            'Button2': self.on_middle_click,  # Middle click: Mute/unmute
            'Button3': self.on_right_click   # Right click: Decrease volume
        })
        # Start a background thread to keep updating the widget
        self.start_polling()
    def start_polling(self):
        """Update the volume widget every second in a background thread."""
        def poll():
            while True:
                self.update_volume()
                time.sleep(1)  # Adjust interval as needed
        thread = threading.Thread(target=poll, daemon=True)
        thread.start()
    def update_volume(self):
        """Fetch volume level and update the widget text."""
        result = subprocess.run([get_script_path("OpenFlexOS_Volume.sh")], capture_output=True, text=True)
        self.text = result.stdout.strip()
        self.draw()
    def on_left_click(self):
        subprocess.run([get_script_path("OpenFlexOS_Volume.sh"), "-u"])
        self.update_volume()
    def on_right_click(self):
        subprocess.run([get_script_path("OpenFlexOS_Volume.sh"), "-d"])
        self.update_volume()
    def on_middle_click(self):
        subprocess.run([get_script_path("OpenFlexOS_Volume.sh"), "-m"])
        self.update_volume()
# Create the widget instance globally so hooks can reference it
volume_widget = VolumeWidget()
# Qtile Hooks to Refresh the Widget
@hook.subscribe.startup
def update_volume_on_start():
    volume_widget.update_volume()

# Function to display start/stop for nerd_dictation and to allow left and right click
class nerd_dictation(TextBox):
    def __init__(self):
        super().__init__(foreground="000000", background="#74C7EC", **powerlineright,)
        self.update_nerd_dictation()
        # Add callbacks for mouse clicks
        self.add_callbacks({
            'Button1': self.on_left_click,  # Left click: Increase volume
            'Button3': self.on_right_click   # Right click: Decrease volume
        })
        # Start a background thread to keep updating the widget
        self.start_polling()
    def start_polling(self):
        def poll():
            while True:
                self.update_nerd_dictation()
                time.sleep(1)  # Adjust interval as needed
        thread = threading.Thread(target=poll, daemon=True)
        thread.start()
    def update_nerd_dictation(self):
        result = subprocess.run([get_script_path("OpenFlexOS_NerdDictation.sh")], capture_output=True, text=True)
        self.text = result.stdout.strip()
        self.draw()
    def on_left_click(self):
        subprocess.run([get_script_path("OpenFlexOS_NerdDictation.sh"), "-s"])
        self.update_nerd_dictation()
    def on_right_click(self):
        subprocess.run([get_script_path("OpenFlexOS_NerdDictation.sh"), "-S"])
        self.update_nerd_dictation()
# Create the widget instance globally so hooks can reference it
nerddictation = nerd_dictation()

#############################################################
############### Widgets #####################################
#############################################################
nmcli_widget = widget.GenPollText(
    func=get_nmcli_output,
    update_interval=1,
    fmt='{} ',  # You can customize the formatting here
    mouse_callbacks={
    'Button1': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_Network.sh") + " -d"),
    'Button3': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_Network.sh") + " -r"),
    },
    foreground='000000',
    background="#FE640B", **powerlineright,
)

ssh_widget = widget.TextBox(
    text="󰣀",  # Choose a suitable icon (here's an SSH-related icon)
    fontsize=40,
    foreground='000000',
    background="#B4BEFE", **powerlineright,
    mouse_callbacks={
    'Button1': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_SSH.sh") + " -d"),
    'Button3': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_SSH.sh") + " -r"),
    },
)

# Function to get Login User to Display on qtile bar
def get_current_user():
    return subprocess.check_output(["/bin/bash", "-c", "echo $USER"]).decode().strip()

current_user_widget = widget.TextBox(
    text=get_current_user(),
    foreground='000000',
    background="#45475A", **powerlineright,
)
   
#############################################################
############### Bar #######################################
#############################################################
def init_widgets_list():
    widgets_list = [
            widget.Spacer(length=8),
            widget.TextBox(
                text="",
                fontsize=15,
                foreground='000000',
                mouse_callbacks={
                    'Button1': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_Applications.sh") + " -d"),
                    'Button3': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_Applications.sh") + " -r"),
                },
                background="#313244", **powerline,
            ),
            #widget.Spacer(length=8),
            widget.Clock(
                foreground='000000',
                background="#E8A2AF", **powerline,
                format="  %a %d-%m-%Y",
            ),
            #widget.Spacer(length=8),
            widget.Clock(
                foreground='000000',
                format="  %I:%M:%S %p",
                background="#FAE3B0", **powerline,
            ),
            #widget.Spacer(length=8),
            widget.CPU(
                format=' {load_percent}%',
                foreground='000000',
                background="#A6E3A1", **powerline,
            ),
            #widget.Spacer(length=8),
            widget.Memory(
                foreground='000000',
                format=' {MemPercent}%',
                background="#9399B2", **powerline,
            ),
            #widget.Spacer(length=8),
            widget.WindowName(
                foreground='000000',
                background="#F5C2E7", **powerline,
                scroll=True,
                scroll_delay=2,
                scroll_interval=0.1,
                scroll_step=2,
                scroll_repeat=True,
                scroll_clear=False,
                scroll_fixed_width=True,
                width=100,
            ),
            widget.Spacer(),
            widget.Spacer(length=1, background="#1e1e2e59", **powerlineroundedright), # Same Colour as the bar
            widget.Spacer(length=1, background="#585B70", **powerlineroundedright),
            widget.GroupBox(
                highlight_method='line',
                highlight_color=["#D20F39"],
                background="#585B70", **powerlineroundedleft
            ),
            widget.Spacer(),
            widget.Systray(
                background="#BAC2DE", **powerlineright,
            ),
            #widget.Spacer(length=8),
            widget.CurrentLayout(
                fmt=" {}",
                foreground='000000',
                background="#EA999C", **powerlineright,
            ),
            #widget.Spacer(length=8),
            BrightnessWidget(),
            #widget.Spacer(length=8),
            VolumeWidget(),
            #widget.Spacer(length=8),
            nerd_dictation(),
            #widget.Spacer(length=8),
            widget.GenPollText(
                name="updates",
                update_interval=30,
                func=lambda: subprocess.run(
                    [get_script_path("OpenFlexOS_UpdateCheck.sh")],
                    capture_output=True,
                    text=True
                ).stdout.strip(),
                background="#E64553",
                foreground="#000000",
                mouse_callbacks={
                    'Button1': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_UpdateCheck.sh") + " -u"),
                    'Button3': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_UpdateCheck.sh") + " -v"),
                },
                **powerlineright,
            ),
            battery_widget(),
            #widget.Spacer(length=8),
            nmcli_widget,  # (Network Widget) A Script runs and displays an icon depending on if connected to wifi, ethernet, or disconnected
            #widget.Spacer(length=8),
            ssh_widget,
            #widget.Spacer(length=8),
            current_user_widget,
            widget.Spacer(length=8),
            widget.TextBox(
                text="",
                foreground='000000',
                background="#FAB387", **powerlineright,
                mouse_callbacks={
                'Button1': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_Power.sh") + " -d"),
                'Button3': lambda: qtile.cmd_spawn(get_script_path("OpenFlexOS_Power.sh") + " -r"),
                },
            ),
        ]
    return widgets_list

def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    return widgets_screen1 

def init_widgets_screen2():
    widgets_screen2 = init_widgets_list()
    # Remove Widgets by counting the number of widgets and use the number of that widget starting from 0, EG remove first widget use 0 [0] or [0:4] below
    # 10=systray
    del widgets_screen2[10]
    return widgets_screen2

def init_screens():
    return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), margin=[20, 18, 0, 18], size=24, background="#1e1e2e59")),
            Screen(top=bar.Bar(widgets=init_widgets_screen2(), margin=[10, 13, 0, 13], size=34, background="#1e1e2e59")),
            Screen(top=bar.Bar(widgets=init_widgets_screen2(), margin=[10, 13, 0, 13], size=24, background="#1e1e2e59"))]

if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()

#############################################################
############### Variables ###################################
#############################################################
# Alternative modifier key (Alt key)
alt = "mod1"

# Primary modifier key (Super/Windows key)
mod = "mod4"

# Automatically detect the default terminal emulator
terminal = guess_terminal()

# Define workspaces/groups (1-9) for window management
groups = [Group(i) for i in "123456789"]

# No key bindings for dynamically assigned groups
dgroups_key_binder = None

# No specific application rules for dynamic groups
dgroups_app_rules = []  # type: list

# Focus follows the mouse cursor when hovering over a window
follow_mouse_focus = True

# Clicking on a window does not bring it to the front
bring_front_click = False

# Keep floating windows above tiled windows
floats_kept_above = True

# Disable cursor warping when switching focus between windows
cursor_warp = False

# Enable automatic fullscreen for certain applications
auto_fullscreen = True

# Automatically focus on newly opened windows based on context
focus_on_window_activation = "smart"

# Reload screen configurations when they change (e.g., external monitors)
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on thef
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

#############################################################
############### KeyBindings #################################
#############################################################

keys = [

# My Key Chords
    KeyChord([alt], "a", [
        Key([], "d", lazy.spawn(get_script_path("OpenFlexOS_Applications.sh") + " -d"), desc="Dmenu"),
        Key([], "r", lazy.spawn(get_script_path("OpenFlexOS_Applications.sh") + " -r"), desc="Rofi"),
    ], mode="Launcher"),

    KeyChord([alt], "p", [
        Key([], "d", lazy.spawn(get_script_path("OpenFlexOS_Power.sh") + " -d"), desc="Dmenu"),
        Key([], "r", lazy.spawn(get_script_path("OpenFlexOS_Power.sh") + " -r"), desc="Rofi"),
    ], mode="Power"),

    KeyChord([alt], "s", [
        Key([], "d", lazy.spawn(get_script_path("OpenFlexOS_SSH.sh") + " -d"), desc="Dmenu"),
        Key([], "r", lazy.spawn(get_script_path("OpenFlexOS_SSH.sh") + " -r"), desc="Rofi"),
    ], mode="SSH"),

    KeyChord([alt], "n", [
        Key([], "d", lazy.spawn(get_script_path("OpenFlexOS_Network.sh") + " -d"), desc="Dmenu"),
        Key([], "r", lazy.spawn(get_script_path("OpenFlexOS_Network.sh") + " -r"), desc="Rofi"),
    ], mode="Network"),

    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Grow/resize Windows in monadtall
    Key([mod], "i", lazy.layout.grow()),
    Key([mod], "m", lazy.layout.shrink()),

    # Grow/shrink/resize in floating mode
    Key([alt], "l", resize_floating_window(width=10), desc="Increase width by 10"),
    Key([alt], "h", resize_floating_window(width=-10), desc="Decrease width by 10"),
    Key([alt], "j", resize_floating_window(height=10), desc="Increase height by 10"),
    Key([alt], "k", resize_floating_window(height=-10), desc="Decrease height by 10"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),

    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),

    Key(
        [mod], "f", lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),

    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    # Start of My Config: setting my own keys
    Key([alt], "f", lazy.spawn("firefox"), desc="Launch Firefox"),
    Key([alt], "b", lazy.spawn("brave --password-store=basic"), desc="Launch Brave"),
    Key([mod, alt], "b", lazy.spawn([get_script_path("OpenFlexOS_NerdDictation.sh "), "start"]), desc="begin/start nerd dictation"),
    Key([mod, alt], "e", lazy.spawn([get_script_path("OpenFlexOS_NerdDictation.sh "), "stop"]), desc="end/stop nerd dictation"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(get_script_path("OpenFlexOS_Volume.sh") + " up"), desc="Increase volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn(get_script_path("OpenFlexOS_Volume.sh") + " down"), desc="Decrease volume"),
    Key([], "XF86AudioMute", lazy.spawn(get_script_path("OpenFlexOS_Volume.sh") + " mute"), desc="Mute/Unmute"),
    # End of My Config: setting my own keys
]

#############################################################
############### Miscellaneous ###############################
#############################################################
layouts = [
    layout.MonadTall(margin=15),
    layout.MonadWide(margin=15),
    layout.RatioTile(margin=15),
    layout.TreeTab(),
]

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=2,
)

floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="Galculator"),
        Match(wm_class="zenity"),
        Match(wm_class="tilda"),
    ]
)

extension_defaults = widget_defaults.copy()

#############################################################
############### For Loops ###################################
#############################################################

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )
