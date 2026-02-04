#!/bin/bash

CONFIG_FILE="config.json"

# Ask user if they want to start with R+Enter
CHOICE=$(yad --title="Macro Launcher" \
    --text="Start macro with R + Enter?" \
    --button="Yes":0 --button="No":1 --width=300 --height=100)

if [ $? -eq 0 ]; then
    sed -i 's/"start_with_r_enter": false/"start_with_r_enter": true/' "$CONFIG_FILE"
else
    sed -i 's/"start_with_r_enter": true/"start_with_r_enter": false/' "$CONFIG_FILE"
fi

# Ask user if macro should be enabled on startup
CHOICE=$(yad --title="Macro Launcher" \
    --text="Enable macro on startup?" \
    --button="Yes":0 --button="No":1 --width=300 --height=100)

if [ $? -eq 0 ]; then
    sed -i 's/"macro_enabled": false/"macro_enabled": true/' "$CONFIG_FILE"
else
    sed -i 's/"macro_enabled": true/"macro_enabled": false/' "$CONFIG_FILE"
fi

yad --info --text="Config updated! Start your macro script." --width=300 --height=100

cp ./config.json ./Resources/config.json
