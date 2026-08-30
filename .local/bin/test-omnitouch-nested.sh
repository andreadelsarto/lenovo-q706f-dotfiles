#!/usr/bin/env bash
kwin_wayland --socket=wayland-test --width 1280 --height 800 &
KWIN_PID=$!
sleep 1
if command -v quickshell &> /dev/null; then
    WAYLAND_DISPLAY=wayland-test quickshell --config "$HOME/.config/omnitouch/shell.qml"
elif command -v qml6 &> /dev/null; then
    echo "QuickShell non trovato nel PATH, esecuzione preview con qml6..."
    WAYLAND_DISPLAY=wayland-test qml6 "$HOME/.config/omnitouch/shell.qml"
else
    echo "Né quickshell né qml6 trovati per il rendering QML."
fi
kill $KWIN_PID 2>/dev/null
