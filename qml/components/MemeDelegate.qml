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
    backgroundColor: memeDelegate.darkMode ? "#000000" : "#F6F7F8"

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
    property string timestamp: "6h ago" // Default timestamp, can be calculated
    
    // Multi-subreddit properties
    property bool isMultiSubredditMode: false
    property string subredditSource: ""
    
    // Bookmark properties
    property bool isBookmarked: false

    // Signals
    signal shareRequested(string url, string title)
    signal downloadRequested(string url, string title)
    signal imageClicked(string url)
    signal commentClicked(string id, string subreddit)
    signal bookmarkToggled(var meme, bool bookmark)
    signal backRequested() // New signal for back button

    // Main container
    Item {
        anchors.fill: parent

        // Header bar - Reddit style with "Post" title
        // Rectangle {
        //     id: headerBar
        //     anchors.top: parent.top
        //     width: parent.width
            
        //     color: memeDelegate.darkMode ? "#2B2B2B" : "#FFFFFF"
        //     z: 10

            // Row {
            //     anchors.fill: parent
            //     anchors.leftMargin: units.gu(0.5)
            //     anchors.rightMargin: units.gu(0.5)
            //     spacing: 0

            //     // Back button
            //     Rectangle {
            //         width: units.gu(5)
            //         height: parent.height
            //         color: "transparent"

            //         Icon {
            //             name: "back"
            //             width: units.gu(2.5)
            //             height: units.gu(2.5)
            //             anchors.centerIn: parent
            //             color: memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C"
            //         }

            //         MouseArea {
            //             anchors.fill: parent
            //             onClicked: {
            //                 console.log("MemeDelegate: Back button clicked");
            //                 memeDelegate.backRequested();
            //             }
            //         }
            //     }

            //     // "Post" title (centered)
            //     Item {
            //         width: parent.width - units.gu(17)
            //         height: parent.height
            //         anchors.verticalCenter: parent.verticalCenter
                    
            //         Label {
            //             text: "Post"
            //             font.bold: false
            //             fontSize: "large"
            //             color: memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C"
            //             anchors.verticalCenter: parent.verticalCenter
            //             anchors.left: parent.left
            //             anchors.leftMargin: units.gu(1)
            //         }
            //     }

            //     // Action buttons (right side)
            //     Row {
            //         spacing: units.gu(0.5)
            //         anchors.verticalCenter: parent.verticalCenter

            //         // Bookmark button
            //         Rectangle {
            //             width: units.gu(5)
            //             height: units.gu(5)
            //             color: "transparent"

            //             Icon {
            //                 name: memeDelegate.isBookmarked ? "starred" : "non-starred"
            //                 width: units.gu(2.5)
            //                 height: units.gu(2.5)
            //                 anchors.centerIn: parent
            //                 color: memeDelegate.isBookmarked ? "#FFD700" : (memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C")
            //             }

            //             MouseArea {
            //                 anchors.fill: parent
            //                 onClicked: {
            //                     console.log("MemeDelegate: Toggling bookmark for meme:", memeDelegate.memeTitle);
            //                     var memeData = {
            //                         id: memeDelegate.memeId,
            //                         title: memeDelegate.memeTitle,
            //                         image: memeDelegate.memeImage,
            //                         subreddit: memeDelegate.memeSubreddit,
            //                         author: memeDelegate.memeAuthor,
            //                         permalink: memeDelegate.memePermalink,
            //                         upvotes: memeDelegate.memeUpvotes,
            //                         comments: memeDelegate.memeComments
            //                     };
            //                     memeDelegate.bookmarkToggled(memeData, !memeDelegate.isBookmarked);
            //                 }
            //             }
            //         }

            //         // Share button
            //         Rectangle {
            //             width: units.gu(5)
            //             height: units.gu(5)
            //             color: "transparent"

            //             Icon {
            //                 name: "share"
            //                 width: units.gu(2.5)
            //                 height: units.gu(2.5)
            //                 anchors.centerIn: parent
            //                 color: memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C"
            //             }

            //             MouseArea {
            //                 anchors.fill: parent
            //                 onClicked: {
            //                     console.log("MemeDelegate: Sharing meme:", memeDelegate.memeTitle);
            //                     memeDelegate.shareRequested(
            //                         "https://reddit.com" + memeDelegate.memePermalink, 
            //                         memeDelegate.memeTitle
            //                     );
            //                 }
            //             }
            //         }

            //         // More options button
            //         Rectangle {
            //             width: units.gu(5)
            //             height: units.gu(5)
            //             color: "transparent"

            //             Icon {
            //                 name: "navigation-menu"
            //                 width: units.gu(2.5)
            //                 height: units.gu(2.5)
            //                 anchors.centerIn: parent
            //                 color: memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C"
            //             }

            //             MouseArea {
            //                 anchors.fill: parent
            //                 onClicked: {
            //                     console.log("MemeDelegate: More options clicked");
            //                     // Can add menu functionality here
            //                 }
            //             }
            //         }
            //     }
            // }
      //  }

        // Content area
        Rectangle {
            id: contentArea
         anchors.fill: parent
            width: parent.width
            color: memeDelegate.darkMode ? "#1A1A1A" : "#FFFFFF"

            Flickable {
                anchors.fill: parent
                contentHeight: contentColumn.height
                clip: true

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: 0

                    // Post metadata (subreddit, author, timestamp)
                    Rectangle {
                        width: parent.width
                        height: units.gu(5)
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: units.gu(1.5)
                            anchors.rightMargin: units.gu(1.5)
                            spacing: units.gu(1)
                            anchors.verticalCenter: parent.verticalCenter

                            // Subreddit badge
                            Rectangle {
                                width: units.gu(0.8)
                                height: units.gu(0.8)
                                radius: width / 2
                                color: "#FF4500"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Subreddit and author text
                            Label {
                                text: "r/" + (memeDelegate.isMultiSubredditMode && memeDelegate.subredditSource !== "" ? 
                                      memeDelegate.subredditSource : memeDelegate.memeSubreddit)
                                font.bold: true
                                fontSize: "small"
                                color: memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: "•"
                                fontSize: "small"
                                color: memeDelegate.darkMode ? "#818384" : "#7C7C7C"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: "Posted by u/" + memeDelegate.memeAuthor
                                fontSize: "small"
                                color: memeDelegate.darkMode ? "#818384" : "#7C7C7C"
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Post title
                    Rectangle {
                        width: parent.width
                        height: titleLabel.height + units.gu(2)
                        color: "transparent"

                        Label {
                            id: titleLabel
                            width: parent.width - units.gu(3)
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(1.5)
                            anchors.top: parent.top
                            anchors.topMargin: units.gu(0.5)
                            text: memeDelegate.memeTitle
                            font.bold: true
                            fontSize: units.gu(1.8)
                            wrapMode: Text.WordWrap
                            color: memeDelegate.darkMode ? "#FFFFFF" : "#1C1C1C"
                            maximumLineCount: 6
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("MemeDelegate: Title clicked, opening comments");
                                memeDelegate.commentClicked(memeDelegate.memeId, memeDelegate.memeSubreddit);
                            }
                        }
                    }

                    // Text content for text posts
                    Rectangle {
                        width: parent.width
                        height: {
                            if (memeDelegate.postType === "text" && memeDelegate.selftext !== "") {
                                // For text-only posts, use much more space
                                return Math.max(units.gu(30), Math.min(units.gu(60), textLabel.contentHeight + units.gu(3)));
                            }
                            return 0;
                        }
                        color: "transparent"
                        visible: memeDelegate.postType === "text" && memeDelegate.selftext !== ""
                        
                        Label {
                            id: textLabel
                            anchors.fill: parent
                            anchors.leftMargin: units.gu(1.5)
                            anchors.rightMargin: units.gu(1.5)
                            anchors.topMargin: units.gu(1)
                            anchors.bottomMargin: units.gu(1)
                            text: memeDelegate.selftext
                            fontSize: "medium"
                            color: memeDelegate.darkMode ? "#D7DADC" : "#1C1C1C"
                            wrapMode: Text.Wrap
                            elide: Text.ElideNone
                            verticalAlignment: Text.AlignTop
                        }
                    }

                    // Image container
                    Rectangle {
                        width: parent.width
                        height: Math.min(memeImage.sourceSize.height * (parent.width / Math.max(memeImage.sourceSize.width, 1)), units.gu(80))
                        color: memeDelegate.darkMode ? "#000000" : "#F6F7F8"
                        clip: true
                        visible: memeDelegate.postType === "image" && memeDelegate.memeImage !== ""

                        Image {
                            id: memeImage
                            anchors.centerIn: parent
                            width: parent.width
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
                        // UbuntuShape {
                        //     id: subredditBadge
                        //     visible: memeDelegate.isMultiSubredditMode && memeDelegate.subredditSource !== ""
                        //     anchors.top: parent.top
                        //     anchors.right: parent.right
                        //     anchors.margins: units.gu(1.5)
                        //     width: subredditLabel.width + units.gu(2)
                        //     height: units.gu(3.5)
                        //     backgroundColor: "#FF4500"
                        //     opacity: 0.95

                        //     Label {
                        //         id: subredditLabel
                        //         text: "r/" + memeDelegate.subredditSource
                        //         anchors.centerIn: parent
                        //         color: "white"
                        //         fontSize: "small"
                        //         font.bold: true
                        //     }
                        // }
                    }
                }
            }
        }

        // Bottom engagement bar - Reddit style
        Rectangle {
            id: bottomBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: units.gu(6)
            color: memeDelegate.darkMode ? "#1A1A1A" : "#FFFFFF"
            z: 10

            Row {
                anchors.fill: parent
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                spacing: units.gu(3)

                // Upvote/Downvote section
                Rectangle {
                    width: units.gu(10)
                    height: parent.height
                    color: "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(0.5)

                        // Upvote arrow
                        Icon {
                            name: "go-up"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
                            anchors.verticalCenter: parent.verticalCenter
                            color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                        }

                        // Vote count
                        Label {
                            text: {
                                if (memeDelegate.memeUpvotes >= 1000) {
                                    return (memeDelegate.memeUpvotes / 1000).toFixed(1) + "k";
                                }
                                return memeDelegate.memeUpvotes.toString();
                            }
                            color: memeDelegate.darkMode ? "#D7DADC" : "#1C1C1C"
                            fontSize: "medium"
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Downvote arrow
                        Icon {
                            name: "go-down"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
                            anchors.verticalCenter: parent.verticalCenter
                            color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                        }
                    }
                }

                // Comments section
                Rectangle {
                    width: units.gu(8)
                    height: parent.height
                    color: "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(0.8)

                        Icon {
                            name: "message"
                            width: units.gu(2.5)
                            height: units.gu(2.5)
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
                            color: memeDelegate.darkMode ? "#D7DADC" : "#1C1C1C"
                            fontSize: "medium"
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("MemeDelegate: Comments clicked");
                            memeDelegate.commentClicked(memeDelegate.memeId, memeDelegate.memeSubreddit);
                        }
                    }
                }

                // Spacer
                Item {
                    width: parent.width - units.gu(30)
                    height: parent.height
                }

                // Share icon
                Rectangle {
                    width: units.gu(4)
                    height: parent.height
                    color: "transparent"

                    Icon {
                        name: "share"
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        anchors.centerIn: parent
                        color: memeDelegate.darkMode ? "#818384" : "#878A8C"
                    }
                }

                // Timestamp
                Label {
                    text: memeDelegate.timestamp
                    fontSize: "small"
                    color: memeDelegate.darkMode ? "#818384" : "#7C7C7C"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}