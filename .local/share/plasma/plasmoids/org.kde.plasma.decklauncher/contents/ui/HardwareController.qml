import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root

    property int currentBrightness: 40
    property int currentVolume: 45
    property string activePowerProfile: "balanced"

    signal volumeUpdated(int vol)
    signal brightnessUpdated(int bright)

    Plasma5Support.DataSource {
        id: execEngine
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            var stderr = (data["stderr"] || "").toString().trim();

            if (sourceName.indexOf("get-sink-volume") !== -1) {
                var m = stdout.match(/([0-9]+)%/);
                if (m && m[1]) {
                    var v = parseInt(m[1]);
                    if (!isNaN(v)) {
                        root.currentVolume = v;
                        root.volumeUpdated(v);
                    }
                }
            } else if (sourceName.indexOf("BrightnessControl.brightness") !== -1) {
                var bVal = parseInt(stdout);
                if (!isNaN(bVal)) {
                    var bPct = Math.round(bVal / 100);
                    root.currentBrightness = bPct;
                    root.brightnessUpdated(bPct);
                }
            }

            disconnectSource(sourceName);
        }
    }

    function runCmd(cmd) {
        if (!cmd || cmd.length === 0) return;
        execEngine.connectSource(cmd);
    }

    function setBrightness(pct) {
        var safePct = Math.max(5, Math.min(100, Math.round(pct)));
        var targetVal = safePct * 100;
        root.currentBrightness = safePct;
        runCmd("export XDG_RUNTIME_DIR=/run/user/10000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness " + targetVal);
    }

    function setVolume(pct) {
        var safeVol = Math.max(0, Math.min(100, Math.round(pct)));
        root.currentVolume = safeVol;
        runCmd("pactl set-sink-volume @DEFAULT_SINK@ " + safeVol + "%");
    }

    function setPowerProfile(profile) {
        if (profile === "power-saver" || profile === "balanced" || profile === "performance") {
            root.activePowerProfile = profile;
            runCmd("powerprofilesctl set " + profile);
        }
    }

    function refreshHardware() {
        runCmd("pactl get-sink-volume @DEFAULT_SINK@");
        runCmd("export XDG_RUNTIME_DIR=/run/user/10000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightness");
    }

    Component.onCompleted: {
        refreshHardware();
    }
}
