/*
* Copyright (C) 2025 Suraj Yadav
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; version 3.
*
* memesapp is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
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
    id: bookmarksDialog
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: Math.min(parent.width * 0.9, units.gu(50))
    height: Math.min(parent.height * 0.8, units.gu(60))
    modal: true

    title: "Bookmarked Memes (" + bookmarksList.length + ")"

    // Properties
    property var bookmarksList: []
    property bool darkMode: false

        // Signals
        signal memeSelected(var meme)
        signal removeBookmark(string memeId)
        signal clearAllBookmarks()

        header: Rectangle {
            width: parent.width
            height: units.gu(6)
            color: bookmarksDialog.darkMode ? "#2D2D2D" : "#F5F5F5"

            Row {
                anchors.fill: parent
                anchors.margins: units.gu(1)
                spacing: units.gu(1)

                Label {
                    text: "Bookmarked Memes (" + bookmarksDialog.bookmarksList.length + ")"
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    color: bookmarksDialog.darkMode ? "#FFFFFF" : "#000000"
                }

                Item { Layout.fillWidth: true; width: 1; height: 1 }

                // Clear all button
                CustomButton {
                    text: "Clear All"
                    height: units.gu(4)
                    width: units.gu(7)

                    visible: bookmarksDialog.bookmarksList.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        clearAllConfirmDialog.open();
                    }
                }

                // Close button
                CustomButton {
                    text: "Close"
                    height: units.gu(4)
                    width: units.gu(7)
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: bookmarksDialog.close()
                }
            }
        }

        // Main content
        ScrollView {
            anchors.fill: parent
            anchors.margins: units.gu(1)

            ListView {
                id: bookmarksListView
                model: bookmarksDialog.bookmarksList
                spacing: units.gu(1)

                delegate: Rectangle {
                    width: bookmarksListView.width
                    height: units.gu(12)
                    color: bookmarksDialog.darkMode ? "#3D3D3D" : "#FFFFFF"
                    border.color: bookmarksDialog.darkMode ? "#555555" : "#E0E0E0"
                    border.width: 1
                    radius: units.gu(0.5)

                    Row {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)
                        spacing: units.gu(1)

                        // Thumbnail
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(10)
                            color: bookmarksDialog.darkMode ? "#1A1A1A" : "#F0F0F0"
                            radius: units.gu(0.5)
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: thumbnailImage
                                source: modelData.image || ""
                                anchors.fill: parent
                                anchors.margins: units.gu(0.2)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true

                                onStatusChanged: {
                                    if (status === Image.Error)
                                    {
                                        visible = false;
                                        placeholderIcon.visible = true;
                                    }
                                }
                            }

                            Icon {
                                id: placeholderIcon
                                name: "image-x-generic-symbolic"
                                anchors.centerIn: parent
                                width: units.gu(4)
                                height: units.gu(4)
                                color: bookmarksDialog.darkMode ? "#666666" : "#CCCCCC"
                                visible: thumbnailImage.status === Image.Error || !modelData.image
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("BookmarksDialog: Opening bookmarked meme:", modelData.title);
                                    bookmarksDialog.memeSelected(modelData);
                                    bookmarksDialog.close();
                                }
                            }
                        }

                        // Content
                        Column {
                            width: parent.width - units.gu(12) - removeButton.width
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: units.gu(0.5)

                            // Title
                            Label {
                                text: modelData.title || "Untitled"
                                font.bold: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                width: parent.width
                                color: bookmarksDialog.darkMode ? "#FFFFFF" : "#000000"
                            }

                            // Subreddit and stats
                            Row {
                                spacing: units.gu(1)

                                Label {
                                    text: "r/" + (modelData.subreddit || "unknown")
                                    fontSize: "small"
                                    color: bookmarksDialog.darkMode ? "#AAAAAA" : "#666666"
                                }

                                Label {
                                    text: "👍 " + (modelData.upvotes || 0)
                                    fontSize: "small"
                                    color: bookmarksDialog.darkMode ? "#AAAAAA" : "#666666"
                                }

                                Label {
                                    text: "💬 " + (modelData.comments || 0)
                                    fontSize: "small"
                                    color: bookmarksDialog.darkMode ? "#AAAAAA" : "#666666"
                                }
                            }

                            // Date bookmarked
                            Label {
                                text: "Saved: " + Qt.formatDateTime(new Date(modelData.dateBookmarked), "MMM dd, yyyy hh:mm")
                                fontSize: "x-small"
                                color: bookmarksDialog.darkMode ? "#888888" : "#999999"
                            }
                        }

                        // Remove button
                        CustomButton {
                            id: removeButton
                            text: "Remove"
                            height: units.gu(4)
                            width: units.gu(7)
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                console.log("BookmarksDialog: Removing bookmark for:", modelData.title);
                                bookmarksDialog.removeBookmark(modelData.id);
                            }
                        }
                    }
                }

                // Empty state
                Label {
                    anchors.centerIn: parent
                    text: "No bookmarked memes yet!\nTap the ★ icon on any meme to bookmark it."
                    horizontalAlignment: Text.AlignHCenter
                    color: bookmarksDialog.darkMode ? "#AAAAAA" : "#666666"
                    visible: bookmarksDialog.bookmarksList.length === 0
                }
            }
        }

        // Clear all confirmation dialog
        Dialog {
            id: clearAllConfirmDialog
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: units.gu(30)
            height: units.gu(15)
            modal: true
            title: "Clear All Bookmarks"

            Column {
                anchors.fill: parent
                anchors.margins: units.gu(1)
                spacing: units.gu(2)

                Label {
                    text: "Are you sure you want to remove all bookmarked memes? This action cannot be undone."
                    wrapMode: Text.WordWrap
                    width: parent.width
                    color: bookmarksDialog.darkMode ? "#FFFFFF" : "#000000"
                }

                Row {
                    spacing: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter

                    CustomButton {
                        text: "Cancel"
                        onClicked: clearAllConfirmDialog.close()
                    }

                    CustomButton {
                        text: "Clear All"
                        bgColor: "#e74c3c"  // Red color for destructive action
                        onClicked: {
                            bookmarksDialog.clearAllBookmarks();
                            clearAllConfirmDialog.close();
                        }
                    }
                }
            }
        }

        // Functions
        function loadBookmarks(bookmarks)
        {
            bookmarksDialog.bookmarksList = bookmarks || [];
            console.log("BookmarksDialog: Loaded", bookmarksDialog.bookmarksList.length, "bookmarks");
        }

        function refreshBookmarks()
        {
            // This will be called from Main.qml to refresh the list
            console.log("BookmarksDialog: Refreshing bookmarks list");
        }
    }