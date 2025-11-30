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

Item {
    id: memeDelegate

    // Adaptive height based on content type
    width: parent ? parent.width : 0
    height: contentColumn.height + units.gu(1.5) // Dynamic height based on actual content

    // Properties
    property bool darkMode: false
    property string memeTitle: model.title || "Untitled"
    property string memeImage: model.image || ""
    property string postType: model.postType || "image"
    property string selftext: model.selftext || ""
    property int memeUpvotes: model.upvotes || 0
    property int memeComments: model.comments || 0
    property string memeSubreddit: model.subreddit || ""
    property string memeAuthor: model.author || ""
    property string memePermalink: model.permalink || ""
    property string memeId: model.id || ""
    property string timestamp: "6h ago"
    
    // Multi-subreddit properties
    property bool isMultiSubredditMode: false
    property string subredditSource: ""
    
    // Bookmark properties
    property bool isBookmarked: false
    
    // Text preview settings
    property int collapsedTextLines: 5
    property int maxCollapsedHeight: units.gu(15)

    // Signals
    signal shareRequested(string url, string title)
    signal downloadRequested(string url, string title)
    signal imageClicked(string url)
    signal commentClicked(string id, string subreddit)
    signal bookmarkToggled(var meme, bool bookmark)
    signal backRequested()

    // Main card container
    UbuntuShape {
        id: cardBackground
        anchors.fill: parent
        anchors.margins: units.gu(0.5)
        backgroundColor: memeDelegate.darkMode ? "#1A1A1B" : "#FFFFFF"
        radius: "medium"

        // Subtle shadow/border effect
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: memeDelegate.darkMode ? "#343536" : "#EDEFF1"
            border.width: 1
            radius: units.gu(1)
        }

        Column {
            id: contentColumn
            width: parent.width - units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            // Post metadata (subreddit, author, timestamp)
            Item {
                width: parent.width
                height: units.gu(4.5)

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1.5)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: units.gu(0.8)

                    // Subreddit icon
                    Rectangle {
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        radius: width / 2
                        color: "#FF4500"
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            anchors.centerIn: parent
                            text: "r"
                            color: "white"
                            fontSize: "x-small"
                            font.bold: true
                        }
                    }

                    // Subreddit name
                    Label {
                        text: "r/" + (memeDelegate.isMultiSubredditMode && memeDelegate.subredditSource !== "" ? 
                              memeDelegate.subredditSource : memeDelegate.memeSubreddit)
                        font.bold: true
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#D7DADC" : "#1C1C1C"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Label {
                        text: "•"
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#818384" : "#787C7E"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: "u/" + memeDelegate.memeAuthor
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#818384" : "#787C7E"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: "•"
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#818384" : "#787C7E"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: memeDelegate.timestamp
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#818384" : "#787C7E"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // More options button (right side)
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1)
                    anchors.verticalCenter: parent.verticalCenter
                    width: units.gu(4)
                    height: units.gu(4)
                    color: "transparent"
                    radius: width / 2

                    Icon {
                        name: "contextual-menu"
                        width: units.gu(2)
                        height: units.gu(2)
                        anchors.centerIn: parent
                        color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = memeDelegate.darkMode ? "#333333" : "#F0F0F0"
                        onExited: parent.color = "transparent"
                    }
                }
            }

            // Post title
            Item {
                width: parent.width
                height: titleLabel.height + units.gu(1)

                Label {
                    id: titleLabel
                    width: parent.width - units.gu(3)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1.5)
                    anchors.top: parent.top
                    text: memeDelegate.memeTitle
                    font.bold: true
                    font.pixelSize: units.gu(2)
                    wrapMode: Text.WordWrap
                    color: memeDelegate.darkMode ? "#D7DADC" : "#1A1A1B"
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        memeDelegate.commentClicked(memeDelegate.memeId, memeDelegate.memeSubreddit);
                    }
                }
            }

            // Text content for text posts (with Read More)
            Item {
                width: parent.width
                height: {
                    if (memeDelegate.postType === "text" && memeDelegate.selftext !== "") {
                        var needsExpansion = fullTextLabel.contentHeight > maxCollapsedHeight;
                        return Math.min(collapsedTextLabel.contentHeight, maxCollapsedHeight) + (needsExpansion ? units.gu(5) : units.gu(2));
                    }
                    return 0;
                }
                visible: memeDelegate.postType === "text" && memeDelegate.selftext !== ""
                clip: true

                // Background for text post
                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
                    color: memeDelegate.darkMode ? "#272729" : "#F6F7F8"
                    radius: units.gu(0.8)
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Open comments/post detail page to read full text
                            memeDelegate.commentClicked(memeDelegate.memeId, memeDelegate.memeSubreddit);
                        }
                    }
                }

                // Hidden label to measure full text height
                Label {
                    id: fullTextLabel
                    width: parent.width - units.gu(4)
                    text: memeDelegate.selftext
                    fontSize: "medium"
                    color: "transparent"
                    wrapMode: Text.Wrap
                    visible: false
                }

                // Collapsed text view (always shows preview)
                Label {
                    id: collapsedTextLabel
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    text: memeDelegate.selftext
                    fontSize: "medium"
                    color: memeDelegate.darkMode ? "#D7DADC" : "#1A1A1B"
                    wrapMode: Text.Wrap
                    maximumLineCount: memeDelegate.collapsedTextLines
                    elide: Text.ElideRight
                    lineHeight: 1.3
                }

                // Gradient fade for collapsed text
                Rectangle {
                    anchors.bottom: readMoreButton.visible ? readMoreButton.top : parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
                    height: units.gu(3)
                    visible: fullTextLabel.contentHeight > maxCollapsedHeight
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: memeDelegate.darkMode ? "#272729" : "#F6F7F8" }
                    }
                }

                // Read More button - opens comments page
                Rectangle {
                    id: readMoreButton
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: readMoreLabel.width + units.gu(3)
                    height: units.gu(3.5)
                    color: memeDelegate.darkMode ? "#333333" : "#EDEFF1"
                    radius: units.gu(1.5)
                    visible: fullTextLabel.contentHeight > maxCollapsedHeight

                    Label {
                        id: readMoreLabel
                        anchors.centerIn: parent
                        text: "Read More"
                        fontSize: "small"
                        font.bold: true
                        color: "#0079D3"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Open comments/post detail page to read full text
                            memeDelegate.commentClicked(memeDelegate.memeId, memeDelegate.memeSubreddit);
                        }
                        hoverEnabled: true
                        onEntered: parent.color = memeDelegate.darkMode ? "#444444" : "#E0E0E0"
                        onExited: parent.color = memeDelegate.darkMode ? "#333333" : "#EDEFF1"
                    }
                }
            }

            // Image container - Adaptive sizing
            Item {
                id: imageContainer
                width: parent.width
                height: {
                    if (memeDelegate.postType !== "image" || memeDelegate.memeImage === "") {
                        return 0;
                    }
                    if (memeImageLoader.status === Image.Ready) {
                        var aspectRatio = memeImageLoader.sourceSize.width / Math.max(memeImageLoader.sourceSize.height, 1);
                        var calculatedHeight = (width / Math.max(aspectRatio, 0.3));
                        // Clamp: min 15gu for very wide images, max 60gu for very tall images
                        return Math.max(units.gu(15), Math.min(calculatedHeight, units.gu(60)));
                    }
                    return units.gu(25); // Default placeholder height
                }
                visible: memeDelegate.postType === "image" && memeDelegate.memeImage !== ""
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: memeDelegate.darkMode ? "#0D0D0D" : "#F8F9FA"
                }

                Image {
                    id: memeImageLoader
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: memeDelegate.memeImage
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    visible: status === Image.Ready

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            memeDelegate.imageClicked(memeDelegate.memeImage);
                        }
                    }
                }

                // Loading indicator with shimmer effect
                Rectangle {
                    anchors.fill: parent
                    color: memeDelegate.darkMode ? "#1A1A1A" : "#F0F0F0"
                    visible: memeImageLoader.status === Image.Loading

                    ActivityIndicator {
                        anchors.centerIn: parent
                        running: memeImageLoader.status === Image.Loading
                    }

                    Label {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: units.gu(4)
                        text: "Loading..."
                        fontSize: "small"
                        color: memeDelegate.darkMode ? "#666666" : "#999999"
                    }
                }

                // Error placeholder
                Rectangle {
                    anchors.fill: parent
                    color: memeDelegate.darkMode ? "#1A1A1A" : "#F5F5F5"
                    visible: memeImageLoader.status === Image.Error

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(1)

                        Icon {
                            name: "image-x-generic-symbolic"
                            width: units.gu(5)
                            height: units.gu(5)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: memeDelegate.darkMode ? "#666666" : "#999999"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Failed to load image"
                            color: memeDelegate.darkMode ? "#818384" : "#787C7E"
                            fontSize: "small"
                        }

                        // Retry button
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: retryLabel.width + units.gu(2)
                            height: units.gu(3)
                            color: "#0079D3"
                            radius: units.gu(1)

                            Label {
                                id: retryLabel
                                anchors.centerIn: parent
                                text: "Retry"
                                color: "white"
                                fontSize: "small"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    memeImageLoader.source = "";
                                    memeImageLoader.source = memeDelegate.memeImage;
                                }
                            }
                        }
                    }
                }

                // NSFW/Spoiler overlay (if needed)
                // Rectangle {
                //     anchors.fill: parent
                //     color: memeDelegate.darkMode ? "#1A1A1A" : "#F0F0F0"
                //     visible: false // Set based on NSFW/spoiler flags
                // }
            }

            // Spacer before bottom bar
            Item {
                width: parent.width
                height: units.gu(0.5)
            }

            // Bottom engagement bar - Reddit style
            Item {
                id: bottomBar
                width: parent.width
                height: units.gu(5)

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: units.gu(0.5)

                    // Upvote button
                    Rectangle {
                        width: units.gu(4)
                        height: units.gu(4)
                        color: "transparent"
                        radius: units.gu(0.5)

                        Icon {
                            name: "go-up"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
                            anchors.centerIn: parent
                            color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = memeDelegate.darkMode ? "#333333" : "#F0F0F0"
                            onExited: parent.color = "transparent"
                        }
                    }

                    // Vote count
                    Label {
                        text: {
                            if (memeDelegate.memeUpvotes >= 1000000) {
                                return (memeDelegate.memeUpvotes / 1000000).toFixed(1) + "M";
                            } else if (memeDelegate.memeUpvotes >= 1000) {
                                return (memeDelegate.memeUpvotes / 1000).toFixed(1) + "k";
                            }
                            return memeDelegate.memeUpvotes.toString();
                        }
                        color: memeDelegate.darkMode ? "#D7DADC" : "#1A1A1B"
                        fontSize: "small"
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Downvote button
                    Rectangle {
                        width: units.gu(4)
                        height: units.gu(4)
                        color: "transparent"
                        radius: units.gu(0.5)

                        Icon {
                            name: "go-down"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
                            anchors.centerIn: parent
                            color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = memeDelegate.darkMode ? "#333333" : "#F0F0F0"
                            onExited: parent.color = "transparent"
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: units.gu(2.5)
                        color: memeDelegate.darkMode ? "#343536" : "#EDEFF1"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Comments button
                    Rectangle {
                        width: commentRow.width + units.gu(2)
                        height: units.gu(4)
                        color: "transparent"
                        radius: units.gu(0.5)

                        Row {
                            id: commentRow
                            anchors.centerIn: parent
                            spacing: units.gu(0.6)

                            Icon {
                                name: "message"
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                anchors.verticalCenter: parent.verticalCenter
                                color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                            }

                            Label {
                                text: {
                                    if (memeDelegate.memeComments >= 1000) {
                                        return (memeDelegate.memeComments / 1000).toFixed(1) + "k";
                                    }
                                    return memeDelegate.memeComments.toString();
                                }
                                color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                                fontSize: "small"
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = memeDelegate.darkMode ? "#333333" : "#F0F0F0"
                            onExited: parent.color = "transparent"
                            onClicked: {
                                memeDelegate.commentClicked(memeDelegate.memeId, memeDelegate.memeSubreddit);
                            }
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: units.gu(2.5)
                        color: memeDelegate.darkMode ? "#343536" : "#EDEFF1"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Share button
                    Rectangle {
                        width: shareRow.width + units.gu(2)
                        height: units.gu(4)
                        color: "transparent"
                        radius: units.gu(0.5)

                        Row {
                            id: shareRow
                            anchors.centerIn: parent
                            spacing: units.gu(0.6)

                            Icon {
                                name: "share"
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                anchors.verticalCenter: parent.verticalCenter
                                color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                            }

                            Label {
                                text: "Share"
                                color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                                fontSize: "small"
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = memeDelegate.darkMode ? "#333333" : "#F0F0F0"
                            onExited: parent.color = "transparent"
                            onClicked: {
                                memeDelegate.shareRequested(
                                    "https://reddit.com" + memeDelegate.memePermalink,
                                    memeDelegate.memeTitle
                                );
                            }
                        }
                    }
                }

                // Bookmark button (right side)
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1)
                    anchors.verticalCenter: parent.verticalCenter
                    width: units.gu(4)
                    height: units.gu(4)
                    color: "transparent"
                    radius: units.gu(0.5)

                    Icon {
                        name: memeDelegate.isBookmarked ? "starred" : "non-starred"
                        width: units.gu(2.2)
                        height: units.gu(2.2)
                        anchors.centerIn: parent
                        color: memeDelegate.isBookmarked ? "#FFD700" : (memeDelegate.darkMode ? "#818384" : "#878A8C")
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = memeDelegate.darkMode ? "#333333" : "#F0F0F0"
                        onExited: parent.color = "transparent"
                        onClicked: {
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
    }
}