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

PageHeader {
    id: appHeader
    
    // Properties
    property string currentSubreddit: "funny"
    property bool isLoading: false
    
    // Signals
    signal subredditSelectionRequested()
    signal settingsRequested()
    signal refreshRequested()
    signal manageSubredditsRequested()
    
    title: "r/" + currentSubreddit
    
    leadingActionBar {
        actions: [
            Action {
                id: subredditAction
                iconName: "view-list-symbolic"
                text: "Select Subreddit"
                onTriggered: {
                    console.log("AppHeader: Subreddit selection requested");
                    appHeader.subredditSelectionRequested();
                }
            }
        ]
    }
    
    trailingActionBar {
        actions: [
            Action {
                id: manageAction
                iconName: "bookmark-new"
                text: "Manage Subreddits"
                onTriggered: {
                    console.log("AppHeader: Manage subreddits requested");
                    appHeader.manageSubredditsRequested();
                }
            },
            Action {
                id: refreshAction
                iconName: "reload"
                text: "Refresh"
                enabled: !appHeader.isLoading
                onTriggered: {
                    console.log("AppHeader: Refresh requested");
                    appHeader.refreshRequested();
                }
            },
            Action {
                id: settingsAction
                iconName: "settings"
                text: "Settings"
                onTriggered: {
                    console.log("AppHeader: Settings requested");
                    appHeader.settingsRequested();
                }
            }
        ]
    }
    
    // Loading indicator overlay on refresh button
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.gu(1)
        width: units.gu(4)
        height: units.gu(4)
        color: "transparent"
        visible: appHeader.isLoading
        
        ActivityIndicator {
            anchors.centerIn: parent
            running: appHeader.isLoading
        }
    }
}