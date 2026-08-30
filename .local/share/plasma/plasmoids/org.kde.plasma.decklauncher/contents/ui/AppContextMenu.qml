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
    signal playRequested(var appItem)
    signal toggleFavoriteRequested(var appItem)
    signal openPropertiesRequested(var appItem)
    signal manageDiscoverRequested(var appItem)

    property var currentApp: null
    property string activeLang: Plasmoid.configuration.currentLanguage || "it"

    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    function open(appItem) {
        currentApp = appItem;
        opacity = 1.0;
        menuCard.scale = 1.0;
        menuCard.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        menuCard.scale = 0.92;
        root.closed();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    // Semi-transparent dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.70 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Modal Menu Card
    Rectangle {
        id: menuCard
        width: 380
        height: cardContent.implicitHeight + 40
        radius: 18
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#25344a"
        border.width: 1.5

        scale: 0.92
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Header (Icon + App Title)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 52
                    height: 52
                    radius: 14
                    color: "#1a2536"
                    border.color: "#3daee9"
                    border.width: 1

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 36
                        height: 36
                        source: root.currentApp ? (root.currentApp.iconName || "application-x-executable") : "application-x-executable"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: root.currentApp ? (root.currentApp.name || "App") : "App"
                        color: "#ffffff"
                        font.pixelSize: 17
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.currentApp ? (root.currentApp.category || root.currentApp.genericName || "Applicazione") : "Applicazione"
                        color: "#8a9ba8"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#1e293b"
            }

            // Menu Actions List
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // 1. Play / Launch
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 10
                    color: playMouse.containsMouse ? "#22c55e" : "#16202e"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Kirigami.Icon {
                            width: 20
                            height: 20
                            source: "media-playback-start"
                            color: playMouse.containsMouse ? "#0e141d" : "#4ade80"
                        }

                        Text {
                            text: I18n.t("launch", root.activeLang)
                            color: playMouse.containsMouse ? "#0e141d" : "#ffffff"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var app = root.currentApp;
                            root.close();
                            root.playRequested(app);
                        }
                    }
                }

                // 2. Toggle Favorite
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 10
                    color: favMouse.containsMouse ? "#243347" : "#16202e"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Kirigami.Icon {
                            width: 20
                            height: 20
                            source: "favorite"
                            color: "#f59e0b"
                        }

                        Text {
                            text: I18n.t("toggle_fav_add", root.activeLang)
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: favMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var app = root.currentApp;
                            root.close();
                            root.toggleFavoriteRequested(app);
                        }
                    }
                }

                // 3. Properties (Fullscreen & custom launch options)
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 10
                    color: propMouse.containsMouse ? "#243347" : "#16202e"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Kirigami.Icon {
                            width: 20
                            height: 20
                            source: "configure"
                            color: "#3daee9"
                        }

                        Text {
                            text: I18n.t("app_properties", root.activeLang)
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: propMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var app = root.currentApp;
                            root.close();
                            root.openPropertiesRequested(app);
                        }
                    }
                }

                // 4. Manage in Discover
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 10
                    color: discMouse.containsMouse ? "#243347" : "#16202e"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Kirigami.Icon {
                            width: 20
                            height: 20
                            source: "plasmagetter"
                            color: "#a855f7"
                        }

                        Text {
                            text: I18n.t("manage_discover", root.activeLang)
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: discMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var app = root.currentApp;
                            root.close();
                            root.manageDiscoverRequested(app);
                        }
                    }
                }
            }

            // Close Action
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: "#1e293b"

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("cancel", root.activeLang)
                    color: "#94a3b8"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }
    }
}
