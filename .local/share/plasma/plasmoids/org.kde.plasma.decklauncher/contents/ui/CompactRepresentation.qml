import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker as Kicker

Item {
    id: root

    property var kickerRoot: null

    readonly property Component dashWindowComponent: Qt.createComponent(Qt.resolvedUrl("./DeckDashboard.qml"), root)
    readonly property Kicker.DashboardWindow dashWindow: dashWindowComponent && dashWindowComponent.status === Component.Ready
        ? dashWindowComponent.createObject(root, { visualParent: root, kickerRoot: root.kickerRoot }) : null

    Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    Layout.minimumWidth: Kirigami.Units.gridUnit * 2
    Layout.minimumHeight: Kirigami.Units.gridUnit * 2
    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isOpened: dashWindow && dashWindow.visible

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.isOpened ? "#3daee9" : (root.isHovered ? "#243247" : "transparent")
        opacity: root.isOpened ? 0.4 : (root.isHovered ? 0.3 : 0.0)
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Kirigami.Icon {
        id: buttonIcon
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.85
        height: width
        source: "applications-games"
        scale: root.isOpened ? 0.92 : (root.isHovered ? 1.08 : 1.0)
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        activeFocusOnTab: true
        hoverEnabled: !root.dashWindow || !root.dashWindow.visible
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (dashWindow) {
                dashWindow.toggle();
            } else {
                console.error("[PlasmaDeckLauncher] Errore: dashWindow non ancora pronto");
            }
        }
    }

    Component.onCompleted: {
        plasmoid.activated.connect(function() {
            if (dashWindow) {
                dashWindow.toggle();
            }
        });
    }
}
