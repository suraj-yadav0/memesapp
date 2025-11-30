/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
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
    id: settingsDialog
    
    // Properties
    property bool darkMode: false
    property string currentSubreddit: ""
    property int totalMemesLoaded: 0
    property string appVersion: "1.0.0"
    
    // Theme colors
    readonly property color bgColor: darkMode ? "#0F0F0F" : "#F5F5F5"
    readonly property color cardColor: darkMode ? "#1A1A1B" : "#FFFFFF"
    readonly property color textColor: darkMode ? "#D7DADC" : "#1A1A1B"
    readonly property color subtextColor: darkMode ? "#818384" : "#787C7E"
    readonly property color accentColor: "#FF4500"
    readonly property color dividerColor: darkMode ? "#343536" : "#EDEFF1"
    
    // Signals
    signal darkModeToggled(bool enabled)
    signal clearBookmarksRequested()
    signal clearCacheRequested()
    
    // Dialog Geometry - Full screen style
    x: 0
    y: 0
    width: parent.width
    height: parent.height
    
    modal: true
    focus: true
    padding: 0
    margins: 0
    
    // No default header/footer
    header: null
    footer: null
    
    // Custom Background
    background: Rectangle {
        color: settingsDialog.bgColor
    }

    // Main Content
    contentItem: Item {
        anchors.fill: parent
        
        // Custom Header
        Rectangle {
            id: headerBar
            width: parent.width
            height: units.gu(7)
            color: settingsDialog.cardColor
            z: 10
            
            // Shadow
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: units.gu(0.5)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: settingsDialog.darkMode ? "#40000000" : "#20000000" }
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
                color: backMouseArea.pressed ? settingsDialog.dividerColor : "transparent"
                radius: width / 2
                
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    name: "back"
                    color: settingsDialog.textColor
                }
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: settingsDialog.close()
                }
            }
            
            // Title
            Label {
                anchors.centerIn: parent
                text: "Settings"
                font.pixelSize: units.gu(2.2)
                font.weight: Font.DemiBold
                color: settingsDialog.textColor
            }
        }
        
        // Scrollable Content
        Flickable {
            id: settingsFlickable
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            contentHeight: mainColumn.height + units.gu(4)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            
            Column {
                id: mainColumn
                width: parent.width
                spacing: units.gu(2)
                topPadding: units.gu(2)
                
                // ═══════════════════════════════════════════
                // APPEARANCE SECTION
                // ═══════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: units.gu(0.5)
                    
                    // Section Header
                    Item {
                        width: parent.width
                        height: units.gu(2.5)
                        
                        Label {
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(2)
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Appearance"
                            font.pixelSize: units.gu(1.5)
                            font.weight: Font.DemiBold
                            color: settingsDialog.accentColor
                        }
                    }
                    
                    // Dark Mode Card
                    Rectangle {
                        width: parent.width
                        height: units.gu(8)
                        color: settingsDialog.cardColor
                        
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: units.gu(2)
                            anchors.rightMargin: units.gu(2)
                            spacing: units.gu(1.5)
                            
                            // Icon container
                            Rectangle {
                                width: units.gu(5)
                                height: units.gu(5)
                                anchors.verticalCenter: parent.verticalCenter
                                radius: units.gu(1)
                                color: settingsDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                                
                                Icon {
                                    anchors.centerIn: parent
                                    width: units.gu(2.8)
                                    height: units.gu(2.8)
                                    name: "night-mode"
                                    color: settingsDialog.accentColor
                                }
                            }
                            
                            // Text
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - units.gu(16)
                                spacing: units.gu(0.3)
                                
                                Label {
                                    text: "Dark Mode"
                                    font.pixelSize: units.gu(1.9)
                                    font.weight: Font.Medium
                                    color: settingsDialog.textColor
                                }
                                
                                Label {
                                    text: settingsDialog.darkMode ? "Currently using dark theme" : "Currently using light theme"
                                    font.pixelSize: units.gu(1.4)
                                    color: settingsDialog.subtextColor
                                }
                            }
                            
                            // Toggle
                            Item {
                                width: units.gu(6)
                                height: parent.height
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Rectangle {
                                    id: toggleBg
                                    width: units.gu(5.5)
                                    height: units.gu(3)
                                    anchors.centerIn: parent
                                    radius: height / 2
                                    color: settingsDialog.darkMode ? settingsDialog.accentColor : "#767676"
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    
                                    Rectangle {
                                        id: toggleKnob
                                        width: units.gu(2.4)
                                        height: units.gu(2.4)
                                        radius: height / 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: settingsDialog.darkMode ? parent.width - width - units.gu(0.3) : units.gu(0.3)
                                        color: "white"
                                        
                                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: settingsDialog.darkModeToggled(!settingsDialog.darkMode)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // ═══════════════════════════════════════════
                // STATISTICS SECTION
                // ═══════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: units.gu(0.5)
                    
                    // Section Header
                    Item {
                        width: parent.width
                        height: units.gu(2.5)
                        
                        Label {
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(2)
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Statistics"
                            font.pixelSize: units.gu(1.5)
                            font.weight: Font.DemiBold
                            color: settingsDialog.accentColor
                        }
                    }
                    
                    // Stats Card
                    Rectangle {
                        width: parent.width
                        height: statsRow.height + units.gu(3)
                        color: settingsDialog.cardColor
                        
                        Row {
                            id: statsRow
                            anchors.centerIn: parent
                            width: parent.width - units.gu(4)
                            spacing: units.gu(1)
                            
                            // Current Subreddit Stat
                            Rectangle {
                                width: (parent.width - units.gu(1)) / 2
                                height: units.gu(9)
                                radius: units.gu(1.2)
                                color: settingsDialog.darkMode ? "#2D2D2E" : "#F8F8F8"
                                border.width: 1
                                border.color: settingsDialog.dividerColor
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: units.gu(0.5)
                                    
                                    Icon {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: units.gu(3)
                                        height: units.gu(3)
                                        name: "stock_website"
                                        color: "#0079D3"
                                    }
                                    
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "r/" + (settingsDialog.currentSubreddit || "multi")
                                        font.pixelSize: units.gu(1.5)
                                        font.weight: Font.DemiBold
                                        color: settingsDialog.textColor
                                        elide: Text.ElideRight
                                        width: Math.min(implicitWidth, units.gu(15))
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Current Feed"
                                        font.pixelSize: units.gu(1.2)
                                        color: settingsDialog.subtextColor
                                    }
                                }
                            }
                            
                            // Memes Loaded Stat
                            Rectangle {
                                width: (parent.width - units.gu(1)) / 2
                                height: units.gu(9)
                                radius: units.gu(1.2)
                                color: settingsDialog.darkMode ? "#2D2D2E" : "#F8F8F8"
                                border.width: 1
                                border.color: settingsDialog.dividerColor
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: units.gu(0.5)
                                    
                                    Icon {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: units.gu(3)
                                        height: units.gu(3)
                                        name: "view-grid-symbolic"
                                        color: "#46D160"
                                    }
                                    
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: settingsDialog.totalMemesLoaded.toString()
                                        font.pixelSize: units.gu(2)
                                        font.weight: Font.Bold
                                        color: settingsDialog.textColor
                                    }
                                    
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Posts Loaded"
                                        font.pixelSize: units.gu(1.2)
                                        color: settingsDialog.subtextColor
                                    }
                                }
                            }
                        }
                    }
                }
                
                // ═══════════════════════════════════════════
                // DATA MANAGEMENT SECTION
                // ═══════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: units.gu(0.5)
                    
                    // Section Header
                    Item {
                        width: parent.width
                        height: units.gu(2.5)
                        
                        Label {
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(2)
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Data Management"
                            font.pixelSize: units.gu(1.5)
                            font.weight: Font.DemiBold
                            color: settingsDialog.accentColor
                        }
                    }
                    
                    // Actions Card
                    Rectangle {
                        width: parent.width
                        height: actionsColumn.height
                        color: settingsDialog.cardColor
                        
                        Column {
                            id: actionsColumn
                            width: parent.width
                            
                            // Clear Bookmarks
                            Rectangle {
                                width: parent.width
                                height: units.gu(7)
                                color: clearBookmarksArea.pressed ? settingsDialog.dividerColor : "transparent"
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: units.gu(2)
                                    anchors.rightMargin: units.gu(2)
                                    spacing: units.gu(1.5)
                                    
                                    Rectangle {
                                        width: units.gu(5)
                                        height: units.gu(5)
                                        anchors.verticalCenter: parent.verticalCenter
                                        radius: units.gu(1)
                                        color: "#FFE5E5"
                                        
                                        Icon {
                                            anchors.centerIn: parent
                                            width: units.gu(2.5)
                                            height: units.gu(2.5)
                                            name: "delete"
                                            color: "#E53935"
                                        }
                                    }
                                    
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: units.gu(0.2)
                                        
                                        Label {
                                            text: "Clear Bookmarks"
                                            font.pixelSize: units.gu(1.8)
                                            font.weight: Font.Medium
                                            color: "#E53935"
                                        }
                                        
                                        Label {
                                            text: "Remove all saved posts"
                                            font.pixelSize: units.gu(1.4)
                                            color: settingsDialog.subtextColor
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: clearBookmarksArea
                                    anchors.fill: parent
                                    onClicked: settingsDialog.clearBookmarksRequested()
                                }
                            }
                            
                            // Divider
                            Rectangle {
                                width: parent.width - units.gu(9)
                                height: 1
                                anchors.right: parent.right
                                color: settingsDialog.dividerColor
                            }
                            
                            // Clear Cache
                            Rectangle {
                                width: parent.width
                                height: units.gu(7)
                                color: clearCacheArea.pressed ? settingsDialog.dividerColor : "transparent"
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: units.gu(2)
                                    anchors.rightMargin: units.gu(2)
                                    spacing: units.gu(1.5)
                                    
                                    Rectangle {
                                        width: units.gu(5)
                                        height: units.gu(5)
                                        anchors.verticalCenter: parent.verticalCenter
                                        radius: units.gu(1)
                                        color: settingsDialog.darkMode ? "#2D2D2E" : "#F0F0F0"
                                        
                                        Icon {
                                            anchors.centerIn: parent
                                            width: units.gu(2.5)
                                            height: units.gu(2.5)
                                            name: "reload"
                                            color: settingsDialog.textColor
                                        }
                                    }
                                    
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: units.gu(0.2)
                                        
                                        Label {
                                            text: "Refresh Content"
                                            font.pixelSize: units.gu(1.8)
                                            font.weight: Font.Medium
                                            color: settingsDialog.textColor
                                        }
                                        
                                        Label {
                                            text: "Clear cache and reload feed"
                                            font.pixelSize: units.gu(1.4)
                                            color: settingsDialog.subtextColor
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: clearCacheArea
                                    anchors.fill: parent
                                    onClicked: settingsDialog.clearCacheRequested()
                                }
                            }
                        }
                    }
                }
                
                // ═══════════════════════════════════════════
                // ABOUT SECTION
                // ═══════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: units.gu(0.5)
                    
                    // Section Header
                    Item {
                        width: parent.width
                        height: units.gu(2.5)
                        
                        Label {
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(2)
                            anchors.verticalCenter: parent.verticalCenter
                            text: "About"
                            font.pixelSize: units.gu(1.5)
                            font.weight: Font.DemiBold
                            color: settingsDialog.accentColor
                        }
                    }
                    
                    // About Card
                    Rectangle {
                        width: parent.width
                        height: aboutColumn.height + units.gu(4)
                        color: settingsDialog.cardColor
                        
                        Column {
                            id: aboutColumn
                            width: parent.width
                            anchors.centerIn: parent
                            spacing: units.gu(1.5)
                            
                            // App Icon
                            Rectangle {
                                width: units.gu(12)
                                height: units.gu(12)
                                anchors.horizontalCenter: parent.horizontalCenter
                                radius: units.gu(2.5)
                                color: settingsDialog.accentColor
                                
                                Image {
                                    source: "../images/meme.png"
                                    anchors.centerIn: parent
                                    width: units.gu(8)
                                    height: units.gu(8)
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            
                            // App Name
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "MemeStream"
                                font.pixelSize: units.gu(2.8)
                                font.weight: Font.Bold
                                color: settingsDialog.textColor
                            }
                            
                            // Version Badge
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: versionLabel.width + units.gu(2)
                                height: units.gu(2.8)
                                radius: height / 2
                                color: settingsDialog.accentColor
                                
                                Label {
                                    id: versionLabel
                                    anchors.centerIn: parent
                                    text: "v" + settingsDialog.appVersion
                                    font.pixelSize: units.gu(1.3)
                                    font.weight: Font.Medium
                                    color: "white"
                                }
                            }
                            
                            // Description
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - units.gu(6)
                                text: "A native Reddit meme viewer\nfor Ubuntu Touch"
                                font.pixelSize: units.gu(1.5)
                                color: settingsDialog.subtextColor
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }
                            
                            // Divider
                            Rectangle {
                                width: units.gu(8)
                                height: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: settingsDialog.dividerColor
                                radius: 1
                            }
                            
                            // Copyright
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Made with ❤️ by Suraj Yadav"
                                font.pixelSize: units.gu(1.4)
                                color: settingsDialog.subtextColor
                            }
                            
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "© 2025 • Open Source"
                                font.pixelSize: units.gu(1.2)
                                color: settingsDialog.subtextColor
                                opacity: 0.7
                            }
                        }
                    }
                }
                
                // Bottom padding
                Item { width: 1; height: units.gu(2) }
            }
        }
        
        // Scroll indicator
        Rectangle {
            width: units.gu(0.5)
            height: settingsFlickable.height * (settingsFlickable.height / settingsFlickable.contentHeight)
            anchors.right: parent.right
            anchors.rightMargin: units.gu(0.3)
            y: headerBar.height + (settingsFlickable.contentY / settingsFlickable.contentHeight) * settingsFlickable.height
            radius: width / 2
            color: settingsDialog.subtextColor
            opacity: settingsFlickable.moving ? 0.8 : 0
            visible: settingsFlickable.contentHeight > settingsFlickable.height
            
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
}
