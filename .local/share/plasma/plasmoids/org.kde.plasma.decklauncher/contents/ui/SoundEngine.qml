import QtQuick
import QtMultimedia
import org.kde.plasma.plasmoid

Item {
    id: root

    property bool soundEnabled: Plasmoid.configuration.enableSoundFx !== false

    SoundEffect {
        id: navSnd
        source: Qt.resolvedUrl("../audio/nav.wav")
        volume: 0.35
    }

    SoundEffect {
        id: selectSnd
        source: Qt.resolvedUrl("../audio/select.wav")
        volume: 0.45
    }

    SoundEffect {
        id: backSnd
        source: Qt.resolvedUrl("../audio/back.wav")
        volume: 0.35
    }

    SoundEffect {
        id: toggleSnd
        source: Qt.resolvedUrl("../audio/toggle.wav")
        volume: 0.30
    }

    function playNav() {
        if (root.soundEnabled) navSnd.play();
    }

    function playSelect() {
        if (root.soundEnabled) selectSnd.play();
    }

    function playBack() {
        if (root.soundEnabled) backSnd.play();
    }

    function playToggle() {
        if (root.soundEnabled) toggleSnd.play();
    }
}
