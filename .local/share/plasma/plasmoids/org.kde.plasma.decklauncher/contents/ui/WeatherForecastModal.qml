import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root
    anchors.fill: parent
    visible: opacity > 0
    opacity: 0.0

    signal closed()

    property string cityName: Plasmoid.configuration.weatherCity || "Milano"
    property string currentTemp: "22°C"
    property string currentDesc: "Sereno"
    property string currentIcon: "weather-clear"

    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    function open(city, temp, desc, icon) {
        if (city) cityName = city;
        if (temp) currentTemp = temp;
        if (desc) currentDesc = desc;
        if (icon) currentIcon = icon;
        fetch3DayForecast(cityName);
        opacity = 1.0;
        forecastModal.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        root.closed();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    // 3-Day Forecast Data Model
    ListModel {
        id: forecastListModel
    }

    Plasma5Support.DataSource {
        id: forecastSource
        engine: "executable"
        connectedSources: []

        onNewData: function(src, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            disconnectSource(src);
            if (!stdout || stdout.length === 0) return;
            try {
                var res = JSON.parse(stdout);
                var days = res.weather || [];
                var dayLabels = ["Oggi", "Domani", "Dopodomani"];

                forecastListModel.clear();
                for (var i = 0; i < Math.min(3, days.length); i++) {
                    var dayData = days[i];
                    var noon = (dayData.hourly && dayData.hourly.length > 4) ? dayData.hourly[4] : (dayData.hourly ? dayData.hourly[0] : {});
                    var desc = noon.weatherDesc && noon.weatherDesc[0] ? noon.weatherDesc[0].value : "Sereno";
                    var code = parseInt(noon.weatherCode || "113");
                    var icon = "weather-clear";

                    if (code === 113) icon = "weather-clear";
                    else if (code === 116 || code === 119) icon = "weather-clouds";
                    else if (code >= 200 && code < 300) icon = "weather-storm";
                    else if (code >= 300 && code < 600) icon = "weather-showers";
                    else if (code >= 600) icon = "weather-snow";
                    else icon = "weather-few-clouds";

                    forecastListModel.append({
                        dayLabel: dayLabels[i] || dayData.date,
                        dateStr: dayData.date,
                        minTemp: dayData.mintempC + "°C",
                        maxTemp: dayData.maxtempC + "°C",
                        weatherDesc: desc,
                        weatherIcon: icon,
                        windSpeed: (noon.windspeedKmph || "12") + " km/h",
                        rainChance: (noon.chanceofrain || "0") + "%",
                        accentColor: (i === 0 ? "#38bdf8" : (i === 1 ? "#fbbf24" : "#a855f7"))
                    });
                }
            } catch(e) {
                console.log("[PlasmaDeckLauncher] Errore parsing meteo 3 giorni:", e);
            }
        }
    }

    function fetch3DayForecast(city) {
        forecastListModel.clear();
        var safeCity = (city || "Milano").replace(/[^a-zA-Z0-9_\s-]/g, "").trim();
        forecastSource.connectSource("python3 ~/.local/share/plasma/plasmoids/org.kde.plasma.decklauncher/contents/scripts/fetch_weather.py \"" + safeCity + "\"");
    }

    // Backdrop overlay
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
        id: forecastModal
        width: 720
        height: 480
        radius: 20
        anchors.centerIn: parent
        color: "#121924"
        border.color: "#25344a"
        border.width: 1.5

        scale: root.opacity > 0 ? 1.0 : 0.92
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#1b3248"
                    border.color: "#3daee9"
                    border.width: 1.5

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        source: root.currentIcon
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: "Previsioni Meteo • " + root.cityName
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Condizioni attuali: " + root.currentTemp + " (" + root.currentDesc + ")"
                        color: "#94a3b8"
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: closeBtnMouse.containsMouse ? "#d32f2f" : "#1e293b"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: "dialog-close"
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: closeBtnMouse
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

            // 3-Day Cards Row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                Repeater {
                    model: forecastListModel

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16
                        color: cardMouse.containsMouse ? "#1c283a" : "#16202e"
                        border.color: cardMouse.containsMouse ? model.accentColor : "#25344a"
                        border.width: 1.5

                        scale: cardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            // Day Header
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: model.dayLabel
                                    color: "#ffffff"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: model.dateStr
                                    color: "#64748b"
                                    font.pixelSize: 11
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Weather Icon
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 64
                                height: 64
                                radius: 32
                                color: "#0f1722"
                                border.color: model.accentColor
                                border.width: 1.5

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 38
                                    height: 38
                                    source: model.weatherIcon
                                }
                            }

                            // Temp Range
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: model.maxTemp + " / " + model.minTemp
                                color: "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Black
                            }

                            // Condition
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: model.weatherDesc
                                color: "#cbd5e1"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Item { Layout.fillHeight: true }

                            // Metrics (Rain & Wind)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 28
                                    radius: 8
                                    color: "#0f1722"
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Kirigami.Icon { width: 14; height: 14; source: "weather-showers"; color: "#38bdf8" }
                                        Text { text: model.rainChance; color: "#94a3b8"; font.pixelSize: 10; font.weight: Font.DemiBold }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 28
                                    radius: 8
                                    color: "#0f1722"
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Kirigami.Icon { width: 14; height: 14; source: "weather-windy"; color: "#a855f7" }
                                        Text { text: model.windSpeed; color: "#94a3b8"; font.pixelSize: 10; font.weight: Font.DemiBold }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }

            // Footer hint
            Text {
                text: "Dati meteo sincronizzati in tempo reale • Modifica la città nelle Impostazioni della Sidebar"
                color: "#64748b"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
