import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: drawerRoot
    color: "#0f172a"
    clip: true

    signal itemSelected(string name)
    signal closeRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // Header Drawer (Profilo Utente / Logo)
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: "#1e293b"
                border.color: "#38bdf8"
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text: "👤"
                    font.pixelSize: 20
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "OmniTouch OS"
                    color: "#f8fafc"
                    font.pixelSize: 18
                    font.bold: true
                }
                Text {
                    text: "Lenovo Tab P11/P12 Pro"
                    color: "#38bdf8"
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }
        }

        // Separatore sottile
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#1e293b"
        }

        // Lista Categorie e Applicazioni
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [
                        { name: "Tutte le Applicazioni", icon: "📦", desc: "Launcher touch-first" },
                        { name: "Terminale & Script", icon: "📟", desc: "Konsole, htop, zsh" },
                        { name: "File & Documenti", icon: "📁", desc: "Dolphin storage manager" },
                        { name: "Navigazione Web", icon: "🌐", desc: "Firefox Wayland" },
                        { name: "Emulazione & Giochi", icon: "🎮", desc: "DeckLauncher, RetroArch" },
                        { name: "Dotfiles Wayback", icon: "🔄", desc: "Snapshot e rollback Git" },
                        { name: "Impostazioni Schermo", icon: "⚙️", desc: "120Hz, OLED Dark, Touch" }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 54
                        radius: 14
                        color: navMouse.containsPress ? "#334155" : (navMouse.containsMouse ? "#1e293b" : "transparent")

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14

                            Text {
                                text: modelData.icon
                                font.pixelSize: 22
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.name
                                    color: "#f1f5f9"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Text {
                                    text: modelData.desc
                                    color: "#64748b"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                drawerRoot.itemSelected(modelData.name)
                            }
                        }
                    }
                }
            }
        }

        // Footer Sistema
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 12
            color: "#1e293b"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text { text: "🔋"; font.pixelSize: 16 }
                Text {
                    text: "postmarketOS Edge"
                    color: "#94a3b8"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: "120Hz"
                    color: "#38bdf8"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }
    }
}
