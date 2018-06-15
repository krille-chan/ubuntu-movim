import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
import "../components"

Page {
    id: page
    width: parent.width
    height: parent.height

    header: Rectangle {
        color: UbuntuColors.orange
        width: parent.width
        height: units.gu(0)
    }

    Component {
        id: pickerComponent
        PickerDialog {}
    }

    WebView {
        id: webView
        width: parent.width
        height: parent.height
        visible: false
        onLoadProgressChanged: {
            progressBar.value = loadProgress
            if ( loadProgress === 100 ) visible = true
        }
        anchors.fill: parent
        url: instance.indexOf("http") != -1 ? instance : "https://" + instance
        preferences.localStorageEnabled: true
        preferences.allowFileAccessFromFileUrls: true
        preferences.allowUniversalAccessFromFileUrls: true
        preferences.appCacheEnabled: true
        preferences.javascriptCanAccessClipboard: true
        filePicker: pickerComponent

        // Open external URL's in the browser and not in the app
        onNavigationRequested: {
            console.log ( request.url, ("" + request.url).indexOf ( instance ) !== -1 )
            if ( ("" + request.url).indexOf ( instance ) !== -1 ) {
                request.action = 0
            } else {
                request.action = 1
                Qt.openUrlExternally( request.url )
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: !webView.visible
        color: "#212121"

        Label {
            id: progressLabel
            color: "white"
            text: i18n.tr('Loading ') + instance.replace("https://","").replace("/","")
            anchors.centerIn: parent
            textSize: Label.XLarge
        }

        ProgressBar {
            id: progressBar
            value: 0
            minimumValue: 0
            maximumValue: 100
            anchors.top: progressLabel.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height
            anchors.horizontalCenter: parent.horizontalCenter
            color: UbuntuColors.red
            text: "Choose another Instance"
            onClicked: {
                db.transaction(
                    function(tx) {
                        tx.executeSql('DELETE FROM Url')
                        mainStack.clear ()
                        mainStack.push (Qt.resolvedUrl("./InstancePicker.qml"))
                    }
                )
            }
        }
    }



}
