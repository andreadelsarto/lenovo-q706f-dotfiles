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
    signal settingsChanged()

    property string activeLang: Plasmoid.configuration.currentLanguage || "it"
    property string activeCategory: "themes"

    property var sysInfoData: ({
        "kernel": "6.11.0-rc4 (aarch64)",
        "os": "postmarketOS Linux",
        "ram": "8.0 GB LPDDR5",
        "cpu": "Qualcomm Snapdragon 870 (8 Cores @ 3.2 GHz)",
        "gpu": "Qualcomm Adreno 650 • turnip Mesa 26.1.6 (Vulkan 1.3)",
        "kde": "KDE Plasma 6 (Wayland)",
        "proton": "FEX-Emu / Box64 • Proton 9 / Wine Gaming Layer"
    })

    Plasma5Support.DataSource {
        id: sysInfoSource
        engine: "executable"
        connectedSources: []

        onNewData: function(src, data) {
            var stdout = (data["stdout"] || "").toString().trim();
            disconnectSource(src);
            if (stdout && stdout.length > 0) {
                try {
                    root.sysInfoData = JSON.parse(stdout);
                } catch(e) {}
            }
        }
    }

    function refreshSysInfo() {
        var scriptPath = Qt.resolvedUrl("../scripts/system_info.py").toString().replace("file://", "");
        sysInfoSource.connectSource("python3 " + scriptPath);
    }

    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    function open() {
        opacity = 1.0;
        drawerCard.x = root.width - drawerCard.width;
        refreshSysInfo();
        drawerCard.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        drawerCard.x = root.width;
        root.closed();
    }

    Keys.onEscapePressed: root.close()
    Keys.onBackPressed: root.close()

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.70 * root.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Main Drawer Card (Bazzite OS / Steam Deck Quick Settings Style)
    Rectangle {
        id: drawerCard
        width: Math.min(680, root.width * 0.75)
        height: root.height
        x: root.width
        color: "#0f1622"
        border.color: "#1e293b"
        border.width: 1

        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // =================================================================
            // LEFT RAIL: CATEGORIES (Bazzite OS / Decky Style)
            // =================================================================
            Rectangle {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                color: "#0a0f18"
                border.color: "#1e293b"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Header
                    RowLayout {
                        spacing: 8
                        Layout.bottomMargin: 10

                        Kirigami.Icon {
                            width: 20
                            height: 20
                            source: "configure"
                            color: "#3daee9"
                        }

                        Text {
                            text: "NEBULA MENU"
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.weight: Font.Black
                            font.letterSpacing: 0.8
                        }
                    }

                    // Category Items
                    Repeater {
                        model: [
                            { id: "themes", name: "Temi & Aspetto", icon: "games-config-theme", color: "#38bdf8" },
                            { id: "performance", name: "Prestazioni & Audio", icon: "speedometer", color: "#22c55e" },
                            { id: "interface", name: "Interfaccia", icon: "view-grid", color: "#f59e0b" },
                            { id: "language", name: "Lingua & Meteo", icon: "preferences-desktop-locale", color: "#a855f7" },
                            { id: "system", name: "Sistema & Info", icon: "dialog-information", color: "#64748b" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 44
                            radius: 10
                            readonly property bool isCurrent: root.activeCategory === modelData.id
                            color: isCurrent ? "#162234" : (catMouse.containsMouse ? "#101824" : "transparent")
                            border.color: isCurrent ? modelData.color : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                Kirigami.Icon {
                                    width: 18
                                    height: 18
                                    source: modelData.icon
                                    color: isCurrent ? modelData.color : (catMouse.containsMouse ? "#ffffff" : "#8a9ba8")
                                }

                                Text {
                                    text: modelData.name
                                    color: isCurrent ? "#ffffff" : (catMouse.containsMouse ? "#e2e8f0" : "#94a3b8")
                                    font.pixelSize: 11
                                    font.weight: isCurrent ? Font.Bold : Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                id: catMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeCategory = modelData.id;
                                    if (modelData.id === "system") {
                                        root.refreshSysInfo();
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Close button at bottom of rail
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        radius: 10
                        color: closeRailMouse.containsMouse ? "#d32f2f" : "#16202e"
                        border.color: "#25344a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Kirigami.Icon {
                                width: 14
                                height: 14
                                source: "dialog-close"
                                color: "#ffffff"
                            }

                            Text {
                                text: I18n.t("close", root.activeLang)
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: closeRailMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
                    }
                }
            }

            // =================================================================
            // RIGHT PANE: CATEGORY CONTENT
            // =================================================================
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 18
                    contentHeight: contentColumn.implicitHeight + 30
                    clip: true

                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        spacing: 14

                        // --- CATEGORY 1: TEMI & ASPETTO ---
                        ColumnLayout {
                            visible: root.activeCategory === "themes"
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "TEMI NEBULADECK & SFONDI"
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                font.letterSpacing: 0.5
                            }

                            Text {
                                text: "Seleziona uno stile visivo per il launcher"
                                color: "#8a9ba8"
                                font.pixelSize: 11
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: 8
                                columnSpacing: 8

                                Repeater {
                                    model: [
                                        { id: "ocean_calm", icon: "view-media-album-cover", nameKey: "theme_ocean", descKey: "theme_ocean_desc", color: "#06b6d4" },
                                        { id: "aurora", icon: "view-media-album-cover", nameKey: "theme_aurora", descKey: "theme_aurora_desc", color: "#a855f7" },
                                        { id: "weather_dynamic", icon: "weather-showers-scattered", nameKey: "theme_weather", descKey: "theme_weather_desc", color: "#38bdf8" },
                                        { id: "sunset_wilderness", icon: "weather-sunset", nameKey: "theme_wilderness", descKey: "theme_wilderness_desc", color: "#f97316" },
                                        { id: "manga_phantom", icon: "games-config-theme", nameKey: "theme_manga", descKey: "theme_manga_desc", color: "#ef4444" },
                                        { id: "circadian_daylight", icon: "weather-clear", nameKey: "theme_circadian", descKey: "theme_circadian_desc", color: "#38bdf8" },
                                        { id: "obsidian_minimal", icon: "view-media-playlist", nameKey: "theme_obsidian", descKey: "theme_obsidian_desc", color: "#ffffff" },
                                        { id: "synthwave_84", icon: "games-config-theme", nameKey: "theme_synthwave", descKey: "theme_synthwave_desc", color: "#f43f5e" },
                                        { id: "hybrid_console", icon: "input-gaming", nameKey: "theme_hybrid", descKey: "theme_hybrid_desc", color: "#00c3e3" },
                                        { id: "night_shift", icon: "weather-sunset", nameKey: "theme_night", descKey: "theme_night_desc", color: "#f59e0b" },
                                        { id: "dot_matrix_8bit", icon: "applications-games", nameKey: "theme_dotmatrix", descKey: "theme_dotmatrix_desc", color: "#8bac0f" },
                                        { id: "matrix_rain", icon: "utilities-terminal", nameKey: "theme_matrix", descKey: "theme_matrix_desc", color: "#22c55e" },
                                        { id: "drops", icon: "weather-showers", nameKey: "theme_drops", descKey: "theme_drops_desc", color: "#38bdf8" },
                                        { id: "bubbles", icon: "color-picker", nameKey: "theme_bubbles", descKey: "theme_bubbles_desc", color: "#38bdf8" }
                                    ]

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 58
                                        radius: 10
                                        readonly property bool isSelected: (Plasmoid.configuration.currentTheme || "obsidian_minimal") === modelData.id
                                        color: isSelected ? "#1f2d3f" : (themeMouse.containsMouse ? "#16202e" : "#101724")
                                        border.color: isSelected ? modelData.color : (themeMouse.containsMouse ? "#38bdf8" : "#1e293b")
                                        border.width: isSelected ? 2 : 1

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            spacing: 10

                                            Rectangle {
                                                width: 34
                                                height: 34
                                                radius: 8
                                                color: isSelected ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.20) : "#16202e"
                                                border.color: isSelected ? modelData.color : "#25344a"
                                                border.width: 1

                                                Kirigami.Icon {
                                                    anchors.centerIn: parent
                                                    width: 18
                                                    height: 18
                                                    source: modelData.icon
                                                    color: modelData.color
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    text: I18n.t(modelData.nameKey, root.activeLang)
                                                    color: isSelected ? "#ffffff" : "#e2e8f0"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    text: I18n.t(modelData.descKey, root.activeLang)
                                                    color: isSelected ? modelData.color : "#8a9ba8"
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            Kirigami.Icon {
                                                visible: isSelected
                                                width: 16
                                                height: 16
                                                source: "emblem-checked"
                                                color: modelData.color
                                            }
                                        }

                                        MouseArea {
                                            id: themeMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Plasmoid.configuration.currentTheme = modelData.id;
                                                if (modelData.id === "gameboy_classic") {
                                                    Plasmoid.configuration.accentColor = "#8bac0f";
                                                } else if (modelData.id === "matrix_rain") {
                                                    Plasmoid.configuration.accentColor = "#22c55e";
                                                } else if (modelData.id === "synthwave_84") {
                                                    Plasmoid.configuration.accentColor = "#f43f5e";
                                                } else if (modelData.id === "switch_deck") {
                                                    Plasmoid.configuration.accentColor = "#00c3e3";
                                                } else if (modelData.id === "night_shift") {
                                                    Plasmoid.configuration.accentColor = "#f59e0b";
                                                }
                                                root.settingsChanged();
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // --- CATEGORY 2: PRESTAZIONI & AUDIO ---
                        ColumnLayout {
                            visible: root.activeCategory === "performance"
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "PRESTAZIONI, BATTERIA & AUDIO"
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                font.letterSpacing: 0.5
                            }

                            // Toggle Sfondi Animati
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.enableAnimatedOrbs ? "#22c55e" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "speedometer"; color: Plasmoid.configuration.enableAnimatedOrbs ? "#22c55e" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_animated_bg", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Disattiva canvas GPU per massimizzare la batteria"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.enableAnimatedOrbs
                                        onCheckedChanged: { Plasmoid.configuration.enableAnimatedOrbs = checked; root.settingsChanged(); }
                                    }
                                }
                            }

                            // Toggle Sound FX
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.enableSoundFx !== false ? "#3daee9" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "audio-volume-high"; color: Plasmoid.configuration.enableSoundFx !== false ? "#3daee9" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_sound_fx", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Feedback audio ad ogni tocco nei menu"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.enableSoundFx !== false
                                        onCheckedChanged: { Plasmoid.configuration.enableSoundFx = checked; root.settingsChanged(); }
                                    }
                                }
                            }

                            // Toggle Performance Overlay (FPS & RAM)
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.showPerformanceOverlay ? "#3daee9" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "utilities-system-monitor"; color: Plasmoid.configuration.showPerformanceOverlay ? "#3daee9" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_perf", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Mostra contatore 60 FPS e badge RAM con Top 10 processi"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.showPerformanceOverlay
                                        onCheckedChanged: { Plasmoid.configuration.showPerformanceOverlay = checked; root.settingsChanged(); }
                                    }
                                }
                            }
                        }

                        // --- CATEGORY 3: INTERFACCIA & LAYOUT ---
                        ColumnLayout {
                            visible: root.activeCategory === "interface"
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "INTERFACCIA & LAYOUT"
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                font.letterSpacing: 0.5
                            }

                            // Toggle Hero Carousel
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.showHeroCarousel ? "#3daee9" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "view-media-playlist"; color: Plasmoid.configuration.showHeroCarousel ? "#3daee9" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_hero", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Carosello superiore dei giochi recenti in grande"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.showHeroCarousel
                                        onCheckedChanged: { Plasmoid.configuration.showHeroCarousel = checked; root.settingsChanged(); }
                                    }
                                }
                            }

                            // Toggle Playtime Counter
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.showPlaytime ? "#3daee9" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "chronometer"; color: Plasmoid.configuration.showPlaytime ? "#3daee9" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_playtime", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Mostra contatore ore giocate sotto ai giochi recenti"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.showPlaytime
                                        onCheckedChanged: { Plasmoid.configuration.showPlaytime = checked; root.settingsChanged(); }
                                    }
                                }
                            }

                            // Toggle Clean View (Swipeable Single Row Peek Drawer)
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.enableCleanView !== false ? "#3daee9" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "view-fullscreen"; color: Plasmoid.configuration.enableCleanView !== false ? "#3daee9" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_clean_view", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Carosello grande in primo piano e 1 sola riga di app; espandi con swipe"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.enableCleanView !== false
                                        onCheckedChanged: { Plasmoid.configuration.enableCleanView = checked; root.settingsChanged(); }
                                    }
                                }
                            }

                            // Toggle Top Weather Widget
                            Rectangle {
                                Layout.fillWidth: true
                                height: 56
                                radius: 12
                                color: "#16202e"
                                border.color: Plasmoid.configuration.showWeather ? "#3daee9" : "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "weather-clouds"; color: Plasmoid.configuration.showWeather ? "#3daee9" : "#94a3b8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_toggle_weather", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Temperatura e previsioni nella barra di stato superiore"; color: "#8a9ba8"; font.pixelSize: 10 }
                                    }
                                    QQC2.Switch {
                                        checked: Plasmoid.configuration.showWeather
                                        onCheckedChanged: { Plasmoid.configuration.showWeather = checked; root.settingsChanged(); }
                                    }
                                }
                            }

                            // App Grid Columns Selector
                            Rectangle {
                                Layout.fillWidth: true
                                height: 64
                                radius: 12
                                color: "#16202e"
                                border.color: "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "view-grid"; color: "#3daee9" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: I18n.t("settings_grid_cols", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Numero di colonne di giochi per riga: " + (Plasmoid.configuration.gridColumns || 5); color: "#8a9ba8"; font.pixelSize: 10 }
                                    }

                                    RowLayout {
                                        spacing: 6
                                        Repeater {
                                            model: [4, 5, 6, 7]
                                            Rectangle {
                                                width: 32
                                                height: 32
                                                radius: 8
                                                readonly property bool isSelected: (Plasmoid.configuration.gridColumns || 5) === modelData
                                                color: isSelected ? "#3daee9" : (colMouse.containsMouse ? "#243247" : "#0f1622")
                                                border.color: isSelected ? "#66c0f4" : "#25344a"
                                                border.width: 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData
                                                    color: isSelected ? "#0e141d" : "#ffffff"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                }

                                                MouseArea {
                                                    id: colMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: { Plasmoid.configuration.gridColumns = modelData; root.settingsChanged(); }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // --- CATEGORY 4: LINGUA & METEO ---
                        ColumnLayout {
                            visible: root.activeCategory === "language"
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "LINGUA & CONFIGURAZIONE METEO"
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                font.letterSpacing: 0.5
                            }

                            // Language Selector Pills
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
                                    spacing: 8

                                    Text { text: I18n.t("settings_section_language", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }

                                    RowLayout {
                                        spacing: 8
                                        Repeater {
                                            model: [
                                                { code: "it", name: "Italiano" },
                                                { code: "en", name: "English" },
                                                { code: "es", name: "Español" },
                                                { code: "fr", name: "Français" },
                                                { code: "de", name: "Deutsch" }
                                            ]

                                            Rectangle {
                                                width: langRow.implicitWidth + 18
                                                height: 28
                                                radius: 14
                                                readonly property bool isSelected: (Plasmoid.configuration.currentLanguage || "it") === modelData.code
                                                color: isSelected ? "#a855f7" : (langMouse.containsMouse ? "#243247" : "#0f1622")
                                                border.color: isSelected ? "#c084fc" : "#25344a"
                                                border.width: 1

                                                RowLayout {
                                                    id: langRow
                                                    anchors.centerIn: parent
                                                    spacing: 4
                                                    Text {
                                                        text: modelData.name
                                                        color: isSelected ? "#ffffff" : "#94a3b8"
                                                        font.pixelSize: 10
                                                        font.weight: isSelected ? Font.Bold : Font.Medium
                                                    }
                                                }

                                                MouseArea {
                                                    id: langMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        Plasmoid.configuration.currentLanguage = modelData.code;
                                                        root.activeLang = modelData.code;
                                                        root.settingsChanged();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Weather City Input
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

                                    Text { text: I18n.t("settings_weather_city", root.activeLang); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 32
                                            radius: 8
                                            color: "#0f1622"
                                            border.color: cityInput.activeFocus ? "#3daee9" : "#25344a"
                                            border.width: 1

                                            TextInput {
                                                id: cityInput
                                                anchors.fill: parent
                                                anchors.margins: 6
                                                text: Plasmoid.configuration.weatherCity || "Milano"
                                                color: "#ffffff"
                                                font.pixelSize: 12
                                                verticalAlignment: TextInput.AlignVCenter
                                                onEditingFinished: {
                                                    Plasmoid.configuration.weatherCity = text;
                                                    root.settingsChanged();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // --- CATEGORY 5: SISTEMA & INFO ---
                        ColumnLayout {
                            visible: root.activeCategory === "system"
                            Layout.fillWidth: true
                            spacing: 12

                            // 1. TOP BRAND BANNER WITH LOGO (Always at the very top of system pane!)
                            Rectangle {
                                Layout.fillWidth: true
                                height: 90
                                radius: 14
                                color: "#16202e"
                                border.color: "#38bdf8"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 14

                                    Image {
                                        Layout.preferredWidth: 64
                                        Layout.preferredHeight: 64
                                        source: Qt.resolvedUrl("../assets/logo/nebuladeck_logo.svg")
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        mipmap: true
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            spacing: 8
                                            Text {
                                                text: "NEBULADECK"
                                                color: "#ffffff"
                                                font.pixelSize: 16
                                                font.weight: Font.Black
                                                font.letterSpacing: 1.0
                                            }
                                            Rectangle {
                                                height: 18
                                                width: verBadgeText.implicitWidth + 10
                                                radius: 9
                                                color: "#22c55e"
                                                Text {
                                                    id: verBadgeText
                                                    anchors.centerIn: parent
                                                    text: "v1.0.0 Stable"
                                                    color: "#0e141d"
                                                    font.pixelSize: 10
                                                    font.weight: Font.Black
                                                }
                                            }
                                        }

                                        Text {
                                            text: "Native Big Picture Gaming Launcher per KDE Plasma 6"
                                            color: "#38bdf8"
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                        }

                                        Text {
                                            text: "Ottimizzato per dispositivi ARM64 e Tablet Touchscreen"
                                            color: "#8a9ba8"
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }

                            // 2. LIVE HARDWARE & DRIVER SPEC CARDS
                            Text {
                                text: "SPECIFICHE HARDWARE & SOFTWARE (IN TEMPO REALE)"
                                color: "#64748b"
                                font.pixelSize: 11
                                font.weight: Font.Black
                                font.letterSpacing: 0.8
                                Layout.topMargin: 4
                            }

                            // Spec Card 1: Desktop & OS
                            Rectangle {
                                Layout.fillWidth: true
                                height: 58
                                radius: 10
                                color: "#16202e"
                                border.color: "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "kde"; color: "#38bdf8" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: "Desktop & Sistema Operativo"; color: "#8a9ba8"; font.pixelSize: 10 }
                                        Text { text: (root.sysInfoData.kde || "KDE Plasma 6 (Wayland)") + " • " + (root.sysInfoData.os || "postmarketOS Linux") + " (" + (root.sysInfoData.kernel || "6.11.0-rc4") + ")"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }
                                }
                            }

                            // Spec Card 2: GPU & Graphics Driver
                            Rectangle {
                                Layout.fillWidth: true
                                height: 58
                                radius: 10
                                color: "#16202e"
                                border.color: "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "video-card"; color: "#22c55e" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: "Scheda Grafica & Driver Vulkan / Mesa"; color: "#8a9ba8"; font.pixelSize: 10 }
                                        Text { text: root.sysInfoData.gpu || "Qualcomm Adreno 650 • turnip Mesa 26.1.6 (Vulkan 1.3)"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }
                                }
                            }

                            // Spec Card 3: Proton / Gaming Translation Layer
                            Rectangle {
                                Layout.fillWidth: true
                                height: 58
                                radius: 10
                                color: "#16202e"
                                border.color: "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "applications-games"; color: "#f59e0b" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: "Compatibilità Giochi & Proton / Wine Layer"; color: "#8a9ba8"; font.pixelSize: 10 }
                                        Text { text: root.sysInfoData.proton || "FEX-Emu / Box64 x86_64 • Proton 9 / Wine Gaming Layer"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }
                                }
                            }

                            // Spec Card 4: SoC Processor & RAM
                            Rectangle {
                                Layout.fillWidth: true
                                height: 58
                                radius: 10
                                color: "#16202e"
                                border.color: "#25344a"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Kirigami.Icon { width: 22; height: 22; source: "cpu"; color: "#a855f7" }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { text: "Processore SoC & Memoria RAM"; color: "#8a9ba8"; font.pixelSize: 10 }
                                        Text { text: (root.sysInfoData.cpu || "Snapdragon 870 5G (8 Cores @ 3.2GHz)") + " • " + (root.sysInfoData.ram || "7.4 GB LPDDR5"); color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
