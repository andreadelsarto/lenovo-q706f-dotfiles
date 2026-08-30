import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "i18n.js" as I18n

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal closeRequested()
    signal checkUpdatesRequested()
    signal applyUpdatesRequested()

    property string activeLang: Plasmoid.configuration.currentLanguage || "it"
    property bool isChecking: false
    property int totalUpdatesCount: 0
    property string lastCheckTime: "Ora"
    property string updateStatusMsg: ""

    Keys.onEscapePressed: root.closeRequested()
    Keys.onBackPressed: root.closeRequested()

    ListModel {
        id: realUpdatesModel
    }

    Plasma5Support.DataSource {
        id: updatesSource
        engine: "executable"
        connectedSources: []

        onNewData: function(src, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            disconnectSource(src);
            root.isChecking = false;

            if (!stdout || stdout.length === 0) {
                realUpdatesModel.clear();
                root.totalUpdatesCount = 0;
                return;
            }

            var lines = stdout.split("\n");
            var isApkSection = false;
            var list = [];

            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim();
                if (l === "---APK_UPDATES---") {
                    isApkSection = true;
                    continue;
                }

                if (isApkSection) {
                    if (l.indexOf("<") !== -1) {
                        var parts = l.split("<");
                        var left = parts[0].trim();
                        var right = parts[1].trim();

                        var lastHyphen = left.lastIndexOf("-");
                        var pkgName = left;
                        var currVer = "";
                        if (lastHyphen !== -1) {
                            var secondHyphen = left.lastIndexOf("-", lastHyphen - 1);
                            if (secondHyphen !== -1) {
                                pkgName = left.substring(0, secondHyphen);
                                currVer = left.substring(secondHyphen + 1);
                            } else {
                                pkgName = left.substring(0, lastHyphen);
                                currVer = left.substring(lastHyphen + 1);
                            }
                        }

                        if (pkgName.endsWith("-lang") || pkgName.endsWith("-pyc") || pkgName.endsWith("-doc")) continue;

                        list.push({
                            pkgName: pkgName,
                            category: "postmarketOS / Alpine Linux",
                            currentVer: currVer || "Installata",
                            newVer: right,
                            size: "Sistema",
                            type: "Sistema",
                            icon: "system-software-update"
                        });
                    }
                } else {
                    var fpParts = l.split("\t");
                    if (fpParts.length >= 3) {
                        var fpName = fpParts[0].trim();
                        var fpId = fpParts[1].trim();
                        var fpVer = fpParts[2].trim();

                        list.push({
                            pkgName: fpName,
                            category: "Flatpak (" + fpId + ")",
                            currentVer: "Installata",
                            newVer: fpVer || "Nuovo Rilascio",
                            size: "Flatpak",
                            type: "Flatpak",
                            icon: "applications-games"
                        });
                    }
                }
            }

            realUpdatesModel.clear();
            for (var j = 0; j < list.length; j++) {
                realUpdatesModel.append(list[j]);
            }
            root.totalUpdatesCount = list.length;
            root.lastCheckTime = Qt.formatTime(new Date(), "hh:mm:ss");
        }
    }

    function scanUpdates() {
        root.isChecking = true;
        root.updateStatusMsg = "Verifica repository Flatpak e postmarketOS in corso...";
        var cmd = "flatpak remote-ls --updates 2>/dev/null; echo '---APK_UPDATES---'; apk version -v -l '<' 2>/dev/null";
        updatesSource.connectSource(cmd);
    }

    Component.onCompleted: scanUpdates()

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Top Navigation & Action Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    id: backBtn
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: backLayout.implicitWidth + 24
                    radius: 19
                    color: backMouse.containsMouse ? "#3daee9" : "#1a2536"
                    border.color: backMouse.containsMouse ? "#66c0f4" : "#2e405a"
                    border.width: 1

                    RowLayout {
                        id: backLayout
                        anchors.centerIn: parent
                        spacing: 8

                        Kirigami.Icon {
                            width: 16
                            height: 16
                            source: "go-previous"
                            color: backMouse.containsMouse ? "#0e141d" : "#ffffff"
                        }

                        Text {
                            text: I18n.t("back", root.activeLang)
                            color: backMouse.containsMouse ? "#0e141d" : "#ffffff"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 0.5
                        }
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeRequested()
                    }
                }

                Item { Layout.fillWidth: true }

                // Check for Updates Button
                Rectangle {
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: checkLayout.implicitWidth + 22
                    radius: 19
                    color: checkMouse.containsMouse ? "#243247" : "#16202e"
                    border.color: "#3daee9"
                    border.width: 1

                    RowLayout {
                        id: checkLayout
                        anchors.centerIn: parent
                        spacing: 6

                        Kirigami.Icon {
                            width: 15
                            height: 15
                            source: "view-refresh"
                            color: "#3daee9"
                        }

                        Text {
                            text: root.isChecking ? "Controllo in corso..." : I18n.t("updates_check", root.activeLang)
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: checkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.scanUpdates()
                    }
                }

                // Apply Updates (Discover) Button
                Rectangle {
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: applyLayout.implicitWidth + 24
                    radius: 19
                    color: applyMouse.containsMouse ? "#22c55e" : "#16a34a"

                    RowLayout {
                        id: applyLayout
                        anchors.centerIn: parent
                        spacing: 6

                        Kirigami.Icon {
                            width: 16
                            height: 16
                            source: "software-update-available"
                            color: "#0e141d"
                        }

                        Text {
                            text: I18n.t("updates_apply", root.activeLang)
                            color: "#0e141d"
                            font.pixelSize: 12
                            font.weight: Font.Black
                        }
                    }

                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.applyUpdatesRequested()
                    }
                }
            }

            // Summary Info Banner
            Rectangle {
                Layout.fillWidth: true
                height: 54
                radius: 12
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 14

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: root.totalUpdatesCount > 0 ? "#f59e0b" : "#22c55e"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            source: root.totalUpdatesCount > 0 ? "software-update-available" : "security-high"
                            color: "#0e141d"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.totalUpdatesCount > 0 ? (root.totalUpdatesCount + " AGGIORNAMENTI DISPONIBILI") : "SISTEMA COMPLETAMENTE AGGIORNATO"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.letterSpacing: 0.5
                        }

                        Text {
                            text: "Ultimo controllo: " + root.lastCheckTime + " • Flatpak & repository postmarketOS/Alpine"
                            color: "#8a9ba8"
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // STRICTLY ALIGNED TABLE HEADER
            Rectangle {
                visible: root.totalUpdatesCount > 0
                Layout.fillWidth: true
                height: 32
                radius: 8
                color: "#0f1622"
                border.color: "#1e293b"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "PACCHETTO / ORIGINE"
                        color: "#64748b"
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "VERSIONE ATTUALE"
                        color: "#64748b"
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 170
                    }

                    Text {
                        text: "NUOVA VERSIONE"
                        color: "#64748b"
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 170
                    }
                }
            }

            // Real Updates List View
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Empty State: All Up to date
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !root.isChecking && root.totalUpdatesCount === 0
                    spacing: 12

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        width: 54
                        height: 54
                        source: "security-high"
                        color: "#22c55e"
                    }

                    Text {
                        text: I18n.t("updates_up_to_date", root.activeLang)
                        color: "#ffffff"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Tutti i tuoi giochi, emulatori e pacchetti di sistema sono all'ultima versione disponibile."
                        color: "#64748b"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                ListView {
                    id: updatesListView
                    anchors.fill: parent
                    visible: root.totalUpdatesCount > 0
                    clip: true
                    spacing: 6
                    model: realUpdatesModel

                    delegate: Rectangle {
                        width: updatesListView.width
                        height: 52
                        radius: 10
                        color: "#16202e"
                        border.color: itemHoverMouse.containsMouse ? "#38bdf8" : "#25344a"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12

                            // Col 1: Icon + App/Package Name & Origin
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 8
                                    color: "#0f1622"
                                    border.color: "#25344a"
                                    border.width: 1

                                    Kirigami.Icon {
                                        anchors.centerIn: parent
                                        width: 18
                                        height: 18
                                        source: model.icon || "system-software-update"
                                        color: model.type === "Flatpak" ? "#38bdf8" : "#22c55e"
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: model.pkgName
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: model.category
                                        color: "#8a9ba8"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            // Col 2: Currently Installed Version (Aligned, 170px, Non-overflowing)
                            Item {
                                Layout.preferredWidth: 170
                                height: parent.height

                                Rectangle {
                                    anchors.centerIn: parent
                                    height: 26
                                    width: parent.width - 10
                                    radius: 6
                                    color: "#0f1622"
                                    border.color: "#25344a"
                                    border.width: 1

                                    Text {
                                        id: currVerText
                                        anchors.centerIn: parent
                                        width: parent.width - 12
                                        text: model.currentVer
                                        color: "#94a3b8"
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            // Col 3: New Version Available (Aligned, 170px, Non-overflowing)
                            Item {
                                Layout.preferredWidth: 170
                                height: parent.height

                                Rectangle {
                                    anchors.centerIn: parent
                                    height: 26
                                    width: parent.width - 10
                                    radius: 6
                                    color: "#0f2017"
                                    border.color: "#166534"
                                    border.width: 1

                                    RowLayout {
                                        anchors.centerIn: parent
                                        width: parent.width - 12
                                        spacing: 4

                                        Kirigami.Icon {
                                            width: 10
                                            height: 10
                                            source: "arrow-up"
                                            color: "#4ade80"
                                        }

                                        Text {
                                            id: newVerText
                                            Layout.fillWidth: true
                                            text: model.newVer
                                            color: "#4ade80"
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            horizontalAlignment: Text.AlignHCenter
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: itemHoverMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
