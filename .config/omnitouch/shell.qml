import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: "OmniTouch OS"

    // Palette OLED / Dark Modern
    readonly property color bgDark: "#09090b"
    readonly property color barBg: "#f0121216"
    readonly property color accentColor: "#6366f1"
    readonly property color textPrimary: "#f4f4f5"
    readonly property color textSecondary: "#a1a1aa"
    readonly property color cardBg: "#18181f"

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#14141d" }
            GradientStop { position: 1.0; color: root.bgDark }
        }
    }

    // =========================================================================
    // 1. TOP STATUS BAR (Trasparente / Blur Look)
    // =========================================================================
    header: Rectangle {
        id: topStatusBar
        height: 48
        color: root.barBg
        z: 100

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 16

            // Logo / Nome Shell
            RowLayout {
                spacing: 8
                Text {
                    text: "OmniTouch"
                    color: root.accentColor
                    font.pixelSize: 15
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
                    font.pixelSize: 13
                }
            }

            Item { Layout.fillWidth: true }

            // Orologio Centrale
            Text {
                id: clockText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                color: root.textPrimary
                font.pixelSize: 15
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
                spacing: 14

                Text {
                    text: "📶 Wi-Fi"
                    color: root.textSecondary
                    font.pixelSize: 13
                }

                Text {
                    text: "🔋 100%"
                    color: root.textSecondary
                    font.pixelSize: 13
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
        anchors.fill: parent

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 28
            width: Math.min(parent.width - 60, 680)

            // Card di Benvenuto
            Rectangle {
                Layout.fillWidth: true
                height: 150
                radius: 20
                color: root.cardBg
                border.color: "#2e2e38"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 10

                    Text {
                        text: "OmniTouch Shell"
                        color: root.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Text {
                        text: "Ambiente sperimentale touch-first per Lenovo Tab P11/P12 Pro (Q706F).\nEsecuzione nativa su Wayland."
                        color: root.textSecondary
                        font.pixelSize: 14
                        lineHeight: 1.3
                    }
                }
            }

            // Quick App Launcher Pills
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Repeater {
                    model: [
                        { name: "Terminale", icon: "📟", exec: "konsole" },
                        { name: "Browser", icon: "🌐", exec: "firefox" },
                        { name: "File", icon: "📁", exec: "dolphin" },
                        { name: "Impostazioni", icon: "⚙️", exec: "systemsettings" }
                    ]

                    Rectangle {
                        width: 130
                        height: 100
                        radius: 18
                        color: btnArea.containsPress ? "#312e81" : (btnArea.containsMouse ? "#272732" : root.cardBg)
                        border.color: btnArea.containsPress ? root.accentColor : "#2e2e38"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                font.pixelSize: 32
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.name
                                color: root.textPrimary
                                font.pixelSize: 13
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
    footer: Rectangle {
        id: bottomNavBar
        height: 64
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
            spacing: 80

            // Pulsante Indietro (Back)
            Rectangle {
                width: 52
                height: 52
                radius: 26
                color: backArea.containsPress ? "#3f3f46" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "◀"
                    color: root.textPrimary
                    font.pixelSize: 20
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
                width: 160
                height: 10
                radius: 5
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
                width: 52
                height: 52
                radius: 26
                color: overviewArea.containsPress ? "#3f3f46" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "▢"
                    color: root.textPrimary
                    font.pixelSize: 22
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
