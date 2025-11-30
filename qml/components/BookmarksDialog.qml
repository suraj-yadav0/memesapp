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
import QtQuick.Controls 2.12 as QC2
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3

QC2.Dialog {
    id: bookmarksDialog
    
    // Properties
    property var bookmarksList: []
    property bool darkMode: false
    
    // Theme colors
    readonly property color bgColor: darkMode ? "#0F0F0F" : "#F5F5F5"
    readonly property color cardColor: darkMode ? "#1A1A1B" : "#FFFFFF"
    readonly property color textColor: darkMode ? "#D7DADC" : "#1A1A1B"
    readonly property color subtextColor: darkMode ? "#818384" : "#787C7E"
    readonly property color accentColor: "#FF4500"
    readonly property color dividerColor: darkMode ? "#343536" : "#EDEFF1"
    
    // Signals
    signal memeSelected(var meme)
    signal removeBookmark(string memeId)
    signal clearAllBookmarks()
    
    // Full screen dialog
    x: 0
    y: 0
    width: parent.width
    height: parent.height
    
    modal: true
    focus: true
    padding: 0
    margins: 0
    
    header: null
    footer: null
    
    background: Rectangle {
        color: bookmarksDialog.bgColor
    }
    
    contentItem: Item {
        anchors.fill: parent
        
        // Header
        Rectangle {
            id: headerBar
            width: parent.width
            height: units.gu(7)
            color: bookmarksDialog.cardColor
            z: 10
            
            // Shadow
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: units.gu(0.5)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: bookmarksDialog.darkMode ? "#40000000" : "#20000000" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            // Back button
            Rectangle {
                id: backButton
                width: units.gu(5)
                height: units.gu(5)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                color: backMouseArea.pressed ? bookmarksDialog.dividerColor : "transparent"
                radius: width / 2
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    name: "back"
                    color: bookmarksDialog.textColor
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: bookmarksDialog.close()
                }
            }
            
            // Title with count
            Column {
                anchors.centerIn: parent
                spacing: units.gu(0.2)
                
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Bookmarks"
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.DemiBold
                    color: bookmarksDialog.textColor
                }
                
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: bookmarksDialog.bookmarksList.length + " saved posts"
                    font.pixelSize: units.gu(1.3)
                    color: bookmarksDialog.subtextColor
                    visible: bookmarksDialog.bookmarksList.length > 0
                }
            }
            
            // Clear All button
            Rectangle {
                width: units.gu(5)
                height: units.gu(5)
                anchors.right: parent.right
                anchors.rightMargin: units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                color: clearMouseArea.pressed ? bookmarksDialog.dividerColor : "transparent"
                radius: width / 2
                visible: bookmarksDialog.bookmarksList.length > 0
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    name: "delete"
                    color: "#E53935"
                }
                
                MouseArea {
                    id: clearMouseArea
                    anchors.fill: parent
                    onClicked: clearAllConfirmDialog.open()
                }
            }
        }
        
        // Content
        ListView {
            id: bookmarksListView
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: units.gu(1)
            clip: true
            spacing: units.gu(1)
            
            model: bookmarksDialog.bookmarksList
            
            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: units.gu(2)
                visible: bookmarksDialog.bookmarksList.length === 0
                
                Rectangle {
                    width: units.gu(12)
                    height: units.gu(12)
                    radius: width / 2
                    color: bookmarksDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(6)
                        height: units.gu(6)
                        name: "bookmark"
                        color: bookmarksDialog.subtextColor
                    }
                }
                
                Label {
                    text: "No bookmarks yet"
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.DemiBold
                    color: bookmarksDialog.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Label {
                    text: "Tap the bookmark icon on any post\nto save it here for later"
                    font.pixelSize: units.gu(1.6)
                    color: bookmarksDialog.subtextColor
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            delegate: Rectangle {
                width: bookmarksListView.width
                height: units.gu(14)
                color: bookmarksDialog.cardColor
                
                // Clickable area
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("BookmarksDialog: Opening bookmarked meme:", modelData.title);
                        bookmarksDialog.memeSelected(modelData);
                        bookmarksDialog.close();
                    }
                }
                
                Row {
                    anchors.fill: parent
                    anchors.margins: units.gu(1.5)
                    spacing: units.gu(1.5)
                    
                    // Thumbnail
                    Rectangle {
                        width: units.gu(11)
                        height: units.gu(11)
                        radius: units.gu(1)
                        color: bookmarksDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                        
                        Image {
                            id: thumbnailImage
                            anchors.fill: parent
                            anchors.margins: units.gu(0.3)
                            source: modelData.image || ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready
                        }
                        
                        // Placeholder
                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(4)
                            height: units.gu(4)
                            name: "image-x-generic-symbolic"
                            color: bookmarksDialog.subtextColor
                            visible: thumbnailImage.status !== Image.Ready && modelData.image
                        }
                        
                        // Text post indicator
                        Rectangle {
                            anchors.fill: parent
                            radius: units.gu(1)
                            color: bookmarksDialog.accentColor
                            visible: !modelData.image || modelData.image === ""
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(4)
                                height: units.gu(4)
                                name: "note"
                                color: "white"
                            }
                        }
                    }
                    
                    // Content
                    Column {
                        width: parent.width - units.gu(17)
                        height: parent.height
                        spacing: units.gu(0.5)
                        
                        // Title
                        Label {
                            width: parent.width
                            text: modelData.title || "Untitled"
                            font.pixelSize: units.gu(1.7)
                            font.weight: Font.Medium
                            color: bookmarksDialog.textColor
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        
                        // Subreddit badge
                        Rectangle {
                            width: subredditLabel.width + units.gu(1.5)
                            height: units.gu(2.5)
                            radius: units.gu(0.5)
                            color: bookmarksDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                            
                            Label {
                                id: subredditLabel
                                anchors.centerIn: parent
                                text: "r/" + (modelData.subreddit || "unknown")
                                font.pixelSize: units.gu(1.3)
                                font.weight: Font.Medium
                                color: bookmarksDialog.accentColor
                            }
                        }
                        
                        // Stats row
                        Row {
                            spacing: units.gu(2)
                            
                            Row {
                                spacing: units.gu(0.5)
                                
                                Icon {
                                    width: units.gu(1.8)
                                    height: units.gu(1.8)
                                    name: "like"
                                    color: bookmarksDialog.subtextColor
                                }
                                
                                Label {
                                    text: formatNumber(modelData.upvotes || 0)
                                    font.pixelSize: units.gu(1.3)
                                    color: bookmarksDialog.subtextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            Row {
                                spacing: units.gu(0.5)
                                
                                Icon {
                                    width: units.gu(1.8)
                                    height: units.gu(1.8)
                                    name: "message"
                                    color: bookmarksDialog.subtextColor
                                }
                                
                                Label {
                                    text: formatNumber(modelData.comments || 0)
                                    font.pixelSize: units.gu(1.3)
                                    color: bookmarksDialog.subtextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                        
                        // Date saved
                        Label {
                            text: "Saved " + formatDate(modelData.dateBookmarked)
                            font.pixelSize: units.gu(1.2)
                            color: bookmarksDialog.subtextColor
                            opacity: 0.7
                        }
                    }
                    
                    // Remove button
                    Rectangle {
                        width: units.gu(4)
                        height: units.gu(4)
                        anchors.verticalCenter: parent.verticalCenter
                        radius: width / 2
                        color: removeArea.pressed ? "#40E53935" : "transparent"
                        
                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(2.2)
                            height: units.gu(2.2)
                            name: "close"
                            color: "#E53935"
                        }
                        
                        MouseArea {
                            id: removeArea
                            anchors.fill: parent
                            onClicked: {
                                console.log("BookmarksDialog: Removing bookmark for:", modelData.title);
                                bookmarksDialog.removeBookmark(modelData.id);
                            }
                        }
                    }
                }
                
                // Bottom divider
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(14)
                    anchors.right: parent.right
                    height: 1
                    color: bookmarksDialog.dividerColor
                }
            }
        }
    }
    
    // Clear all confirmation dialog
    QC2.Dialog {
        id: clearAllConfirmDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(parent.width * 0.85, units.gu(40))
        modal: true
        padding: 0
        
        background: Rectangle {
            color: bookmarksDialog.cardColor
            radius: units.gu(2)
        }
        
        contentItem: Column {
            spacing: units.gu(2)
            topPadding: units.gu(2.5)
            bottomPadding: units.gu(2.5)
            leftPadding: units.gu(2.5)
            rightPadding: units.gu(2.5)
            
            // Warning icon
            Rectangle {
                width: units.gu(8)
                height: units.gu(8)
                radius: width / 2
                color: "#20E53935"
                anchors.horizontalCenter: parent.horizontalCenter
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(4)
                    height: units.gu(4)
                    name: "dialog-warning-symbolic"
                    color: "#E53935"
                }
            }
            
            Label {
                text: "Clear All Bookmarks?"
                font.pixelSize: units.gu(2.2)
                font.weight: Font.DemiBold
                color: bookmarksDialog.textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Label {
                text: "This will remove all " + bookmarksDialog.bookmarksList.length + " saved posts. This action cannot be undone."
                font.pixelSize: units.gu(1.6)
                color: bookmarksDialog.subtextColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width - units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Buttons
            Row {
                spacing: units.gu(1.5)
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Cancel button
                Rectangle {
                    width: units.gu(14)
                    height: units.gu(5)
                    radius: units.gu(2.5)
                    color: cancelArea.pressed ? bookmarksDialog.dividerColor : (bookmarksDialog.darkMode ? "#2D2D2E" : "#F0F0F0")
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: units.gu(1.7)
                        font.weight: Font.Medium
                        color: bookmarksDialog.textColor
                    }
                    
                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        onClicked: clearAllConfirmDialog.close()
                    }
                }
                
                // Clear button
                Rectangle {
                    width: units.gu(14)
                    height: units.gu(5)
                    radius: units.gu(2.5)
                    color: clearConfirmArea.pressed ? "#C62828" : "#E53935"
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Clear All"
                        font.pixelSize: units.gu(1.7)
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                    MouseArea {
                        id: clearConfirmArea
                        anchors.fill: parent
                        onClicked: {
                            bookmarksDialog.clearAllBookmarks();
                            clearAllConfirmDialog.close();
                        }
                    }
                }
            }
        }
    }
    
    // Helper functions
    function formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + "M";
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + "k";
        }
        return num.toString();
    }
    
    function formatDate(dateStr) {
        if (!dateStr) return "";
        var date = new Date(dateStr);
        var now = new Date();
        var diff = now - date;
        var days = Math.floor(diff / (1000 * 60 * 60 * 24));
        
        if (days === 0) return "today";
        if (days === 1) return "yesterday";
        if (days < 7) return days + " days ago";
        if (days < 30) return Math.floor(days / 7) + " weeks ago";
        return Qt.formatDateTime(date, "MMM dd, yyyy");
    }
    
    function loadBookmarks(bookmarks) {
        bookmarksDialog.bookmarksList = bookmarks || [];
        console.log("BookmarksDialog: Loaded", bookmarksDialog.bookmarksList.length, "bookmarks");
    }
    
    function refreshBookmarks() {
        console.log("BookmarksDialog: Refreshing bookmarks list");
    }
}
