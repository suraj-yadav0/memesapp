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
    id: manageSubredditsDialog
    modal: true
    focus: true
    standardButtons: Dialog.Close
    
    width: Math.min(parent.width * 0.9, units.gu(60))
    height: Math.min(parent.height * 0.8, units.gu(50))
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    title: "Manage My Subreddit Collection"
    
    // Properties
    property var customSubreddits: []
    
    // Signals
    signal toggleFavorite(string subredditName)
    signal useSubreddit(string subredditName)
    signal removeSubreddit(string subredditName)
    
    background: Rectangle {
        color: theme.palette.normal.background
        radius: units.gu(1)
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(1)
        
        Text {
            text: "Your Custom Subreddits (" + manageSubredditsDialog.customSubreddits.length + ")"
            font.bold: true
            color: theme.palette.normal.backgroundText
            Layout.fillWidth: true
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ListView {
                id: customSubredditsListView
                model: manageSubredditsDialog.customSubreddits
                spacing: units.gu(0.5)
                
                delegate: Rectangle {
                    width: customSubredditsListView.width
                    height: units.gu(6)
                    color: theme.palette.normal.background
                    border.color: theme.palette.normal.base
                    border.width: 1
                    radius: 4
                    
                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: units.gu(1)
                        spacing: units.gu(1)
                        
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - buttonRow.width - parent.spacing
                            
                            Text {
                                text: modelData.displayName + (modelData.isFavorite ? " ⭐" : "")
                                font.bold: true
                                color: theme.palette.normal.backgroundText
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Text {
                                text: "r/" + modelData.subredditName + " • Used " + modelData.usageCount + " times"
                                font.pixelSize: units.gu(1.2)
                                color: theme.palette.normal.backgroundSecondaryText
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                        
                        Row {
                            id: buttonRow
                            spacing: units.gu(0.5)
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Button {
                                text: modelData.isFavorite ? "★" : "☆"
                                width: units.gu(4)
                                height: units.gu(4)
                                onClicked: {
                                    console.log("ManageSubredditsDialog: Toggling favorite for:", modelData.subredditName);
                                    manageSubredditsDialog.toggleFavorite(modelData.subredditName);
                                }
                            }
                            
                            Button {
                                text: "Use"
                                width: units.gu(6)
                                height: units.gu(4)
                                onClicked: {
                                    console.log("ManageSubredditsDialog: Using custom subreddit:", modelData.subredditName);
                                    manageSubredditsDialog.useSubreddit(modelData.subredditName);
                                }
                            }
                            
                            Button {
                                text: "✕"
                                width: units.gu(4)
                                height: units.gu(4)
                                onClicked: {
                                    console.log("ManageSubredditsDialog: Removing custom subreddit:", modelData.subredditName);
                                    manageSubredditsDialog.removeSubreddit(modelData.subredditName);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        Text {
            text: manageSubredditsDialog.customSubreddits.length === 0 ? 
                  "No custom subreddits saved yet. Use 'Select Subreddit' → 'Custom Subreddit' → 'Add to My Collection' to save subreddits." :
                  "Tip: ⭐ Mark favorites to show them at the top of the list."
            font.pixelSize: units.gu(1.2)
            color: theme.palette.normal.backgroundSecondaryText
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignCenter
        }
    }
}