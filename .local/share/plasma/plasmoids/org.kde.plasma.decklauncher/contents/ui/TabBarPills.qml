import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "i18n.js" as I18n

Item {
    id: root
    implicitHeight: 44
    height: 44
    Layout.fillWidth: true
    Layout.preferredHeight: 44

    signal tabSelected(int index, string categoryId)
    signal focusUpRequested()
    signal focusDownRequested()

    property alias currentIndex: tabList.currentIndex
    property alias count: tabModel.count
    property string activeLang: Plasmoid.configuration.currentLanguage || "it"

    ListModel {
        id: tabModel

        ListElement { key: "all"; iconName: "applications-other"; catKey: "all" }
        ListElement { key: "favorites"; iconName: "favorite"; catKey: "favorites" }
        ListElement { key: "games"; iconName: "applications-games"; catKey: "games" }
        ListElement { key: "audio"; iconName: "applications-multimedia"; catKey: "audio" }
        ListElement { key: "video"; iconName: "video-player"; catKey: "video" }
        ListElement { key: "graphics"; iconName: "applications-graphics"; catKey: "graphics" }
        ListElement { key: "utilities"; iconName: "applications-utilities"; catKey: "utilities" }
        ListElement { key: "updates"; iconName: "system-software-update"; catKey: "updates" }
    }

    ListView {
        id: tabList
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 10
        model: tabModel
        clip: false

        Keys.onLeftPressed: {
            if (currentIndex > 0) decrementCurrentIndex();
        }
        Keys.onRightPressed: {
            if (currentIndex < count - 1) incrementCurrentIndex();
        }
        Keys.onUpPressed: root.focusUpRequested()
        Keys.onDownPressed: root.focusDownRequested()

        delegate: Rectangle {
            id: pillDelegate
            width: pillRow.implicitWidth + 28
            height: 36
            radius: 18

            readonly property bool isSelected: tabList.currentIndex === index
            readonly property bool isHovered: pillMouseArea.containsMouse

            color: isSelected ? "#3daee9" : (isHovered ? "#223147" : "#141c28")
            border.color: isSelected ? "#3daee9" : (isHovered ? "#38bdf8" : "#243247")
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                id: pillRow
                anchors.centerIn: parent
                spacing: 8

                Kirigami.Icon {
                    width: 16
                    height: 16
                    source: model.iconName
                    color: pillDelegate.isSelected ? "#0e141d" : (pillDelegate.isHovered ? "#ffffff" : "#94a3b8")
                }

                Text {
                    text: I18n.t(model.catKey, root.activeLang)
                    color: pillDelegate.isSelected ? "#0e141d" : (pillDelegate.isHovered ? "#ffffff" : "#cbd5e1")
                    font.pixelSize: 13
                    font.weight: pillDelegate.isSelected ? Font.Bold : Font.DemiBold
                }
            }

            MouseArea {
                id: pillMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    tabList.currentIndex = index;
                    root.tabSelected(index, model.key);
                }
            }
        }
    }
}
