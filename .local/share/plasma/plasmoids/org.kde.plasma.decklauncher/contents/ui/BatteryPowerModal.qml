import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import "i18n.js" as I18n

Item {
    id: root
    anchors.fill: parent
    visible: opacity > 0
    opacity: 0.0

    signal closed()
    signal powerProfileRequested(string profile)

    property int batteryPct: 23
    property bool isCharging: false
    property string powerRate: "6.60 W"
    property string voltage: "3.66 V"
    property string temperature: "33.2 °C"
    property string health: "84.1%"
    property string timeRemaining: "1.4 ore"
    property string powerProfile: "balanced"
    property string activeLang: Plasmoid.configuration.currentLanguage || "it"

    Behavior on opacity { NumberAnimation { duration: 200 } }

    Plasma5Support.DataSource {
        id: liveBatterySource
        engine: "executable"
        connectedSources: []

        onNewData: function(src, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            disconnectSource(src);

            if (!stdout || stdout.length === 0) return;
            var lines = stdout.split("\n");
            if (lines.length >= 5) {
                var cMicro = parseInt(lines[0]);
                var vMicro = parseInt(lines[1]);
                var cap = parseInt(lines[2]);
                var tempRaw = parseInt(lines[3]);
                var st = lines[4].trim().toLowerCase();

                if (!isNaN(cap)) root.batteryPct = cap;
                root.isCharging = (st === "charging" || st === "full");

                if (!isNaN(vMicro) && vMicro > 0) {
                    root.voltage = (vMicro / 1000000.0).toFixed(2) + " V";
                }

                if (!isNaN(cMicro) && !isNaN(vMicro) && vMicro > 0) {
                    var watts = (Math.abs(cMicro) * vMicro) / 1000000000000.0;
                    root.powerRate = watts.toFixed(2) + " W";

                    if (watts > 0 && !root.isCharging) {
                        var remainWh = (root.batteryPct / 100.0) * 28.0;
                        var remHrs = (remainWh / watts).toFixed(1);
                        root.timeRemaining = remHrs + " " + (root.activeLang === "it" ? "ore" : (root.activeLang === "en" ? "hours" : "hrs"));
                    } else if (root.isCharging) {
                        root.timeRemaining = "⚡ Fast Charge";
                    }
                }

                if (!isNaN(tempRaw) && tempRaw > 0) {
                    root.temperature = (tempRaw / 10.0).toFixed(1) + " °C";
                }
            }
        }
    }

    function fetchLiveBattery() {
        liveBatterySource.connectSource("cat /sys/class/power_supply/bq27541-0/current_now /sys/class/power_supply/bq27541-0/voltage_now /sys/class/power_supply/bq27541-0/capacity /sys/class/power_supply/bq27541-0/temp /sys/class/power_supply/bq27541-0/status");
    }

    Timer {
        id: livePollTimer
        interval: 1200
        repeat: true
        running: false
        onTriggered: root.fetchLiveBattery()
    }

    function open(pct, charging) {
        if (pct !== undefined) batteryPct = pct;
        if (charging !== undefined) isCharging = charging;
        fetchLiveBattery();
        opacity = 1.0;
        livePollTimer.restart();
        batteryModalCard.forceActiveFocus();
    }

    function close() {
        livePollTimer.stop();
        opacity = 0.0;
        root.closed();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.75 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    Rectangle {
        id: batteryModalCard
        width: 480
        height: cardCol.implicitHeight + 44
        radius: 20
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#25344a"
        border.width: 1.5

        scale: root.opacity > 0 ? 1.0 : 0.92
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        ColumnLayout {
            id: cardCol
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: root.batteryPct <= 20 ? "#450a0a" : "#0f2d1e"
                    border.color: root.batteryPct <= 20 ? "#ef4444" : "#22c55e"
                    border.width: 1.5

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        source: root.isCharging ? "battery-charging" : "battery-good"
                        color: root.batteryPct <= 20 ? "#ef4444" : "#22c55e"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 8
                        Text {
                            text: I18n.t("battery_title", root.activeLang)
                            color: "#ffffff"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                        }

                        Rectangle {
                            width: 46
                            height: 18
                            radius: 9
                            color: "#0284c7"
                            Text {
                                anchors.centerIn: parent
                                text: "LIVE"
                                color: "#ffffff"
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }
                    }

                    Text {
                        text: root.batteryPct + "% • " + (root.isCharging ? "⚡ Charging" : root.timeRemaining)
                        color: "#8a9ba8"
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: closeBtnMouse.containsMouse ? "#d32f2f" : "#1e293b"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 14
                        height: 14
                        source: "dialog-close"
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: closeBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#1e293b"
            }

            // Real Battery Hardware Metrics Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                // Metric 1: Consumo Istantaneo
                Rectangle {
                    Layout.fillWidth: true
                    height: 64
                    radius: 12
                    color: "#16202e"
                    border.color: "#25344a"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        Text { text: I18n.t("power_consumption", root.activeLang); color: "#38bdf8"; font.pixelSize: 8; font.weight: Font.Black }
                        RowLayout {
                            Kirigami.Icon { width: 16; height: 16; source: "speedometer"; color: "#38bdf8" }
                            Text { text: root.powerRate; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        }
                    }
                }

                // Metric 2: Tensione Elettrica
                Rectangle {
                    Layout.fillWidth: true
                    height: 64
                    radius: 12
                    color: "#16202e"
                    border.color: "#25344a"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        Text { text: I18n.t("voltage", root.activeLang); color: "#64748b"; font.pixelSize: 8; font.weight: Font.Black }
                        RowLayout {
                            Kirigami.Icon { width: 16; height: 16; source: "flash"; color: "#facc15" }
                            Text { text: root.voltage; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        }
                    }
                }

                // Metric 3: Temperatura Sensore
                Rectangle {
                    Layout.fillWidth: true
                    height: 64
                    radius: 12
                    color: "#16202e"
                    border.color: "#25344a"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        Text { text: I18n.t("temperature", root.activeLang); color: "#64748b"; font.pixelSize: 8; font.weight: Font.Black }
                        RowLayout {
                            Kirigami.Icon { width: 16; height: 16; source: "temperature-normal"; color: "#fb923c" }
                            Text { text: root.temperature; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        }
                    }
                }

                // Metric 4: Stato Salute
                Rectangle {
                    Layout.fillWidth: true
                    height: 64
                    radius: 12
                    color: "#16202e"
                    border.color: "#25344a"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        Text { text: I18n.t("battery_health", root.activeLang); color: "#64748b"; font.pixelSize: 8; font.weight: Font.Black }
                        RowLayout {
                            Kirigami.Icon { width: 16; height: 16; source: "health"; color: "#4ade80" }
                            Text { text: root.health; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        }
                    }
                }
            }

            // Power Profile Selector
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text { text: I18n.t("power_profiles", root.activeLang); color: "#cbd5e1"; font.pixelSize: 11; font.weight: Font.Bold }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { id: "power-saver", nameKey: "profile_saver", icon: "battery-low", color: "#22c55e" },
                            { id: "balanced", nameKey: "profile_balanced", icon: "battery-good", color: "#38bdf8" },
                            { id: "performance", nameKey: "profile_perf", icon: "speedometer", color: "#ef4444" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: 8
                            color: root.powerProfile === modelData.id ? "#223348" : "#141c28"
                            border.color: root.powerProfile === modelData.id ? modelData.color : "#25344a"
                            border.width: root.powerProfile === modelData.id ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Kirigami.Icon { width: 16; height: 16; source: modelData.icon; color: modelData.color }
                                Text { text: I18n.t(modelData.nameKey, root.activeLang); color: "#ffffff"; font.pixelSize: 11; font.weight: Font.DemiBold }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerProfile = modelData.id;
                                    root.powerProfileRequested(modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Close Button
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 10
                color: closeBottomMouse.containsMouse ? "#2980b9" : "#3daee9"

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("close", root.activeLang)
                    color: "#0e141d"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: closeBottomMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }
    }
}
