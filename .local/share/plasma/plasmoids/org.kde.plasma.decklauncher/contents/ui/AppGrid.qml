import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal appLaunched(var item)
    signal appContextMenuRequested(var item)
    signal focusUpRequested()

    property string searchQuery: ""
    property string currentCategory: "all"
    property int columnsCount: 5

    ListModel {
        id: displayAppsModel
    }

    readonly property var tabletInstalledApps: [
        { name: "SuperTuxKart", icon: "net.supertuxkart.SuperTuxKart", exec: "net.supertuxkart.SuperTuxKart", category: "games", desc: "Corse kart 3D arcade" },
        { name: "RetroArch", icon: "org.libretro.RetroArch", exec: "org.libretro.RetroArch", category: "games", desc: "Frontend emulatori universale" },
        { name: "SuperTux", icon: "org.supertuxproject.SuperTux", exec: "org.supertuxproject.SuperTux", category: "games", desc: "Platformer classico 2D" },
        { name: "Dolphin Emulator", icon: "org.DolphinEmu.dolphin-emu", exec: "org.DolphinEmu.dolphin-emu", category: "games", desc: "Emulatore GameCube & Wii" },
        { name: "Frozen Bubble", icon: "frozen-bubble", exec: "frozen-bubble", category: "games", desc: "Puzzle bubble arcade" },
        { name: "ProtonUp-Qt", icon: "net.davidotek.pupgui2", exec: "net.davidotek.pupgui2", category: "games", desc: "Gestore GE-Proton per gaming" },
        { name: "LÖVE 2D", icon: "love", exec: "love", category: "games", desc: "Engine giochi 2D Lua" },
        { name: "Spotube", icon: "com.github.KRTirtho.Spotube", exec: "com.github.KRTirtho.Spotube", category: "multimedia", desc: "Streaming Spotify e YT Music" },
        { name: "EasyEffects", icon: "com.github.wwmm.easyeffects", exec: "com.github.wwmm.easyeffects", category: "multimedia", desc: "Equalizzatore audio PipeWire" },
        { name: "AudioTube", icon: "org.kde.audiotube", exec: "org.kde.audiotube", category: "multimedia", desc: "Player YouTube Music KDE" },
        { name: "YTMDesktop", icon: "app.ytmdesktop.ytmdesktop", exec: "app.ytmdesktop.ytmdesktop", category: "multimedia", desc: "YouTube Music Desktop Player" },
        { name: "VLC", icon: "vlc", exec: "vlc", category: "multimedia", desc: "Riproduttore video e media" },
        { name: "Gwenview", icon: "org.kde.gwenview", exec: "org.kde.gwenview", category: "multimedia", desc: "Visualizzatore immagini" },
        { name: "Firefox", icon: "firefox", exec: "firefox", category: "internet", desc: "Navigatore Web open source" },
        { name: "KDE Connect", icon: "kdeconnect", exec: "org.kde.kdeconnect.app", category: "internet", desc: "Integrazione smartphone" },
        { name: "Telegram", icon: "org.telegram.desktop", exec: "org.telegram.desktop", category: "internet", desc: "Messaggistica istantanea" },
        { name: "Kate", icon: "org.kde.kate", exec: "org.kde.kate", category: "utilities", desc: "Editor di testo e codice" },
        { name: "Ark", icon: "org.kde.ark", exec: "org.kde.ark", category: "utilities", desc: "Gestore archivi compressi" },
        { name: "KDE Discover", icon: "plasmadiscover", exec: "org.kde.discover", category: "system", desc: "Software Center e Aggiornamenti" },
        { name: "Impostazioni di Sistema", icon: "systemsettings", exec: "systemsettings", category: "system", desc: "Pannello configurazione KDE" },
        { name: "Dolphin File Manager", icon: "org.kde.dolphin", exec: "org.kde.dolphin", category: "system", desc: "Gestione file e cartelle" },
        { name: "Konsole", icon: "org.kde.konsole", exec: "org.kde.konsole", category: "system", desc: "Terminale a riga di comando" },
        { name: "Monitor di Sistema", icon: "org.kde.plasma-systemmonitor", exec: "org.kde.plasma-systemmonitor", category: "system", desc: "Controllo processi e memoria" },
        { name: "Btop", icon: "btop", exec: "btop", category: "system", desc: "Monitor risorse da terminale" },
        { name: "KFind", icon: "org.kde.kfind", exec: "org.kde.kfind", category: "system", desc: "Trova file e cartelle" },
        { name: "Info di Sistema", icon: "org.kde.kinfocenter", exec: "org.kde.kinfocenter", category: "system", desc: "Informazioni hardware e Plasma" }
    ]

    function isFavorite(item) {
        var favStr = Plasmoid.configuration.favoriteApps || "";
        var favList = favStr.split(",");
        return (favList.indexOf(item.exec) !== -1 || favList.indexOf(item.name) !== -1);
    }

    function toggleFavorite(item) {
        var favStr = Plasmoid.configuration.favoriteApps || "";
        var favList = favStr.length > 0 ? favStr.split(",") : [];
        var idx = favList.indexOf(item.exec);
        if (idx !== -1) {
            favList.splice(idx, 1);
        } else {
            favList.push(item.exec);
        }
        Plasmoid.configuration.favoriteApps = favList.join(",");
        refreshApps();
    }

    function refreshApps() {
        displayAppsModel.clear();
        var q = searchQuery.toLowerCase().trim();
        var cat = currentCategory.toLowerCase();

        for (var i = 0; i < tabletInstalledApps.length; i++) {
            var app = tabletInstalledApps[i];
            var fav = isFavorite(app);

            if (cat === "favorites" && !fav) continue;
            if (cat !== "all" && cat !== "favorites" && cat !== "updates" && app.category !== cat) {
                if (cat === "audio" && app.category !== "multimedia") continue;
                if (cat === "video" && app.category !== "multimedia") continue;
                if (cat === "utilities" && app.category !== "system") continue;
                if (cat === "graphics" && app.category !== "multimedia") continue;
            }

            if (q.length > 0) {
                var nameMatch = app.name.toLowerCase().indexOf(q) !== -1;
                var descMatch = app.desc.toLowerCase().indexOf(q) !== -1;
                var execMatch = app.exec.toLowerCase().indexOf(q) !== -1;
                if (!nameMatch && !descMatch && !execMatch) continue;
            }

            displayAppsModel.append({
                name: app.name,
                icon: app.icon,
                exec: app.exec,
                desc: app.desc,
                category: app.category,
                isFav: fav
            });
        }
    }

    onSearchQueryChanged: refreshApps()
    onCurrentCategoryChanged: refreshApps()
    Component.onCompleted: refreshApps()

    // Empty state placeholder
    Item {
        anchors.fill: parent
        visible: displayAppsModel.count === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                width: 48
                height: 48
                source: "edit-find"
                color: "#64748b"
            }

            Text {
                text: "Nessuna applicazione trovata"
                color: "#94a3b8"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // High performance GridView with delegate reuse and optimized cell calculations
    GridView {
        id: gridView
        anchors.fill: parent
        clip: true
        reuseItems: true

        cellWidth: Math.floor(width / Math.max(1, root.columnsCount))
        cellHeight: 140
        model: displayAppsModel

        Keys.onUpPressed: {
            if (currentIndex < root.columnsCount) {
                root.focusUpRequested();
            } else {
                moveCurrentIndexUp();
            }
        }
        Keys.onDownPressed: moveCurrentIndexDown()
        Keys.onLeftPressed: moveCurrentIndexLeft()
        Keys.onRightPressed: moveCurrentIndexRight()
        Keys.onReturnPressed: {
            var item = displayAppsModel.get(currentIndex);
            if (item) root.appLaunched(item);
        }
        Keys.onEnterPressed: Keys.onReturnPressed(event)

        delegate: Item {
            id: gridItemDelegate
            width: gridView.cellWidth
            height: gridView.cellHeight

            readonly property bool isSelected: gridView.currentIndex === index
            readonly property bool isHovered: mouseArea.containsMouse

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                radius: 16
                color: gridItemDelegate.isSelected ? "#223147" : (gridItemDelegate.isHovered ? "#1a2536" : "#111823")
                border.color: gridItemDelegate.isSelected ? "#3daee9" : (gridItemDelegate.isHovered ? "#2e425e" : "#1e293b")
                border.width: gridItemDelegate.isSelected ? 2 : 1

                scale: gridItemDelegate.isSelected ? 1.04 : (gridItemDelegate.isHovered ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 150 } }

                Kirigami.Icon {
                    visible: model.isFav
                    width: 14
                    height: 14
                    source: "favorite"
                    color: "#facc15"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 8
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    width: parent.width - 16

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 52
                        height: 52
                        radius: 14
                        color: "#0f1622"
                        border.color: gridItemDelegate.isSelected ? "#3daee9" : "#243247"
                        border.width: 1

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 36
                            height: 36
                            source: model.icon
                            fallback: "application-x-executable"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: model.name
                        color: gridItemDelegate.isSelected ? "#ffffff" : "#e2ecf5"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        style: Text.Outline
                        styleColor: "#050811"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: model.desc
                        color: "#8a9ba8"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
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
                    gridView.currentIndex = index;
                    if (mouse.button === Qt.RightButton) {
                        root.appContextMenuRequested(displayAppsModel.get(index));
                    } else {
                        root.appLaunched(displayAppsModel.get(index));
                    }
                }
                onPressAndHold: {
                    gridView.currentIndex = index;
                    root.appContextMenuRequested(displayAppsModel.get(index));
                }
            }
        }
    }
}
