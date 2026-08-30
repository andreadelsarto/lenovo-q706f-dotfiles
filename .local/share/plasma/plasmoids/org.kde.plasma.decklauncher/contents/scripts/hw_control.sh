#!/bin/sh
ACTION="$1"
VALUE="$2"

export XDG_RUNTIME_DIR=/run/user/10000
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus

case "$ACTION" in
    "get_brightness")
        CUR=$(cat /sys/class/backlight/*/brightness 2>/dev/null | head -n 1)
        MAX=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -n 1)
        if [ -n "$CUR" ] && [ -n "$MAX" ] && [ "$MAX" -gt 0 ]; then
            echo $((CUR * 100 / MAX))
        else
            echo 40
        fi
        ;;
    "set_brightness")
        if [ -n "$VALUE" ]; then
            TARGET=$((VALUE * 100))
            qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness "$TARGET" >/dev/null 2>&1
        fi
        ;;
    "get_volume")
        VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o '[0-9]\+%' | head -n 1 | tr -d '%')
        if [ -n "$VOL" ]; then
            echo "$VOL"
        else
            echo 50
        fi
        ;;
    "set_volume")
        if [ -n "$VALUE" ]; then
            pactl set-sink-volume @DEFAULT_SINK@ "${VALUE}%" >/dev/null 2>&1
        fi
        ;;
    *)
        echo "Usage: hw_control.sh [get_brightness|set_brightness <val>|get_volume|set_volume <val>]"
        ;;
esac
