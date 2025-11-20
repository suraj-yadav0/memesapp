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
import QtQuick.Controls 2.12
import Lomiri.Components 1.3
import "../models"
import "../services"

Item {
    id: memeGridView
    
    // Properties
    property alias count: gridView.count
    property bool isLoading: false
    property string loadingText: "Loading..."
    property string errorMessage: ""
    property bool isMultiSubredditMode: false
    property var subredditSources: ({})
    property var bookmarkStatus: ({}) // Maps meme IDs to bookmark status
    
    // Signals
    signal memeClicked(int index, string imageUrl)
    signal loadMore()
    signal refreshRequested()
    signal bookmarkToggled(var meme, bool bookmark)
    signal backRequested() // New signal for back button
    
    // GridView
    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: units.gu(2)
        
        cellWidth: width
        cellHeight: cellWidth * 1.5
      
        model: MemeModel {
            id: memeModel
        }
        
        delegate: MemeDelegate {

            
            width: gridView.cellWidth - units.gu(0.5)
            height: gridView.cellHeight - units.gu(0.5)
            
            property var memeData: memeModel.get(index)
            isMultiSubredditMode: memeGridView.isMultiSubredditMode
            subredditSource: memeGridView.isMultiSubredditMode ? 
                            (memeGridView.subredditSources[memeData ? memeData.id : ""] || "unknown") : ""
            isBookmarked: memeGridView.bookmarkStatus[memeData ? memeData.id : ""] || false
            
            onImageClicked: {
                var meme = memeModel.get(index);
                var imageUrl = meme ? meme.image : "";
                console.log("MemeGridView: Meme clicked at index:", index, "URL:", imageUrl);
                memeGridView.memeClicked(index, imageUrl);
            }
            
            onBookmarkToggled: {
                console.log("MemeGridView: Bookmark toggled for:", meme.title);
                memeGridView.bookmarkToggled(meme, bookmark);
            }
            
            onBackRequested: {
                console.log("MemeGridView: Back button pressed");
                memeGridView.backRequested();
            }
        }
        
        // Pull to refresh and load more
        property bool refreshing: false
        property real refreshThreshold: units.gu(8)
        
        onContentYChanged: {
            // Pull to refresh
            if (contentY < -refreshThreshold && !refreshing && !memeGridView.isLoading) {
                refreshing = true;
                memeGridView.refreshRequested();
                refreshTimer.start();
            }
            
            // Load more when near bottom
            var nearBottom = (contentY + height) >= (contentHeight - units.gu(10));
            if (nearBottom && !memeGridView.isLoading && count > 0) {
                console.log("MemeGridView: Near bottom, loading more memes");
                memeGridView.loadMore();
            }
        }
        
        Timer {
            id: refreshTimer
            interval: 1000 // Minimum refresh duration
            onTriggered: {
                gridView.refreshing = false;
                gridView.contentY = 0; // Reset position
            }
        }
        
        // Empty state
        Rectangle {
            anchors.centerIn: parent
            width: emptyColumn.width + units.gu(4)
            height: emptyColumn.height + units.gu(4)
            color: theme.palette.normal.background
            radius: units.gu(1)
            border.color: theme.palette.normal.base
            border.width: units.dp(1)
            visible: !memeGridView.isLoading && gridView.count === 0 && !memeGridView.errorMessage
            
            Column {
                id: emptyColumn
                anchors.centerIn: parent
                spacing: units.gu(2)
                
                Icon {
                    name: "image-x-generic-symbolic"
                    width: units.gu(6)
                    height: units.gu(6)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: theme.palette.normal.backgroundText
                }
                
                Label {
                    text: "No memes found"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.weight: Font.Medium
                }
                
                Label {
                    text: "Try selecting a different subreddit or check your connection"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: theme.palette.normal.backgroundSecondaryText
                    wrapMode: Text.WordWrap
                    width: units.gu(30)
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        
        // Error state
        Rectangle {
            anchors.centerIn: parent
            width: errorColumn.width + units.gu(4)
            height: errorColumn.height + units.gu(4)
            color: theme.palette.normal.background
            radius: units.gu(1)
            border.color: "#E74C3C"
            border.width: units.dp(2)
            visible: memeGridView.errorMessage !== ""
            
            Column {
                id: errorColumn
                anchors.centerIn: parent
                spacing: units.gu(2)
                
                Icon {
                    name: "dialog-warning-symbolic"
                    width: units.gu(6)
                    height: units.gu(6)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#E74C3C"
                }
                
                Label {
                    text: "Error Loading Memes"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.weight: Font.Medium
                    color: "#E74C3C"
                }
                
                Label {
                    text: memeGridView.errorMessage
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: theme.palette.normal.backgroundSecondaryText
                    wrapMode: Text.WordWrap
                    width: units.gu(35)
                    horizontalAlignment: Text.AlignHCenter
                }
                
                CustomButton {
                    text: "Retry"
                    anchors.horizontalCenter: parent.horizontalCenter
                   // color: LomiriColors.orange
                    onClicked: {
                        memeGridView.errorMessage = "";
                        memeGridView.refreshRequested();
                    }
                }
            }
        }
        
        // Pull to refresh indicator
        Rectangle {
            id: refreshIndicator
            anchors.top: parent.top
            anchors.topMargin: -height - units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            width: refreshRow.width + units.gu(2)
            height: units.gu(4)
            color: theme.palette.normal.background
            radius: height / 2
            border.color: theme.palette.normal.base
            border.width: units.dp(1)
            visible: gridView.contentY < -units.gu(2)
            opacity: Math.min(1.0, Math.abs(gridView.contentY) / gridView.refreshThreshold)
            
            Row {
                id: refreshRow
                anchors.centerIn: parent
                spacing: units.gu(1)
                
                ActivityIndicator {
                    running: gridView.refreshing
                    visible: running
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Icon {
                    name: "reload"
                    width: units.gu(2)
                    height: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !gridView.refreshing
                    rotation: gridView.refreshing ? 0 : Math.abs(gridView.contentY) * 2
                }
                
                Label {
                    text: gridView.refreshing ? "Refreshing..." : 
                          Math.abs(gridView.contentY) > gridView.refreshThreshold ? "Release to refresh" : "Pull to refresh"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: units.gu(1.2)
                }
            }
        }
    }
    
    // Loading overlay
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
        opacity: 0.9
        visible: memeGridView.isLoading && gridView.count === 0
        
        Column {
            anchors.centerIn: parent
            spacing: units.gu(2)
            
            ActivityIndicator {
                running: parent.parent.visible
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Label {
                text: memeGridView.loadingText
                anchors.horizontalCenter: parent.horizontalCenter
                font.weight: Font.Medium
            }
        }
    }
    
    // Loading more indicator (bottom)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: units.gu(1)
        width: loadMoreRow.width + units.gu(2)
        height: units.gu(4)
        color: theme.palette.normal.background
        radius: height / 2
        border.color: theme.palette.normal.base
        border.width: units.dp(1)
        visible: memeGridView.isLoading && gridView.count > 0
        
        Row {
            id: loadMoreRow
            anchors.centerIn: parent
            spacing: units.gu(1)
            
            ActivityIndicator {
                running: parent.parent.visible
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Label {
                text: "Loading more..."
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: units.gu(1.2)
            }
        }
    }
    
    // Public functions
    function clearMemes() {
        memeModel.clear();
    }
    
    function addMemes(memes) {
        for (var i = 0; i < memes.length; i++) {
            memeModel.append(memes[i]);
        }
    }
    
    function getMemeAt(index) {
        return memeModel.get(index);
    }
    
    function scrollToTop() {
        gridView.positionViewAtBeginning();
    }
    
    function setError(message) {
        errorMessage = message;
        isLoading = false;
    }
    
    function clearError() {
        errorMessage = "";
    }
}