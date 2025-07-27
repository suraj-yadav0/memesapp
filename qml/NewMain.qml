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
import "components"
import "models"
import "services"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'memesapp.surajyadav'
    automaticOrientation: true

    height: units.gu(70)
    width: units.gu(60)

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
            "Anime Memes": "AnimeMemes",
            "Meme Economy": "memeeconomy",
            "Surreal Memes": "surrealmemes",
            "Deep Fried": "DeepFriedMemes",
            "OK Buddy Retard": "okbuddyretard",
            "Teenagers": "teenagers",
            "Me_IRL": "me_irl",
            "Comedy Cemetery": "ComedyCemetery",
            "Comedy Heaven": "comedyheaven",
            "Bone Hurting Juice": "bonehurtingjuice",
            "Anti Meme": "antimeme",
            "Crappy Design": "CrappyDesign",
            "Software Gore": "softwaregore",
            "Tech Support Gore": "techsupportgore",
            "Mad Lads": "madlads",
            "Cursed Images": "cursedimages",
            "Blursed Images": "blursedimages",
            "Hmmm": "hmmm",
            "Cats Standing Up": "CatsStandingUp"
        })

    // Array of category names for the OptionSelector
    property var categoryNames: ["General Memes", "Dank Memes", "Wholesome Memes", "Funny", "Programming Humor", "Me IRL", "Star Wars Memes", "History Memes", "Gaming Memes", "Anime Memes", "Meme Economy", "Surreal Memes", "Deep Fried", "OK Buddy Retard", "Teenagers", "Me_IRL", "Comedy Cemetery", "Comedy Heaven", "Bone Hurting Juice", "Anti Meme", "Crappy Design", "Software Gore", "Tech Support Gore", "Mad Lads", "Cursed Images", "Blursed Images", "Hmmm", "Cats Standing Up"]

    // Theme management
    theme.name: root.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"

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
            // You could show a notification or error dialog here
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

    PageStack {
        id: pageStack

        Page {
            id: mainPage
            title: "MemeStream"

            header: PageHeader {
                id: pageHeader
                title: "MemeStream"
                subtitle: "Your daily dose of memes"

                trailingActionBar {
                    actions: [
                        Action {
                            iconName: "reload"
                            text: "Refresh"
                            onTriggered: {
                                console.log("Main: Refresh action triggered");
                                memeService.refreshMemes();
                            }
                        },
                        Action {
                            iconName: "settings"
                            text: "Settings"
                            onTriggered: {
                                console.log("Main: Settings action triggered");
                                openSettingsPage();
                            }
                        }
                    ]
                }
            }

            ColumnLayout {
                id: mainColumn
                anchors.top: pageHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: units.gu(1)
                spacing: units.gu(1)

                // Loading indicator
                ActivityIndicator {
                    id: loadingIndicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: memeService.isLoading
                    visible: memeService.isLoading
                    Layout.preferredHeight: units.gu(5)
                }

                // Current subreddit info
                Label {
                    text: "r/" + root.selectedSubreddit
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.darkMode ? "#FFFFFF" : "#000000"
                    visible: !memeService.isLoading && !memeService.isModelEmpty()
                }

                // Meme list
                ListView {
                    id: memeList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: memeModel
                    visible: !memeService.isLoading
                    spacing: units.gu(1)

                    delegate: MemeDelegate {
                        width: memeList.width
                        darkMode: root.darkMode

                        onShareRequested: {
                            downloadManager.shareMeme(url, title);
                        }

                        onDownloadRequested: {
                            downloadManager.downloadMeme(url, title);
                        }

                        onImageClicked: {
                            console.log("Main: Image clicked:", url);
                            // Could open in full screen view
                        }
                    }

                    // Scroll to top button
                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                // Empty state
                Column {
                    Layout.alignment: Qt.AlignCenter
                    visible: memeService.isModelEmpty() && !memeService.isLoading
                    spacing: units.gu(2)

                    Label {
                        text: "No memes found"
                        fontSize: "large"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.darkMode ? "#FFFFFF" : "#000000"
                    }

                    Label {
                        text: "Try selecting a different category or refresh"
                        fontSize: "medium"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.darkMode ? "#CCCCCC" : "#666666"
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
                    spacing: units.gu(2)

                    Label {
                        text: "Error loading memes"
                        fontSize: "large"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.darkMode ? "#FF6B6B" : "#D32F2F"
                    }

                    Label {
                        text: memeService.lastError
                        fontSize: "medium"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.darkMode ? "#CCCCCC" : "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
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
        var settingsPage = Qt.createComponent("SettingsPage.qml");

        if (settingsPage.status === Component.Ready) {
            console.log("Main: Settings component ready, creating page");
            var page = settingsPage.createObject(root, {
                darkMode: root.darkMode,
                selectedSubreddit: root.selectedSubreddit,
                categoryNames: root.categoryNames,
                categoryMap: root.categoryMap,
                memeService: memeService
            });

            if (page) {
                console.log("Main: Settings page created, connecting signals");
                page.darkModeChanged.connect(handleDarkModeChanged);
                page.selectedSubredditChanged.connect(handleSelectedSubredditChanged);
                pageStack.push(page);
            } else {
                console.log("Main: Failed to create settings page object");
            }
        } else if (settingsPage.status === Component.Loading) {
            console.log("Main: Settings component loading...");
            settingsPage.statusChanged.connect(function () {
                if (settingsPage.status === Component.Ready) {
                    openSettingsPage(); // Retry
                } else if (settingsPage.status === Component.Error) {
                    console.log("Main: Settings component error:", settingsPage.errorString());
                }
            });
        } else if (settingsPage.status === Component.Error) {
            console.log("Main: Settings component error:", settingsPage.errorString());
        }
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

        // Initial fetch
        memeService.fetchMemes(root.selectedSubreddit);
    }
}
