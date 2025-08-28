/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * memesapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Qt.labs.settings 1.0
import "components"
import "models"
import "services"

ApplicationWindow {
    id: root
    visible: true
    title: "MemeStream"
    width: 400
    height: 600

    // Application properties
    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property bool useCustomSubreddit: false
    // Fullscreen image viewer source
    property string dialogImageSource: ""

    // Category mapping for better user experience
    property var categoryMap: ({
            "General Memes": "memes",
            "Dank Memes": "dankmemes",
            "Wholesome Memes": "wholesomememes",
            "Funny": "funny",
            "Programming Humor": "ProgrammerHumor",
            "Me IRL": "meirl",
            "Star Wars Memes": "PrequelMemes",
            "History Memes": "HistoryMemes",
            "Gaming Memes": "gaming",
            "Anime Memes": "AnimeMemes"
        })

    // Array of category names for the OptionSelector
    property var categoryNames: ["General Memes", "Dank Memes", "Wholesome Memes", "Funny", "Programming Humor", "Me IRL", "Star Wars Memes", "History Memes", "Gaming Memes", "Anime Memes"]

    // Model
    MemeModel {
        id: memeModel

        onModelUpdated: {
            console.log("Main: Model updated with", count, "memes");
        }

        onModelCleared: {
            console.log("Main: Model cleared");
        }
    }

    // Service
    MemeService {
        id: memeService

        Component.onCompleted: {
            console.log("Main: Setting model for service");
            setModel(memeModel);
        }

        onMemesRefreshed: {
            console.log("Main: Memes refreshed, count:", count);
        }

        onLoadingChanged: {
            console.log("Main: Loading state changed:", loading);
        }

        onErrorOccurred: {
            console.log("Main: Service error:", message);
        }

        onSubredditChanged: {
            console.log("Main: Subreddit changed to:", subreddit);
            root.selectedSubreddit = subreddit;
        }
    }

    // Download Manager
    QtObject {
        id: downloadManager

        function downloadMeme(imageUrl, title) {
            console.log("DownloadManager: Starting download for:", imageUrl);
            try {
                Qt.openUrlExternally(imageUrl);
                console.log("DownloadManager: Opened image URL externally:", imageUrl);
            } catch (e) {
                console.log("DownloadManager: Failed to open URL externally:", e);
            }
        }

        function shareMeme(url, title) {
            console.log("DownloadManager: Sharing meme:", title, "URL:", url);
            try {
                Qt.openUrlExternally(url);
                console.log("DownloadManager: Opened share URL externally:", url);
            } catch (e) {
                console.log("DownloadManager: Failed to open share URL externally:", e);
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPageComponent
    }

    Component {
        id: mainPageComponent

        Page {
            title: "MemeStream"
            Rectangle {
                anchors.fill: parent
                color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : theme.palette.normal.background
                z: -1  // Ensure it stays behind other content
            }

            header: PageHeader {
                title: i18n.tr("M E M E S T R E A M")
                subtitle: i18n.tr("r/" + root.selectedSubreddit)
                StyleHints {
                    backgroundColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : "#081831"
                    foregroundColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#9b4f22" : "white"
                }

                trailingActionBar.actions: [
                    Action {
                        iconName: "settings"
                        text: i18n.tr("Select Subreddit")
                        onTriggered: {
                            subredditSelectionDialog.open();
                        }
                    },
                    Action {
                        iconName: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "weather-clear-night-symbolic" : "weather-clear-symbolic"
                        text: theme.name === "Ubuntu.Components.Themes.SuruDark" ? i18n.tr("Light Mode") : i18n.tr("Dark Mode")
                        onTriggered: {
                            Theme.name = theme.name === "Ubuntu.Components.Themes.SuruDark" ? "Ubuntu.Components.Themes.Ambiance" : "Ubuntu.Components.Themes.SuruDark";
                        }
                    }
                ]
            }

            ColumnLayout {

                anchors.fill: parent
                anchors.margins: units.gu(2)
                anchors.topMargin: units.gu(4)
                spacing: units.gu(1.5)

                // Loading indicator
                BusyIndicator {
                    visible: memeService.isLoading
                    running: memeService.isLoading
                    Layout.alignment: Qt.AlignHCenter
                }

                // Current subreddit info
                Text {
                    text: "r/" + root.selectedSubreddit
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    color: theme.palette.normal.backgroundText
                    visible: !memeService.isLoading && !memeService.isModelEmpty()
                    Layout.alignment: Qt.AlignHCenter
                }

                // Meme list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: memeModel
                    visible: !memeService.isLoading
                    clip: true
                    spacing: units.gu(1.5)
                    delegate: Rectangle {
                        width: ListView.view ? ListView.view.width : units.gu(37.5)
                        height: delegateColumn.height + 20
                        color: theme.palette.normal.background
                        border.color: theme.palette.normal.base
                        border.width: 1
                        radius: 8

                        Column {
                            id: delegateColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 10
                            spacing: 5

                            Text {
                                text: model.title || "Untitled"
                                font.bold: true
                                wrapMode: Text.WordWrap
                                width: parent.width
                                color: theme.palette.normal.backgroundText
                            }

                            Image {
                                source: model.image || ""
                                width: Math.min(parent.width, 350)
                                height: Math.min(width * 0.8, 250)
                                fillMode: Image.PreserveAspectFit
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: source != ""

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("Failed to load image:", model.image);
                                        visible = false;
                                    }
                                }

                                // Open fullscreen viewer when clicked
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (model.image) {
                                            root.dialogImageSource = model.image;
                                            attachmentDialog.open();
                                        }
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Row {
                                spacing: units.gu(2.5)

                                Text {
                                    text: "👍 " + (model.upvotes || 0)
                                    color: theme.palette.normal.backgroundText
                                }

                                Text {
                                    text: "💬 " + (model.comments || 0)
                                    color: theme.palette.normal.backgroundText
                                }

                                Text {
                                    text: "r/" + (model.subreddit || "")
                                    color: theme.palette.normal.backgroundText
                                }

                                Text {
                                    text: "📤"
                                    font.pixelSize: units.gu(1.5)
                                    color: theme.palette.normal.backgroundText

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            downloadManager.shareMeme(model.permalink || model.image, model.title);
                                        }
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                Text {
                                    text: "💾"
                                    font.pixelSize: units.gu(1.5)
                                    color: theme.palette.normal.backgroundText

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            downloadManager.downloadMeme(model.image, model.title);
                                        }
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Column {
                    Layout.alignment: Qt.AlignCenter
                    visible: memeService.isModelEmpty() && !memeService.isLoading
                    spacing: units.gu(1.5)
                    Text {
                        text: "No memes found"
                        font.pixelSize: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.backgroundText
                    }

                    Text {
                        text: root.useCustomSubreddit ? "Try a different subreddit or check the spelling" : "Try selecting a different category or refresh"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.backgroundSecondaryText
                    }

                    Button {
                        text: "Refresh"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: memeService.refreshMemes()
                    }
                }

                // Error state
                Column {
                    Layout.alignment: Qt.AlignCenter
                    visible: memeService.lastError !== "" && !memeService.isLoading
                    spacing: units.gu(1.5)
                    Text {
                        text: "Error loading memes"
                        font.pixelSize: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.negative
                    }

                    Text {
                        text: memeService.lastError
                        font.pixelSize: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.backgroundSecondaryText
                        wrapMode: Text.WordWrap
                        width: units.gu(40)
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        text: "Try Again"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: memeService.refreshMemes()
                    }
                }
            }
        }
    }

    // Settings persistence
    Settings {
        id: settings
        property alias darkMode: root.darkMode
        property alias selectedSubreddit: root.selectedSubreddit
        property alias useCustomSubreddit: root.useCustomSubreddit
    }

    // Subreddit Selection Dialog
    Dialog {
        id: subredditSelectionDialog
        title: "Select Subreddit"
        modal: true
        focus: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        width: Math.min(root.width * 0.9, units.gu(50))
        x: (root.width - width) / 2
        y: (root.height - height) / 2

        background: Rectangle {
            color: theme.palette.normal.background
            border.color: theme.palette.normal.base
            border.width: 1
            radius: units.gu(1)
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: units.gu(2)

            // Mode selector (Category vs Custom)
            GroupBox {
                title: "Selection Mode"
                Layout.fillWidth: true
                anchors.margins: units.gu(1)

                background: Rectangle {
                    color: theme.palette.normal.base
                    border.color: theme.palette.normal.baseBorder
                    border.width: units.gu(0.1)
                    radius: units.gu(.5)
                }

                label: Text {
                    text: "Selection Mode"
                    color: theme.palette.normal.backgroundText
                    anchors.margins: units.gu(1)
                    font.bold: true
                }

                Column {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    RadioButton {
                        id: dialogCategoryModeRadio
                        text: "Predefined Categories"
                        checked: !root.useCustomSubreddit

                        contentItem: Text {
                            text: dialogCategoryModeRadio.text
                            color: theme.palette.normal.backgroundText
                            leftPadding: dialogCategoryModeRadio.indicator.width + dialogCategoryModeRadio.spacing
                        }
                    }

                    RadioButton {
                        id: dialogCustomModeRadio
                        text: "Custom Subreddit"
                        checked: root.useCustomSubreddit

                        contentItem: Text {
                            text: dialogCustomModeRadio.text
                            color: theme.palette.normal.backgroundText
                            leftPadding: dialogCustomModeRadio.indicator.width + dialogCustomModeRadio.spacing
                        }
                    }
                }
            }

            // Category Selector (shown when category mode is selected)
            GroupBox {
                title: "Choose Category"
                Layout.fillWidth: true
                visible: dialogCategoryModeRadio.checked

                background: Rectangle {
                    color: theme.palette.normal.base
                    border.color: theme.palette.normal.baseBorder
                    border.width: 1
                    radius: 4
                }

                label: Text {
                    text: "Choose Category"
                    color: theme.palette.normal.backgroundText
                    font.bold: true
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    Text {
                        text: "Select a meme category:"
                        Layout.fillWidth: true
                        color: theme.palette.normal.backgroundText
                    }

                    ComboBox {
                        id: dialogCategoryCombo
                        model: root.categoryNames
                        Layout.fillWidth: true

                        background: Rectangle {
                            color: theme.palette.normal.field
                            border.color: theme.palette.normal.base
                            border.width: 1
                            radius: 4
                        }

                        contentItem: Text {
                            text: dialogCategoryCombo.displayText
                            color: theme.palette.normal.fieldText
                            leftPadding: units.gu(1)
                            rightPadding: units.gu(3)
                            verticalAlignment: Text.AlignVCenter
                        }

                        Component.onCompleted: {
                            // Set initial selection based on current subreddit
                            if (!root.useCustomSubreddit) {
                                for (var i = 0; i < root.categoryNames.length; i++) {
                                    if (root.categoryMap[root.categoryNames[i]] === root.selectedSubreddit) {
                                        currentIndex = i;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Custom subreddit input (shown when custom mode is selected)
            GroupBox {
                title: "Enter Custom Subreddit"
                Layout.fillWidth: true
                visible: dialogCustomModeRadio.checked

                background: Rectangle {
                    color: theme.palette.normal.base
                    border.color: theme.palette.normal.baseBorder
                    border.width: 1
                    radius: 4
                }

                label: Text {
                    text: "Enter Custom Subreddit"
                    color: theme.palette.normal.backgroundText
                    font.bold: true
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    Text {
                        text: "Enter the name of any subreddit:"
                        Layout.fillWidth: true
                        color: theme.palette.normal.backgroundText
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(1)

                        Text {
                            text: "r/"
                            font.bold: true
                            color: theme.palette.normal.backgroundText
                        }

                        TextField {
                            id: dialogCustomSubredditField
                            Layout.fillWidth: true
                            placeholderText: "e.g., memes, funny, programming"
                            text: root.useCustomSubreddit ? root.selectedSubreddit : ""

                            Rectangle {
                                color: theme.palette.normal.field
                                border.color: theme.palette.normal.base
                                border.width: 1
                                radius: 4
                            }

                            color: theme.palette.normal.fieldText

                            onTextChanged: {
                                // Remove 'r/' prefix if user types it
                                if (text.toLowerCase().startsWith("r/")) {
                                    text = text.substring(2);
                                }
                                // Remove any invalid characters for subreddit names
                                var cleanText = text.replace(/[^a-zA-Z0-9_]/g, '');
                                if (cleanText !== text) {
                                    text = cleanText;
                                }
                            }

                            Keys.onReturnPressed: subredditSelectionDialog.accept()
                            Keys.onEnterPressed: subredditSelectionDialog.accept()
                        }
                    }

                    Text {
                        text: "Note: Make sure the subreddit exists and contains images"
                        font.pixelSize: units.gu(1.2)
                        color: theme.palette.normal.backgroundSecondaryText
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        onAccepted: {
            var newSubreddit = "";
            var newUseCustom = dialogCustomModeRadio.checked;

            if (newUseCustom) {
                // Custom subreddit mode
                var customText = dialogCustomSubredditField.text.trim().toLowerCase();
                if (customText !== "") {
                    newSubreddit = customText;
                } else {
                    // Invalid input, don't close dialog
                    return;
                }
            } else {
                // Category mode
                if (dialogCategoryCombo.currentIndex >= 0 && dialogCategoryCombo.currentText) {
                    var categoryName = dialogCategoryCombo.currentText;
                    newSubreddit = root.categoryMap[categoryName];
                }
            }

            if (newSubreddit && (newSubreddit !== root.selectedSubreddit || newUseCustom !== root.useCustomSubreddit)) {
                console.log("Dialog: Applying new subreddit:", newSubreddit, "Custom:", newUseCustom);
                root.useCustomSubreddit = newUseCustom;
                root.selectedSubreddit = newSubreddit;
                memeService.fetchMemes(newSubreddit);
            }
        }

        onOpened: {
            // Reset dialog state when opened
            dialogCategoryModeRadio.checked = !root.useCustomSubreddit;
            dialogCustomModeRadio.checked = root.useCustomSubreddit;

            if (root.useCustomSubreddit) {
                dialogCustomSubredditField.text = root.selectedSubreddit;
                dialogCustomSubredditField.forceActiveFocus();
            } else {
                // Update category combo to match current subreddit
                for (var i = 0; i < root.categoryNames.length; i++) {
                    if (root.categoryMap[root.categoryNames[i]] === root.selectedSubreddit) {
                        dialogCategoryCombo.currentIndex = i;
                        break;
                    }
                }
            }
        }
    }

    // Fullscreen image viewer dialog
    Dialog {
        id: attachmentDialog
        modal: true
        focus: true
        padding: 0
        // Make it fullscreen
        x: 0
        y: 0
        width: root.width
        height: root.height
        background: Rectangle {
            color: "transparent"
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000CC" // slightly darker overlay

            Image {
                id: fullImage
                anchors.centerIn: parent
                width: parent.width * 0.94
                height: parent.height * 0.94
                fillMode: Image.PreserveAspectFit
                source: root.dialogImageSource
                cache: true
                smooth: true
            }

            // Consume clicks on the image so outer area can differentiate
            MouseArea {
                anchors.fill: fullImage
                onClicked: /* no-op to prevent propagation so image click doesn't close */ {}
                acceptedButtons: Qt.AllButtons
            }

            // Close button
            Button {
                text: "\u2715" // X
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: units.gu(1)
                width: units.gu(4)
                height: units.gu(4)
                onClicked: attachmentDialog.close()
            }

            // Click outside image also closes
            MouseArea {
                anchors.fill: parent
                onClicked: attachmentDialog.close()
                hoverEnabled: true
                propagateComposedEvents: true
            }
        }

        Keys.onEscapePressed: attachmentDialog.close()
        onClosed: root.dialogImageSource = ""
    }

    function handleSelectedSubredditChanged(subreddit) {
        console.log("Main: Selected subreddit changed to:", subreddit);
        root.selectedSubreddit = subreddit;
        memeService.fetchMemes(subreddit);
    }

    // Initialization
    Component.onCompleted: {
        console.log("Main: App starting up");
        console.log("Main: Selected subreddit:", root.selectedSubreddit);
        console.log("Main: Dark mode:", root.darkMode);
        console.log("Main: Use custom subreddit:", root.useCustomSubreddit);

        // Delay initial fetch to ensure service is ready
        Qt.callLater(function () {
            memeService.fetchMemes(root.selectedSubreddit);
        });
    }
}
