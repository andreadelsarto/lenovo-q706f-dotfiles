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
    signal saved(var appItem, bool isFullscreen, string customArgs, bool highPerf)

    property var currentApp: null
    property bool fullscreenEnabled: true
    property string extraArguments: ""
    property bool highPerformanceMode: false
    property string activeLang: Plasmoid.configuration.currentLanguage || "it"

    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    function open(appItem) {
        currentApp = appItem;
        fullscreenEnabled = true;
        extraArguments = "";
        highPerformanceMode = false;

        if (appItem && appItem.exec) {
            try {
                var raw = Plasmoid.configuration.appLaunchOptions || "{}";
                var map = JSON.parse(raw);
                if (map[appItem.exec]) {
                    var conf = map[appItem.exec];
                    if (conf.fullscreen !== undefined) fullscreenEnabled = conf.fullscreen;
                    if (conf.args !== undefined) extraArguments = conf.args;
                    if (conf.highPerf !== undefined) highPerformanceMode = conf.highPerf;
                }
            } catch(e) {}
        }

        opacity = 1.0;
        propsCard.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        root.closed();
    }

    function saveSettings() {
        if (currentApp && currentApp.exec) {
            try {
                var raw = Plasmoid.configuration.appLaunchOptions || "{}";
                var map = JSON.parse(raw);
                map[currentApp.exec] = {
                    fullscreen: fullscreenEnabled,
                    args: extraArguments,
                    highPerf: highPerformanceMode
                };
                Plasmoid.configuration.appLaunchOptions = JSON.stringify(map);
            } catch(e) {}
            root.saved(currentApp, fullscreenEnabled, extraArguments, highPerformanceMode);
        }
        root.close();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    // Semi-transparent backdrop
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.75 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Modal Card
    Rectangle {
        id: propsCard
        width: 440
        height: contentCol.implicitHeight + 40
        radius: 18
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#25344a"
        border.width: 1.5

        scale: root.opacity > 0 ? 1.0 : 0.92
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Kirigami.Icon {
                    width: 28
                    height: 28
                    source: "configure"
                    color: "#3daee9"
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: I18n.t("app_properties", root.activeLang)
                        color: "#ffffff"
                        font.pixelSize: 17
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.currentApp ? (root.currentApp.name || "") : ""
                        color: "#38bdf8"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: closeArea.containsMouse ? "#d32f2f" : "#1e293b"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 14
                        height: 14
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

            // Option 1: Fullscreen Toggle
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 10
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Kirigami.Icon { width: 22; height: 22; source: "view-fullscreen"; color: "#22c55e" }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true
                        Text { text: I18n.t("fullscreen_mode", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                        Text { text: "Forza avvio massimizzato senza bordi"; color: "#8a9ba8"; font.pixelSize: 10 }
                    }

                    QQC2.Switch {
                        checked: root.fullscreenEnabled
                        onCheckedChanged: root.fullscreenEnabled = checked
                    }
                }
            }

            // Option 2: Gaming Priority Boost
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 10
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Kirigami.Icon { width: 22; height: 22; source: "speedometer"; color: "#ef4444" }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true
                        Text { text: I18n.t("gaming_boost", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                        Text { text: I18n.t("gaming_boost_desc", root.activeLang); color: "#8a9ba8"; font.pixelSize: 10 }
                    }

                    QQC2.Switch {
                        checked: root.highPerformanceMode
                        onCheckedChanged: root.highPerformanceMode = checked
                    }
                }
            }

            // Option 3: Custom Command line arguments
            Rectangle {
                Layout.fillWidth: true
                height: 66
                radius: 10
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text { text: "PARAMETRI / ARGOMENTI DI AVVIO"; color: "#cbd5e1"; font.pixelSize: 10; font.weight: Font.Bold }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: "#0f1622"
                        border.color: "#2a3d57"
                        border.width: 1

                        TextInput {
                            id: argsInput
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "#ffffff"
                            font.pixelSize: 11
                            text: root.extraArguments
                            onTextChanged: root.extraArguments = text
                            selectByMouse: true
                        }
                    }
                }
            }

            // Buttons (Cancel / Save)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: cancelMouse.containsMouse ? "#223147" : "#16202e"
                    border.color: "#2a3d57"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: I18n.t("cancel", root.activeLang)
                        color: "#cbd5e1"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: saveMouse.containsMouse ? "#2980b9" : "#3daee9"

                    Text {
                        anchors.centerIn: parent
                        text: I18n.t("save", root.activeLang)
                        color: "#0e141d"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.saveSettings()
                    }
                }
            }
        }
    }
}
