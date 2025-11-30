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
    id: defaultSubredditsDialog
    
    // Properties
    property var categoryMap: ({})
    property var hiddenSubreddits: []
    property bool darkMode: false
    
    // Theme colors
    readonly property color bgColor: darkMode ? "#0F0F0F" : "#F5F5F5"
    readonly property color cardColor: darkMode ? "#1A1A1B" : "#FFFFFF"
    readonly property color textColor: darkMode ? "#D7DADC" : "#1A1A1B"
    readonly property color subtextColor: darkMode ? "#818384" : "#787C7E"
    readonly property color accentColor: "#FF4500"
    readonly property color dividerColor: darkMode ? "#343536" : "#EDEFF1"
    
    // Signals
    signal hideSubreddit(string subredditName)
    signal unhideSubreddit(string subredditName)
    signal restoreAllDefaults()
    
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
        color: defaultSubredditsDialog.bgColor
    }
    
    contentItem: Item {
        anchors.fill: parent
        
        // Header
        Rectangle {
            id: headerBar
            width: parent.width
            height: units.gu(7)
            color: defaultSubredditsDialog.cardColor
            z: 10
            
            // Shadow
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: units.gu(0.5)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: defaultSubredditsDialog.darkMode ? "#40000000" : "#20000000" }
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
                color: backMouseArea.pressed ? defaultSubredditsDialog.dividerColor : "transparent"
                radius: width / 2
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    name: "back"
                    color: defaultSubredditsDialog.textColor
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: defaultSubredditsDialog.close()
                }
            }
            
            // Title
            Label {
                anchors.centerIn: parent
                text: "Default Subreddits"
                font.pixelSize: units.gu(2.2)
                font.weight: Font.DemiBold
                color: defaultSubredditsDialog.textColor
            }
            
            // Restore All button
            Rectangle {
                height: units.gu(4)
                width: restoreLabel.width + units.gu(2)
                anchors.right: parent.right
                anchors.rightMargin: units.gu(1.5)
                anchors.verticalCenter: parent.verticalCenter
                color: restoreMouseArea.pressed ? "#C23D00" : defaultSubredditsDialog.accentColor
                radius: units.gu(2)
                visible: defaultSubredditsDialog.hiddenSubreddits.length > 0
                
                Label {
                    id: restoreLabel
                    anchors.centerIn: parent
                    text: "Restore"
                    font.pixelSize: units.gu(1.5)
                    font.weight: Font.Medium
                    color: "white"
                }
                
                MouseArea {
                    id: restoreMouseArea
                    anchors.fill: parent
                    onClicked: restoreAllConfirmDialog.open()
                }
            }
        }
        
        // Tab bar
        Rectangle {
            id: tabBar
            anchors.top: headerBar.bottom
            width: parent.width
            height: units.gu(6)
            color: defaultSubredditsDialog.cardColor
            
            Row {
                anchors.fill: parent
                
                // Active tab
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: "transparent"
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.5)
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: units.gu(0.5)
                            
                            Label {
                                text: "Active"
                                font.pixelSize: units.gu(1.7)
                                font.weight: tabStack.currentIndex === 0 ? Font.DemiBold : Font.Normal
                                color: tabStack.currentIndex === 0 ? defaultSubredditsDialog.accentColor : defaultSubredditsDialog.subtextColor
                            }
                            
                            Rectangle {
                                width: activeCountLabel.width + units.gu(1)
                                height: units.gu(2.2)
                                radius: height / 2
                                color: tabStack.currentIndex === 0 ? defaultSubredditsDialog.accentColor : (defaultSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0")
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Label {
                                    id: activeCountLabel
                                    anchors.centerIn: parent
                                    text: getActiveCount().toString()
                                    font.pixelSize: units.gu(1.2)
                                    font.weight: Font.Medium
                                    color: tabStack.currentIndex === 0 ? "white" : defaultSubredditsDialog.subtextColor
                                }
                            }
                        }
                    }
                    
                    // Active indicator
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - units.gu(4)
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(0.4)
                        radius: height / 2
                        color: defaultSubredditsDialog.accentColor
                        visible: tabStack.currentIndex === 0
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabStack.currentIndex = 0
                    }
                }
                
                // Hidden tab
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: "transparent"
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.5)
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: units.gu(0.5)
                            
                            Label {
                                text: "Hidden"
                                font.pixelSize: units.gu(1.7)
                                font.weight: tabStack.currentIndex === 1 ? Font.DemiBold : Font.Normal
                                color: tabStack.currentIndex === 1 ? defaultSubredditsDialog.accentColor : defaultSubredditsDialog.subtextColor
                            }
                            
                            Rectangle {
                                width: hiddenCountLabel.width + units.gu(1)
                                height: units.gu(2.2)
                                radius: height / 2
                                color: tabStack.currentIndex === 1 ? defaultSubredditsDialog.accentColor : (defaultSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0")
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Label {
                                    id: hiddenCountLabel
                                    anchors.centerIn: parent
                                    text: defaultSubredditsDialog.hiddenSubreddits.length.toString()
                                    font.pixelSize: units.gu(1.2)
                                    font.weight: Font.Medium
                                    color: tabStack.currentIndex === 1 ? "white" : defaultSubredditsDialog.subtextColor
                                }
                            }
                        }
                    }
                    
                    // Active indicator
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - units.gu(4)
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(0.4)
                        radius: height / 2
                        color: defaultSubredditsDialog.accentColor
                        visible: tabStack.currentIndex === 1
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabStack.currentIndex = 1
                    }
                }
            }
            
            // Divider
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: defaultSubredditsDialog.dividerColor
            }
        }
        
        // Content stack
        StackLayout {
            id: tabStack
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            currentIndex: 0
            
            // Active subreddits
            ListView {
                id: activeListView
                clip: true
                spacing: 0
                model: getActiveSubreddits()
                
                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(2)
                    visible: activeListView.count === 0
                    
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(12)
                        radius: width / 2
                        color: defaultSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(6)
                            height: units.gu(6)
                            name: "view-off"
                            color: defaultSubredditsDialog.subtextColor
                        }
                    }
                    
                    Label {
                        text: "All subreddits hidden"
                        font.pixelSize: units.gu(2)
                        font.weight: Font.DemiBold
                        color: defaultSubredditsDialog.textColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Label {
                        text: "Tap 'Restore' to bring them back"
                        font.pixelSize: units.gu(1.5)
                        color: defaultSubredditsDialog.subtextColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                
                delegate: Rectangle {
                    width: activeListView.width
                    height: units.gu(8)
                    color: defaultSubredditsDialog.cardColor
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: units.gu(2)
                        anchors.rightMargin: units.gu(2)
                        spacing: units.gu(1.5)
                        
                        // Avatar
                        Rectangle {
                            width: units.gu(5)
                            height: units.gu(5)
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: {
                                var colors = ["#FF4500", "#0079D3", "#46D160", "#FF6B6B", "#9B59B6", "#3498DB"];
                                var index = modelData.subredditName.charCodeAt(0) % colors.length;
                                return colors[index];
                            }
                            
                            Label {
                                anchors.centerIn: parent
                                text: modelData.displayName.charAt(0).toUpperCase()
                                font.pixelSize: units.gu(2)
                                font.weight: Font.Bold
                                color: "white"
                            }
                        }
                        
                        // Text
                        Column {
                            width: parent.width - units.gu(16)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: units.gu(0.2)
                            
                            Label {
                                text: modelData.displayName
                                font.pixelSize: units.gu(1.7)
                                font.weight: Font.Medium
                                color: defaultSubredditsDialog.textColor
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Label {
                                text: "r/" + modelData.subredditName
                                font.pixelSize: units.gu(1.4)
                                color: defaultSubredditsDialog.subtextColor
                            }
                        }
                        
                        // Hide button
                        Rectangle {
                            width: units.gu(8)
                            height: units.gu(4)
                            anchors.verticalCenter: parent.verticalCenter
                            radius: units.gu(2)
                            color: hideArea.pressed ? defaultSubredditsDialog.dividerColor : (defaultSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0")
                            border.width: 1
                            border.color: defaultSubredditsDialog.dividerColor
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Hide"
                                font.pixelSize: units.gu(1.5)
                                font.weight: Font.Medium
                                color: defaultSubredditsDialog.textColor
                            }
                            
                            MouseArea {
                                id: hideArea
                                anchors.fill: parent
                                onClicked: {
                                    console.log("DefaultSubredditsDialog: Hiding subreddit:", modelData.subredditName);
                                    defaultSubredditsDialog.hideSubreddit(modelData.subredditName);
                                }
                            }
                        }
                    }
                    
                    // Divider
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(9)
                        anchors.right: parent.right
                        height: 1
                        color: defaultSubredditsDialog.dividerColor
                    }
                }
            }
            
            // Hidden subreddits
            ListView {
                id: hiddenListView
                clip: true
                spacing: 0
                model: getHiddenSubreddits()
                
                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(2)
                    visible: hiddenListView.count === 0
                    
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(12)
                        radius: width / 2
                        color: "#2046D160"
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(6)
                            height: units.gu(6)
                            name: "tick"
                            color: "#46D160"
                        }
                    }
                    
                    Label {
                        text: "All subreddits active"
                        font.pixelSize: units.gu(2)
                        font.weight: Font.DemiBold
                        color: defaultSubredditsDialog.textColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Label {
                        text: "No hidden subreddits"
                        font.pixelSize: units.gu(1.5)
                        color: defaultSubredditsDialog.subtextColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                
                delegate: Rectangle {
                    width: hiddenListView.width
                    height: units.gu(8)
                    color: defaultSubredditsDialog.cardColor
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: units.gu(2)
                        anchors.rightMargin: units.gu(2)
                        spacing: units.gu(1.5)
                        
                        // Avatar (greyed out)
                        Rectangle {
                            width: units.gu(5)
                            height: units.gu(5)
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: defaultSubredditsDialog.darkMode ? "#2D2D2E" : "#E0E0E0"
                            
                            Label {
                                anchors.centerIn: parent
                                text: modelData.displayName.charAt(0).toUpperCase()
                                font.pixelSize: units.gu(2)
                                font.weight: Font.Bold
                                color: defaultSubredditsDialog.subtextColor
                            }
                        }
                        
                        // Text
                        Column {
                            width: parent.width - units.gu(16)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: units.gu(0.2)
                            
                            Label {
                                text: modelData.displayName
                                font.pixelSize: units.gu(1.7)
                                font.weight: Font.Medium
                                color: defaultSubredditsDialog.subtextColor
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Label {
                                text: "r/" + modelData.subredditName + " • Hidden"
                                font.pixelSize: units.gu(1.4)
                                color: defaultSubredditsDialog.subtextColor
                                opacity: 0.7
                            }
                        }
                        
                        // Restore button
                        Rectangle {
                            width: units.gu(8)
                            height: units.gu(4)
                            anchors.verticalCenter: parent.verticalCenter
                            radius: units.gu(2)
                            color: restoreArea.pressed ? "#3D9E50" : "#46D160"
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Restore"
                                font.pixelSize: units.gu(1.5)
                                font.weight: Font.Medium
                                color: "white"
                            }
                            
                            MouseArea {
                                id: restoreArea
                                anchors.fill: parent
                                onClicked: {
                                    console.log("DefaultSubredditsDialog: Restoring subreddit:", modelData.subredditName);
                                    defaultSubredditsDialog.unhideSubreddit(modelData.subredditName);
                                }
                            }
                        }
                    }
                    
                    // Divider
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(9)
                        anchors.right: parent.right
                        height: 1
                        color: defaultSubredditsDialog.dividerColor
                    }
                }
            }
        }
    }
    
    // Restore all confirmation dialog
    QC2.Dialog {
        id: restoreAllConfirmDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(parent.width * 0.85, units.gu(40))
        modal: true
        padding: 0
        
        background: Rectangle {
            color: defaultSubredditsDialog.cardColor
            radius: units.gu(2)
        }
        
        contentItem: Column {
            spacing: units.gu(2)
            topPadding: units.gu(2.5)
            bottomPadding: units.gu(2.5)
            leftPadding: units.gu(2.5)
            rightPadding: units.gu(2.5)
            
            // Icon
            Rectangle {
                width: units.gu(8)
                height: units.gu(8)
                radius: width / 2
                color: "#2046D160"
                anchors.horizontalCenter: parent.horizontalCenter
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(4)
                    height: units.gu(4)
                    name: "undo"
                    color: "#46D160"
                }
            }
            
            Label {
                text: "Restore All Subreddits?"
                font.pixelSize: units.gu(2.2)
                font.weight: Font.DemiBold
                color: defaultSubredditsDialog.textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Label {
                text: "This will restore all " + defaultSubredditsDialog.hiddenSubreddits.length + " hidden subreddits back to the active list."
                font.pixelSize: units.gu(1.6)
                color: defaultSubredditsDialog.subtextColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width - units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Buttons
            Row {
                spacing: units.gu(1.5)
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    width: units.gu(14)
                    height: units.gu(5)
                    radius: units.gu(2.5)
                    color: cancelArea.pressed ? defaultSubredditsDialog.dividerColor : (defaultSubredditsDialog.darkMode ? "#2D2D2E" : "#F0F0F0")
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: units.gu(1.7)
                        font.weight: Font.Medium
                        color: defaultSubredditsDialog.textColor
                    }
                    
                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        onClicked: restoreAllConfirmDialog.close()
                    }
                }
                
                Rectangle {
                    width: units.gu(14)
                    height: units.gu(5)
                    radius: units.gu(2.5)
                    color: confirmArea.pressed ? "#3D9E50" : "#46D160"
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Restore All"
                        font.pixelSize: units.gu(1.7)
                        font.weight: Font.Medium
                        color: "white"
                    }
                    
                    MouseArea {
                        id: confirmArea
                        anchors.fill: parent
                        onClicked: {
                            defaultSubredditsDialog.restoreAllDefaults();
                            restoreAllConfirmDialog.close();
                        }
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
        activeListView.model = getActiveSubreddits();
        hiddenListView.model = getHiddenSubreddits();
    }
}
