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
    id: defaultSubredditsDialog
    modal: true
    focus: true
    
    width: Math.min(parent.width * 0.9, units.gu(60))
    height: Math.min(parent.height * 0.8, units.gu(60))
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    title: "Manage Default Subreddits"
    
    // Properties
    property var categoryMap: ({})
    property var hiddenSubreddits: []
    property bool darkMode: false
    
    // Signals
    signal hideSubreddit(string subredditName)
    signal unhideSubreddit(string subredditName)
    signal restoreAllDefaults()
    
    background: Rectangle {
        color: defaultSubredditsDialog.darkMode ? "#2D2D2D" : theme.palette.normal.background
        radius: units.gu(1)
    }
    
    header: Rectangle {
        width: parent.width
        height: units.gu(6)
        color: defaultSubredditsDialog.darkMode ? "#1A1A1A" : "#F5F5F5"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: units.gu(1)
            spacing: units.gu(1)
            
            Label {
                text: "Default Subreddits"
                font.bold: true
                Layout.fillWidth: true
                color: defaultSubredditsDialog.darkMode ? "#FFFFFF" : "#000000"
            }
            
            Button {
                text: "Restore All"
                visible: defaultSubredditsDialog.hiddenSubreddits.length > 0
                onClicked: {
                    restoreAllConfirmDialog.open();
                }
            }
            
            Button {
                text: "Close"
                onClicked: defaultSubredditsDialog.close()
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        spacing: units.gu(1)
        
        Label {
            text: "Manage the built-in subreddits. Hidden subreddits won't appear in selection lists."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: defaultSubredditsDialog.darkMode ? "#AAAAAA" : "#666666"
            font.pixelSize: units.gu(1.5)
        }
        
        // Tabs for Active and Hidden
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            
            TabButton {
                text: "Active (" + getActiveCount() + ")"
            }
            TabButton {
                text: "Hidden (" + defaultSubredditsDialog.hiddenSubreddits.length + ")"
            }
        }
        
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            
            // Active Subreddits Tab
            ScrollView {
                clip: true
                
                ListView {
                    id: activeListView
                    model: getActiveSubreddits()
                    spacing: units.gu(0.5)
                    
                    delegate: Rectangle {
                        width: activeListView.width
                        height: units.gu(6)
                        color: defaultSubredditsDialog.darkMode ? "#3D3D3D" : "#FFFFFF"
                        border.color: defaultSubredditsDialog.darkMode ? "#555555" : "#E0E0E0"
                        border.width: 1
                        radius: units.gu(0.5)
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.gu(1)
                            spacing: units.gu(1)
                            
                            Column {
                                Layout.fillWidth: true
                                spacing: units.gu(0.2)
                                
                                Label {
                                    text: modelData.displayName
                                    font.bold: true
                                    color: defaultSubredditsDialog.darkMode ? "#FFFFFF" : "#000000"
                                }
                                
                                Label {
                                    text: "r/" + modelData.subredditName
                                    font.pixelSize: units.gu(1.5)
                                    color: defaultSubredditsDialog.darkMode ? "#AAAAAA" : "#666666"
                                }
                            }
                            
                            Button {
                                text: "Hide"
                                Layout.preferredWidth: units.gu(10)
                                onClicked: {
                                    console.log("DefaultSubredditsDialog: Hiding subreddit:", modelData.subredditName);
                                    defaultSubredditsDialog.hideSubreddit(modelData.subredditName);
                                }
                            }
                        }
                    }
                    
                    Label {
                        anchors.centerIn: parent
                        text: "All default subreddits are hidden.\nUse 'Restore All' to bring them back."
                        horizontalAlignment: Text.AlignHCenter
                        color: defaultSubredditsDialog.darkMode ? "#AAAAAA" : "#666666"
                        visible: activeListView.count === 0
                    }
                }
            }
            
            // Hidden Subreddits Tab
            ScrollView {
                clip: true
                
                ListView {
                    id: hiddenListView
                    model: getHiddenSubreddits()
                    spacing: units.gu(0.5)
                    
                    delegate: Rectangle {
                        width: hiddenListView.width
                        height: units.gu(6)
                        color: defaultSubredditsDialog.darkMode ? "#3D3D3D" : "#FFFFFF"
                        border.color: defaultSubredditsDialog.darkMode ? "#555555" : "#E0E0E0"
                        border.width: 1
                        radius: units.gu(0.5)
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.gu(1)
                            spacing: units.gu(1)
                            
                            Column {
                                Layout.fillWidth: true
                                spacing: units.gu(0.2)
                                
                                Label {
                                    text: modelData.displayName
                                    font.bold: true
                                    color: defaultSubredditsDialog.darkMode ? "#FFFFFF" : "#000000"
                                }
                                
                                Label {
                                    text: "r/" + modelData.subredditName + " (Hidden)"
                                    font.pixelSize: units.gu(1.5)
                                    color: defaultSubredditsDialog.darkMode ? "#AAAAAA" : "#666666"
                                }
                            }
                            
                            Button {
                                text: "Restore"
                                Layout.preferredWidth: units.gu(10)
                                onClicked: {
                                    console.log("DefaultSubredditsDialog: Restoring subreddit:", modelData.subredditName);
                                    defaultSubredditsDialog.unhideSubreddit(modelData.subredditName);
                                }
                            }
                        }
                    }
                    
                    Label {
                        anchors.centerIn: parent
                        text: "No hidden subreddits.\nAll default subreddits are active."
                        horizontalAlignment: Text.AlignHCenter
                        color: defaultSubredditsDialog.darkMode ? "#AAAAAA" : "#666666"
                        visible: hiddenListView.count === 0
                    }
                }
            }
        }
    }
    
    // Restore all confirmation dialog
    Dialog {
        id: restoreAllConfirmDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: units.gu(35)
        height: units.gu(18)
        modal: true
        title: "Restore All Subreddits"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: units.gu(1)
            spacing: units.gu(2)
            
            Label {
                text: "Are you sure you want to restore all hidden default subreddits?"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                color: defaultSubredditsDialog.darkMode ? "#FFFFFF" : "#000000"
            }
            
            RowLayout {
                spacing: units.gu(1)
                Layout.alignment: Qt.AlignHCenter
                
                Button {
                    text: "Cancel"
                    onClicked: restoreAllConfirmDialog.close()
                }
                
                Button {
                    text: "Restore All"
                    highlighted: true
                    onClicked: {
                        defaultSubredditsDialog.restoreAllDefaults();
                        restoreAllConfirmDialog.close();
                    }
                }
            }
        }
    }
    
    // Functions
    function getActiveSubreddits() {
        var activeList = [];
        for (var category in defaultSubredditsDialog.categoryMap) {
            var subredditName = defaultSubredditsDialog.categoryMap[category];
            if (defaultSubredditsDialog.hiddenSubreddits.indexOf(subredditName) === -1) {
                activeList.push({
                    displayName: category,
                    subredditName: subredditName
                });
            }
        }
        return activeList;
    }
    
    function getHiddenSubreddits() {
        var hiddenList = [];
        for (var category in defaultSubredditsDialog.categoryMap) {
            var subredditName = defaultSubredditsDialog.categoryMap[category];
            if (defaultSubredditsDialog.hiddenSubreddits.indexOf(subredditName) >= 0) {
                hiddenList.push({
                    displayName: category,
                    subredditName: subredditName
                });
            }
        }
        return hiddenList;
    }
    
    function getActiveCount() {
        var count = 0;
        for (var category in defaultSubredditsDialog.categoryMap) {
            var subredditName = defaultSubredditsDialog.categoryMap[category];
            if (defaultSubredditsDialog.hiddenSubreddits.indexOf(subredditName) === -1) {
                count++;
            }
        }
        return count;
    }
    
    function refreshLists() {
        // Trigger model refresh
        activeListView.model = getActiveSubreddits();
        hiddenListView.model = getHiddenSubreddits();
    }
}
