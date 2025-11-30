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
    id: subredditSelectionDialog
    
    // Properties
    property var categoryNames: []
    property var extendedCategoryMap: ({})
    property bool useCustomSubreddit: false
    property string selectedSubreddit: ""
    property bool darkMode: false
    
    // Theme colors
    readonly property color bgColor: darkMode ? "#0F0F0F" : "#F5F5F5"
    readonly property color cardColor: darkMode ? "#1A1A1B" : "#FFFFFF"
    readonly property color textColor: darkMode ? "#D7DADC" : "#1A1A1B"
    readonly property color subtextColor: darkMode ? "#818384" : "#787C7E"
    readonly property color accentColor: "#FF4500"
    readonly property color dividerColor: darkMode ? "#343536" : "#EDEFF1"
    readonly property color inputBgColor: darkMode ? "#272729" : "#F6F7F8"
    
    // Signals
    signal subredditSelected(string subreddit, bool isCustom)
    signal addToCollection(string subredditName)

    // Dialog settings
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
        color: subredditSelectionDialog.bgColor
    }
    
    contentItem: Item {
        anchors.fill: parent
        
        // Header
        Rectangle {
            id: headerBar
            width: parent.width
            height: units.gu(7)
            color: subredditSelectionDialog.cardColor
            z: 10
            
            // Shadow
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: units.gu(0.5)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: subredditSelectionDialog.darkMode ? "#40000000" : "#20000000" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            // Back/Close button
            Rectangle {
                width: units.gu(5)
                height: units.gu(5)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                color: backMouseArea.pressed ? subredditSelectionDialog.dividerColor : "transparent"
                radius: width / 2
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    name: "back" 
                    color: subredditSelectionDialog.textColor
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: subredditSelectionDialog.close()
                }
            }
            
            // Title
            Label {
                anchors.centerIn: parent
                text: "Select Subreddit"
                font.pixelSize: units.gu(2.2)
                font.weight: Font.DemiBold
                color: subredditSelectionDialog.textColor
            }
        }
        
        // Tab Bar
        Rectangle {
            id: tabBar
            anchors.top: headerBar.bottom
            width: parent.width
            height: units.gu(6)
            color: subredditSelectionDialog.cardColor
            
            Row {
                anchors.fill: parent
                
                // Categories Tab
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: "transparent"
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Categories"
                        font.pixelSize: units.gu(1.7)
                        font.weight: tabStack.currentIndex === 0 ? Font.DemiBold : Font.Normal
                        color: tabStack.currentIndex === 0 ? subredditSelectionDialog.accentColor : subredditSelectionDialog.subtextColor
                    }
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - units.gu(4)
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(0.4)
                        radius: height / 2
                        color: subredditSelectionDialog.accentColor
                        visible: tabStack.currentIndex === 0
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabStack.currentIndex = 0
                    }
                }
                
                // Custom Tab
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: "transparent"
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Custom"
                        font.pixelSize: units.gu(1.7)
                        font.weight: tabStack.currentIndex === 1 ? Font.DemiBold : Font.Normal
                        color: tabStack.currentIndex === 1 ? subredditSelectionDialog.accentColor : subredditSelectionDialog.subtextColor
                    }
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width - units.gu(4)
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(0.4)
                        radius: height / 2
                        color: subredditSelectionDialog.accentColor
                        visible: tabStack.currentIndex === 1
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabStack.currentIndex = 1
                    }
                }
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: subredditSelectionDialog.dividerColor
            }
        }
        
        // Content
        StackLayout {
            id: tabStack
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            currentIndex: 0
            
            // Categories List
            ListView {
                id: categoriesList
                clip: true
                model: subredditSelectionDialog.categoryNames
                
                delegate: Rectangle {
                    width: categoriesList.width
                    height: units.gu(7)
                    color: categoryMouseArea.pressed ? subredditSelectionDialog.dividerColor : subredditSelectionDialog.cardColor
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: units.gu(2)
                        anchors.rightMargin: units.gu(2)
                        spacing: units.gu(2)
                        
                        // Icon/Avatar placeholder
                        Rectangle {
                            width: units.gu(4.5)
                            height: units.gu(4.5)
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: {
                                var colors = ["#FF4500", "#0079D3", "#46D160", "#FF6B6B", "#9B59B6", "#3498DB"];
                                var index = modelData.charCodeAt(0) % colors.length;
                                return colors[index];
                            }
                            
                            Label {
                                anchors.centerIn: parent
                                text: modelData.charAt(0).toUpperCase()
                                font.pixelSize: units.gu(2)
                                font.weight: Font.Bold
                                color: "white"
                            }
                        }
                        
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: units.gu(0.2)
                            
                            Label {
                                text: modelData
                                font.pixelSize: units.gu(1.7)
                                font.weight: Font.Medium
                                color: subredditSelectionDialog.textColor
                            }
                            
                            Label {
                                text: "r/" + subredditSelectionDialog.extendedCategoryMap[modelData]
                                font.pixelSize: units.gu(1.4)
                                color: subredditSelectionDialog.subtextColor
                            }
                        }
                    }
                    
                    // Selected indicator
                    Icon {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        name: "tick"
                        color: subredditSelectionDialog.accentColor
                        visible: subredditSelectionDialog.extendedCategoryMap[modelData] === subredditSelectionDialog.selectedSubreddit && !subredditSelectionDialog.useCustomSubreddit
                    }
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(8.5)
                        anchors.right: parent.right
                        height: 1
                        color: subredditSelectionDialog.dividerColor
                    }
                    
                    MouseArea {
                        id: categoryMouseArea
                        anchors.fill: parent
                        onClicked: {
                            var subreddit = subredditSelectionDialog.extendedCategoryMap[modelData];
                            subredditSelectionDialog.subredditSelected(subreddit, false);
                            subredditSelectionDialog.close();
                        }
                    }
                }
            }
            
            // Custom Input
            Item {
                
                Column {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.8, units.gu(40))
                    spacing: units.gu(3)
                    
                    // Icon
                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: units.gu(8)
                        height: units.gu(8)
                        name: "edit"
                        color: subredditSelectionDialog.accentColor
                    }
                    
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Enter Subreddit Name"
                        font.pixelSize: units.gu(2.2)
                        font.weight: Font.DemiBold
                        color: subredditSelectionDialog.textColor
                    }
                    
                    // Input Field
                    Rectangle {
                        width: parent.width
                        height: units.gu(6)
                        radius: units.gu(1)
                        color: subredditSelectionDialog.inputBgColor
                        border.width: customInput.activeFocus ? 2 : 0
                        border.color: subredditSelectionDialog.accentColor
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.gu(1.5)
                            spacing: units.gu(1)
                            
                            Label {
                                text: "r/"
                                font.pixelSize: units.gu(1.8)
                                color: subredditSelectionDialog.subtextColor
                                font.weight: Font.Bold
                            }
                            
                            TextInput {
                                id: customInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.gu(1.8)
                                color: subredditSelectionDialog.textColor
                                verticalAlignment: TextInput.AlignVCenter
                                selectByMouse: true
                                
                                onTextChanged: {
                                    var cleanText = text.replace(/[^a-zA-Z0-9_]/g, '');
                                    if (cleanText !== text) {
                                        text = cleanText;
                                    }
                                }
                                
                                Keys.onReturnPressed: goButtonRect.enabled ? goButtonArea.clicked(null) : null
                                Keys.onEnterPressed: goButtonRect.enabled ? goButtonArea.clicked(null) : null
                            }
                        }
                    }
                    
                    // Buttons
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: units.gu(2)
                        
                        // Add to Collection Button
                        Rectangle {
                            width: units.gu(6)
                            height: units.gu(6)
                            radius: width / 2
                            color: addToCollectionArea.pressed ? subredditSelectionDialog.dividerColor : subredditSelectionDialog.inputBgColor
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(3)
                                height: units.gu(3)
                                name: "add"
                                color: subredditSelectionDialog.textColor
                            }
                            
                            MouseArea {
                                id: addToCollectionArea
                                anchors.fill: parent
                                onClicked: {
                                    var text = customInput.text.trim();
                                    if (text.length > 0) {
                                        subredditSelectionDialog.addToCollection(text);
                                        // Show feedback?
                                    }
                                }
                            }
                        }
                        
                        // Go Button
                        Rectangle {
                            id: goButtonRect
                            width: units.gu(16)
                            height: units.gu(6)
                            radius: units.gu(3)
                            color: goButtonArea.pressed ? "#C23D00" : subredditSelectionDialog.accentColor
                            opacity: customInput.text.trim().length > 0 ? 1.0 : 0.5
                            enabled: customInput.text.trim().length > 0
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Go"
                                font.pixelSize: units.gu(1.8)
                                font.weight: Font.Bold
                                color: "white"
                            }
                            
                            MouseArea {
                                id: goButtonArea
                                anchors.fill: parent
                                onClicked: {
                                    var text = customInput.text.trim();
                                    if (text.length > 0) {
                                        subredditSelectionDialog.subredditSelected(text, true);
                                        subredditSelectionDialog.close();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    onOpened: {
        if (useCustomSubreddit) {
            tabStack.currentIndex = 1;
            customInput.text = selectedSubreddit;
        } else {
            tabStack.currentIndex = 0;
            customInput.text = "";
        }
    }
}
