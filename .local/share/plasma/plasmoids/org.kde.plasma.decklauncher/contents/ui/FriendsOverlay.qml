import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "i18n.js" as I18n

Item {
    id: root
    anchors.fill: parent
    visible: opacity > 0
    opacity: 0.0

    signal closed()
    signal profileUpdated(string newName, string newAvatar)

    property string activeLang: Plasmoid.configuration.currentLanguage || "it"
    property bool isScanning: false

    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    function open() {
        opacity = 1.0;
        drawerBox.x = root.width - drawerBox.width;
        drawerBox.forceActiveFocus();
        refreshKdeConnect();
    }

    function close() {
        opacity = 0.0;
        drawerBox.x = root.width;
        root.closed();
    }

    ListModel {
        id: kdeDevicesModel
    }

    Plasma5Support.DataSource {
        id: kdeConnectSource
        engine: "executable"
        connectedSources: []

        onNewData: function(src, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            disconnectSource(src);
            root.isScanning = false;

            if (!stdout || stdout.length === 0) return;

            var lines = stdout.split("\n");
            var seenIds = {};
            var parsedDevices = [];

            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.startsWith("- ")) {
                    var raw = line.substring(2);
                    var colonIdx = raw.indexOf(":");
                    if (colonIdx !== -1) {
                        var dName = raw.substring(0, colonIdx).trim();
                        var rest = raw.substring(colonIdx + 1).trim();
                        var dId = rest.split(" ")[0].trim();
                        var isReachable = rest.indexOf("reachable") !== -1;
                        var isPaired = rest.indexOf("paired") !== -1;
                        var isPhone = dName.toLowerCase().indexOf("pc") === -1 && dName.toLowerCase().indexOf("desktop") === -1 && dName.toLowerCase().indexOf("laptop") === -1;

                        if (!seenIds[dId]) {
                            seenIds[dId] = true;
                            parsedDevices.push({
                                deviceId: dId,
                                deviceName: dName,
                                deviceType: isPhone ? "phone" : "desktop",
                                status: isPaired ? (isReachable ? "Connesso & Sincronizzato" : "Dispositivo Associato") : "Disponibile per Associazione",
                                isReachable: isReachable,
                                isPaired: isPaired
                            });
                        }
                    }
                }
            }

            kdeDevicesModel.clear();
            for (var j = 0; j < parsedDevices.length; j++) {
                kdeDevicesModel.append(parsedDevices[j]);
            }
        }
    }

    function refreshKdeConnect() {
        root.isScanning = true;
        kdeConnectSource.connectSource("export XDG_RUNTIME_DIR=/run/user/10000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; kdeconnect-cli --refresh; sleep 1; kdeconnect-cli -l; kdeconnect-cli -a");
    }

    function triggerRing(deviceId) {
        if (!deviceId) return;
        kdeConnectSource.connectSource("export XDG_RUNTIME_DIR=/run/user/10000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; kdeconnect-cli -d " + deviceId + " --ring");
    }

    function triggerPing(deviceId) {
        if (!deviceId) return;
        kdeConnectSource.connectSource("export XDG_RUNTIME_DIR=/run/user/10000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; kdeconnect-cli -d " + deviceId + " --ping");
    }

    function triggerPair(deviceId) {
        if (!deviceId) return;
        kdeConnectSource.connectSource("export XDG_RUNTIME_DIR=/run/user/10000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/10000/bus; kdeconnect-cli -d " + deviceId + " --pair");
    }

    // Backdrop overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.65 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Slide-out Drawer Panel
    Rectangle {
        id: drawerBox
        width: 420
        height: parent.height
        x: root.width
        color: "#121924"
        border.color: "#223147"
        border.width: 1

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        Keys.onEscapePressed: root.close()
        Keys.onBackPressed: root.close()

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Header of Drawer
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Kirigami.Icon {
                    width: 24
                    height: 24
                    source: "user-identity"
                    color: "#3daee9"
                }

                Text {
                    text: I18n.t("profile_title", root.activeLang)
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: closeArea.containsMouse ? "#d32f2f" : "#1e293b"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: "dialog-close"
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: closeArea
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

            // User Profile Card
            Rectangle {
                Layout.fillWidth: true
                height: 130
                radius: 12
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: "#3daee9"

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                source: Plasmoid.configuration.customUserAvatar || "user-identity"
                                color: "#0e141d"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 30
                                    radius: 6
                                    color: "#0f1622"
                                    border.color: "#2a3d57"
                                    border.width: 1

                                    TextInput {
                                        id: nameInputField
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        text: Plasmoid.configuration.customUserName || "User"
                                        selectByMouse: true
                                    }
                                }

                                Rectangle {
                                    width: 65
                                    height: 30
                                    radius: 6
                                    color: saveNameMouse.containsMouse ? "#2980b9" : "#3daee9"

                                    Text {
                                        anchors.centerIn: parent
                                        text: I18n.t("save_name", root.activeLang)
                                        color: "#0e141d"
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: saveNameMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var n = nameInputField.text.trim();
                                            if (n.length > 0) {
                                                Plasmoid.configuration.customUserName = n;
                                                root.profileUpdated(n, Plasmoid.configuration.customUserAvatar || "user-identity");
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                text: "Online • postmarketOS ARM64"
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    // Avatar Presets
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text { text: "Avatar:"; color: "#94a3b8"; font.pixelSize: 11; font.weight: Font.DemiBold }

                        Repeater {
                            model: [
                                { icon: "user-identity", name: "User" },
                                { icon: "applications-games", name: "Gamer" },
                                { icon: "distributor-logo-plasma", name: "Plasma" },
                                { icon: "input-gaming", name: "Joypad" },
                                { icon: "computer", name: "PC" }
                            ]

                            Rectangle {
                                width: 26
                                height: 26
                                radius: 13
                                color: (Plasmoid.configuration.customUserAvatar || "user-identity") === modelData.icon ? "#3daee9" : "#223147"

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16
                                    source: modelData.icon
                                    color: (Plasmoid.configuration.customUserAvatar || "user-identity") === modelData.icon ? "#0e141d" : "#cbd5e1"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Plasmoid.configuration.customUserAvatar = modelData.icon;
                                        root.profileUpdated(Plasmoid.configuration.customUserName || "User", modelData.icon);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // KDE Connect Real Section Header & Refresh Action
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Kirigami.Icon {
                    width: 18
                    height: 18
                    source: "kdeconnect"
                    color: "#38bdf8"
                }

                Text {
                    text: "DISPOSITIVI SMARTPHONE & PC"
                    color: "#64748b"
                    font.pixelSize: 11
                    font.weight: Font.Black
                    font.letterSpacing: 0.8
                    Layout.fillWidth: true
                }

                Rectangle {
                    height: 26
                    width: scanText.implicitWidth + 18
                    radius: 13
                    color: scanMouse.containsMouse ? "#243247" : "#16202e"
                    border.color: "#25344a"
                    border.width: 1

                    RowLayout {
                        id: scanText
                        anchors.centerIn: parent
                        spacing: 4
                        Kirigami.Icon { width: 13; height: 13; source: "view-refresh"; color: "#38bdf8" }
                        Text { text: root.isScanning ? "Scansione..." : "Aggiorna"; color: "#e2ecf5"; font.pixelSize: 10; font.weight: Font.Bold }
                    }

                    MouseArea {
                        id: scanMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refreshKdeConnect()
                    }
                }
            }

            // Device List / Empty State
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent
                    visible: kdeDevicesModel.count === 0
                    spacing: 10

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        width: 48
                        height: 48
                        source: "kdeconnect"
                        color: "#475569"
                    }

                    Text {
                        text: "Nessun dispositivo KDE Connect rilevato"
                        color: "#94a3b8"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Apri l'app KDE Connect sul tuo smartphone\ne assicurati di essere connesso alla stessa rete Wi-Fi"
                        color: "#64748b"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                ListView {
                    anchors.fill: parent
                    visible: kdeDevicesModel.count > 0
                    spacing: 10
                    clip: true
                    model: kdeDevicesModel

                    delegate: Rectangle {
                        width: drawerBox.width - 36
                        height: 94
                        radius: 12
                        color: "#16202e"
                        border.color: model.isPaired ? "#38bdf8" : "#25344a"
                        border.width: model.isPaired ? 1.5 : 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Kirigami.Icon {
                                    width: 22
                                    height: 22
                                    source: model.deviceType === "desktop" ? "computer" : "smartphone"
                                    color: model.isPaired ? "#38bdf8" : "#64748b"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: model.deviceName
                                        color: "#ffffff"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: model.status
                                        color: model.isReachable ? "#4ade80" : "#38bdf8"
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            // Action Buttons
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    visible: model.isPaired
                                    Layout.fillWidth: true
                                    height: 26
                                    radius: 6
                                    color: ringMouse.containsMouse ? "#2980b9" : "#1f2d3d"
                                    border.color: "#38bdf8"
                                    border.width: 1

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Kirigami.Icon { width: 12; height: 12; source: "notifications"; color: "#38bdf8" }
                                        Text { text: "Squilla Telefono"; color: "#ffffff"; font.pixelSize: 9; font.weight: Font.Bold }
                                    }

                                    MouseArea {
                                        id: ringMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.triggerRing(model.deviceId)
                                    }
                                }

                                Rectangle {
                                    visible: model.isPaired
                                    Layout.fillWidth: true
                                    height: 26
                                    radius: 6
                                    color: pingMouse.containsMouse ? "#2980b9" : "#1f2d3d"
                                    border.color: "#38bdf8"
                                    border.width: 1

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Kirigami.Icon { width: 12; height: 12; source: "network-connect"; color: "#38bdf8" }
                                        Text { text: "Invia Ping"; color: "#ffffff"; font.pixelSize: 9; font.weight: Font.Bold }
                                    }

                                    MouseArea {
                                        id: pingMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.triggerPing(model.deviceId)
                                    }
                                }

                                Rectangle {
                                    visible: !model.isPaired
                                    Layout.fillWidth: true
                                    height: 26
                                    radius: 6
                                    color: pairMouse.containsMouse ? "#16a34a" : "#22c55e"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Associa Dispositivo"; color: "#0e141d"; font.pixelSize: 10; font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: pairMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.triggerPair(model.deviceId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
