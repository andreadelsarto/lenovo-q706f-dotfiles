import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "i18n.js" as I18n

Item {
    id: root
    implicitHeight: (Plasmoid.configuration.currentTheme === "firewatch_poster") ? 270 : 245

    property var appsModel: null
    property string activeLang: "it"
    property string currentAccent: "#38bdf8"
    property var playTimeData: ({})

    signal appSelected(var appItem)
    signal appContextMenuRequested(var appItem)
    signal focusDownRequested()
    signal currentHeroChanged(string accentColor, string heroName)

    function getFormattedPlaytime(exec) {
        if (!exec) return I18n.t("playtime_prefix", root.activeLang) + "0m";
        var cleanKey = exec.replace(/[^a-zA-Z0-9_-]/g, "_").toLowerCase();
        var mins = (root.playTimeData && root.playTimeData[cleanKey]) ? root.playTimeData[cleanKey] : 0;
        if (mins <= 0) return I18n.t("playtime_prefix", root.activeLang) + "0m";
        var h = Math.floor(mins / 60);
        var m = mins % 60;
        if (h > 0) {
            return I18n.t("playtime_prefix", root.activeLang) + h + "h " + m + "m";
        }
        return I18n.t("playtime_prefix", root.activeLang) + m + "m";
    }

    // Curated high-res dedicated wallpapers and accents for real Linux/KDE/Gaming apps
    function getAppBannerAndColor(appName, execName, iconName, category) {
        var lower = (appName + " " + execName + " " + iconName + " " + category).toLowerCase();

        if (lower.indexOf("supertuxkart") !== -1 || lower.indexOf("kart") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800&q=80",
                color: "#ef4444",
                badge: "CORSE 3D"
            };
        } else if (lower.indexOf("retroarch") !== -1 || lower.indexOf("libretro") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80",
                color: "#38bdf8",
                badge: "EMULATORE"
            };
        } else if (lower.indexOf("dolphin-emu") !== -1 || lower.indexOf("dolphin emulator") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80",
                color: "#0284c7",
                badge: "GAMECUBE & WII"
            };
        } else if (lower.indexOf("supertux") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=800&q=80",
                color: "#22c55e",
                badge: "PLATFORM"
            };
        } else if (lower.indexOf("spotube") !== -1 || lower.indexOf("spotify") !== -1 || lower.indexOf("audiotube") !== -1 || lower.indexOf("ytm") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80",
                color: "#10b981",
                badge: "MUSICA"
            };
        } else if (lower.indexOf("steam") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80",
                color: "#1d4ed8",
                badge: "STEAM"
            };
        } else if (lower.indexOf("heroic") !== -1 || lower.indexOf("lutris") !== -1 || lower.indexOf("proton") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80",
                color: "#a855f7",
                badge: "GAMING"
            };
        } else if (lower.indexOf("discover") !== -1 || lower.indexOf("store") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&q=80",
                color: "#6366f1",
                badge: "SOFTWARE"
            };
        } else if (lower.indexOf("firefox") !== -1 || lower.indexOf("browser") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80",
                color: "#ea580c",
                badge: "WEB"
            };
        } else if (lower.indexOf("spectacle") !== -1 || lower.indexOf("screenshot") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80",
                color: "#38bdf8",
                badge: "SCREENSHOT"
            };
        } else if (lower.indexOf("konsole") !== -1 || lower.indexOf("terminal") !== -1) {
            return {
                banner: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80",
                color: "#22c55e",
                badge: "TERMINALE"
            };
        }

        // Curated game photography fallbacks
        var fallbacks = [
            { banner: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80", color: "#ef4444", badge: "IN EVIDENZA" },
            { banner: "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800&q=80", color: "#38bdf8", badge: "RECENTE" },
            { banner: "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80", color: "#22c55e", badge: "GIOCO" },
            { banner: "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=800&q=80", color: "#f59e0b", badge: "RECENTE" },
            { banner: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&q=80", color: "#a855f7", badge: "APP" }
        ];
        var hash = 0;
        for (var i = 0; i < appName.length; i++) hash += appName.charCodeAt(i);
        return fallbacks[hash % fallbacks.length];
    }

    // Hero Model: Top real apps & featured games
    ListModel {
        id: carouselModel
    }

    // Online Banner Scraper & Cache Engine (Steam Store & Flathub Database)
    Plasma5Support.DataSource {
        id: bannerFetcherSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            var stdout = (data["stdout"] || "").trim();
            if (stdout.length > 0 && stdout.indexOf(".jpg") !== -1) {
                var fileUrl = "file://" + stdout;
                for (var i = 0; i < carouselModel.count; i++) {
                    var item = carouselModel.get(i);
                    if (sourceName.indexOf(item.name) !== -1) {
                        carouselModel.setProperty(i, "banner", fileUrl);
                        break;
                    }
                }
            }
            disconnectSource(sourceName);
        }
    }

    function requestBannerDownload(appName) {
        if (!appName) return;
        var cleanName = appName.replace(/[^a-zA-Z0-9_\s-]/g, "").trim();
        if (cleanName.length === 0) return;
        var sanitizedParam = cleanName.replace(/["\\`$;|&><]/g, "");
        var scriptCmd = "python3 ~/.local/share/plasma/plasmoids/org.kde.plasma.decklauncher/contents/scripts/fetch_banner.py \"" + sanitizedParam + "\"";
        bannerFetcherSource.connectSource(scriptCmd);
    }

    readonly property var defaultFeaturedApps: [
        { name: "SuperTuxKart", category: "Corse 3D Arcade", banner: "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800&q=80", iconName: "net.supertuxkart.SuperTuxKart", accentColor: "#ef4444", exec: "net.supertuxkart.SuperTuxKart", badge: "CORSE 3D" },
        { name: "RetroArch", category: "Frontend Emulatori Universale", banner: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80", iconName: "org.libretro.RetroArch", accentColor: "#38bdf8", exec: "org.libretro.RetroArch", badge: "EMULATORE" },
        { name: "Dolphin Emulator", category: "Emulatore GameCube & Wii", banner: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80", iconName: "org.DolphinEmu.dolphin-emu", accentColor: "#0284c7", exec: "org.DolphinEmu.dolphin-emu", badge: "GAMECUBE & WII" },
        { name: "SuperTux", category: "Platformer Classico 2D", banner: "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=800&q=80", iconName: "org.supertuxproject.SuperTux", accentColor: "#22c55e", exec: "org.supertuxproject.SuperTux", badge: "PLATFORM" },
        { name: "Spotube", category: "Musica & Streaming Spotify", banner: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80", iconName: "com.github.KRTirtho.Spotube", accentColor: "#10b981", exec: "com.github.KRTirtho.Spotube", badge: "MUSICA" },
        { name: "ProtonUp-Qt", category: "Gestore GE-Proton per Giochi", banner: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80", iconName: "net.davidotek.pupgui2", accentColor: "#a855f7", exec: "net.davidotek.pupgui2", badge: "GAMING" },
        { name: "KDE Discover", category: "Software Center & Aggiornamenti", banner: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&q=80", iconName: "plasmadiscover", accentColor: "#6366f1", exec: "org.kde.discover", badge: "SOFTWARE" },
        { name: "Firefox", category: "Navigatore Web Open Source", banner: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80", iconName: "firefox", accentColor: "#ea580c", exec: "firefox", badge: "INTERNET" }
    ]

    function getAppScore(app) {
        var score = 0;
        var cleanKey = (app.exec || app.name).replace(/[^a-zA-Z0-9_-]/g, "_").toLowerCase();
        
        // 1. Playtime bonus (up to +1000 points based on playtime)
        if (root.playTimeData && root.playTimeData[cleanKey]) {
            score += Math.min(root.playTimeData[cleanKey] * 5, 1000);
        }

        // 2. User Favorite app bonus (+500 points)
        var favStr = Plasmoid.configuration.favoriteApps || "";
        if (favStr.indexOf(app.exec) !== -1 || favStr.indexOf(app.name) !== -1) {
            score += 500;
        }

        // 3. Native gaming & Emulation core bonus (+300 points)
        var lower = (app.name + " " + app.category + " " + app.exec).toLowerCase();
        if (lower.indexOf("kart") !== -1 || lower.indexOf("retro") !== -1 || lower.indexOf("emu") !== -1 || lower.indexOf("game") !== -1 || lower.indexOf("steam") !== -1 || lower.indexOf("tux") !== -1 || lower.indexOf("proton") !== -1) {
            score += 300;
        }

        return score;
    }

    function populateCarousel() {
        carouselModel.clear();
        
        // Create sorted list of featured candidates based on real user playtime & favorites
        var list = defaultFeaturedApps.slice(0);
        list.sort(function(a, b) {
            return getAppScore(b) - getAppScore(a);
        });

        for (var p = 0; p < list.length; p++) {
            var item = list[p];
            var score = getAppScore(item);
            var badgeText = item.badge;
            if (p === 0 && score >= 500) badgeText = "PIÙ GIOCATO";
            else if (score >= 500) badgeText = "PREFERITO";

            carouselModel.append({
                name: item.name,
                category: item.category,
                banner: item.banner,
                iconName: item.iconName,
                accentColor: item.accentColor,
                exec: item.exec,
                badge: badgeText
            });

            // Request background fetch & caching
            requestBannerDownload(item.name);
        }

        if (carouselModel.count > 0) {
            var first = carouselModel.get(0);
            if (first) {
                root.currentHeroChanged(first.accentColor, first.name);
            }
        }
    }

    Component.onCompleted: populateCarousel()

    function forceFocus() {
        carouselView.forceActiveFocus();
    }

    // Horizontal Carousel Container
    Item {
        anchors.fill: parent

        // Manga Comic Background Slash Ribbon
        Rectangle {
            visible: (Plasmoid.configuration.currentTheme === "manga_phantom" || Plasmoid.configuration.currentTheme === "persona_phantom")
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: -80
            anchors.rightMargin: -80
            height: 72
            rotation: -3.0
            color: "#000000"
            z: 0
        }

        readonly property bool isPoster: (Plasmoid.configuration.currentTheme === "sunset_wilderness" || Plasmoid.configuration.currentTheme === "firewatch_poster")

        ListView {
            id: carouselView
            anchors.fill: parent
            z: 1
            orientation: ListView.Horizontal
            spacing: parent.isPoster ? 14 : 18
            model: carouselModel
            clip: false
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: 24
            preferredHighlightEnd: width - (parent.isPoster ? 190 : 380)
            boundsBehavior: Flickable.StopAtBounds

            onCurrentIndexChanged: {
                if (carouselModel && currentIndex >= 0 && currentIndex < carouselModel.count) {
                    var item = carouselModel.get(currentIndex);
                    if (item) {
                        root.currentHeroChanged(item.accentColor, item.name);
                    }
                }
            }

            Keys.onLeftPressed: {
                if (currentIndex > 0) decrementCurrentIndex();
            }
            Keys.onRightPressed: {
                if (currentIndex < count - 1) incrementCurrentIndex();
            }
            Keys.onDownPressed: root.focusDownRequested()
            Keys.onReturnPressed: {
                var item = carouselModel.get(currentIndex);
                root.appSelected(item);
            }
            Keys.onEnterPressed: Keys.onReturnPressed(event)

            delegate: Item {
                id: cardDelegate
                width: cardDelegate.isPoster ? 180 : 380
                height: cardDelegate.isPoster ? 260 : 240

                readonly property bool isSelected: carouselView.currentIndex === index
                readonly property bool isHovered: mouseArea.containsMouse
                readonly property bool isPersona: (Plasmoid.configuration.currentTheme === "manga_phantom" || Plasmoid.configuration.currentTheme === "persona_phantom")
                readonly property bool isPoster: (Plasmoid.configuration.currentTheme === "sunset_wilderness" || Plasmoid.configuration.currentTheme === "firewatch_poster")

                scale: isSelected ? 1.05 : (isHovered ? 1.02 : 0.94)
                opacity: isPoster ? (isSelected ? 1.0 : 0.35) : (isSelected ? 1.0 : (isHovered ? 0.92 : 0.72))
                rotation: isPersona ? (isSelected ? -3.5 : (index % 2 === 0 ? 2.8 : -2.5)) : 0.0

                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on rotation { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    // Outer Frame (Poster / Comic / Glass Card)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: cardDelegate.isPoster ? 250 : 180
                        radius: cardDelegate.isPoster ? 20 : (cardDelegate.isPersona ? 0 : 18)
                        clip: true
                        color: cardDelegate.isPoster ? "#180d1e" : (cardDelegate.isPersona ? "#000000" : "#0f1722")

                        border.color: cardDelegate.isPoster ? (cardDelegate.isSelected ? "#ffffff" : "#2d1228") : (cardDelegate.isPersona ? (cardDelegate.isSelected ? "#ffffff" : "#000000") : (cardDelegate.isSelected ? model.accentColor : (cardDelegate.isHovered ? "#3daee9" : "#223147")))
                        border.width: cardDelegate.isPoster ? (cardDelegate.isSelected ? 3.5 : 1.5) : (cardDelegate.isPersona ? (cardDelegate.isSelected ? 4.5 : 3.0) : (cardDelegate.isSelected ? 3.5 : 1))

                        // Inner Manga Artwork Container with White Border
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: cardDelegate.isPersona ? 8 : 0
                            radius: cardDelegate.isPoster ? 18 : (cardDelegate.isPersona ? 0 : 18)
                            clip: true
                            color: "#0f1722"
                            border.color: cardDelegate.isPersona ? "#ffffff" : "transparent"
                            border.width: cardDelegate.isPersona ? 2.5 : 0

                            Image {
                                anchors.fill: parent
                                source: model.banner
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }

                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.4; color: Qt.rgba(0, 0, 0, 0.2) }
                                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.85) }
                                }
                            }

                            // Top Row: Badges
                            RowLayout {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 10
                                spacing: 8

                                Rectangle {
                                    height: 20
                                    width: badgeText.implicitWidth + 12
                                    radius: cardDelegate.isPersona ? 0 : 10
                                    color: cardDelegate.isPersona ? "#ef4444" : model.accentColor
                                    border.color: cardDelegate.isPersona ? "#ffffff" : "transparent"
                                    border.width: cardDelegate.isPersona ? 1.5 : 0

                                    Text {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        text: model.badge
                                        color: "#ffffff"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            // Bottom Row: Icon & Game Titles
                            RowLayout {
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    width: 42
                                    height: 42
                                    radius: cardDelegate.isPersona ? 0 : 11
                                    color: "#0f1722"
                                    border.color: cardDelegate.isPersona ? "#ffffff" : (cardDelegate.isSelected ? model.accentColor : "#243247")
                                    border.width: cardDelegate.isPersona ? 2 : 1

                                    Kirigami.Icon {
                                        anchors.centerIn: parent
                                        width: 30
                                        height: 30
                                        source: model.iconName
                                        fallback: "applications-games"
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Layout.fillWidth: true

                                    Text {
                                        text: model.name
                                        color: "#ffffff"
                                        font.pixelSize: 16
                                        font.weight: Font.Black
                                        style: Text.Outline
                                        styleColor: "#000000"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: model.category
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        style: Text.Outline
                                        styleColor: "#000000"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        spacing: 6

                        Text {
                            visible: Plasmoid.configuration.showPlaytime === true
                            text: "▶ " + root.getFormattedPlaytime(model.exec)
                            color: cardDelegate.isSelected ? model.accentColor : "#94a3b8"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            style: Text.Outline
                            styleColor: "#050811"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            visible: cardDelegate.isSelected
                            text: I18n.t("hold_options", root.activeLang)
                            color: "#8a9ba8"
                            font.pixelSize: 10
                            style: Text.Outline
                            styleColor: "#050811"
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function(mouse) {
                        carouselView.currentIndex = index;
                        if (mouse.button === Qt.RightButton) {
                            root.appContextMenuRequested(carouselModel.get(index));
                        } else {
                            root.appSelected(carouselModel.get(index));
                        }
                    }
                    onPressAndHold: {
                        carouselView.currentIndex = index;
                        root.appContextMenuRequested(carouselModel.get(index));
                    }
                }
            }
        }
    }
}
