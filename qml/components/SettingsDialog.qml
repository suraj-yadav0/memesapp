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
    
    // Signals
    signal darkModeToggled(bool enabled)
    signal clearBookmarksRequested()
    signal clearCacheRequested()
    
    // Dialog Geometry
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent.width * 0.95, units.gu(50))
    height: Math.min(parent.height * 0.9, units.gu(75))
    
    modal: true
    focus: true
    title: "Settings"
    
    // Custom Background
    background: Rectangle {
        color: theme.palette.normal.background
        radius: units.gu(1.5)
        border.color: theme.palette.normal.base
        border.width: units.dp(1)
        clip: true
    }
    
    // Custom Header
    header: Item {
        width: parent.width
        height: units.gu(7)
        
        Label {
            anchors.centerIn: parent
            text: "Settings"
            font.pixelSize: units.gu(2.2)
            font.weight: Font.DemiBold
            color: theme.palette.normal.foregroundText
        }
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: units.dp(1)
            color: theme.palette.normal.base
            opacity: 0.5
        }
    }

    // Main Content
    contentItem: ColumnLayout {
        spacing: 0
        
        // Scrollable Settings Area
        QC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            QC2.ScrollBar.vertical.policy: QC2.ScrollBar.AsNeeded
            
            ColumnLayout {
                width: parent.width
                spacing: units.gu(2.5)
                
                // Top Spacer
                Item { height: units.gu(0.5); Layout.fillWidth: true }

                // --- Appearance Section ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    spacing: units.gu(1)
                    
                    Label {
                        text: "APPEARANCE"
                        font.pixelSize: units.gu(1.4)
                        font.weight: Font.Bold
                        color: theme.palette.normal.foregroundText
                        opacity: 0.7
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: appearanceRow.implicitHeight + units.gu(3)
                        color: theme.palette.normal.base
                        radius: units.gu(1)
                        
                        RowLayout {
                            id: appearanceRow
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: units.gu(1.5)
                            spacing: units.gu(2)
                            
                            Icon {
                                name: "night-mode"
                                width: units.gu(3)
                                height: units.gu(3)
                                color: theme.palette.normal.foregroundText
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: units.gu(0.2)
                                
                                Label {
                                    text: "Dark Mode"
                                    font.weight: Font.Medium
                                    color: theme.palette.normal.foregroundText
                                    font.pixelSize: units.gu(1.8)
                                }
                                Label {
                                    text: "Switch between light and dark themes"
                                    font.pixelSize: units.gu(1.3)
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.6
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                            
                            QC2.Switch {
                                checked: settingsDialog.darkMode
                                onClicked: settingsDialog.darkModeToggled(checked)
                            }
                        }
                    }
                }

                // --- Content Info Section ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    spacing: units.gu(1)
                    
                    Label {
                        text: "CONTENT"
                        font.pixelSize: units.gu(1.4)
                        font.weight: Font.Bold
                        color: theme.palette.normal.foregroundText
                        opacity: 0.7
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: contentCol.implicitHeight + units.gu(3)
                        color: theme.palette.normal.base
                        radius: units.gu(1)
                        
                        ColumnLayout {
                            id: contentCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: units.gu(1.5)
                            spacing: units.gu(1.5)
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Icon {
                                    name: "view-list-symbolic"
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.7
                                }
                                Label {
                                    text: "Current Subreddit"
                                    Layout.fillWidth: true
                                    color: theme.palette.normal.foregroundText
                                    font.pixelSize: units.gu(1.6)
                                }
                                Label {
                                    text: "r/" + settingsDialog.currentSubreddit
                                    font.weight: Font.DemiBold
                                    color: theme.palette.normal.foregroundText
                                    font.pixelSize: units.gu(1.6)
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: units.dp(1)
                                color: theme.palette.disabled.base
                                opacity: 0.2
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Icon {
                                    name: "image-x-generic-symbolic"
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.7
                                }
                                Label {
                                    text: "Memes Loaded"
                                    Layout.fillWidth: true
                                    color: theme.palette.normal.foregroundText
                                    font.pixelSize: units.gu(1.6)
                                }
                                Label {
                                    text: settingsDialog.totalMemesLoaded.toString()
                                    font.weight: Font.DemiBold
                                    color: theme.palette.normal.foregroundText
                                    font.pixelSize: units.gu(1.6)
                                }
                            }
                        }
                    }
                }
                
                // --- Data Management Section ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    spacing: units.gu(1)
                    
                    Label {
                        text: "DATA MANAGEMENT"
                        font.pixelSize: units.gu(1.4)
                        font.weight: Font.Bold
                        color: theme.palette.normal.foregroundText
                        opacity: 0.7
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: dataCol.implicitHeight + units.gu(3)
                        color: theme.palette.normal.base
                        radius: units.gu(1)
                        
                        ColumnLayout {
                            id: dataCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: units.gu(1.5)
                            spacing: units.gu(1.5)
                            
                            QC2.Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: units.gu(5)
                                
                                contentItem: RowLayout {
                                    spacing: units.gu(1)
                                    Icon {
                                        name: "delete"
                                        color: "#E74C3C" // Red color
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                    Label {
                                        text: "Clear All Bookmarks"
                                        color: "#E74C3C"
                                        font.weight: Font.Medium
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                    Item { Layout.fillWidth: true }
                                }
                                
                                background: Rectangle {
                                    color: parent.down ? Qt.rgba(0.9, 0.3, 0.3, 0.1) : "transparent"
                                    border.color: "#E74C3C"
                                    border.width: units.dp(1)
                                    radius: units.gu(0.5)
                                }
                                
                                onClicked: settingsDialog.clearBookmarksRequested()
                            }
                            
                            QC2.Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: units.gu(5)
                                
                                contentItem: RowLayout {
                                    spacing: units.gu(1)
                                    Icon {
                                        name: "reload"
                                        color: theme.palette.normal.foregroundText
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                    Label {
                                        text: "Clear Cache & Reload"
                                        color: theme.palette.normal.foregroundText
                                        font.weight: Font.Medium
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                    Item { Layout.fillWidth: true }
                                }
                                
                                background: Rectangle {
                                    color: parent.down ? Qt.rgba(0.5, 0.5, 0.5, 0.1) : "transparent"
                                    border.color: theme.palette.normal.foregroundText
                                    border.width: units.dp(1)
                                    opacity: 0.5
                                    radius: units.gu(0.5)
                                }
                                
                                onClicked: settingsDialog.clearCacheRequested()
                            }
                        }
                    }
                }

                // --- About Section ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    spacing: units.gu(1)
                    
                    Label {
                        text: "ABOUT"
                        font.pixelSize: units.gu(1.4)
                        font.weight: Font.Bold
                        color: theme.palette.normal.foregroundText
                        opacity: 0.7
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: aboutCol.implicitHeight + units.gu(4)
                        color: theme.palette.normal.base
                        radius: units.gu(1)
                        
                        ColumnLayout {
                            id: aboutCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: units.gu(2)
                            spacing: units.gu(1.5)
                            
                            Image {
                                source: "../images/meme.png"
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: units.gu(10)
                                Layout.preferredHeight: units.gu(10)
                                fillMode: Image.PreserveAspectFit
                            }
                            
                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: units.gu(0.5)
                                
                                Label {
                                    text: "MemeStream"
                                    font.pixelSize: units.gu(2.5)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignHCenter
                                    color: theme.palette.normal.foregroundText
                                }
                                
                                Label {
                                    text: "Version " + settingsDialog.appVersion
                                    font.pixelSize: units.gu(1.4)
                                    Layout.alignment: Qt.AlignHCenter
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.6
                                }
                                
                                Label {
                                    text: "A native Reddit meme viewer for Ubuntu Touch"
                                    font.pixelSize: units.gu(1.4)
                                    Layout.alignment: Qt.AlignHCenter
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.8
                                    Layout.topMargin: units.gu(1)
                                }
                                
                                Label {
                                    text: "© 2025 Suraj Yadav"
                                    font.pixelSize: units.gu(1.2)
                                    Layout.alignment: Qt.AlignHCenter
                                    color: theme.palette.normal.foregroundText
                                    opacity: 0.5
                                    Layout.topMargin: units.gu(0.5)
                                }
                            }
                        }
                    }
                }
                
                // Bottom Spacer
                Item { height: units.gu(2); Layout.fillWidth: true }
            }
        }
        
        // Footer
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(9)
            
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: units.dp(1)
                color: theme.palette.normal.base
                opacity: 0.5
            }
            
            QC2.Button {
                anchors.centerIn: parent
                width: units.gu(20)
                height: units.gu(5)
                
                text: "Close"
                font.weight: Font.Medium
                
                onClicked: settingsDialog.close()
            }
        }
    }
}
