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

import Lomiri.Components 1.3
import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'memesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(40)
    height: units.gu(70)

    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property bool isLoading: false

    // Theme management
    theme.name: root.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"

    Page {
        title: "MemeStream"

        header: PageHeader {
            id: pageHeader
            title: "MemeStream"

            trailingActionBar {
                actions: [
                    Action {
                        iconName: "reload"
                        text: "Refresh"
                        onTriggered: memeFetcher.fetchMemes()
                    },
                    Action {
                        iconName: root.darkMode ? "weather-clear" : "weather-clear-night"
                        text: root.darkMode ? "Light Mode" : "Dark Mode"
                        onTriggered: root.darkMode = !root.darkMode
                    }
                ]
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: units.gu(1)

            // Subreddit selection
            Row {
                width: parent.width
                height: units.gu(5)
                spacing: units.gu(1)

                Label {
                    text: "Subreddit:"
                    anchors.verticalCenter: parent.verticalCenter
                }

                OptionSelector {
                    id: subredditSelector
                    model: ["memes", "dankmemes", "wholesomememes", "funny", "ProgrammerHumor", "meirl"]
                    selectedIndex: 0
                    width: units.gu(20)
                    anchors.verticalCenter: parent.verticalCenter

                    onSelectedIndexChanged: {
                        console.log("OptionSelector changed to index:", selectedIndex, "subreddit:", model[selectedIndex]);
                        root.selectedSubreddit = model[selectedIndex];
                        memeFetcher.fetchMemes();
                    }
                }

                Item {
                    width: units.gu(2)
                    height: 1
                }

                Switch {
                    id: darkSwitch
                    checked: root.darkMode
                    anchors.verticalCenter: parent.verticalCenter
                    onCheckedChanged: {
                        root.darkMode = checked;
                    }
                }

                Label {
                    text: "Dark"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Loading indicator
            ActivityIndicator {
                id: loadingIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                running: root.isLoading
                visible: root.isLoading
            }

            // Meme list
            ListView {
                id: memeList
                width: parent.width
                height: parent.height - units.gu(6)
                model: memeModel
                visible: !root.isLoading

                delegate: UbuntuShape {
                    width: parent.width
                    height: contentColumn.height + units.gu(2)
                    backgroundColor: root.darkMode ? "#2D2D2D" : "#FFFFFF"

                    Column {
                        id: contentColumn
                        width: parent.width - units.gu(2)
                        anchors.centerIn: parent
                        spacing: units.gu(1)

                        Label {
                            id: titleLabel
                            text: model.title
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                            color: root.darkMode ? "#FFFFFF" : "#000000"
                        }

                        UbuntuShape {
                            width: parent.width
                            height: memeImage.height
                            backgroundColor: root.darkMode ? "#1A1A1A" : "#F5F5F5"

                            Image {
                                id: memeImage
                                source: model.image
                                width: parent.width
                                height: {
                                    if (sourceSize.height > 0 && sourceSize.width > 0) {
                                        var ratio = sourceSize.height / sourceSize.width;
                                        return Math.min(width * ratio, units.gu(50));
                                    }
                                    return units.gu(30);
                                }
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        visible = false;
                                    }
                                }
                            }
                        }

                        Row {
                            spacing: units.gu(2)
                            width: parent.width
                            height: units.gu(4)

                            Label {
                                text: "👍 " + (model.upvotes || 0)
                                color: root.darkMode ? "#CCCCCC" : "#666666"
                                fontSize: "small"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: "💬 " + (model.comments || 0)
                                color: root.darkMode ? "#CCCCCC" : "#666666"
                                fontSize: "small"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: "r/" + model.subreddit
                                color: root.darkMode ? "#CCCCCC" : "#666666"
                                fontSize: "small"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                       

                            Button {
                                text: "Download"
                                width: units.gu(12)
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    console.log("Downloading meme:", model.title);
                                    downloadManager.downloadMeme(model.image, model.title);
                                }
                            }
                        }
                    }
                }

                // Pull to refresh
                PullToRefresh {
                    refreshing: root.isLoading
                    onRefresh: memeFetcher.fetchMemes()
                }
            }

            // Empty state
            Column {
                anchors.centerIn: parent
                visible: memeModel.count === 0 && !root.isLoading
                spacing: units.gu(2)

                Label {
                    text: "No memes found"
                    fontSize: "large"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Try Again"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: memeFetcher.fetchMemes()
                }
            }
        }
    }

    QtObject {
        id: memeFetcher

        function fetchMemes() {
            if (root.isLoading) {
                console.log("Already loading, skipping fetch");
                return;
            }
            console.log("Starting to fetch memes for subreddit:", root.selectedSubreddit);
            root.isLoading = true;
            var subreddit = root.selectedSubreddit;
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "https://www.reddit.com/r/" + subreddit + "/hot.json?limit=50", true);
            xhr.setRequestHeader("User-Agent", "UbuntuTouchMemeApp/1.0");

            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    root.isLoading = false;

                    if (xhr.status === 200) {
                        try {
                            var json = JSON.parse(xhr.responseText);
                            var posts = json.data.children;
                            console.log("Received", posts.length, "posts from Reddit");

                            memeModel.clear();

                            for (var i = 0; i < posts.length; i++) {
                                var post = posts[i].data;

                                // Check for images (including imgur, i.redd.it, etc.)
                                if (post.post_hint === "image" || post.url.includes("i.redd.it") || post.url.includes("i.imgur.com") || post.url.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
                                    var memeItem = {
                                        title: post.title,
                                        image: post.url,
                                        upvotes: post.ups,
                                        comments: post.num_comments,
                                        subreddit: post.subreddit
                                    };
                                    memeModel.append(memeItem);
                                }
                            }

                            console.log("Added", memeModel.count, "image posts to model");
                        } catch (e) {
                            console.log("Error parsing JSON:", e);
                        }
                    } else {
                        console.log("Network error:", xhr.status);
                    }
                }
            };

            xhr.send();
        }
    }

    QtObject {
        id: downloadManager

        function downloadMeme(imageUrl, title) {
            console.log("Starting download for:", imageUrl);

            // For Ubuntu Touch, we'll use a simpler approach
            // Save the image URL to clipboard or try to open with external app
            try {
                // Try to copy the image URL to clipboard as a fallback
                Qt.openUrlExternally(imageUrl);
                console.log("Opened image URL externally:", imageUrl);
            } catch (e) {
                console.log("Failed to open URL externally:", e);
            }
        }
    }

    ListModel {
        id: memeModel
    }

    // Settings persistence
    Settings {
        id: settings
        property alias darkMode: root.darkMode
        property alias selectedSubreddit: root.selectedSubreddit
    }

    Component.onCompleted: {
        console.log("App starting up with selectedSubreddit:", root.selectedSubreddit);

        // Sync subreddit selector with loaded settings
        var subreddits = ["memes", "dankmemes", "wholesomememes", "funny", "ProgrammerHumor", "meirl"];
        var initialIndex = subreddits.indexOf(root.selectedSubreddit);
        console.log("Found initial index:", initialIndex, "for subreddit:", root.selectedSubreddit);

        if (initialIndex !== -1) {
            subredditSelector.selectedIndex = initialIndex;
            console.log("Set OptionSelector to index:", initialIndex);
        }

        memeFetcher.fetchMemes();
    }
}
