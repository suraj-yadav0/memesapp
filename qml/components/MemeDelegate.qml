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

UbuntuShape {
    id: memeDelegate

    width: parent.width
    height: parent.height
    backgroundColor: memeDelegate.darkMode ? "#000000" : "#FFFFFF"

    // Properties
    property bool darkMode: false
    property string memeTitle: model.title || "Untitled"
    property string memeImage: model.image || ""
    property int memeUpvotes: model.upvotes || 0
    property int memeComments: model.comments || 0
    property string memeSubreddit: model.subreddit || ""
    property string memeAuthor: model.author || ""
    property string memePermalink: model.permalink || ""
    property string memeId: model.id || ""
    
    // Multi-subreddit properties
    property bool isMultiSubredditMode: false
    property string subredditSource: ""
    
    // Bookmark properties
    property bool isBookmarked: false

    // Signals
    signal shareRequested(string url, string title)
    signal downloadRequested(string url, string title)
    signal imageClicked(string url)
    signal bookmarkToggled(var meme, bool bookmark)

    // Main container
    Item {
        anchors.fill: parent

        // Top info bar (like Reddit's header)
        Rectangle {
            id: topBar
            anchors.top: parent.top
            width: parent.width
            height: units.gu(6)
            border.color: memeDelegate.darkMode ? "#333333" : "#DDDDDD"
            color: memeDelegate.darkMode ? "#1A1A1A" : "#FFFFFF"
            z: 10

            Row {
                anchors.fill: parent
                anchors.leftMargin: units.gu(1.5)
                anchors.rightMargin: units.gu(1.5)
                spacing: units.gu(1)

                // Subreddit info
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: units.gu(0.3)
                    width: parent.width - bookmarkIcon.width - units.gu(3)

                    Label {
                        text: "r/" + (memeDelegate.isMultiSubredditMode && memeDelegate.subredditSource !== "" ? 
                              memeDelegate.subredditSource : memeDelegate.memeSubreddit)
                        font.bold: true
                        fontSize: "medium"
                        color: memeDelegate.darkMode ? "#FFFFFF" : "#000000"
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Label {
                        text: "u/" + memeDelegate.memeAuthor
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#888888" : "#999999"
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }

                // Bookmark icon
                Icon {
                    id: bookmarkIcon
                    name: memeDelegate.isBookmarked ? "starred" : "non-starred"
                    width: units.gu(3)
                    height: units.gu(3)
                    anchors.verticalCenter: parent.verticalCenter
                    color: memeDelegate.isBookmarked ? "#FFD700" : (memeDelegate.darkMode ? "#CCCCCC" : "#666666")

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -units.gu(1)
                        onClicked: {
                            console.log("MemeDelegate: Toggling bookmark for meme:", memeDelegate.memeTitle);
                            var memeData = {
                                id: memeDelegate.memeId,
                                title: memeDelegate.memeTitle,
                                image: memeDelegate.memeImage,
                                subreddit: memeDelegate.memeSubreddit,
                                author: memeDelegate.memeAuthor,
                                permalink: memeDelegate.memePermalink,
                                upvotes: memeDelegate.memeUpvotes,
                                comments: memeDelegate.memeComments
                            };
                            memeDelegate.bookmarkToggled(memeData, !memeDelegate.isBookmarked);
                        }
                    }
                }
            }
        }

        // Title section
        Rectangle {
            id: titleSection
            anchors.top: topBar.bottom
            width: parent.width
            height:  units.gu(8)
             border.color: memeDelegate.darkMode ? "#333333" : "#DDDDDD" // This title card is not working
            color: memeDelegate.darkMode ? "#333333" : "#E0E0E0"
            z: 9

            Label {
                id: titleLabel
                anchors.fill: parent
                anchors.leftMargin: units.gu(1.5)
                anchors.rightMargin: units.gu(1.5)
                anchors.topMargin: units.gu(1)
                anchors.bottomMargin: units.gu(1)
                text: memeDelegate.memeTitle
                font.bold: true
                fontSize: units.gu(1.5)
              //  wrapMode: Text.WordWrap
                color: memeDelegate.darkMode ? '#d11111' : '#470404'
                maximumLineCount: 3
               
            }
        }

        // Image container - takes up all available space (Reddit style)
        Rectangle {
            id: imageContainer
            anchors.top: titleSection.bottom
            anchors.bottom: bottomBar.top
            anchors.left: parent.left
            anchors.right: parent.right
             border.color: memeDelegate.darkMode ? "#333333" : "#DDDDDD"
           color: memeDelegate.darkMode ? "#000000" : "#FFFFFF"
            clip: true

            Image {
                id: memeImage
                anchors.fill: parent
                source: memeDelegate.memeImage
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
                visible: status === Image.Ready

                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("MemeDelegate: Failed to load image:", memeDelegate.memeImage);
                    } else if (status === Image.Ready) {
                        console.log("MemeDelegate: Image loaded successfully");
                    }
                }

                // Double tap to zoom (Reddit-like interaction)
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        memeDelegate.imageClicked(memeDelegate.memeImage);
                    }
                    onDoubleClicked: {
                        if (memeImage.fillMode === Image.PreserveAspectFit) {
                            memeImage.fillMode = Image.PreserveAspectCrop;
                        } else {
                            memeImage.fillMode = Image.PreserveAspectFit;
                        }
                    }
                }
            }

            // Loading indicator
            ActivityIndicator {
                anchors.centerIn: parent
                running: memeImage.status === Image.Loading
                visible: running
            }

            // Error placeholder
            Rectangle {
                anchors.fill: parent
                color: memeDelegate.darkMode ? "#1A1A1A" : "#F5F5F5"
                visible: memeImage.status === Image.Error

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    Icon {
                        name: "image-x-generic-symbolic"
                        width: units.gu(6)
                        height: units.gu(6)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: memeDelegate.darkMode ? "#666666" : "#999999"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Image failed to load"
                        color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                        fontSize: "small"
                    }
                }
            }

            // Subreddit badge overlay (for multi-subreddit mode)
            UbuntuShape {
                id: subredditBadge
                visible: memeDelegate.isMultiSubredditMode && memeDelegate.subredditSource !== ""
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: units.gu(1.5)
                width: subredditLabel.width + units.gu(2)
                height: units.gu(3.5)
                backgroundColor: "#FF4500"
                opacity: 0.95

                Label {
                    id: subredditLabel
                    text: "r/" + memeDelegate.subredditSource
                    anchors.centerIn: parent
                    color: "white"
                    fontSize: "small"
                    font.bold: true
                }
            }
        }

        // Bottom action bar (Reddit style)
        Rectangle {
            id: bottomBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: units.gu(6)
            border.color: memeDelegate.darkMode ? "#333333" : "#DDDDDD"
            color: memeDelegate.darkMode ? "#1A1A1A" : "#FFFFFF"
            z: 10

            Row {
                anchors.fill: parent
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                spacing: units.gu(2)

                // Upvotes button
                Rectangle {
                    width: parent.width / 4
                    height: parent.height
                    color: "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(0.8)

                        Icon {
                            name: "like"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
                            anchors.verticalCenter: parent.verticalCenter
                            color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                        }

                        Label {
                            text: memeDelegate.memeUpvotes > 999 ? 
                                  (memeDelegate.memeUpvotes / 1000).toFixed(1) + "k" : 
                                  memeDelegate.memeUpvotes.toString()
                            color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                            fontSize: "medium"
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Comments button
                Rectangle {
                    width: parent.width / 4
                    height: parent.height
                    color: "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(1)

                        Icon {
                            name: "message"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
                            anchors.verticalCenter: parent.verticalCenter
                            color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                        }

                        Label {
                            text: memeDelegate.memeComments > 999 ? 
                                  (memeDelegate.memeComments / 1000).toFixed(1) + "k" : 
                                  memeDelegate.memeComments.toString()
                            color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                            fontSize: "medium"
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Share button
                // Rectangle {
                //     width: parent.width / 4
                //     height: parent.height
                //     color: "transparent"

                //     Icon {
                //         name: "share"
                //         width: units.gu(2.5)
                //         height: units.gu(2.5)
                //         anchors.centerIn: parent
                //         color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                //     }

                //     MouseArea {
                //         anchors.fill: parent
                //         onClicked: {
                //             console.log("MemeDelegate: Sharing meme:", memeDelegate.memeTitle);
                //             memeDelegate.shareRequested(
                //                 "https://reddit.com" + memeDelegate.memePermalink, 
                //                 memeDelegate.memeTitle
                //             );
                //         }
                //     }
                // }

                // Download button
                // Rectangle {
                //     width: parent.width / 4
                //     height: parent.height
                //     color: "transparent"

                //     Icon {
                //         name: "save"
                //         width: units.gu(2.5)
                //         height: units.gu(2.5)
                //         anchors.centerIn: parent
                //         color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                //     }

                //     MouseArea {
                //         anchors.fill: parent
                //         onClicked: {
                //             console.log("MemeDelegate: Downloading meme:", memeDelegate.memeTitle);
                //             memeDelegate.downloadRequested(memeDelegate.memeImage, memeDelegate.memeTitle);
                //         }
                //     }
                // }
            }
        }
    }
}