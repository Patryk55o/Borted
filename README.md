<p align='center'>
<img src="https://github.com/Patryk55o/Borted/blob/main/BraveBee.png">
</p>

<h1 align='center'> Borted</h1>
A bss (Bee Swarm Simulator) macro written in shell (and python for keybinds) for linux, TESTED ON DEBIAN 13/trixie. I do not know If it works on other distros.

# Information
Are you tired of waiting for macros from popular macro makers to port their macros into linux? Borted comes and fixes that issue. Though this project isnt complete YET...
If you need to macro you can go check out this repo <a href="https://github.com/painvision/BeeTuxMacro"> BeeTuxMacro </a>. I support this macro

This macro supports webhooks, so edit the file and EDIT the WEBHOOK_URL to have your webhook.

I also dont know if it works on anything other than KDE Plasma X11

# Guide/How to Start.
<h1> IMPORTANT YOU MUST HAVE 100% SCALE DISPLAY, Roblox on full screen windowed mode</h1>

Debian Based distros/Packages That are needed to start/do anything in the macro. Just run

```
sudo apt install -y jq maim imagemagick xdotool xbindkeys curl python3 python3-venv
pip install pynput
```
If you have Debian run IN THE MACRO DIRECTORY,

```
python3 -m venv .
source ./bin/activate
```

To start the macro press F1, to stop F2

# Things that i plan to add:

| Fields               |  Features |
|----------------------|-----------|
|  ✅ Pine Tree Field  | ❌ Auto Sprinkler
|  ❌ Rose Field       | ❌ GUI for settings
|  ❌ Pineapple Field  | ❌ Disconnect Recognition
|  ❌ Cocount Field    | ❌ Auto Claim Hive
