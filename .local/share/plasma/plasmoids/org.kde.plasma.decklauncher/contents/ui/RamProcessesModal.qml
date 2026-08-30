import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "i18n.js" as I18n

Item {
    id: root
    anchors.fill: parent
    visible: opacity > 0
    opacity: 0.0

    signal closed()

    property string activeLang: Plasmoid.configuration.currentLanguage || "it"
    property string ramSummaryUsed: "0 GB"
    property string ramSummaryTotal: "0 GB"
    property int ramSummaryPct: 0
    property bool isRefreshing: false

    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    function open() {
        opacity = 1.0;
        ramPollTimer.start();
        pollProcesses();
        modalCard.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        ramPollTimer.stop();
        root.closed();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    ListModel {
        id: processesModel
    }

    Plasma5Support.DataSource {
        id: ramProcSource
        engine: "executable"
        connectedSources: []

        onNewData: function(src, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            disconnectSource(src);
            root.isRefreshing = false;

            if (!stdout || stdout.length === 0) return;

            var lines = stdout.split("\n");
            var isMemInfo = false;
            var procList = [];

            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim();
                if (l === "---MEMINFO---") {
                    isMemInfo = true;
                    continue;
                }

                if (isMemInfo) {
                    var mParts = l.split(" ");
                    if (mParts.length >= 2) {
                        var totKb = parseInt(mParts[0]);
                        var availKb = parseInt(mParts[1]);
                        if (!isNaN(totKb) && !isNaN(availKb) && totKb > 0) {
                            var usedKb = totKb - availKb;
                            root.ramSummaryUsed = (usedKb / (1024 * 1024)).toFixed(1) + " GB";
                            root.ramSummaryTotal = (totKb / (1024 * 1024)).toFixed(1) + " GB";
                            root.ramSummaryPct = Math.round((usedKb / totKb) * 100);
                        }
                    }
                } else {
                    var pParts = l.split("|");
                    if (pParts.length >= 5) {
                        procList.push({
                            pid: pParts[0].trim(),
                            rss: pParts[1].trim(),
                            pmem: pParts[2].trim(),
                            pcpu: pParts[3].trim(),
                            comm: pParts[4].trim()
                        });
                    }
                }
            }

            processesModel.clear();
            for (var j = 0; j < procList.length; j++) {
                processesModel.append(procList[j]);
            }
        }
    }

    function pollProcesses() {
        root.isRefreshing = true;
        var cmd = "top -b -n 1 | tail -n +5 | grep -v ' top ' | head -n 10 | awk '{ " +
                  "pid = $1; rss = $5; pct = $6; cpu = $8; comm = \"\"; " +
                  "commFile = \"/proc/\" pid \"/comm\"; " +
                  "if ((getline comm < commFile) > 0) { close(commFile); } else { comm = $9; } " +
                  "print pid \"|\" rss \"|\" pct \"|\" cpu \"|\" comm; " +
                  "}'; echo '---MEMINFO---'; awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t \" \" a}' /proc/meminfo";
        ramProcSource.connectSource(cmd);
    }

    function killProcess(pid, comm) {
        if (!pid || pid === "1") return;
        ramProcSource.connectSource("kill -15 " + pid + " 2>/dev/null || kill -9 " + pid);
        pollProcesses();
    }

    Timer {
        id: ramPollTimer
        interval: 1500
        repeat: true
        running: false
        onTriggered: pollProcesses()
    }

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
        id: modalCard
        width: Math.min(parent.width - 32, 720)
        height: Math.min(parent.height - 32, 590)
        radius: 18
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#38bdf8"
        border.width: 1.5

        scale: root.opacity > 0 ? 1.0 : 0.94
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: "#16202e"
                    border.color: "#38bdf8"
                    border.width: 1.5

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: "memory"
                        color: "#38bdf8"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "TOP 10 PROCESSI PER CONSUMO RAM"
                        color: "#ffffff"
                        font.pixelSize: 15
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                    }

                    Text {
                        text: "Monitoraggio in tempo reale kernel Linux (1.5s)"
                        color: "#8a9ba8"
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
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

            // RAM Live Progress Summary Box
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 10
                color: "#16202e"
                border.color: "#25344a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Utilizzo Totale: " + root.ramSummaryUsed + " / " + root.ramSummaryTotal + " (" + root.ramSummaryPct + "%)"
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                        RowLayout {
                            spacing: 6

                            Rectangle {
                                id: pulsingDot
                                width: 8
                                height: 8
                                radius: 4
                                color: "#22c55e"

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: root.opacity > 0
                                    NumberAnimation { from: 1.0; to: 0.25; duration: 750; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 0.25; to: 1.0; duration: 750; easing.type: Easing.InOutQuad }
                                }
                            }

                            Text {
                                text: "LIVE"
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.weight: Font.Black
                                font.letterSpacing: 0.8
                            }
                        }
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
                            width: Math.max(4, parent.width * (root.ramSummaryPct / 100.0))
                            radius: 4
                            color: root.ramSummaryPct >= 85 ? "#ef4444" : (root.ramSummaryPct >= 65 ? "#facc15" : "#38bdf8")

                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        }
                    }
                }
            }

            // Table Header Bar
            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: 6
                color: "#0f1622"
                border.color: "#1e293b"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text { text: "#"; color: "#64748b"; font.pixelSize: 10; font.weight: Font.Bold; Layout.preferredWidth: 26 }
                    Text { text: "PROCESSO"; color: "#64748b"; font.pixelSize: 10; font.weight: Font.Bold; Layout.fillWidth: true }
                    Text { text: "PID"; color: "#64748b"; font.pixelSize: 10; font.weight: Font.Bold; Layout.preferredWidth: 55; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "RAM (RSS)"; color: "#64748b"; font.pixelSize: 10; font.weight: Font.Bold; Layout.preferredWidth: 95; horizontalAlignment: Text.AlignRight }
                    Text { text: "CPU"; color: "#64748b"; font.pixelSize: 10; font.weight: Font.Bold; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
                    Text { text: "AZIONE"; color: "#64748b"; font.pixelSize: 10; font.weight: Font.Bold; Layout.preferredWidth: 68; horizontalAlignment: Text.AlignHCenter }
                }
            }

            // Process List View
            ListView {
                id: procListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: processesModel

                delegate: Rectangle {
                    width: procListView.width
                    height: 33
                    radius: 6
                    color: index % 2 === 0 ? "#16202e" : "#111823"
                    border.color: itemMouse.containsMouse ? "#38bdf8" : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        // Rank Badge
                        Rectangle {
                            Layout.preferredWidth: 22
                            height: 18
                            radius: 9
                            color: index < 3 ? "#38bdf8" : "#223147"

                            Text {
                                anchors.centerIn: parent
                                text: "" + (index + 1)
                                color: index < 3 ? "#0e141d" : "#cbd5e1"
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }

                        // Process Name
                        Text {
                            text: model.comm
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // PID
                        Text {
                            text: model.pid
                            color: "#94a3b8"
                            font.pixelSize: 10
                            Layout.preferredWidth: 55
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // RAM Consumed (RSS + %)
                        Text {
                            text: model.rss + " (" + model.pmem + ")"
                            color: "#38bdf8"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            Layout.preferredWidth: 95
                            horizontalAlignment: Text.AlignRight
                        }

                        // CPU %
                        Text {
                            text: model.pcpu
                            color: model.pcpu !== "0%" ? "#facc15" : "#64748b"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }

                        // Kill Action Button
                        Rectangle {
                            Layout.preferredWidth: 68
                            height: 22
                            radius: 5
                            color: killMouse.containsMouse ? "#d32f2f" : "#1f2937"
                            border.color: killMouse.containsMouse ? "#ef4444" : "#374151"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Termina"
                                color: killMouse.containsMouse ? "#ffffff" : "#ef4444"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: killMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.killProcess(model.pid, model.comm)
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
