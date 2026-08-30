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
    signal actionTriggered(string actionId)

    Behavior on opacity { NumberAnimation { duration: 200 } }

    function open() {
        opacity = 1.0;
        powerModal.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        root.closed();
    }

    // Dark backdrop overlay
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
        id: powerModal
        width: 580
        height: 480
        radius: 20
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#223147"
        border.width: 1.5

        scale: root.opacity > 0 ? 1.0 : 0.92
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        Keys.onEscapePressed: root.close()
        Keys.onBackPressed: root.close()

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 20

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Kirigami.Icon {
                    width: 28
                    height: 28
                    source: "system-shutdown"
                    color: "#ef4444"
                }

                Text {
                    text: "Menu di Spegnimento e Sessione"
                    color: "#ffffff"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: closeBtnArea.containsMouse ? "#d32f2f" : "#1e293b"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: "dialog-close"
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: closeBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }

            // Power Actions Grid
            GridView {
                id: powerGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 260
                cellHeight: 90
                clip: true
                focus: true

                model: ListModel {
                    ListElement {
                        actionId: "suspend"
                        title: "Sospendi"
                        subtitle: "Metti in standby rapido"
                        iconName: "system-suspend"
                        accentColor: "#3daee9"
                    }
                    ListElement {
                        actionId: "reboot"
                        title: "Riavvia Sistema"
                        subtitle: "Riavvio completo del PC"
                        iconName: "system-reboot"
                        accentColor: "#f59e0b"
                    }
                    ListElement {
                        actionId: "poweroff"
                        title: "Spegni"
                        subtitle: "Arresto completo del sistema"
                        iconName: "system-shutdown"
                        accentColor: "#ef4444"
                    }
                    ListElement {
                        actionId: "lock"
                        title: "Blocca Schermo"
                        subtitle: "Proteggi la sessione attiva"
                        iconName: "system-lock-screen"
                        accentColor: "#a855f7"
                    }
                    ListElement {
                        actionId: "logout"
                        title: "Termina Sessione"
                        subtitle: "Disconnetti l'utente corrente"
                        iconName: "system-log-out"
                        accentColor: "#64748b"
                    }
                    ListElement {
                        actionId: "desktop_mode"
                        title: "Passa al Desktop"
                        subtitle: "Ritorna a KDE Plasma Desktop"
                        iconName: "user-desktop"
                        accentColor: "#10b981"
                    }
                }

                Keys.onLeftPressed: {
                    if (currentIndex % 2 === 1) currentIndex--;
                }
                Keys.onRightPressed: {
                    if (currentIndex % 2 === 0 && currentIndex < count - 1) currentIndex++;
                }
                Keys.onUpPressed: {
                    if (currentIndex >= 2) currentIndex -= 2;
                }
                Keys.onDownPressed: {
                    if (currentIndex + 2 < count) currentIndex += 2;
                }
                Keys.onReturnPressed: {
                    var item = model.get(currentIndex);
                    executeAction(item.actionId);
                }
                Keys.onEnterPressed: Keys.onReturnPressed(event)

                function executeAction(act) {
                    root.actionTriggered(act);
                    root.close();
                }

                delegate: Item {
                    width: 250
                    height: 80

                    readonly property bool isSelected: powerGrid.currentIndex === index && powerGrid.activeFocus
                    readonly property bool isHovered: btnMouse.containsMouse

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: isSelected ? "#24344d" : (isHovered ? "#1a2638" : "#16202e")
                        border.color: isSelected ? model.accentColor : (isHovered ? "#2d4260" : "#223147")
                        border.width: isSelected ? 2 : 1

                        scale: isSelected ? 1.03 : (isHovered ? 1.01 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Rectangle {
                                width: 44
                                height: 44
                                radius: 12
                                color: "#0f1622"
                                border.color: model.accentColor
                                border.width: 1

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: model.iconName
                                    color: model.accentColor
                                }
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                Text {
                                    text: model.title
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: model.subtitle
                                    color: "#8a9ba8"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                powerGrid.currentIndex = index;
                                powerGrid.executeAction(model.actionId);
                            }
                        }
                    }
                }
            }

            // Footer info
            Text {
                text: "Premi B o Esc per annullare • Frecce direzionali o D-Pad per navigare"
                color: "#64748b"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
