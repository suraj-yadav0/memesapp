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
    property bool isMultiSubredditMode: false
    property var currentSubreddits: []
    
    // Signals
    signal subredditSelectionRequested()
    signal multiSubredditSelectionRequested()
    signal settingsRequested()
    signal refreshRequested()
    signal manageSubredditsRequested()
    signal bookmarksRequested()
    
    title: isMultiSubredditMode ? 
           "Multi-Feed (" + currentSubreddits.length + ")" : 
           "r/" + currentSubreddit


     StyleHints {
            foregroundColor: "white"

            backgroundColor: '#116297'
            dividerColor: LomiriColors.slate
        }
    
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
            },
            Action {
                id: multiSubredditAction
                iconName: "view-grid-symbolic"
                text: "Multi-Subreddit Feed"
                onTriggered: {
                    console.log("AppHeader: Multi-subreddit selection requested");
                    appHeader.multiSubredditSelectionRequested();
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
                id: bookmarksAction
                iconName: "starred"
                text: "Bookmarks"
                onTriggered: {
                    console.log("AppHeader: Bookmarks requested");
                    appHeader.bookmarksRequested();
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
        
        RedditLoadingAnimation {
            anchors.centerIn: parent
            running: appHeader.isLoading
            width: units.gu(3)
            height: units.gu(3)
            accentColor: "white"
        }
    }
}