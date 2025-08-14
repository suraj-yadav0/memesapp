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

            header: PageHeader {
                title: i18n.tr("M E M E S T R E A M")
                StyleHints {
                    backgroundColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : "#1c355e"
                    foregroundColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#fac34d" : "white"
                }

                trailingActionBar.actions: [
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
                    visible: !memeService.isLoading && !memeService.isModelEmpty()
                    Layout.alignment: Qt.AlignHCenter
                }

                // Subreddit selection section
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: units.gu(1)
                    visible: !memeService.isLoading

                    // Mode selector (Category vs Custom)
                    Row {
                        spacing: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter

                        RadioButton {
                            id: categoryModeRadio
                            text: "Categories"
                            checked: !root.useCustomSubreddit
                            onCheckedChanged: {
                                if (checked) {
                                    root.useCustomSubreddit = false;
                                    // Reset to current category if available
                                    if (categoryCombo.currentIndex >= 0) {
                                        var categoryName = root.categoryNames[categoryCombo.currentIndex];
                                        var subreddit = root.categoryMap[categoryName];
                                        if (subreddit !== root.selectedSubreddit) {
                                            root.selectedSubreddit = subreddit;
                                            memeService.fetchMemes(subreddit);
                                        }
                                    }
                                }
                            }
                        }

                        RadioButton {
                            id: customModeRadio
                            text: "Custom"
                            checked: root.useCustomSubreddit
                            onCheckedChanged: {
                                if (checked) {
                                    root.useCustomSubreddit = true;
                                    customSubredditField.forceActiveFocus();
                                }
                            }
                        }
                    }

                    // Category Selector (shown when category mode is selected)
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: units.gu(1.5)
                        visible: !root.useCustomSubreddit

                        Text {
                            text: "Category:"
                            font.bold: true
                        }

                        ComboBox {
                            id: categoryCombo
                            model: root.categoryNames
                            Layout.preferredWidth: units.gu(25)

                            Component.onCompleted: {
                                // Set initial selection based on current subreddit
                                for (var i = 0; i < root.categoryNames.length; i++) {
                                    if (root.categoryMap[root.categoryNames[i]] === root.selectedSubreddit) {
                                        currentIndex = i;
                                        break;
                                    }
                                }
                            }

                            onCurrentTextChanged: {
                                if (!root.useCustomSubreddit && currentText && root.categoryMap[currentText]) {
                                    var newSubreddit = root.categoryMap[currentText];
                                    console.log("Main: Category changed to:", currentText, "-> subreddit:", newSubreddit);
                                    if (newSubreddit !== root.selectedSubreddit) {
                                        root.selectedSubreddit = newSubreddit;
                                        memeService.fetchMemes(newSubreddit);
                                    }
                                }
                            }
                        }
                    }

                    // Custom subreddit input (shown when custom mode is selected)
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: units.gu(1.5)
                        visible: root.useCustomSubreddit

                        Text {
                            text: "r/"
                            font.bold: true
                        }

                        TextField {
                            id: customSubredditField
                            Layout.preferredWidth: units.gu(20)
                            placeholderText: "Enter subreddit name"
                            text: root.useCustomSubreddit ? root.selectedSubreddit : ""
                            
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

                            onAccepted: {
                                if (text.trim() !== "" && root.useCustomSubreddit) {
                                    var subreddit = text.trim().toLowerCase();
                                    console.log("Main: Custom subreddit entered:", subreddit);
                                    root.selectedSubreddit = subreddit;
                                    memeService.fetchMemes(subreddit);
                                }
                            }

                            Keys.onReturnPressed: accepted()
                            Keys.onEnterPressed: accepted()
                        }

                        Button {
                            text: "Go"
                            enabled: customSubredditField.text.trim() !== ""
                            onClicked: {
                                if (customSubredditField.text.trim() !== "" && root.useCustomSubreddit) {
                                    var subreddit = customSubredditField.text.trim().toLowerCase();
                                    console.log("Main: Custom subreddit button clicked:", subreddit);
                                    root.selectedSubreddit = subreddit;
                                    memeService.fetchMemes(subreddit);
                                }
                            }
                        }
                    }
                }

                // Meme list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: memeModel
                    visible: !memeService.isLoading
                    spacing: units.gu(1.5)
                    delegate: Rectangle {
                        width: ListView.view ? ListView.view.width : units.gu(37.5)
                        height: delegateColumn.height + 20
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
                                }

                                Text {
                                    text: "💬 " + (model.comments || 0)
                                }

                                Text {
                                    text: "r/" + (model.subreddit || "")
                                }

                                Text {
                                    text: "📤"
                                    font.pixelSize: units.gu(1.5)

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            downloadManager.shareMeme(model.permalink || model.image, model.title);
                                        }
                                    }
                                }

                                Text {
                                    text: "💾"
                                    font.pixelSize: units.gu(1.5)

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            downloadManager.downloadMeme(model.image, model.title);
                                        }
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
                    }

                    Text {
                        text: root.useCustomSubreddit ? 
                              "Try a different subreddit or check the spelling" :
                              "Try selecting a different category or refresh"
                        anchors.horizontalCenter: parent.horizontalCenter
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
                    }

                    Text {
                        text: memeService.lastError
                        font.pixelSize: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
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
                onClicked: /* no-op to prevent propagation so image click doesn't close */{}
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