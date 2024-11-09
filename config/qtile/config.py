from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

import os
import subprocess
from libqtile import hook

@lazy.function
def resize_floating_window(qtile, width: int = 0, height: int = 0):
    w = qtile.current_window
    w.cmd_set_size_floating(w.width + width, w.height + height)


def get_current_user():
    return subprocess.check_output(["/bin/bash", "-c", "echo $USER"]).decode().strip()

current_user_widget = widget.TextBox(
    text=get_current_user(),
    foreground='#ffe135',  # Choose your desired color
)

def get_script_path(script_name):
    home_dir = os.path.expanduser("~")
    return os.path.join(home_dir, ".config", "qtile", "scripts", script_name)

def battery_widget():
    if os.path.exists("/sys/class/power_supply/BAT0"):
        return widget.Battery(
            battery="BAT0",
            charge_char="󰂄 ",
            discharge_char="  ",
            format="{char} {percent:2.0%}",
            full_char="",
            update_interval=1,
            foreground='#0048ba'  # Absolute Zero
        )
    else:
        return widget.TextBox(text="", width=0)

# Start of my config: To increase and decrease volume
from libqtile.widget import TextBox

class VolumeWidget(TextBox):
    def __init__(self):
        super().__init__(text="Vol", foreground="#ace1af")  # Celadon
        self.update_volume()

        # Add callbacks to the widget
        self.add_callbacks({'Button1': self.on_left_click, 'Button3': self.on_right_click})

    def update_volume(self):
        # Run your volume.sh script to get the volume level or mute state
        result = subprocess.run([get_script_path("volume.sh")], capture_output=True, text=True)
        self.text = result.stdout.strip()
        self.draw()

    def on_left_click(self):
        subprocess.run([get_script_path("volume.sh"), "up"])
        self.update_volume()

    def on_right_click(self):
        subprocess.run([get_script_path("volume.sh"), "down"])
        self.update_volume()

class BrightnessWidget(TextBox):
    def __init__(self):
        super().__init__(text="Vol", foreground="#ace1af")  # Celadon
        self.brightness()

        # Add callbacks to the widget
        self.add_callbacks({'Button1': self.on_left_click, 'Button3': self.on_right_click})

    def brightness(self):
        # Run your brightness.sh script to get the volume level or mute state
        result = subprocess.run([get_script_path("brightness.sh")], capture_output=True, text=True)
        self.text = result.stdout.strip()
        self.draw()

    def on_left_click(self):
        subprocess.run([get_script_path("brightness.sh"), "up"])
        self.brightness()
        

    def on_right_click(self):
        subprocess.run([get_script_path("brightness.sh"), "down"])
        self.brightness()
        

# Create an instance of VolumeWidget
volume_widget = VolumeWidget()
# End of my config: To increase and decrease volume

# Start of My Config: (Network Widget) A Script runs and displays an icon depending on if connected to wifi, ethernet, or disconnected
def get_nmcli_output():
    return subprocess.check_output([get_script_path("nmcli.sh")]).decode("utf-8").strip()

script_widget = widget.GenPollText(
    func=get_nmcli_output,
    update_interval=1,
    fmt='{} ',  # You can customize the formatting here
    mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(get_script_path("rofi-wifi-menu.sh"))},
    foreground='#d2691e',  # Chocolate
)
# End of My Config: (Network Widget) A Script runs and displays an icon depending on if connected to wifi, ethernet, or disconnected


ssh_widget = widget.TextBox(
    text="SSH",  # Choose a suitable icon (here's an SSH-related icon)
    foreground='#d2691e',  # Chocolate color, same as your other widgets
    mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(get_script_path("ssh.sh"))},
)


# Start of My Config: Adding a mod key for my personal scripts and launching apps
alt = "mod1"
# End of My Config: Adding a mod key for my personal scripts and launching apps

# Start of My Config: Script to launch things at login
@hook.subscribe.startup_once
def autostart():
    script = get_script_path('autostart.sh')
    subprocess.Popen([script])
# End of My Config: Script to launch things at login

mod = "mod4"
terminal = guess_terminal()

keys = [
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
    # shrink/resize Windows in monadtall
     Key([mod], "m", lazy.layout.shrink()),
    
    # Grow/shrink/resize in floating mode
    Key([alt], "l", resize_floating_window(width=10), desc='increase width by 10'),
    Key([alt], "h", resize_floating_window(width=-10), desc='decrease width by 10'),
    Key([alt], "j", resize_floating_window(height=10), desc='increase height by 10'),
    Key([alt], "k", resize_floating_window(height=-10), desc='decrease height by 10'),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    # Start of My Config: setting my own keys
    Key([alt], "q", lazy.spawn(get_script_path("power.sh")), desc="powermenu"),
    Key([alt], "d", lazy.spawn(get_script_path("applications.sh")), desc="menu"),  
    Key([alt], "f", lazy.spawn("firefox")),
    # End of My Config: setting my own keys
]

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

groups = [Group(i) for i in "123456789"]

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

layouts = [
    # Start of My Config: Added margin of 15 to default layouts and move them up  
    layout.MonadTall(margin=15),
    layout.MonadWide(margin=15),
    layout.RatioTile(margin=15),
    layout.TreeTab(),
    # End Start of My Config: Added margin of 15 to default layouts and move them up  
]

widget_defaults = dict(
    font="sans",
    fontsize=15,
    padding=3,
)
extension_defaults = widget_defaults.copy()

# Start of My Config: Added and moved widgets
screens = [
    Screen(
        top=bar.Bar(
            [
                widget.TextBox(
                    text=" ",
                    foreground='#00ffff',  # Aqua
                    mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(get_script_path("applications.sh"))}
                ),
                widget.Spacer(length=10),
                widget.Clock(
                    foreground='#4666ff',  # Neon Blue
                    format="  %a %d-%m-%Y",
                    #format="  %a %d-%B-%Y",
                ),
                widget.Spacer(length=10),
                widget.Clock(
                    foreground='#ffe135',  # Banana Yellow
                    format="  %I:%M:%S %p",
                ),
                widget.Spacer(length=10),
                widget.CPU(
                    format='   {load_percent}%', 
                    foreground='#ff5800',  # Orange (Crayola)
                ),
                widget.Spacer(length=10),
                widget.Memory(
                    foreground='#ccff00',  # Electric Lime
                    format='   {MemPercent}%',
                ),
                widget.Spacer(),
                widget.GroupBox(
                    active='#ffd700',  # Gold1
                ),
                widget.WindowName(
                    foreground='#39ff14',  # Neon Greenf
                    max_chars=70
                ),
                widget.Systray(),
                widget.Spacer(length=20),
                widget.CurrentLayout(
                    foreground='#fc74fd',  # Pink Flamingo
                ),
                widget.Spacer(length=10),
                BrightnessWidget(),
                VolumeWidget(),
                widget.Spacer(length=10),
                widget.CheckUpdates(
                    distro="Arch",
                    colour_have_updates='#f38fa9',
                    colour_no_updates='#f38fa9', 
                    display_format='󰇚 {updates}',
                ),
                widget.Spacer(length=10),
                battery_widget(),
                widget.Spacer(length=10),
                script_widget,  # (Network Widget) A Script runs and displays an icon depending on if connected to wifi, ethernet, or disconnected
                ssh_widget,
                widget.Spacer(length=10),
                current_user_widget,
                widget.TextBox(
                    text="⏻ ",
                    foreground='#00ff7f',  # SpringGreen1
                    mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(get_script_path("power.sh"))},
                ),
                # End of My Config: Added and moved widgets
            ],
            24,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
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
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
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
