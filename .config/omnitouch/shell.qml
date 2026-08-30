import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: "OmniTouch - Canvas Push Drawer"

    property bool drawerOpen: false

    // Sfondo globale scuro
    background: Rectangle {
        color: "#090d16"
    }

    // =========================================================================
    // 1. LAYER INFERIORE: SIDE DRAWER (Menu laterale a tutta altezza)
    // =========================================================================
    SideDrawer {
        id: sideDrawer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 320
        opacity: root.drawerOpen ? 1.0 : 0.0
        scale: root.drawerOpen ? 1.0 : 0.95
        transformOrigin: Item.Left

        Behavior on opacity { NumberAnimation { duration: 260 } }
        Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        onItemSelected: (name) => {
            console.log("[OmniTouch] Voce selezionata dal drawer:", name)
            root.drawerOpen = false
        }
        onCloseRequested: root.drawerOpen = false
    }

    // =========================================================================
    // 2. LAYER SUPERIORE: APP WORKSPACE CANVAS (Scale, Shift & Rounded)
    // =========================================================================
    // Ombra/Bordo decorativo per profondità 3D quando ridotto
    Rectangle {
        id: shadowCard
        anchors.fill: appCanvas
        radius: appCanvas.radius
        color: "#000000"
        opacity: root.drawerOpen ? 0.6 : 0.0
        z: appCanvas.z - 1
        scale: appCanvas.scale
        transformOrigin: appCanvas.transformOrigin

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    AppWorkspace {
        id: appCanvas
        anchors.fill: parent
        z: 10
        drawerOpen: root.drawerOpen

        // Trasformazioni Canvas Push
        transformOrigin: Item.Right
        scale: root.drawerOpen ? 0.82 : 1.0
        x: root.drawerOpen ? 300 : 0
        radius: root.drawerOpen ? 24 : 0

        border.color: root.drawerOpen ? "#38bdf8" : "transparent"
        border.width: root.drawerOpen ? 2 : 0

        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on radius { NumberAnimation { duration: 220 } }
        Behavior on border.width { NumberAnimation { duration: 200 } }

        onToggleDrawer: root.drawerOpen = !root.drawerOpen
        onCloseDrawer: root.drawerOpen = false
    }
}
