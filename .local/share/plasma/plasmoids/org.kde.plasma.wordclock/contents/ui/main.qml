import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation

    fullRepresentation: Rectangle {
        id: fullView
        anchors.fill: parent
        color: "#000000"

        readonly property var hoursWords: [
            "Twelve", "One", "Two", "Three", "Four", "Five",
            "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve"
        ]

        readonly property var numToWords: ({
            0: "O'Clock", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five",
            6: "Six", 7: "Seven", 8: "Eight", 9: "Nine", 10: "Ten",
            11: "Eleven", 12: "Twelve", 13: "Thirteen", 14: "Fourteen", 15: "Fifteen",
            16: "Sixteen", 17: "Seventeen", 18: "Eighteen", 19: "Nineteen",
            20: "Twenty", 30: "Thirty", 40: "Forty", 50: "Fifty"
        })

        function getMinuteWord(m) {
            if (m === 0) return "O'Clock";
            if (m < 10) return "Oh " + numToWords[m];
            if (numToWords[m]) return numToWords[m];
            var tens = Math.floor(m / 10) * 10;
            var units = m % 10;
            return numToWords[tens] + " " + numToWords[units];
        }

        property string hourString: "One"
        property string minuteString: "Sixteen"
        property string dateString: "Sunday, Oct 18"
        property int batteryPct: 86
        property bool isCharging: false
        property int shiftX: 0
        property int shiftY: 0

        function updateTime() {
            var now = new Date();
            var h12 = now.getHours() % 12;
            fullView.hourString = fullView.hoursWords[h12];
            fullView.minuteString = fullView.getMinuteWord(now.getMinutes());
            fullView.dateString = Qt.formatDate(now, "dddd, MMM d");
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: fullView.updateTime()
        }

        Plasma5Support.DataSource {
            id: batterySource
            engine: "executable"
            connectedSources: []

            onNewData: function(src, data) {
                var stdout = (data["stdout"] || "").toString().trim();
                disconnectSource(src);
                if (!stdout) return;
                var lines = stdout.split("\n");
                if (lines.length >= 1) {
                    var cap = parseInt(lines[0]);
                    if (!isNaN(cap)) fullView.batteryPct = cap;
                }
                if (lines.length >= 2) {
                    var st = lines[1].trim().toLowerCase();
                    fullView.isCharging = (st === "charging" || st === "full");
                }
            }
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                batterySource.connectSource("cat /sys/class/power_supply/bq27541-0/capacity /sys/class/power_supply/bq27541-0/status 2>/dev/null");
            }
        }

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: {
                fullView.shiftX = (Math.random() * 20) - 10;
                fullView.shiftY = (Math.random() * 16) - 8;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (typeof(Qt.quit) === "function") Qt.quit();
            }
        }

        Item {
            id: contentContainer
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 140 + fullView.shiftX
            anchors.topMargin: 120 + fullView.shiftY
            width: 600
            height: 500

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                Text {
                    text: "It’s"
                    color: "#E2E8F0"
                    font.family: "Inter"
                    font.pixelSize: 46
                    font.weight: Font.Light
                }

                Text {
                    text: fullView.hourString
                    color: "#F8FAFC"
                    font.family: "Inter"
                    font.pixelSize: 66
                    font.weight: Font.Normal
                }

                Text {
                    text: fullView.minuteString
                    color: "#F8FAFC"
                    font.family: "Inter"
                    font.pixelSize: 66
                    font.weight: Font.Normal
                }

                Item { Layout.preferredHeight: 22 }

                Text {
                    text: fullView.dateString
                    color: "#7DD3FC"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.weight: Font.Normal
                }

                Item { Layout.preferredHeight: 36 }

                Text {
                    text: fullView.batteryPct + "% " + (fullView.isCharging ? "⚡" : "🔋")
                    color: "#7DD3FC"
                    font.family: "Inter"
                    font.pixelSize: 22
                    font.weight: Font.Normal
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
