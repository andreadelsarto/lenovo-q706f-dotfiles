import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "i18n.js" as I18n

Item {
    id: root
    anchors.fill: parent
    visible: opacity > 0
    opacity: 0.0

    signal closed()
    signal brightnessChanged(int val)
    signal volumeChanged(int val)
    signal gamingBoostToggled(bool enabled)

    property int brightnessVal: 65
    property int volumeVal: 55
    property bool gamingBoost: false
    property string activeLang: Plasmoid.configuration.currentLanguage || "it"

    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    function open() {
        opacity = 1.0;
        drawerCard.x = root.width - drawerCard.width;
        drawerCard.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        drawerCard.x = root.width;
        root.closed();
    }

    // Semi-transparent backdrop overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.65 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Slide-out Right Panel
    Rectangle {
        id: drawerCard
        width: 390
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
            spacing: 16

            // Drawer Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: "#0284c7"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: "quickopen"
                        color: "#ffffff"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: I18n.t("quick_access_title", root.activeLang)
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Lenovo Tab P12 Pro • postmarketOS"
                        color: "#8a9ba8"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: closeQuickMouse.containsMouse ? "#d32f2f" : "#1e293b"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: "dialog-close"
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: closeQuickMouse
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

            // Real Hardware Tablet Storage Indicator (193.9 GB Total NVMe / eMMC)
            Rectangle {
                Layout.fillWidth: true
                height: 72
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
                        Kirigami.Icon { width: 16; height: 16; source: "drive-harddisk"; color: "#3daee9" }
                        Text { text: I18n.t("storage_title", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold; Layout.fillWidth: true }
                        Text { text: "193.9 GB Disponibili"; color: "#38bdf8"; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: "#0f1622"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.22
                            radius: 4
                            color: "#22c55e"
                        }
                    }
                }
            }

            // Brightness Control Slider
            Rectangle {
                Layout.fillWidth: true
                height: 88
                radius: 12
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Kirigami.Icon { width: 16; height: 16; source: "contrast"; color: "#facc15" }
                        Text { text: I18n.t("brightness_title", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.fillWidth: true }
                        Text { text: root.brightnessVal + "%"; color: "#facc15"; font.pixelSize: 12; font.weight: Font.Bold }
                    }

                    QQC2.Slider {
                        Layout.fillWidth: true
                        from: 10
                        to: 100
                        stepSize: 5
                        value: root.brightnessVal
                        onMoved: {
                            root.brightnessVal = Math.round(value);
                            root.brightnessChanged(root.brightnessVal);
                        }
                    }
                }
            }

            // Volume Control Slider
            Rectangle {
                Layout.fillWidth: true
                height: 88
                radius: 12
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Kirigami.Icon { width: 16; height: 16; source: "audio-volume-high"; color: "#38bdf8" }
                        Text { text: I18n.t("volume_title", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.fillWidth: true }
                        Text { text: root.volumeVal + "%"; color: "#38bdf8"; font.pixelSize: 12; font.weight: Font.Bold }
                    }

                    QQC2.Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        stepSize: 5
                        value: root.volumeVal
                        onMoved: {
                            root.volumeVal = Math.round(value);
                            root.volumeChanged(root.volumeVal);
                        }
                    }
                }
            }

            // Gaming Performance Boost Toggle
            Rectangle {
                Layout.fillWidth: true
                height: 72
                radius: 12
                color: "#16202e"
                border.color: root.gamingBoost ? "#ef4444" : "#25344a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Kirigami.Icon { width: 22; height: 22; source: "speedometer"; color: root.gamingBoost ? "#ef4444" : "#94a3b8" }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        Text { text: I18n.t("gaming_boost", root.activeLang); color: "#ffffff"; font.pixelSize: 13; font.weight: Font.Bold }
                        Text { text: I18n.t("gaming_boost_desc", root.activeLang); color: "#8a9ba8"; font.pixelSize: 10 }
                    }

                    QQC2.Switch {
                        checked: root.gamingBoost
                        onCheckedChanged: {
                            root.gamingBoost = checked;
                            root.gamingBoostToggled(checked);
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Close Button
            Rectangle {
                Layout.fillWidth: true
                height: 42
                radius: 10
                color: closeBottomMouse.containsMouse ? "#2980b9" : "#3daee9"

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("close", root.activeLang)
                    color: "#0e141d"
                    font.pixelSize: 13
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
