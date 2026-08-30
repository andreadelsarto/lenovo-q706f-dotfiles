import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker
import "i18n.js" as I18n

Kicker.DashboardWindow {
    id: root

    property var kickerRoot: null
    backgroundColor: "transparent"

    property color activeHeroColor: Plasmoid.configuration.accentColor || "#38bdf8"
    property string activeTheme: Plasmoid.configuration.currentTheme || "obsidian_minimal"
    property string activeLang: Plasmoid.configuration.currentLanguage || "it"
    property bool enableAnimatedBg: Plasmoid.configuration.enableAnimatedOrbs
    property bool isCleanViewExpanded: false

    function logEvent(message, isError) {
        var dateStr = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss.zzz");
        var prefix = isError ? "[ERROR]" : "[INFO]";
        var line = dateStr + " " + prefix + " [NebulaDeck] " + message;
        if (isError) {
            console.error(line);
        } else {
            console.log(line);
        }
    }

    onVisibleChanged: {
        root.logEvent("Visibilità Deck Dashboard cambiata: " + visible, false);
        if (visible) {
            hardwareCtrl.refreshHardware();
            container.forceActiveFocus();
        } else {
            container.currentSearchText = "";
            container.activeViewMode = "launcher";
            tabBar.currentIndex = 0;
        }
    }

    HardwareController {
        id: hardwareCtrl
        onVolumeUpdated: function(vol) {
            quickAccessDrawer.volumeVal = vol;
        }
        onBrightnessUpdated: function(bright) {
            quickAccessDrawer.brightnessVal = bright;
        }
    }

    SoundEngine {
        id: soundEngine
    }

    Item {
        id: container
        anchors.fill: parent

        property string activeViewMode: "launcher"
        property string currentSearchText: ""
        property string lastErrorMessage: ""

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_PageUp || event.key === Qt.Key_BracketLeft) {
                event.accepted = true;
                if (tabBar.currentIndex > 0) tabBar.currentIndex--;
            } else if (event.key === Qt.Key_PageDown || event.key === Qt.Key_BracketRight) {
                event.accepted = true;
                if (tabBar.currentIndex < tabBar.count - 1) tabBar.currentIndex++;
            }
        }

        Keys.onEscapePressed: {
            soundEngine.playBack();
            if (ramProcessesModal.visible) {
                ramProcessesModal.close();
            } else if (batteryPowerModal.visible) {
                batteryPowerModal.close();
            } else if (quickAccessDrawer.visible) {
                quickAccessDrawer.close();
            } else if (wifiDetailsModal.visible) {
                wifiDetailsModal.close();
            } else if (appPropertiesModal.visible) {
                appPropertiesModal.close();
            } else if (appContextMenu.visible) {
                appContextMenu.close();
            } else if (weatherForecastModal.visible) {
                weatherForecastModal.close();
            } else if (settingsDrawer.visible) {
                settingsDrawer.close();
            } else if (friendsOverlay.visible) {
                friendsOverlay.close();
            } else if (container.activeViewMode === "updates") {
                container.activeViewMode = "launcher";
                tabBar.currentIndex = 0;
            } else {
                root.logEvent("Chiusura tramite tasto Escape", false);
                root.toggle();
            }
        }
        Keys.onBackPressed: {
            soundEngine.playBack();
            if (ramProcessesModal.visible) {
                ramProcessesModal.close();
            } else if (batteryPowerModal.visible) {
                batteryPowerModal.close();
            } else if (quickAccessDrawer.visible) {
                quickAccessDrawer.close();
            } else if (wifiDetailsModal.visible) {
                wifiDetailsModal.close();
            } else if (appPropertiesModal.visible) {
                appPropertiesModal.close();
            } else if (appContextMenu.visible) {
                appContextMenu.close();
            } else if (weatherForecastModal.visible) {
                weatherForecastModal.close();
            } else if (settingsDrawer.visible) {
                settingsDrawer.close();
            } else if (friendsOverlay.visible) {
                friendsOverlay.close();
            } else if (container.activeViewMode === "updates") {
                container.activeViewMode = "launcher";
                tabBar.currentIndex = 0;
            } else {
                root.logEvent("Chiusura tramite tasto Back", false);
                root.toggle();
            }
        }

        DynamicBackground {
            id: dynamicBgLayer
            anchors.fill: parent
            accentColor: root.activeHeroColor
            bgStyle: Plasmoid.configuration.currentTheme || "obsidian_minimal"
            isDashboardVisible: root.visible
            enableAnimatedFx: root.enableAnimatedBg
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            HeaderStatusBar {
                id: headerBar
                Layout.fillWidth: true

                onOpenPowerMenu: {
                    root.logEvent("Apertura Power Menu", false);
                    powerMenuOverlay.open();
                }
                onOpenFriendsOverlay: {
                    root.logEvent("Apertura Friends / Profilo Utente", false);
                    friendsOverlay.open();
                }
                onOpenUpdatesView: {
                    root.logEvent("Navigazione a Vista Aggiornamenti", false);
                    container.activeViewMode = "updates";
                    tabBar.currentIndex = 6;
                }
                onOpenWeatherForecast: function(city, temp, desc, icon) {
                    root.logEvent("Apertura Previsioni Meteo 3 Giorni per " + city, false);
                    weatherForecastModal.open(city, temp, desc, icon);
                }
                onOpenWifiDetails: function(ssid, signal) {
                    root.logEvent("Apertura Modal Dettagli Wi-Fi: " + ssid, false);
                    wifiDetailsModal.open(ssid, signal);
                }
                onOpenBatteryModal: function(pct, isCharging) {
                    root.logEvent("Apertura Modal Gestione Batteria: " + pct + "%", false);
                    batteryPowerModal.open(pct, isCharging);
                }
                onOpenRamProcessesModal: {
                    root.logEvent("Apertura Modal Top 10 Processi RAM", false);
                    ramProcessesModal.open();
                }
                onSearchRequested: function(query) {
                    root.logEvent("Ricerca applicazioni: '" + query + "'", false);
                    container.currentSearchText = query;
                    if (container.activeViewMode !== "launcher") {
                        container.activeViewMode = "launcher";
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#1e293b"
                opacity: 0.8
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    visible: container.activeViewMode === "launcher"
                    spacing: 6

                    // Hero Section Container (Smooth Collapsing with Clean Bounds)
                    ColumnLayout {
                        id: heroSection
                        Layout.fillWidth: true
                        Layout.preferredHeight: (Plasmoid.configuration.enableCleanView !== false && root.isCleanViewExpanded) ? 0 : (Plasmoid.configuration.showHeroCarousel && container.currentSearchText.length === 0 ? (heroCarousel.implicitHeight + 36) : 0)
                        clip: true
                        visible: opacity > 0.02
                        opacity: (Plasmoid.configuration.enableCleanView !== false && root.isCleanViewExpanded) ? 0.0 : 1.0
                        spacing: 4

                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutQuad } }

                        Text {
                            text: I18n.t("hero_title", root.activeLang)
                            color: "#ffffff"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            Layout.leftMargin: 16
                            Layout.topMargin: 2
                        }

                        HeroCarousel {
                            id: heroCarousel
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            appsModel: globalAppsModel
                            playTimeData: Plasmoid.configuration.playTimeData || ({})
                            activeLang: root.activeLang

                            onCurrentHeroChanged: function(accColor, hName) {
                                root.activeHeroColor = accColor;
                                soundEngine.playNav();
                            }

                            onAppSelected: function(appData) {
                                soundEngine.playSelect();
                                container.launchApplication(appData.exec, appData.name);
                            }

                            onAppContextMenuRequested: function(appData) {
                                soundEngine.playSelect();
                                root.logEvent("Menu contestuale richiesto per hero: " + appData.name, false);
                                appContextMenu.open(appData);
                            }

                            onFocusDownRequested: {
                                soundEngine.playNav();
                                tabBar.forceActiveFocus();
                            }
                        }
                    }

                    // Sleek Clean View Peek Drawer Handle
                    Rectangle {
                        visible: Plasmoid.configuration.enableCleanView !== false
                        Layout.alignment: Qt.AlignHCenter
                        width: 90
                        height: 20
                        radius: 10
                        color: handleMouse.containsMouse ? "#1f2d3f" : "#16202e"
                        border.color: "#38bdf8"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Kirigami.Icon {
                                width: 10
                                height: 10
                                source: root.isCleanViewExpanded ? "arrow-down" : "arrow-up"
                                color: "#38bdf8"
                            }

                            Text {
                                text: root.isCleanViewExpanded ? "Comprimi" : "Espandi App"
                                color: "#ffffff"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: handleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            property real startY: 0
                            onPressed: function(mouse) { startY = mouse.y; }
                            onReleased: function(mouse) {
                                var diff = mouse.y - startY;
                                if (diff < -15) {
                                    root.isCleanViewExpanded = true;
                                    soundEngine.playToggle();
                                } else if (diff > 15) {
                                    root.isCleanViewExpanded = false;
                                    soundEngine.playToggle();
                                }
                            }
                            onClicked: {
                                soundEngine.playToggle();
                                root.isCleanViewExpanded = !root.isCleanViewExpanded;
                            }
                        }
                    }

                    TabBarPills {
                        id: tabBar
                        Layout.fillWidth: true
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        activeLang: root.activeLang

                        onTabSelected: function(index, catId) {
                            soundEngine.playNav();
                            root.logEvent("Selezione categoria tab: " + catId, false);
                            if (catId === "updates") {
                                container.activeViewMode = "updates";
                            } else {
                                container.activeViewMode = "launcher";
                                appGrid.currentCategory = catId;
                            }
                        }
                        onFocusUpRequested: {
                            soundEngine.playNav();
                            if (heroCarousel.visible) {
                                root.isCleanViewExpanded = false;
                                heroCarousel.forceActiveFocus();
                            }
                        }
                        onFocusDownRequested: {
                            soundEngine.playNav();
                            root.isCleanViewExpanded = true;
                            appGrid.forceActiveFocus();
                        }
                    }

                    AppGrid {
                        id: appGrid
                        Layout.fillWidth: true
                        Layout.preferredHeight: (Plasmoid.configuration.enableCleanView !== false && !root.isCleanViewExpanded) ? 145 : 0
                        Layout.fillHeight: (Plasmoid.configuration.enableCleanView === false || root.isCleanViewExpanded)
                        searchQuery: container.currentSearchText
                        columnsCount: Plasmoid.configuration.gridColumns || 5

                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

                        onAppLaunched: function(item) {
                            soundEngine.playSelect();
                            container.launchApplication(item.exec, item.name);
                        }
                        onAppContextMenuRequested: function(item) {
                            soundEngine.playSelect();
                            root.logEvent("Menu contestuale richiesto per app: " + item.name, false);
                            appContextMenu.open(item);
                        }
                        onFocusUpRequested: {
                            soundEngine.playNav();
                            tabBar.forceActiveFocus();
                        }
                    }
                }

                UpdatesView {
                    id: updatesViewport
                    anchors.fill: parent
                    visible: container.activeViewMode === "updates"
                    activeLang: root.activeLang
                    onCloseRequested: {
                        soundEngine.playBack();
                        root.logEvent("Ritorno al Launcher dalla vista Aggiornamenti", false);
                        container.activeViewMode = "launcher";
                        tabBar.currentIndex = 0;
                        appGrid.currentCategory = "all";
                    }
                    onApplyUpdatesRequested: {
                        soundEngine.playSelect();
                        root.logEvent("Richiesta applicazione aggiornamenti via Discover", false);
                        container.launchApplication("org.kde.discover", "Discover");
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 38
                color: "#0d131d"
                radius: 10
                border.color: "#1e293b"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 14

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            width: 76
                            height: 24
                            radius: 12
                            color: "#3daee9"
                            Text {
                                anchors.centerIn: parent
                                text: "PLASMA"
                                color: "#0e141d"
                                font.pixelSize: 11
                                font.weight: Font.Black
                            }
                        }
                        Text {
                            text: "DECK"
                            color: "#cbd5e1"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        height: 26
                        width: quickText.implicitWidth + 22
                        radius: 13
                        color: quickMouse.containsMouse ? "#22c55e" : "#1a2536"
                        border.color: "#2a3d57"
                        border.width: 1

                        RowLayout {
                            id: quickText
                            anchors.centerIn: parent
                            spacing: 5
                            Kirigami.Icon { width: 14; height: 14; source: "quickopen"; color: quickMouse.containsMouse ? "#0e141d" : "#4ade80" }
                            Text { text: I18n.t("quick_access", root.activeLang); color: quickMouse.containsMouse ? "#0e141d" : "#e2ecf5"; font.pixelSize: 10; font.weight: Font.Bold }
                        }

                        MouseArea {
                            id: quickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: quickAccessDrawer.open()
                        }
                    }

                    Rectangle {
                        height: 26
                        width: settingsText.implicitWidth + 22
                        radius: 13
                        color: settingsMouse.containsMouse ? "#3daee9" : "#1a2536"
                        border.color: "#2a3d57"
                        border.width: 1

                        RowLayout {
                            id: settingsText
                            anchors.centerIn: parent
                            spacing: 5
                            Kirigami.Icon { width: 14; height: 14; source: "configure"; color: settingsMouse.containsMouse ? "#0e141d" : "#e2ecf5" }
                            Text { text: I18n.t("settings", root.activeLang); color: settingsMouse.containsMouse ? "#0e141d" : "#e2ecf5"; font.pixelSize: 10; font.weight: Font.Bold }
                        }

                        MouseArea {
                            id: settingsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsDrawer.open()
                        }
                    }

                    RowLayout {
                        spacing: 12

                        RowLayout {
                            spacing: 4
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#ffffff"
                                Text { anchors.centerIn: parent; text: "A"; color: "#0e141d"; font.pixelSize: 10; font.weight: Font.Black }
                            }
                            Text { text: I18n.t("select", root.activeLang); color: "#94a3b8"; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }

                        RowLayout {
                            spacing: 4
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: "#223147"
                                border.color: "#475569"
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "B"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.Black }
                            }
                            Text { text: I18n.t("back", root.activeLang); color: "#94a3b8"; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: errorBanner
            visible: container.lastErrorMessage.length > 0
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 48
            width: Math.min(parent.width - 48, errorRow.implicitWidth + 32)
            height: 48
            radius: 14
            color: "#7f1d1d"
            border.color: "#ef4444"
            border.width: 1
            z: 500

            RowLayout {
                id: errorRow
                anchors.centerIn: parent
                spacing: 12

                Kirigami.Icon {
                    width: 22
                    height: 22
                    source: "dialog-warning"
                    color: "#ffffff"
                }

                Text {
                    text: container.lastErrorMessage
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
            }

            Timer {
                id: errorDismissTimer
                interval: 4000
                onTriggered: container.lastErrorMessage = ""
            }
        }

        QuickAccessDrawer {
            id: quickAccessDrawer
            z: 160
            activeLang: root.activeLang
            onClosed: root.logEvent("Chiusura Quick Access Drawer", false)
            onBrightnessChanged: function(val) {
                root.logEvent("Applicazione Luminosità Reale Hardware: " + val + "%", false);
                hardwareCtrl.setBrightness(val);
            }
            onVolumeChanged: function(val) {
                root.logEvent("Applicazione Volume Reale Hardware: " + val + "%", false);
                hardwareCtrl.setVolume(val);
            }
        }

        SettingsDrawer {
            id: settingsDrawer
            z: 150
            activeLang: root.activeLang
            onClosed: root.logEvent("Chiusura Impostazioni Sidebar", false)
            onSettingsChanged: {
                appGrid.columnsCount = Plasmoid.configuration.gridColumns || 5;
                root.activeHeroColor = Plasmoid.configuration.accentColor || "#38bdf8";
                root.activeTheme = Plasmoid.configuration.currentTheme || "obsidian_minimal";
                root.activeLang = Plasmoid.configuration.currentLanguage || "it";
                root.enableAnimatedBg = Plasmoid.configuration.enableAnimatedOrbs;
                tabBar.activeLang = root.activeLang;
                heroCarousel.activeLang = root.activeLang;
                quickAccessDrawer.activeLang = root.activeLang;
                batteryPowerModal.activeLang = root.activeLang;
                appContextMenu.activeLang = root.activeLang;
                appPropertiesModal.activeLang = root.activeLang;
            }
        }

        FriendsOverlay {
            id: friendsOverlay
            z: 100
            onProfileUpdated: function(newName, newAvatar) {
                headerBar.userName = newName;
                headerBar.userAvatar = newAvatar;
                root.logEvent("Profilo utente aggiornato: " + newName + " (" + newAvatar + ")", false);
            }
            onClosed: root.logEvent("Chiusura Friends Overlay", false)
        }

        PowerMenu {
            id: powerMenuOverlay
            z: 200
            onClosed: root.logEvent("Chiusura Power Menu", false)
            onActionTriggered: function(actionId) {
                root.logEvent("Azione Power Menu selezionata: " + actionId, false);
                container.handlePowerAction(actionId);
            }
        }

        AppContextMenu {
            id: appContextMenu
            z: 350
            activeLang: root.activeLang
            onPlayRequested: function(appItem) {
                container.launchApplication(appItem.exec, appItem.name);
            }
            onToggleFavoriteRequested: function(appItem) {
                root.logEvent("Toggle preferiti per: " + appItem.name, false);
                appGrid.toggleFavorite(appItem);
            }
            onOpenPropertiesRequested: function(appItem) {
                root.logEvent("Apertura Proprietà Applicazione per: " + appItem.name, false);
                appPropertiesModal.open(appItem);
            }
            onManageDiscoverRequested: function(appItem) {
                container.launchApplication("org.kde.discover", "Discover");
            }
            onClosed: root.logEvent("Chiusura Menu Contestuale App", false)
        }

        WeatherForecastModal {
            id: weatherForecastModal
            z: 400
            onClosed: root.logEvent("Chiusura Modal Previsioni Meteo", false)
        }

        AppPropertiesModal {
            id: appPropertiesModal
            z: 450
            activeLang: root.activeLang
            onSaved: function(appItem, isFullscreen, customArgs, highPerf) {
                root.logEvent("Salvate impostazioni per " + appItem.name + ": Fullscreen=" + isFullscreen + ", Args=" + customArgs, false);
            }
            onClosed: root.logEvent("Chiusura Modal Proprietà", false)
        }

        WifiDetailsModal {
            id: wifiDetailsModal
            z: 600
            onClosed: root.logEvent("Chiusura Modal Wi-Fi Details", false)
        }

        BatteryPowerModal {
            id: batteryPowerModal
            z: 600
            activeLang: root.activeLang
            onClosed: root.logEvent("Chiusura Modal Batteria & Energia", false)
            onPowerProfileRequested: function(prof) {
                hardwareCtrl.setPowerProfile(prof);
            }
        }

        RamProcessesModal {
            id: ramProcessesModal
            z: 600
            activeLang: root.activeLang
            onClosed: root.logEvent("Chiusura Modal Top 10 Processi RAM", false)
        }

        function launchApplication(execId, appName) {
            try {
                root.logEvent("Richiesta avvio applicazione: " + execId + " (nome: " + appName + ")", false);
                root.toggle();

                if (!execId || execId.length === 0) {
                    throw new Error("Identificatore applicazione vuoto!");
                }

                var isFullscreen = true;
                try {
                    var rawConf = Plasmoid.configuration.appLaunchOptions || "{}";
                    var map = JSON.parse(rawConf);
                    if (map[execId] && map[execId].fullscreen !== undefined) {
                        isFullscreen = map[execId].fullscreen;
                    }
                } catch(e) {}

                function triggerInModel(model) {
                    if (!model || model.count === 0) return false;
                    for (var i = 0; i < model.count; i++) {
                        var child = model.modelForRow(i);
                        if (child != null) {
                            if (triggerInModel(child)) return true;
                        } else {
                            var url = (model.data(model.index(i, 0), Qt.UserRole + 1) || "").toString();
                            var name = (model.data(model.index(i, 0), Qt.DisplayRole) || "").toString();
                            var urlLower = url.toLowerCase();
                            var nameLower = name.toLowerCase();
                            var targetLower = execId.toLowerCase();
                            var appNameLower = appName ? appName.toLowerCase() : "";

                            if (urlLower.indexOf(targetLower) !== -1 ||
                                (appNameLower.length > 0 && nameLower === appNameLower) ||
                                (nameLower.indexOf(targetLower) !== -1)) {
                                root.logEvent("Trovato in AppsModel sub-tree (" + name + ") -> trigger(" + i + ") [Fullscreen=" + isFullscreen + "]", false);
                                model.trigger(i, "", null);
                                return true;
                            }
                        }
                    }
                    return false;
                }

                var rootModel = root.kickerRoot ? root.kickerRoot.appsModel : null;
                if (triggerInModel(rootModel)) {
                    return;
                }

                // Robust Direct command fallback
                var cleanExec = execId.replace(/["\\`$;|&><]/g, "").trim();
                if (cleanExec.length > 0) {
                    root.logEvent("Avvio diretto tramite fallback per: " + cleanExec, false);
                    hardwareCtrl.runCmd("gtk-launch " + cleanExec + " 2>/dev/null || kstart6 -- " + cleanExec + " 2>/dev/null || " + cleanExec + " &");
                    return;
                }

                root.logEvent("Avviso: Applicazione non trovata nell'albero AppsModel per: " + execId, true);
            } catch(err) {
                var errStr = "Errore durante l'avvio di '" + execId + "': " + err.message;
                root.logEvent(errStr, true);
                container.lastErrorMessage = errStr;
                errorDismissTimer.restart();
            }
        }

        function handlePowerAction(action) {
            try {
                root.logEvent("Esecuzione comando sessione: " + action, false);
                switch(action) {
                    case "suspend":
                        root.logEvent("Esecuzione sospensione sistema...", false);
                        hardwareCtrl.runCmd("systemctl suspend || loginctl suspend");
                        root.toggle();
                        break;
                    case "reboot":
                        root.logEvent("Esecuzione riavvio sistema...", false);
                        hardwareCtrl.runCmd("qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndReboot || systemctl reboot || loginctl reboot");
                        break;
                    case "poweroff":
                        root.logEvent("Esecuzione spegnimento sistema...", false);
                        hardwareCtrl.runCmd("qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndShutdown || systemctl poweroff || loginctl poweroff");
                        break;
                    case "lock":
                        root.logEvent("Esecuzione blocco schermo...", false);
                        hardwareCtrl.runCmd("qdbus6 org.freedesktop.ScreenSaver /ScreenSaver Lock || loginctl lock-session");
                        root.toggle();
                        break;
                    case "logout":
                        root.logEvent("Esecuzione termine sessione...", false);
                        hardwareCtrl.runCmd("qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout || qdbus6 org.kde.ksmserver /KSMServer logout 0 0 0 || loginctl terminate-session self");
                        break;
                    case "desktop_mode":
                        root.toggle();
                        break;
                    default:
                        throw new Error("Azione di sessione non riconosciuta: " + action);
                }
            } catch(err) {
                var errStr = "Errore Power Action '" + action + "': " + err.message;
                root.logEvent(errStr, true);
                container.lastErrorMessage = errStr;
                errorDismissTimer.restart();
            }
        }
    }
}
