import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Page {
    id: instancePickerPage
    anchors.fill: parent
    Component.onCompleted: getSample ()

    property var pods: null

    function search () {
        var input = customInstanceInput.displayText
        if ( input === " ") customInstanceInput.text = input = ""
        if ( pods === null || input === "" ) return
        input = input.toLowerCase()
        instanceList.children = ""
        loading.visible = false
        for ( var i = 0; i < pods.length; i++ ) {
            if ( pods[i].url.indexOf( input ) !== -1 ) {
                console.log( pods[i].url )
                var item = Qt.createComponent("../components/InstanceItem.qml")
                var displayDomain = pods[i].url.replace("https://","").replace("/","")
                item.createObject(instanceList, {
                    "text": "<b>%1</b> (%2) - Users: %3/%4".arg(displayDomain).arg(pods[i].language).arg(pods[i].connected).arg(pods[i].population),
                    "description": pods[i].description,
                    "url": pods[i].url
                })
            }
        }

        var item = Qt.createComponent("../components/InstanceItem.qml")
        item.createObject(instanceList, {
            "text": "<b>%1</b>".arg(input),
            "description": "Custom domain",
            "url": input
        })
    }

    /* Load list of Movim Pods from https://api.movim.eu/pods/favorite
    */
    function getSample () {

        var http = new XMLHttpRequest();
        var data = "?" +
        "sort_by=connections&" +
        "sort_order=desc&" +
        "count=20"

        http.open("GET", "https://api.movim.eu/pods/favorite", true)
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                var response = JSON.parse(http.responseText)
                pods = response.pods
                instanceList.writeInList ( response.pods )
            }
        }
        http.send();
    }


    header: PageHeader {
        id: header
        title: i18n.tr('Choose a Movim Pod')
        StyleHints {
            foregroundColor: "white"
            backgroundColor: "#3F51B5"
        }
        trailingActionBar {
            actions: [
            Action {
                text: i18n.tr("Info")
                iconName: "info"
                onTriggered: {
                    mainStack.push(Qt.resolvedUrl("./Info.qml"))
                }
            },
            Action {
                iconName: "search"
                onTriggered: {
                    if ( customInstanceInput.displayText == "" ) {
                        customInstanceInput.focus = true
                    }
                    else search ()
                }
            }
            ]
        }
    }

    ActivityIndicator {
        id: loading
        visible: true
        running: true
        anchors.centerIn: parent
    }


    TextField {
        id: customInstanceInput
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: height
        width: parent.width - height
        placeholderText: i18n.tr("Search or enter a custom address")
        onTextChanged: search ()
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height - 3*customInstanceInput.height
        anchors.top: customInstanceInput.bottom
        anchors.topMargin: customInstanceInput.height
        contentItem: Column {
            id: instanceList
            width: root.width

            // Write a list of instances to the ListView
            function writeInList ( list ) {
                instanceList.children = ""
                loading.visible = false
                for ( var i = 0; i < list.length; i++ ) {
                    var item = Qt.createComponent("../components/InstanceItem.qml")
                    var displayDomain = list[i].url.replace("https://","").replace("/","").replace("/","")
                    item.createObject(this, {
                        "text": "<b>%1</b> (%2) - Users: %3/%4".arg(displayDomain).arg(list[i].language).arg(list[i].connected).arg(list[i].population),
                        "description": list[i].description,
                        "url": list[i].url
                    })
                }
            }
        }
    }

}
