import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Item {
    id: root
    anchors.fill: parent
    visible: opacity > 0
    opacity: 0.0

    signal closed()

    property string ssid: "TIM-75484303"
    property int signalLevel: 78
    property string ipAddress: "192.168.1.14"

    Behavior on opacity { NumberAnimation { duration: 200 } }

    function open(currentSsid, currentSignal) {
        if (currentSsid) ssid = currentSsid;
        if (currentSignal) signalLevel = currentSignal;
        opacity = 1.0;
        wifiCard.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        root.closed();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    // Semi-transparent dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.75 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Centered Modal Floating Card (Guaranteed ON TOP of everything!)
    Rectangle {
        id: wifiCard
        width: 380
        height: wifiCol.implicitHeight + 40
        radius: 20
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#25344a"
        border.width: 1.5

        scale: root.opacity > 0 ? 1.0 : 0.92
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        ColumnLayout {
            id: wifiCol
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#1b344d"
                    border.color: "#38bdf8"
                    border.width: 1.5

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        source: "network-wireless-connected-100"
                        color: "#38bdf8"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: "Connessione Wi-Fi"
                        color: "#ffffff"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.ssid
                        color: "#38bdf8"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
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

            // Signal Strength Progress Bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Potenza Segnale"; color: "#cbd5e1"; font.pixelSize: 11; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    Text { text: root.signalLevel + "% (Ottimo)"; color: "#4ade80"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#1a2536"

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * (root.signalLevel / 100.0)
                        radius: 4
                        color: "#22c55e"
                    }
                }
            }

            // Network Info Fields
            Rectangle {
                Layout.fillWidth: true
                height: 90
                radius: 12
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Indirizzo IP Locale:"; color: "#8a9ba8"; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.ipAddress; color: "#ffffff"; font.pixelSize: 11; font.weight: Font.Bold }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Interfaccia Hardware:"; color: "#8a9ba8"; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: "wlan0 (Qualcomm Wi-Fi)"; color: "#ffffff"; font.pixelSize: 11 }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Crittografia:"; color: "#8a9ba8"; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: "WPA2-Personal (5 GHz)"; color: "#38bdf8"; font.pixelSize: 11 }
                    }
                }
            }

            // Close Button
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 10
                color: closeBtnBottomMouse.containsMouse ? "#2980b9" : "#3daee9"

                Text {
                    anchors.centerIn: parent
                    text: "CHIUDI"
                    color: "#0e141d"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: closeBtnBottomMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }
    }
}
