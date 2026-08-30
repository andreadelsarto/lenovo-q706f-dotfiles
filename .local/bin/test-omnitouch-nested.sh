#!/usr/bin/env bash
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/10000}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export QT_QPA_PLATFORM=wayland

echo "==> Avvio anteprima OmniTouch (Canvas Push Pattern)..."
if command -v quickshell &> /dev/null; then
    quickshell --config "$HOME/.config/omnitouch/shell.qml"
elif command -v qml6 &> /dev/null; then
    qml6 "$HOME/.config/omnitouch/shell.qml"
else
    echo "Né quickshell né qml6 trovati."
fi
