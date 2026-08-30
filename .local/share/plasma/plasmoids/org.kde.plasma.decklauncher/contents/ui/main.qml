import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.kicker as Kicker

PlasmoidItem {
    id: kicker

    preferredRepresentation: fullRepresentation
    compactRepresentation: null
    fullRepresentation: compactRepresentation

    readonly property Kicker.AppsModel appsModel: Kicker.AppsModel {
        id: globalAppsModel
        autoPopulate: true
        flat: true
        showTopLevelItems: true
        sorted: true
        appNameFormat: 0
        appletInterface: kicker

        Component.onCompleted: {
            refresh();
            console.log("[NebulaDeck] globalAppsModel creato. Count:", count);
        }
        onCountChanged: {
            console.log("[NebulaDeck] globalAppsModel count:", count);
        }
    }

    Component {
        id: compactRepresentation
        CompactRepresentation {
            kickerRoot: kicker
        }
    }
}
