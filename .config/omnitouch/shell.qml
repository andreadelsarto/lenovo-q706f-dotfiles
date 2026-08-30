import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1280
    height: 800
    visible: true

    // Palette OLED / Dark Modern
    readonly property color bgDark: "#09090b"
    readonly property color barBg: "#cc121214"
    readonly property color accentColor: "#6366f1"
    readonly property color textPrimary: "#f4f4f5"
    readonly property color textSecondary: "#a1a1aa"
    readonly property color cardBg: "#1e1e24"

    // Sfondo Principale
    Rectangle {
        anchors.fill: parent
        color: root.bgDark

        // Gradiente radiale decorativo sottile
        RadialGradient {
            anchors.fill: parent
            opacity: 0.15
        }
    }

    // =========================================================================
    // 1. TOP STATUS BAR (Trasparente / Blur Look)
    // =========================================================================
    Rectangle {
        id: topStatusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 38
        color: root.barBg
        z: 100

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 16

            // Logo / Nome Shell
            Text {
                text: "OmniTouch"
                color: root.accentColor
                font.pixelSize: 13
                font.bold: true
                font.letterSpacing: 0.5
            }

            Text {
                text: "•"
                color: root.textSecondary
                font.pixelSize: 10
            }

            Text {
                text: "Wayland"
                color: root.textSecondary
                font.pixelSize: 12
            }

            Item { Layout.fillWidth: true }

            // Orologio Centrale
            Text {
                id: clockText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                color: root.textPrimary
                font.pixelSize: 14
                font.bold: true

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }

            Item { Layout.fillWidth: true }

            // Indicatori di stato (Wi-Fi, Batteria, Sessione)
            RowLayout {
                spacing: 12

                Text {
                    text: "📶 Wi-Fi"
                    color: root.textSecondary
                    font.pixelSize: 12
                }

                Text {
                    text: "🔋 100%"
                    color: root.textSecondary
                    font.pixelSize: 12
                }
            }
        }

        // Bordo inferiore sottile
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#27272a"
        }
    }

    // =========================================================================
    // 2. CONTENUTO CENTRALE / SKELETON WORKSPACE
    // =========================================================================
    Item {
        anchors.top: topStatusBar.bottom
        anchors.bottom: bottomNavBar.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24
            width: Math.min(parent.width - 40, 600)

            // Card di Benvenuto
            Rectangle {
                Layout.fillWidth: true
                height: 160
                radius: 16
                color: root.cardBg
                border.color: "#27272a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 8

                    Text {
                        text: "Benvenuto in OmniTouch OS"
                        color: root.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Text {
                        text: "Ambiente sperimentale touch-first per Lenovo Tab P11/P12 Pro (Q706F).\nSessione isolata su postmarketOS edge."
                        color: root.textSecondary
                        font.pixelSize: 14
                        lineHeight: 1.3
                    }
                }
            }

            // Quick App Launcher Pills
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Repeater {
                    model: [
                        { name: "Terminale", icon: "📟", exec: "konsole" },
                        { name: "Browser", icon: "🌐", exec: "firefox" },
                        { name: "File", icon: "📁", exec: "dolphin" },
                        { name: "Impostazioni", icon: "⚙️", exec: "systemsettings" }
                    ]

                    Rectangle {
                        width: 120
                        height: 90
                        radius: 14
                        color: btnArea.containsPress ? "#312e81" : (btnArea.containsMouse ? "#2e2e38" : root.cardBg)
                        border.color: btnArea.containsPress ? root.accentColor : "#27272a"

                        Behavior on color { ColorAnimation { duration: 150 } }

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
                                color: root.textPrimary
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: btnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                console.log("Avvio app:", modelData.exec)
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // 3. BOTTOM NAVIGATION BAR (Touch Dock)
    // =========================================================================
    Rectangle {
        id: bottomNavBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: root.barBg
        z: 100

        // Bordo superiore sottile
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#27272a"
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 60

            // Pulsante Indietro (Back)
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: backArea.containsPress ? "#3f3f46" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "◀"
                    color: root.textPrimary
                    font.pixelSize: 18
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    onClicked: console.log("Nav: Back")
                }
            }

            // Barra Home Pill (Stile Gestures Touch)
            Rectangle {
                id: homePill
                width: 140
                height: 8
                radius: 4
                color: pillArea.containsPress ? root.accentColor : "#71717a"

                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    id: pillArea
                    anchors.fill: parent
                    anchors.margins: -16
                    onClicked: console.log("Nav: Home Gesture / Apps")
                }
            }

            // Pulsante Overview / Task Switcher
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: overviewArea.containsPress ? "#3f3f46" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "▢"
                    color: root.textPrimary
                    font.pixelSize: 20
                }

                MouseArea {
                    id: overviewArea
                    anchors.fill: parent
                    onClicked: console.log("Nav: Overview / Tasks")
                }
            }
        }
    }
}
