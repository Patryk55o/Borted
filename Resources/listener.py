from pynput import keyboard
import json
import os
import signal
import sys

CONFIG_PATH = "config.json"

def set_config(enabled: bool):
    with open(CONFIG_PATH, "r") as f:
        cfg = json.load(f)
    cfg["enabled"] = enabled
    with open(CONFIG_PATH, "w") as f:
        json.dump(cfg, f, indent=4)

def on_press(key):
    try:
        if key == keyboard.Key.f1:
            print("F1 pressed → enabling macro")
            set_config(True)
        elif key == keyboard.Key.f2:
            print("F2 pressed → stopping macro and exiting listener")
            set_config(False)
            # Kill parent shell script
            os.kill(os.getppid(), signal.SIGTERM)
            # Exit listener
            return False
    except Exception as e:
        print("Error:", e)

listener = keyboard.Listener(on_press=on_press)
listener.start()
listener.join()
