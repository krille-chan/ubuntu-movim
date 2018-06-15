import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import "components"
import "pages"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'eu.movim.ut.movim'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)
    anchorToKeyboard: true

    property var instance: "nl.movim.eu"
    property var db: LocalStorage.openDatabaseSync("movimPod", "1.0", "Instance for movim", 1000000)

    PageStack {
        id: mainStack
    }

    Component.onCompleted: {
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Url(url TEXT)')

                var rs = tx.executeSql('SELECT * FROM Url')
                if ( rs.rows.length > 0 ) {
                    instance = rs.rows[0].url
                    mainStack.push(Qt.resolvedUrl("./pages/MovimWebview.qml"))
                }
                else {
                    mainStack.push(Qt.resolvedUrl("./pages/InstancePicker.qml"))
                }
            }
        )

    }
}
