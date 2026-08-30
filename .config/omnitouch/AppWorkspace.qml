import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: workspaceRoot
    color: "#020617"
    clip: true

    property bool drawerOpen: false
    signal toggleDrawer()
    signal closeDrawer()

    // 1. TOP BAR DELL'APP / WORKSPACE
    Rectangle {
        id: appHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 52
        color: "#0b1329"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            // Pulsante Menu Drawer
            Rectangle {
                width: 40
                height: 40
                radius: 10
                color: menuBtnArea.containsPress ? "#334155" : "#1e293b"
                border.color: "#38bdf8"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: workspaceRoot.drawerOpen ? "✕" : "☰"
                    color: "#38bdf8"
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    id: menuBtnArea
                    anchors.fill: parent
                    onClicked: workspaceRoot.toggleDrawer()
                }
            }

            Text {
                text: "OmniTouch Workspace"
                color: "#f8fafc"
                font.pixelSize: 16
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            // Orologio Digitale
            Text {
                id: wsClock
                text: Qt.formatTime(new Date(), "hh:mm")
                color: "#f1f5f9"
                font.pixelSize: 15
                font.bold: true

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: wsClock.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }

            Text {
                text: "🔋 100%"
                color: "#38bdf8"
                font.pixelSize: 13
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#1e293b"
        }
    }

    // 2. CONTENUTO CENTRALE APPLICAZIONE / DESKTOP
    Item {
        anchors.top: appHeader.bottom
        anchors.bottom: appFooter.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24
            width: Math.min(parent.width - 48, 640)

            // Card informativa principale
            Rectangle {
                Layout.fillWidth: true
                height: 150
                radius: 18
                color: "#0f172a"
                border.color: "#1e293b"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8

                    Text {
                        text: "Canvas-Push Navigation Pattern"
                        color: "#38bdf8"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        text: workspaceRoot.drawerOpen
                              ? "✨ Drawer attivo! L'app si è ridimensionata (scale: 0.82) con angoli arrotondati (radius: 24px) e offset X.\nTocca ovunque su questa scheda per ripristinare a tutto schermo."
                              : "Tocca ☰ Menu o fai uno swipe dal bordo sinistro per rivelare il drawer con animazione a molla fluida."
                        color: "#94a3b8"
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        lineHeight: 1.3
                    }
                }
            }

            // Quick App Grid
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Repeater {
                    model: [
                        { name: "Terminale", icon: "📟" },
                        { name: "Firefox", icon: "🌐" },
                        { name: "Dolphin", icon: "📁" },
                        { name: "Waydroid", icon: "🤖" }
                    ]

                    Rectangle {
                        width: 130
                        height: 90
                        radius: 16
                        color: qArea.containsPress ? "#334155" : "#0f172a"
                        border.color: qArea.containsPress ? "#38bdf8" : "#1e293b"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                font.pixelSize: 28
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.name
                                color: "#f8fafc"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: qArea
                            anchors.fill: parent
                            onClicked: console.log("Lancio rapido:", modelData.name)
                        }
                    }
                }
            }
        }
    }

    // 3. BOTTOM NAVIGATION BAR
    Rectangle {
        id: appFooter
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56
        color: "#0b1329"

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#1e293b"
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 80

            Text {
                text: "◀"
                color: "#94a3b8"
                font.pixelSize: 18
            }

            Rectangle {
                width: 140
                height: 8
                radius: 4
                color: "#475569"
            }

            Text {
                text: "▢"
                color: "#94a3b8"
                font.pixelSize: 20
            }
        }
    }

    // 4. EDGE SWIPE DETECTOR (Bordo sinistro per aprire con swipe)
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 30
        enabled: !workspaceRoot.drawerOpen

        property real startX: 0
        onPressed: (mouse) => startX = mouse.x
        onPositionChanged: (mouse) => {
            if (mouse.x - startX > 40) {
                workspaceRoot.toggleDrawer()
            }
        }
    }

    // 5. OVERLAY PER TOCCO CHIUSURA QUANDO RIDOTTO
    MouseArea {
        anchors.fill: parent
        enabled: workspaceRoot.drawerOpen
        onClicked: workspaceRoot.closeDrawer()
    }
}
