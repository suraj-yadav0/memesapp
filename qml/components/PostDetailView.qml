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

Dialog {
    id: postDetailView
    modal: true
    focus: true
    padding: 0
    x: 0
    y: 0
    width: parent.width
    height: parent.height
    
    // Post Properties
    property string postId: ""
    property string postTitle: ""
    property string postImage: ""
    property string postAuthor: ""
    property string postSubreddit: ""
    property int postUpvotes: 0
    property int postCommentCount: 0
    property string postSelfText: ""
    property string postType: "image"
    property string postPermalink: ""
    
    property bool isLoadingComments: false
    property var commentsModel: []
    property bool darkMode: false
    
    // Reddit-style thread line colors
    property var threadColors: [
        "#0079D3", // Reddit blue
        "#FF4500", // Reddit orange
        "#46D160", // Green
        "#FF66AC", // Pink
        "#7193FF", // Light blue
        "#FFD635", // Yellow
        "#9B59B6", // Purple
        "#00D5FA"  // Cyan
    ]

    signal closed()
    signal imageClicked(string url)

    background: Rectangle {
        color: postDetailView.darkMode ? "#030303" : "#DAE0E6"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar - Reddit style
        Rectangle {
            Layout.fillWidth: true
            height: units.gu(6)
            color: postDetailView.darkMode ? "#1A1A1B" : "#FFFFFF"
            z: 10

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: postDetailView.darkMode ? "#343536" : "#EDEFF1"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                spacing: units.gu(1)

                // Back Button
                Rectangle {
                    Layout.preferredWidth: units.gu(5)
                    Layout.preferredHeight: units.gu(5)
                    color: "transparent"
                    radius: units.gu(0.5)

                    Icon {
                        name: "back"
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        anchors.centerIn: parent
                        color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = postDetailView.darkMode ? "#333333" : "#F0F0F0"
                        onExited: parent.color = "transparent"
                        onClicked: postDetailView.close()
                    }
                }

                // Title
                Label {
                    Layout.fillWidth: true
                    text: postDetailView.postCommentCount + " Comments"
                    font.bold: true
                    font.pixelSize: units.gu(2)
                    elide: Text.ElideRight
                    color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                }

                // Sort button (placeholder)
                Rectangle {
                    Layout.preferredWidth: units.gu(5)
                    Layout.preferredHeight: units.gu(5)
                    color: "transparent"
                    radius: units.gu(0.5)

                    Icon {
                        name: "filters"
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        anchors.centerIn: parent
                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = postDetailView.darkMode ? "#333333" : "#F0F0F0"
                        onExited: parent.color = "transparent"
                    }
                }
            }
        }

        // Content ListView
        ListView {
            id: commentsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cacheBuffer: units.gu(100)
            
            model: postDetailView.commentsModel

            header: Item {
                width: parent.width
                height: postCard.height + units.gu(2)

                // Post Card
                Rectangle {
                    id: postCard
                    width: parent.width
                    height: postCardContent.height + units.gu(2)
                    color: postDetailView.darkMode ? "#1A1A1B" : "#FFFFFF"

                    Column {
                        id: postCardContent
                        width: parent.width
                        spacing: units.gu(1)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1)

                        // Subreddit and Author info
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(1.5)
                            spacing: units.gu(0.8)

                            // Subreddit icon
                            Rectangle {
                                width: units.gu(3)
                                height: units.gu(3)
                                radius: width / 2
                                color: "#FF4500"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "r"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: units.gu(1.5)
                                }
                            }

                            Label {
                                text: "r/" + postDetailView.postSubreddit
                                font.bold: true
                                font.pixelSize: units.gu(1.6)
                                color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: "•"
                                color: postDetailView.darkMode ? "#818384" : "#787C7E"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: "u/" + postDetailView.postAuthor
                                font.pixelSize: units.gu(1.5)
                                color: postDetailView.darkMode ? "#818384" : "#787C7E"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Post Title
                        Label {
                            width: parent.width - units.gu(3)
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: postDetailView.postTitle
                            wrapMode: Text.Wrap
                            font.bold: true
                            font.pixelSize: units.gu(2.2)
                            color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                            lineHeight: 1.2
                        }

                        // Post Content (Image or Text)
                        Item {
                            width: parent.width
                            height: {
                                if (postDetailView.postType === "image" && postDetailView.postImage !== "") {
                                    if (postImageLoader.status === Image.Ready) {
                                        var aspectRatio = postImageLoader.sourceSize.width / Math.max(postImageLoader.sourceSize.height, 1);
                                        return Math.min(width / Math.max(aspectRatio, 0.5), units.gu(50));
                                    }
                                    return units.gu(30);
                                } else if (postDetailView.postType === "text" && postDetailView.postSelfText !== "") {
                                    return selfTextLabel.contentHeight + units.gu(3);
                                }
                                return 0;
                            }
                            visible: postDetailView.postImage !== "" || postDetailView.postSelfText !== ""

                            // Image Content
                            Rectangle {
                                anchors.fill: parent
                                color: postDetailView.darkMode ? "#0D0D0D" : "#F8F9FA"
                                visible: postDetailView.postType === "image" && postDetailView.postImage !== ""

                                Image {
                                    id: postImageLoader
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: parent.height
                                    source: postDetailView.postImage
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    cache: true

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: postDetailView.imageClicked(postDetailView.postImage)
                                    }
                                }

                                RedditLoadingAnimation {
                                    anchors.centerIn: parent
                                    running: postImageLoader.status === Image.Loading
                                    visible: running
                                    width: units.gu(6)
                                    height: units.gu(6)
                                    accentColor: "#FF4500"
                                    darkMode: postDetailView.darkMode
                                }
                            }

                            // Text Content
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                color: postDetailView.darkMode ? "#272729" : "#F6F7F8"
                                radius: units.gu(1)
                                visible: postDetailView.postType === "text" && postDetailView.postSelfText !== ""

                                Label {
                                    id: selfTextLabel
                                    width: parent.width - units.gu(2)
                                    anchors.left: parent.left
                                    anchors.leftMargin: units.gu(1)
                                    anchors.top: parent.top
                                    anchors.topMargin: units.gu(1)
                                    text: postDetailView.postSelfText
                                    wrapMode: Text.Wrap
                                    color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                                    lineHeight: 1.5
                                    font.pixelSize: units.gu(1.8)
                                }
                            }
                        }

                        // Post Stats Bar
                        Rectangle {
                            width: parent.width
                            height: units.gu(5)
                            color: "transparent"

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
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                    }
                                }

                                // Vote count
                                Label {
                                    text: {
                                        if (postDetailView.postUpvotes >= 1000) {
                                            return (postDetailView.postUpvotes / 1000).toFixed(1) + "k";
                                        }
                                        return postDetailView.postUpvotes.toString();
                                    }
                                    color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                                    font.bold: true
                                    font.pixelSize: units.gu(1.6)
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
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                    }
                                }

                                // Separator
                                Rectangle {
                                    width: 1
                                    height: units.gu(2.5)
                                    color: postDetailView.darkMode ? "#343536" : "#EDEFF1"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Comments count
                                Row {
                                    spacing: units.gu(0.5)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Icon {
                                        name: "message"
                                        width: units.gu(2.2)
                                        height: units.gu(2.2)
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Label {
                                        text: postDetailView.postCommentCount.toString()
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                        font.bold: true
                                        font.pixelSize: units.gu(1.5)
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Separator
                                Rectangle {
                                    width: 1
                                    height: units.gu(2.5)
                                    color: postDetailView.darkMode ? "#343536" : "#EDEFF1"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Share button
                                Row {
                                    spacing: units.gu(0.5)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Icon {
                                        name: "share"
                                        width: units.gu(2.2)
                                        height: units.gu(2.2)
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Label {
                                        text: "Share"
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                        font.bold: true
                                        font.pixelSize: units.gu(1.5)
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    // Bottom border
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: postDetailView.darkMode ? "#343536" : "#EDEFF1"
                    }
                }
            }

            // Loading Indicator
            footer: Item {
                width: parent.width
                height: postDetailView.isLoadingComments ? units.gu(10) : 0
                visible: postDetailView.isLoadingComments

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    RedditLoadingAnimation {
                        running: postDetailView.isLoadingComments
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: units.gu(4)
                        height: units.gu(4)
                        accentColor: "#FF4500"
                        darkMode: postDetailView.darkMode
                    }

                    Label {
                        text: "Loading comments..."
                        color: postDetailView.darkMode ? "#818384" : "#787C7E"
                        font.pixelSize: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Comment delegate
            delegate: Item {
                id: commentDelegate
                width: parent.width
                height: commentCard.height + units.gu(0.5)

                Rectangle {
                    id: commentCard
                    width: parent.width
                    height: commentColumn.height + units.gu(1.5)
                    color: postDetailView.darkMode ? "#1A1A1B" : "#FFFFFF"

                    Row {
                        id: commentRow
                        anchors.fill: parent
                        anchors.topMargin: units.gu(0.75)
                        anchors.bottomMargin: units.gu(0.75)

                        // Thread lines for depth
                        Repeater {
                            model: modelData.depth || 0

                            Item {
                                width: units.gu(2)
                                height: commentCard.height

                                // Colored thread line
                                Rectangle {
                                    width: units.gu(0.4)
                                    height: parent.height
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: postDetailView.threadColors[index % postDetailView.threadColors.length]
                                    radius: units.gu(0.2)

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -units.gu(0.5)
                                        // Could add collapse functionality here
                                    }
                                }
                            }
                        }

                        // Spacer after thread lines
                        Item {
                            width: units.gu(0.5)
                            height: 1
                        }

                        // Comment content - positioned after the thread lines
                        Column {
                            id: commentColumn
                            width: commentRow.width - ((modelData.depth || 0) * units.gu(2)) - units.gu(1.5)
                            spacing: units.gu(0.5)

                            // Author row
                            Row {
                                spacing: units.gu(0.8)

                                // Avatar placeholder
                                Rectangle {
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    radius: width / 2
                                    color: postDetailView.threadColors[(modelData.depth || 0) % postDetailView.threadColors.length]
                                    anchors.verticalCenter: parent.verticalCenter

                                    Label {
                                        anchors.centerIn: parent
                                        text: (modelData.author || "?").charAt(0).toUpperCase()
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: units.gu(1.2)
                                    }
                                }

                                // Author name
                                Label {
                                    text: modelData.author || "[deleted]"
                                    font.bold: true
                                    font.pixelSize: units.gu(1.5)
                                    color: modelData.is_submitter ? "#0079D3" : (postDetailView.darkMode ? "#D7DADC" : "#1A1A1B")
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // OP badge
                                Rectangle {
                                    width: opLabel.width + units.gu(1)
                                    height: units.gu(2)
                                    radius: units.gu(0.3)
                                    color: "#0079D3"
                                    visible: modelData.is_submitter || false
                                    anchors.verticalCenter: parent.verticalCenter

                                    Label {
                                        id: opLabel
                                        text: "OP"
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: units.gu(1.1)
                                        anchors.centerIn: parent
                                    }
                                }

                                // Time ago (placeholder)
                                Label {
                                    text: "•"
                                    color: postDetailView.darkMode ? "#818384" : "#787C7E"
                                    font.pixelSize: units.gu(1.3)
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Score
                                Label {
                                    text: {
                                        var score = modelData.score || 0;
                                        if (score >= 1000) {
                                            return (score / 1000).toFixed(1) + "k pts";
                                        }
                                        return score + " pts";
                                    }
                                    color: postDetailView.darkMode ? "#818384" : "#787C7E"
                                    font.pixelSize: units.gu(1.3)
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Comment body
                            Text {
                                id: commentBody
                                width: parent.width - units.gu(1)
                                text: modelData.body || ""
                                wrapMode: Text.Wrap
                                color: postDetailView.darkMode ? "#D7DADC" : "#1A1A1B"
                                font.pixelSize: units.gu(1.7)
                                lineHeight: 1.4
                                textFormat: Text.PlainText
                            }

                            // Action buttons row
                            Row {
                                spacing: units.gu(2)
                                height: units.gu(3.5)

                                // Upvote
                                Row {
                                    spacing: units.gu(0.3)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Icon {
                                        name: "go-up"
                                        width: units.gu(2)
                                        height: units.gu(2)
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                    }
                                }

                                // Downvote
                                Row {
                                    spacing: units.gu(0.3)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Icon {
                                        name: "go-down"
                                        width: units.gu(2)
                                        height: units.gu(2)
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                    }
                                }

                                // Reply
                                Row {
                                    spacing: units.gu(0.5)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Icon {
                                        name: "message"
                                        width: units.gu(1.8)
                                        height: units.gu(1.8)
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                    }

                                    Label {
                                        text: "Reply"
                                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                        font.pixelSize: units.gu(1.3)
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // More options
                                Icon {
                                    name: "contextual-menu"
                                    width: units.gu(1.8)
                                    height: units.gu(1.8)
                                    color: postDetailView.darkMode ? "#818384" : "#878A8C"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: units.gu(20)
                visible: !postDetailView.isLoadingComments && postDetailView.commentsModel.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(2)

                    Icon {
                        name: "message"
                        width: units.gu(6)
                        height: units.gu(6)
                        color: postDetailView.darkMode ? "#818384" : "#878A8C"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        text: "No comments yet"
                        color: postDetailView.darkMode ? "#818384" : "#787C7E"
                        font.pixelSize: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        text: "Be the first to share what you think!"
                        color: postDetailView.darkMode ? "#818384" : "#787C7E"
                        font.pixelSize: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    onClosed: {
        postDetailView.commentsModel = []
    }
}
