#!/bin/bash

set -u

# Made for BORTED, https://github.com/Patryk55o/Borted/
# ---------------- CONFIG ----------------
CONFIG_FILE="config.json"
WEBHOOK_URL=""
SCREENSHOT_INTERVAL=20

X=961
Y=46
WIDTH=294
HEIGHT=43

TEMPLATE="./Resources/fullinventory.png"
MATCH_THRESHOLD=0.60
CLICK_INTERVAL=0.03

REGION_IMG="/tmp/region_latest.png"
MATCH_TXT="/tmp/match.txt"
LOOKING_DIRECTION="N"

PYTHON_LISTENER="./Resources/listener.py"

rerunreset=true
# ----------------------------------------

# ---------- Helpers ----------
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

hivetopineSTART () {
            sleep 0.5
            xdotool key Shift
            xdotool key Escape
            xdotool key r
            xdotool key Return
            sleep 6
            xdotool keydown w
            sleep 2
            xdotool keyup w
            xdotool keydown d
            sleep 10
            xdotool keyup d
            for i in 1 2 3 4; do
                xdotool key --delay 120 comma
            done
            xdotool keydown w
            sleep 2
            xdotool keyup w
            xdotool keydown d
            sleep 3
            xdotool keyup d
            xdotool keydown w
            sleep 4
            xdotool keyup w
            xdotool keydown d
            sleep 4
            xdotool keyup d
            xdotool keydown w
            sleep 10
            xdotool keyup w
            xdotool keydown s
            sleep 2
            xdotool keyup s
            xdotool keydown a
            sleep 2
            xdotool keyup a
            for i in 1 2 3 4; do
                xdotool key --delay 120 comma
            done
            xdotool keydown w
            sleep 3
            xdotool keyup w
            for i in 1 2; do
                xdotool key --delay 120 period
            done
            xdotool keydown w
            sleep 10
            xdotool keyup w
            for i in 1 2; do
                xdotool key --delay 120 period
            done
            xdotool keydown w
            sleep 6
            xdotool keyup w
            xdotool keydown a
            sleep 3
            xdotool keyup a
            xdotool keydown w
            sleep 10
            xdotool keyup w
            LOOKING_DIRECTION="N"
}

hivetopine () {
            xdotool keydown w
            sleep 2
            xdotool keyup w
            xdotool keydown d
            sleep 10
            xdotool keyup d
            for i in 1 2 3 4; do
                xdotool key --delay 120 comma
            done
            xdotool keydown w
            sleep 2
            xdotool keyup w
            xdotool keydown d
            sleep 3
            xdotool keyup d
            xdotool keydown w
            sleep 4
            xdotool keyup w
            xdotool keydown d
            sleep 4
            xdotool keyup d
            xdotool keydown w
            sleep 10
            xdotool keyup w
            xdotool keydown s
            sleep 2
            xdotool keyup s
            xdotool keydown a
            sleep 2
            xdotool keyup a
            for i in 1 2 3 4; do
                xdotool key --delay 120 comma
            done
            xdotool keydown w
            sleep 3
            xdotool keyup w
            for i in 1 2; do
                xdotool key --delay 120 period
            done
            xdotool keydown w
            sleep 10
            xdotool keyup w
            for i in 1 2; do
                xdotool key --delay 120 period
            done
            xdotool keydown w
            sleep 6
            xdotool keyup w
            xdotool keydown a
            sleep 3
            xdotool keyup a
            xdotool keydown w
            sleep 10
            xdotool keyup w
            LOOKING_DIRECTION="N"
}

startmacro() {
    (
    END_TIME=$((SECONDS + 3))
    while [ $SECONDS -lt $END_TIME ]; do
        xdotool click 1
        sleep "$CLICK_INTERVAL"
    done
    ) &
    xdotool keydown w
    for i in 1 2 3 4; do
        xdotool key --delay 120 comma
    done
    if [[ "$LOOKING_DIRECTION" == "N" ]]; then
        LOOKING_DIRECTION="S"
    else
        LOOKING_DIRECTION="N"
    fi
    sleep 2.5
    xdotool keyup w
}

pinetohive() {
    if [[ "$LOOKING_DIRECTION" == "S" ]]; then
        for i in 1 2 3 4; do
            xdotool key --delay 120 comma
        done
    fi
}



send_discord_message() {
    curl -s -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\":\"$1\"}" \
        "$WEBHOOK_URL" >/dev/null
}

send_region_screenshot() {
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    FILE="/tmp/screenshot_$TIMESTAMP.png"

    # Take a screenshot of the region
    maim -g "${WIDTH}x${HEIGHT}+${X}+${Y}" "$FILE"

    # Send to Discord
    if [ -s "$FILE" ]; then
        curl -s -F "file=@$FILE" \
             -F "payload_json={\"content\":\"Screenshot $TIMESTAMP → Match: $ECHOMATCH\"}" \
             "$WEBHOOK_URL"
    else
        echo "Screenshot failed: $FILE is empty."
    fi

    # Remove local file
    rm -f "$FILE"
}


cleanup() {
    echo "Stopping everything...",,,
    send_discord_message "🛑 Script stopped @ $(timestamp)"
    [ -n "${LISTENER_PID:-}" ] && kill "$LISTENER_PID" 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# ---------- Start Python listener ----------
python3 "$PYTHON_LISTENER" &
LISTENER_PID=$!

echo "Macro running. F1 = enable | F2 = stop"
echo "This macro is for pine ONLY, you can manually go to other areas but it will break so i dont recommend"

# ---------- Global hotkeys ----------
xbindkeys -f <(cat <<EOF
"jq '.enabled=true' $CONFIG_FILE | sponge $CONFIG_FILE"
    F1
"jq '.enabled=false' $CONFIG_FILE | sponge $CONFIG_FILE"
    F2
EOF
) &

LAST_SCREENSHOT=0
STARTED=false
did_run=false

# ---------- Main Loop ----------
while true; do
    ENABLED=$(jq -r '.enabled' "$CONFIG_FILE")

    if [ "$ENABLED" != "true" ]; then
        sleep 0.2
        continue
    fi

    if ! $did_run; then
        did_run=true
        hivetopineSTART
    fi


    # ---- Capture region ----
    maim -g ${WIDTH}x${HEIGHT}+${X}+${Y} "$REGION_IMG"

    # ---- Template match ----
    compare -metric NCC "$TEMPLATE" "$REGION_IMG" null: 2> "$MATCH_TXT"
    MATCH=$(cat "$MATCH_TXT")
    ECHOMATCH=$(echo "$MATCH * 100" | bc)
    echo "$ECHOMATCH"
    echo "$LOOKING_DIRECTION"

    if awk -v m="$MATCH" -v t="$MATCH_THRESHOLD" 'BEGIN{exit !(m>=t)}'; then
        echo "$(timestamp) → INVENTORY FULL"
        send_region_screenshot
        cleanup
    fi

    # ---- Periodic screenshot ----
    NOW=$(date +%s)
    if (( NOW - LAST_SCREENSHOT >= SCREENSHOT_INTERVAL )); then
        send_region_screenshot
        LAST_SCREENSHOT=$NOW
    fi

    startmacro


done
