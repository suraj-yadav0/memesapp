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
import QtQuick.LocalStorage 2.0
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

                            Label {
                                text: "👍 " + (model.upvotes || 0)
                                color: root.darkMode ? "#CCCCCC" : "#666666"
                                fontSize: "small"
                            }

                            Label {
                                text: "💬 " + (model.comments || 0)
                                color: root.darkMode ? "#CCCCCC" : "#666666"
                                fontSize: "small"
                            }

                            Label {
                                text: "r/" + model.subreddit
                                color: root.darkMode ? "#CCCCCC" : "#666666"
                                fontSize: "small"
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
                            var cacheArray = [];

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
                                    cacheArray.push(memeItem);
                                }
                            }

                            console.log("Added", cacheArray.length, "image posts to model");
                            // Cache the results
                            LocalStorage.setValue("cachedMemes_" + subreddit, JSON.stringify(cacheArray));
                            LocalStorage.setValue("lastFetch_" + subreddit, Date.now().toString());
                        } catch (e) {
                            console.log("Error parsing JSON:", e);
                            memeFetcher.loadFromCache();
                        }
                    } else {
                        console.log("Network error:", xhr.status);
                        memeFetcher.loadFromCache();
                    }
                }
            };

            xhr.send();
        }

        function loadFromCache() {
            var cached = LocalStorage.value("cachedMemes_" + root.selectedSubreddit, "");
            console.log("Attempting to load cache for subreddit:", root.selectedSubreddit);
            if (cached !== "") {
                try {
                    var memes = JSON.parse(cached);
                    console.log("Found", memes.length, "cached memes");
                    memeModel.clear();
                    for (var i = 0; i < memes.length; i++) {
                        memeModel.append(memes[i]);
                    }
                } catch (e) {
                    console.log("Error loading cache:", e);
                }
            } else {
                console.log("No cached data found for subreddit:", root.selectedSubreddit);
            }
        }

        function isCacheValid() {
            var lastFetch = LocalStorage.value("lastFetch_" + root.selectedSubreddit, "0");
            var now = Date.now();
            var cacheAge = now - parseInt(lastFetch);
            return cacheAge < 300000; // 5 minutes
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

        // Load cached data first for instant display
        memeFetcher.loadFromCache();

        // Use a timer to check if we need to fetch after cache loading
        Qt.callLater(function () {
            if (!memeFetcher.isCacheValid() || memeModel.count === 0) {
                console.log("No valid cache found, fetching fresh memes...");
                memeFetcher.fetchMemes();
            } else {
                console.log("Loaded", memeModel.count, "memes from cache");
            }
        });
    }
}
