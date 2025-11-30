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
    property string postType: "image" // "image" or "text"
    property string postPermalink: ""
    
    property bool isLoadingComments: false
    property var commentsModel: []
    
    // Rainbow indentation colors
    property var indentationColors: [
        "#E74C3C", // Red
        "#E67E22", // Orange
        "#F1C40F", // Yellow
        "#2ECC71", // Green
        "#3498DB", // Blue
        "#9B59B6"  // Purple
    ]

    signal closed()
    signal imageClicked(string url)

    background: Rectangle {
        color: theme.palette.normal.background
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: units.gu(6)
            color: theme.palette.normal.base
            z: 10

            RowLayout {
                anchors.fill: parent
                spacing: units.gu(1)

                // Back Button
                AbstractButton {
                    Layout.preferredWidth: units.gu(6)
                    Layout.fillHeight: true
                    onClicked: postDetailView.close()

                    Icon {
                        name: "back"
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        anchors.centerIn: parent
                        color: theme.palette.normal.foregroundText
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: "Comments"
                    font.bold: true
                    fontSize: "large"
                    elide: Text.ElideRight
                    color: theme.palette.normal.foregroundText
                }
            }
        }

        // Content
        ListView {
            id: commentsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            model: postDetailView.commentsModel

            header: Column {
                width: parent.width
                spacing: units.gu(1)
                
                // Post Header Info
                Item {
                    width: parent.width
                    height: units.gu(6)
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)
                        spacing: units.gu(1)
                        
                        Label {
                            text: "r/" + postDetailView.postSubreddit
                            font.bold: true
                            color: theme.palette.normal.foregroundText
                        }
                        
                        Label {
                            text: "• Posted by u/" + postDetailView.postAuthor
                            color: theme.palette.normal.foregroundText
                            opacity: 0.7
                            font.pixelSize: units.gu(1.5)
                        }
                    }
                }
                
                // Post Title
                Label {
                    width: parent.width - units.gu(2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: postDetailView.postTitle
                    wrapMode: Text.Wrap
                    font.bold: true
                    font.pixelSize: units.gu(2)
                    color: theme.palette.normal.foregroundText
                }
                
                // Post Content (Image or Text)
                Item {
                    width: parent.width
                    height: {
                        if (postDetailView.postType === "image" && postDetailView.postImage !== "") {
                            return width * 0.75;
                        } else if (postDetailView.postType === "text" && postDetailView.postSelfText !== "") {
                            return selfTextLabel.contentHeight + units.gu(3);
                        }
                        return 0;
                    }
                    visible: postDetailView.postImage !== "" || postDetailView.postSelfText !== ""
                    
                    // Image Content
                    Image {
                        anchors.fill: parent
                        source: postDetailView.postType === "image" ? postDetailView.postImage : ""
                        fillMode: Image.PreserveAspectFit
                        visible: postDetailView.postType === "image" && postDetailView.postImage !== ""
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: postDetailView.imageClicked(postDetailView.postImage)
                        }
                    }
                    
                    // Text Content - Full scrollable text
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)
                        color: theme.palette.normal.base
                        radius: units.gu(1)
                        visible: postDetailView.postType === "text" && postDetailView.postSelfText !== ""
                        
                        Label {
                            id: selfTextLabel
                            width: parent.width - units.gu(2)
                            anchors.centerIn: parent
                            text: postDetailView.postSelfText
                            wrapMode: Text.Wrap
                            color: theme.palette.normal.foregroundText
                            lineHeight: 1.4
                            font.pixelSize: units.gu(1.8)
                        }
                    }
                }
                
                // Post Stats
                RowLayout {
                    width: parent.width
                    height: units.gu(5)
                    
                    Item { width: units.gu(1) }
                    
                    Icon {
                        name: "like"
                        width: units.gu(2)
                        height: units.gu(2)
                        color: theme.palette.normal.foregroundText
                    }
                    
                    Label {
                        text: postDetailView.postUpvotes
                        color: theme.palette.normal.foregroundText
                    }
                    
                    Item { width: units.gu(2) }
                    
                    Icon {
                        name: "message"
                        width: units.gu(2)
                        height: units.gu(2)
                        color: theme.palette.normal.foregroundText
                    }
                    
                    Label {
                        text: postDetailView.postCommentCount + " Comments"
                        color: theme.palette.normal.foregroundText
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.palette.normal.base
                }
                
                // Loading Indicator
                Item {
                    width: parent.width
                    height: units.gu(10)
                    visible: postDetailView.isLoadingComments
                    
                    ActivityIndicator {
                        anchors.centerIn: parent
                        running: postDetailView.isLoadingComments
                    }
                }
            }

            delegate: Item {
                width: parent.width
                // Ensure minimum height for avatar and dynamic height for content
                height: Math.max(commentContentRow.height, units.gu(5)) + units.gu(1)
                
                // Indentation line
                Row {
                    anchors.fill: parent
                    
                    // Spacers for indentation
                    Repeater {
                        model: modelData.depth
                        Rectangle {
                            width: units.gu(1.5) // Reduced indentation width
                            height: parent.height
                            color: "transparent"
                            
                            Rectangle {
                                width: 2 // Slightly thicker line
                                height: parent.height
                                color: postDetailView.indentationColors[index % postDetailView.indentationColors.length]
                                anchors.right: parent.right
                                opacity: 0.6
                            }
                        }
                    }
                    
                    // Comment Content
                    Row {
                        id: commentContentRow
                        width: parent.width - (modelData.depth * units.gu(1.5)) - units.gu(1)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(1)

                        // Avatar
                        Item {
                            width: units.gu(4)
                            height: units.gu(4)
                            anchors.top: parent.top
                            
                            // Placeholder/Avatar
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: theme.palette.normal.base
                                clip: true
                                
                                // Default icon
                                Icon {
                                    anchors.centerIn: parent
                                    width: parent.width * 0.6
                                    height: parent.height * 0.6
                                    name: "contact"
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.5
                                }
                            }
                        }

                        // Text Content
                        Column {
                            width: parent.width - units.gu(5)
                            spacing: units.gu(0.5)
                            
                            // Author Row
                            Row {
                                spacing: units.gu(1)
                                Label {
                                    text: modelData.author
                                    font.bold: true
                                    font.pixelSize: units.gu(1.5)
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.8
                                }
                                
                                Label {
                                    text: modelData.score + " points"
                                    font.pixelSize: units.gu(1.5)
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.6
                                }
                            }
                            
                            // Body
                            Text {
                                width: parent.width
                                text: modelData.body_html || modelData.body
                                textFormat: Text.RichText
                                wrapMode: Text.Wrap
                                color: theme.palette.normal.foregroundText
                                linkColor: theme.palette.normal.focus
                                
                                onLinkActivated: {
                                    console.log("Link clicked:", link);
                                    Qt.openUrlExternally(link);
                                }
                            }
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.palette.normal.base
                    opacity: 0.2
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
    
    onClosed: {
        postDetailView.commentsModel = []
    }
}
