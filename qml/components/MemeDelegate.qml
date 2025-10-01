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
    height: contentColumn.height + units.gu(2)
    backgroundColor: darkMode ? "#2D2D2D" : "#FFFFFF"

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

    Column {
        id: contentColumn
        width: parent.width - units.gu(2)
        anchors.centerIn: parent
        spacing: units.gu(1)

        // Title
        Label {
            id: titleLabel
            text: memeDelegate.memeTitle
            font.bold: true
            wrapMode: Text.WordWrap
            width: parent.width
            color: memeDelegate.darkMode ? "#FFFFFF" : "#000000"
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        // Image container
        UbuntuShape {
            width: parent.width
            height: memeImage.height
            backgroundColor: memeDelegate.darkMode ? "#1A1A1A" : "#F5F5F5"
            visible: memeDelegate.memeImage !== ""

            Image {
                id: memeImage
                source: memeDelegate.memeImage
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
                asynchronous: true
                cache: true

                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("MemeDelegate: Failed to load image:", memeDelegate.memeImage);
                        visible = false;
                    } else if (status === Image.Ready) {
                        console.log("MemeDelegate: Image loaded successfully");
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        memeDelegate.imageClicked(memeDelegate.memeImage);
                    }
                }
            }
            
            // Subreddit badge for multi-subreddit mode
            UbuntuShape {
                id: subredditBadge
                visible: memeDelegate.isMultiSubredditMode && memeDelegate.subredditSource !== ""
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: units.gu(1)
                width: subredditLabel.width + units.gu(1.5)
                height: units.gu(3)
                backgroundColor: "#FF4500" // Reddit orange
                
                Label {
                    id: subredditLabel
                    text: "r/" + memeDelegate.subredditSource
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: units.gu(1.5)
                    font.bold: true
                }
            }

            // Loading indicator for image
            ActivityIndicator {
                anchors.centerIn: parent
                running: memeImage.status === Image.Loading
                visible: running
            }

            // Error placeholder
            Label {
                anchors.centerIn: parent
                text: "Image failed to load"
                visible: memeImage.status === Image.Error
                color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
            }
        }

        // Metadata row
        Row {
            spacing: units.gu(2)
            width: parent.width
            height: units.gu(4)

            // Upvotes
            Row {
                spacing: units.gu(0.5)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: "👍"
                    anchors.verticalCenter: parent.verticalCenter
                    fontSize: "small"
                }

                Label {
                    text: memeDelegate.memeUpvotes.toString()
                    color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                    fontSize: "small"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Comments
            Row {
                spacing: units.gu(0.5)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: "💬"
                    anchors.verticalCenter: parent.verticalCenter
                    fontSize: "small"
                }

                Label {
                    text: memeDelegate.memeComments.toString()
                    color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                    fontSize: "small"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Subreddit
            Label {
                text: "r/" + memeDelegate.memeSubreddit
                color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"
                fontSize: "small"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Spacer to push actions to the right
            Item {
                width: parent.width - bookmarkIcon.width - shareIcon.width - downloadIcon.width - units.gu(12)
                height: 1
            }

            // Bookmark action
            Icon {
                id: bookmarkIcon
                name: memeDelegate.isBookmarked ? "starred" : "non-starred"
                width: units.gu(2)
                height: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                color: memeDelegate.isBookmarked ? "#FFD700" : (memeDelegate.darkMode ? "#CCCCCC" : "#666666")

                MouseArea {
                    anchors.fill: parent
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

            // Share action
            Icon {
                id: shareIcon
                name: "share"
                width: units.gu(2)
                height: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("MemeDelegate: Sharing meme:", memeDelegate.memeTitle);
                        memeDelegate.shareRequested(memeDelegate.memePermalink || memeDelegate.memeImage, memeDelegate.memeTitle);
                    }
                }
            }

            // Download action
            Icon {
                id: downloadIcon
                name: "save"
                width: units.gu(2)
                height: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                color: memeDelegate.darkMode ? "#CCCCCC" : "#666666"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("MemeDelegate: Downloading meme:", memeDelegate.memeTitle);
                        memeDelegate.downloadRequested(memeDelegate.memeImage, memeDelegate.memeTitle);
                    }
                }
            }
        }

        // Author info (optional, can be hidden)
        Label {
            text: "by u/" + memeDelegate.memeAuthor
            color: memeDelegate.darkMode ? "#888888" : "#999999"
            fontSize: "x-small"
            visible: memeDelegate.memeAuthor !== ""
            width: parent.width
        }
    }
}
