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

    // Theme management (simplified)
    property color backgroundColor: root.darkMode ? "#1A1A1A" : "#FFFFFF"
    property color textColor: root.darkMode ? "#FFFFFF" : "#000000"

    color: backgroundColor

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

            header: ToolBar {
                RowLayout {
                    anchors.fill: parent

                    Label {
                        text: "MemeStream"
                        font.bold: true
                        font.pixelSize: 18
                        color: root.textColor
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "⟳"
                        onClicked: {
                            console.log("Main: Refresh action triggered");
                            memeService.refreshMemes();
                        }
                    }

                    ToolButton {
                        text: "⚙"
                        onClicked: {
                            console.log("Main: Settings action triggered");
                            openSettingsPage();
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

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
                    color: root.textColor
                    visible: !memeService.isLoading && !memeService.isModelEmpty()
                    Layout.alignment: Qt.AlignHCenter
                }

                // Category Selector
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    visible: !memeService.isLoading

                    Text {
                        text: "Category:"
                        color: root.textColor
                        font.bold: true
                    }

                    ComboBox {
                        id: categoryCombo
                        model: root.categoryNames
                        Layout.preferredWidth: 200

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
                            if (currentText && root.categoryMap[currentText]) {
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

                // Meme list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: memeModel
                    visible: !memeService.isLoading
                    spacing: 10

                    delegate: Rectangle {
                        width: ListView.view ? ListView.view.width : 300
                        height: delegateColumn.height + 20
                        color: root.darkMode ? "#2D2D2D" : "#FFFFFF"
                        border.color: root.darkMode ? "#444444" : "#CCCCCC"
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
                                color: root.textColor
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
                            }

                            Row {
                                spacing: 20

                                Text {
                                    text: "👍 " + (model.upvotes || 0)
                                    font.pixelSize: 12
                                    color: root.textColor
                                }

                                Text {
                                    text: "💬 " + (model.comments || 0)
                                    font.pixelSize: 12
                                    color: root.textColor
                                }

                                Text {
                                    text: "r/" + (model.subreddit || "")
                                    font.pixelSize: 12
                                    color: root.textColor
                                }

                                Text {
                                    text: "📤"
                                    font.pixelSize: 12
                                    color: root.textColor

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            downloadManager.shareMeme(model.permalink || model.image, model.title);
                                        }
                                    }
                                }

                                Text {
                                    text: "💾"
                                    font.pixelSize: 12
                                    color: root.textColor

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
                    spacing: 10

                    Text {
                        text: "No memes found"
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.textColor
                    }

                    Text {
                        text: "Try selecting a different category or refresh"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.textColor
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
                    spacing: 10

                    Text {
                        text: "Error loading memes"
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "red"
                    }

                    Text {
                        text: memeService.lastError
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.textColor
                        wrapMode: Text.WordWrap
                        width: 300
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
    }

    // Private functions
    function openSettingsPage() {
        console.log("Main: Opening settings page");
        // For now, just toggle dark mode as a simple settings action
        root.darkMode = !root.darkMode;
        console.log("Main: Dark mode toggled to:", root.darkMode);
    }

    // Signal handlers
    function handleDarkModeChanged(darkMode) {
        console.log("Main: Dark mode changed to:", darkMode);
        root.darkMode = darkMode;
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

        // Delay initial fetch to ensure service is ready
        Qt.callLater(function () {
            memeService.fetchMemes(root.selectedSubreddit);
        });
    }
}
