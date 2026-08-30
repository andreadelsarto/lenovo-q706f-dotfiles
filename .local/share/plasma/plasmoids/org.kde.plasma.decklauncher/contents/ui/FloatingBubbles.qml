import QtQuick
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent
    clip: true

    property color accentColor: "#38bdf8"

    Repeater {
        model: [
            { initX: 0.12, initY: 0.25, size: 280, dur: 14000, maxOpacity: 0.28 },
            { initX: 0.78, initY: 0.15, size: 240, dur: 11000, maxOpacity: 0.24 },
            { initX: 0.45, initY: 0.60, size: 340, dur: 17000, maxOpacity: 0.22 },
            { initX: 0.88, initY: 0.70, size: 220, dur: 13000, maxOpacity: 0.20 },
            { initX: 0.22, initY: 0.80, size: 260, dur: 15000, maxOpacity: 0.25 },
            { initX: 0.65, initY: 0.40, size: 180, dur: 10000, maxOpacity: 0.26 },
            { initX: 0.05, initY: 0.50, size: 200, dur: 12000, maxOpacity: 0.22 }
        ]

        Rectangle {
            id: bubble
            width: modelData.size
            height: modelData.size
            radius: modelData.size / 2

            // Glowing circle with border and radial blur effect
            color: root.accentColor
            opacity: modelData.maxOpacity
            border.color: Qt.lighter(root.accentColor, 1.4)
            border.width: 1.5

            Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.OutCubic } }

            // Floating sinusoidal animation in 2D
            x: (root.width * modelData.initX) + Math.sin(animX.val) * 70
            y: (root.height * modelData.initY) + Math.cos(animY.val) * 50

            property real valX: 0.0
            property real valY: 0.0

            NumberAnimation on valX {
                id: animX
                loops: Animation.Infinite
                from: 0.0
                to: Math.PI * 2
                duration: modelData.dur
            }

            NumberAnimation on valY {
                id: animY
                loops: Animation.Infinite
                from: 0.0
                to: Math.PI * 2
                duration: modelData.dur * 1.3
            }

            // Pulsating scale
            scale: 0.9 + 0.15 * Math.sin(animScale.val)
            property real valScale: 0.0
            NumberAnimation on valScale {
                id: animScale
                loops: Animation.Infinite
                from: 0.0
                to: Math.PI * 2
                duration: modelData.dur * 0.8
            }
        }
    }
}
