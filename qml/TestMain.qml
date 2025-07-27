/*
 * Copyright (C) 2025  Suraj Yadav
 * Simple test version with standard Qt components
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: root
    visible: true
    width: 400
    height: 600
    title: "MemeStream - Test"

    // Application properties
    property bool darkMode: false
    property string selectedSubreddit: "memes"

    // Simple test model
    ListModel {
        id: memeModel

        function addMeme(meme) {
            append(meme);
        }

        function clearModel() {
            clear();
        }
    }

    // Simple API object
    QtObject {
        id: memeAPI

        signal memesLoaded(var memes)
        signal loadingStarted
        signal loadingFinished
        signal error(string message)

        property bool isLoading: false

        function fetchMemes(subreddit) {
            if (isLoading)
                return;

            console.log("API: Fetching memes for", subreddit);
            isLoading = true;
            loadingStarted();

            var xhr = new XMLHttpRequest();
            xhr.open("GET", "https://www.reddit.com/r/" + subreddit + "/hot.json?limit=5", true);
            xhr.setRequestHeader("User-Agent", "UbuntuTouchMemeApp/1.0");

            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    isLoading = false;
                    loadingFinished();

                    if (xhr.status === 200) {
                        try {
                            var json = JSON.parse(xhr.responseText);
                            var posts = json.data.children;
                            var memes = [];

                            for (var i = 0; i < posts.length; i++) {
                                var post = posts[i].data;
                                if (post.post_hint === "image" || post.url.includes("i.redd.it")) {
                                    memes.push({
                                        id: post.id,
                                        title: post.title,
                                        image: post.url,
                                        upvotes: post.ups || 0,
                                        comments: post.num_comments || 0,
                                        subreddit: post.subreddit
                                    });
                                }
                            }

                            memesLoaded(memes);
                        } catch (e) {
                            error("Parse error: " + e);
                        }
                    } else {
                        error("Network error: " + xhr.status);
                    }
                }
            };

            xhr.send();
        }
    }

    // Service layer
    QtObject {
        id: memeService

        property bool isLoading: memeAPI.isLoading
        property string lastError: ""

        signal memesRefreshed(int count)

        Component.onCompleted: {
            memeAPI.memesLoaded.connect(function (memes) {
                console.log("Service: Received", memes.length, "memes");
                memeModel.clearModel();
                for (var i = 0; i < memes.length; i++) {
                    memeModel.addMeme(memes[i]);
                }
                memesRefreshed(memes.length);
            });

            memeAPI.error.connect(function (message) {
                lastError = message;
                console.log("Service: Error -", message);
            });
        }

        function fetchMemes(subreddit) {
            memeAPI.fetchMemes(subreddit || "memes");
        }

        function refreshMemes() {
            fetchMemes(root.selectedSubreddit);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        // Header
        Text {
            text: "MemeStream - Test Version"
            font.bold: true
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
        }

        // Controls
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            ComboBox {
                id: subredditSelector
                model: ["memes", "dankmemes", "funny", "ProgrammerHumor"]
                currentIndex: 0
                onCurrentTextChanged: {
                    root.selectedSubreddit = currentText;
                    console.log("Selected subreddit changed to:", currentText);
                }
            }

            Button {
                text: "Fetch"
                enabled: !memeService.isLoading
                onClicked: {
                    console.log("Fetch button clicked for:", root.selectedSubreddit);
                    memeService.fetchMemes(root.selectedSubreddit);
                }
            }
        }

        // Loading indicator
        BusyIndicator {
            visible: memeService.isLoading
            running: memeService.isLoading
            Layout.alignment: Qt.AlignHCenter
        }

        // Status
        Text {
            text: "r/" + root.selectedSubreddit + " | Memes: " + memeModel.count
            Layout.alignment: Qt.AlignHCenter
            visible: !memeService.isLoading
        }

        // Error display
        Text {
            text: "Error: " + memeService.lastError
            color: "red"
            visible: memeService.lastError !== ""
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Meme list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: memeModel
            spacing: 10

            delegate: Rectangle {
                width: parent.width
                height: column.height + 20
                border.color: "#ccc"
                border.width: 1

                Column {
                    id: column
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 5

                    Text {
                        text: model.title
                        font.bold: true
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Image {
                        source: model.image
                        width: Math.min(parent.width, 300)
                        height: Math.min(width * 0.8, 200)
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("Failed to load image:", model.image);
                            }
                        }
                    }

                    Row {
                        spacing: 20

                        Text {
                            text: "👍 " + model.upvotes
                            font.pixelSize: 12
                        }

                        Text {
                            text: "💬 " + model.comments
                            font.pixelSize: 12
                        }

                        Text {
                            text: "r/" + model.subreddit
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            text: "No memes loaded. Click 'Fetch' to load memes."
            visible: memeModel.count === 0 && !memeService.isLoading
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component.onCompleted: {
        console.log("Test app started");
        console.log("Architecture test - Model-View-Service pattern");
        console.log("API Layer: Separate API calls");
        console.log("Model Layer: Data management");
        console.log("Service Layer: Business logic coordination");
        console.log("View Layer: UI components");

        // Auto-fetch on startup
        memeService.fetchMemes("memes");
    }
}
