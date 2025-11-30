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
    id: manageSubredditsDialog
    
    // Properties
    property var customSubreddits: []
    property bool darkMode: false
    
    // Theme colors
    readonly property color bgColor: darkMode ? "#0F0F0F" : "#F5F5F5"
    readonly property color cardColor: darkMode ? "#1A1A1B" : "#FFFFFF"
    readonly property color textColor: darkMode ? "#D7DADC" : "#1A1A1B"
    readonly property color subtextColor: darkMode ? "#818384" : "#787C7E"
    readonly property color accentColor: "#FF4500"
    readonly property color dividerColor: darkMode ? "#343536" : "#EDEFF1"
    
    // Signals
    signal toggleFavorite(string subredditName)
    signal useSubreddit(string subredditName)
    signal removeSubreddit(string subredditName)
    
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
        color: manageSubredditsDialog.bgColor
    }
    
    contentItem: Item {
        anchors.fill: parent
        
        // Header
        Rectangle {
            id: headerBar
            width: parent.width
            height: units.gu(7)
            color: manageSubredditsDialog.cardColor
            z: 10
            
            // Shadow
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: units.gu(0.5)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: manageSubredditsDialog.darkMode ? "#40000000" : "#20000000" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            // Back button
            Rectangle {
                width: units.gu(5)
                height: units.gu(5)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                color: backMouseArea.pressed ? manageSubredditsDialog.dividerColor : "transparent"
                radius: width / 2
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    name: "back"
                    color: manageSubredditsDialog.textColor
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: manageSubredditsDialog.close()
                }
            }
            
            // Title with count
            Column {
                anchors.centerIn: parent
                spacing: units.gu(0.2)
                
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "My Subreddits"
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.DemiBold
                    color: manageSubredditsDialog.textColor
                }
                
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: manageSubredditsDialog.customSubreddits.length + " custom feeds"
                    font.pixelSize: units.gu(1.3)
                    color: manageSubredditsDialog.subtextColor
                    visible: manageSubredditsDialog.customSubreddits.length > 0
                }
            }
        }
        
        // Content
        ListView {
            id: subredditsListView
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: units.gu(1)
            clip: true
            spacing: 0
            
            model: manageSubredditsDialog.customSubreddits
            
            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: units.gu(2)
                visible: manageSubredditsDialog.customSubreddits.length === 0
                
                Rectangle {
                    width: units.gu(12)
                    height: units.gu(12)
                    radius: width / 2
                    color: manageSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(6)
                        height: units.gu(6)
                        name: "add"
                        color: manageSubredditsDialog.subtextColor
                    }
                }
                
                Label {
                    text: "No custom subreddits"
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.DemiBold
                    color: manageSubredditsDialog.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Label {
                    text: "Add subreddits from the feed selector\nto save them to your collection"
                    font.pixelSize: units.gu(1.6)
                    color: manageSubredditsDialog.subtextColor
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            delegate: Rectangle {
                width: subredditsListView.width
                height: units.gu(9)
                color: manageSubredditsDialog.cardColor
                
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: units.gu(2)
                    anchors.rightMargin: units.gu(1.5)
                    spacing: units.gu(1.5)
                    
                    // Subreddit avatar
                    Rectangle {
                        width: units.gu(6)
                        height: units.gu(6)
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: {
                            // Generate color from name
                            var colors = ["#FF4500", "#0079D3", "#46D160", "#FF6B6B", "#9B59B6", "#3498DB", "#E74C3C", "#1ABC9C"];
                            var index = modelData.subredditName.charCodeAt(0) % colors.length;
                            return colors[index];
                        }
                        
                        Label {
                            anchors.centerIn: parent
                            text: (modelData.displayName || modelData.subredditName).charAt(0).toUpperCase()
                            font.pixelSize: units.gu(2.5)
                            font.weight: Font.Bold
                            color: "white"
                        }
                        
                        // Favorite star
                        Rectangle {
                            width: units.gu(2.2)
                            height: units.gu(2.2)
                            radius: width / 2
                            color: "#FFD700"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: modelData.isFavorite
                            
                            Label {
                                anchors.centerIn: parent
                                text: "★"
                                font.pixelSize: units.gu(1.3)
                                color: "white"
                            }
                        }
                    }
                    
                    // Text content
                    Column {
                        width: parent.width - units.gu(22)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(0.3)
                        
                        Label {
                            text: modelData.displayName || modelData.subredditName
                            font.pixelSize: units.gu(1.8)
                            font.weight: Font.Medium
                            color: manageSubredditsDialog.textColor
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        
                        Label {
                            text: "r/" + modelData.subredditName + " • " + (modelData.usageCount || 0) + " visits"
                            font.pixelSize: units.gu(1.4)
                            color: manageSubredditsDialog.subtextColor
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                    
                    // Action buttons
                    Row {
                        spacing: units.gu(0.8)
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // Favorite button
                        Rectangle {
                            width: units.gu(4.5)
                            height: units.gu(4.5)
                            radius: units.gu(1)
                            color: favArea.pressed ? manageSubredditsDialog.dividerColor : (manageSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0")
                            
                            Label {
                                anchors.centerIn: parent
                                text: modelData.isFavorite ? "★" : "☆"
                                font.pixelSize: units.gu(2.2)
                                color: modelData.isFavorite ? "#FFD700" : manageSubredditsDialog.subtextColor
                            }
                            
                            MouseArea {
                                id: favArea
                                anchors.fill: parent
                                onClicked: {
                                    console.log("ManageSubredditsDialog: Toggling favorite for:", modelData.subredditName);
                                    manageSubredditsDialog.toggleFavorite(modelData.subredditName);
                                }
                            }
                        }
                        
                        // Use button
                        Rectangle {
                            width: units.gu(7)
                            height: units.gu(4.5)
                            radius: units.gu(1)
                            color: useArea.pressed ? "#C23D00" : manageSubredditsDialog.accentColor
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Open"
                                font.pixelSize: units.gu(1.5)
                                font.weight: Font.Medium
                                color: "white"
                            }
                            
                            MouseArea {
                                id: useArea
                                anchors.fill: parent
                                onClicked: {
                                    console.log("ManageSubredditsDialog: Using custom subreddit:", modelData.subredditName);
                                    manageSubredditsDialog.useSubreddit(modelData.subredditName);
                                    manageSubredditsDialog.close();
                                }
                            }
                        }
                        
                        // Remove button
                        Rectangle {
                            width: units.gu(4.5)
                            height: units.gu(4.5)
                            radius: units.gu(1)
                            color: removeArea.pressed ? "#40E53935" : "transparent"
                            border.width: 1
                            border.color: "#E53935"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2)
                                height: units.gu(2)
                                name: "delete"
                                color: "#E53935"
                            }
                            
                            MouseArea {
                                id: removeArea
                                anchors.fill: parent
                                onClicked: {
                                    console.log("ManageSubredditsDialog: Removing custom subreddit:", modelData.subredditName);
                                    manageSubredditsDialog.removeSubreddit(modelData.subredditName);
                                }
                            }
                        }
                    }
                }
                
                // Bottom divider
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(10)
                    anchors.right: parent.right
                    height: 1
                    color: manageSubredditsDialog.dividerColor
                }
            }
            
            // Footer tip
            footer: Item {
                width: parent.width
                height: units.gu(8)
                visible: manageSubredditsDialog.customSubreddits.length > 0
                
                Label {
                    anchors.centerIn: parent
                    width: parent.width - units.gu(4)
                    text: "★ Tap the star to mark favorites - they'll appear at the top"
                    font.pixelSize: units.gu(1.4)
                    color: manageSubredditsDialog.subtextColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
