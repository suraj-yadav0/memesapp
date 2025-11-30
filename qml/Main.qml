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
import Qt.labs.settings 1.0
import "components"
import "models"
import "services"

MainView {
    id: root
    objectName: "mainView"
    applicationName: "memesapp"
    automaticOrientation: true
    
    width: units.gu(45)
    height: units.gu(75)
    
    // Theme colors
    readonly property color bgColor: darkMode ? "#0F0F0F" : "#F5F5F5"
    readonly property color cardColor: darkMode ? "#1A1A1B" : "#FFFFFF"
    readonly property color textColor: darkMode ? "#D7DADC" : "#1A1A1B"
    readonly property color subtextColor: darkMode ? "#818384" : "#787C7E"
    readonly property color accentColor: "#FF4500"
    readonly property color dividerColor: darkMode ? "#343536" : "#EDEFF1"

    // Authentication state
    property bool showLoginScreen: !hasCompletedOnboarding
    property bool hasCompletedOnboarding: false
    property bool isLoggedIn: false
    property string loggedInUsername: ""

    // Application properties
    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property bool useCustomSubreddit: false
    property string dialogImageSource: ""
    property int currentMemeIndex: -1
    
    // Layout mode detection
    property bool isDesktopMode: width > units.gu(100)  // Three columns
    property bool isTabletMode: width > units.gu(60) && width <= units.gu(100)  // Two columns
    property bool isMobileMode: width <= units.gu(60)  // Single column
    
    // Panel visibility
    property bool sidebarVisible: isDesktopMode
    property bool detailPanelVisible: false
    property var currentDetailMeme: null
    
    // Multi-subreddit properties
    property bool isMultiSubredditMode: false
    property var selectedSubreddits: []
    property var subredditSources: ({}) // Maps meme IDs to their source subreddit
    property bool useDefaultMultiFeed: true // Show combined feed from all subreddits by default
    
    // Bookmark properties
    property var bookmarkedMemes: []
    property var bookmarkStatus: ({}) // Maps meme IDs to bookmark status

    // Category mapping for better user experience
    property var categoryMap: ({
        "General Memes": "memes",
        "Dank Memes": "dankmemes",
        "Wholesome Memes": "wholesomememes",
        "Funny": "funny",
        "Programming Humor": "ProgrammerHumor",
        "Me IRL": "meirl",
        "Star Wars Memes": "PrequelMemes",
        "History Memes": "HistoryMemes",
        "Gaming Memes": "gaming",
        "Anime Memes": "AnimeMemes",
        "Cursed Comments": "cursedcomments",
        "Surreal Memes": "surrealmemes",
        "Memes of the Dank": "memesofthedank",
        "Meme Economy": "MemeEconomy",
        "2meirl4meirl": "2meirl4meirl",
        "teenagers": "teenagers",
        "Advice Animals": "AdviceAnimals",
        "Prequel Memes": "PrequelMemes",
        "Sequel Memes": "SequelMemes",
        "OT Memes": "OTMemes",
        "High Quality Memes": "HighQualityGifs",
        "Low Effort Memes": "loweffortmemes",
        "Political Memes": "PoliticalHumor",
        "Animal Memes": "AnimalsBeingDerps",
        "Cat Memes": "catmemes",
        "Dog Memes": "dogmemes",
        "Wholesome Animemes": "wholesomeanimemes",
        "Meme Art": "MemeArt"
    })

    property var categoryNames: ["General Memes", "Dank Memes", "Wholesome Memes", "Funny", "Programming Humor", "Me IRL", "Star Wars Memes", "History Memes", "Gaming Memes", "Anime Memes", "Cursed Comments", "Surreal Memes", "Memes of the Dank", "Meme Economy", "2meirl4meirl", "teenagers", "Advice Animals", "Prequel Memes", "Sequel Memes", "OT Memes", "High Quality Memes", "Low Effort Memes", "Political Memes", "Animal Memes", "Cat Memes", "Dog Memes", "Wholesome Animemes", "Meme Art"]
    
    property var extendedCategoryMap: categoryMap
    property var customSubreddits: []

    // Database Manager
    DatabaseManager {
        id: databaseManager
        
        onCustomSubredditsLoaded: {
            console.log("Main: Custom subreddits loaded:", subreddits.length);
            root.customSubreddits = subreddits;
            updateCategoryLists();
        }
        
        onSubredditAdded: {
            console.log("Main: Subreddit added to database:", displayName);
            updateCategoryLists();
        }
        
        onSubredditRemoved: {
            console.log("Main: Subreddit removed from database:", displayName);
            updateCategoryLists();
        }
        
        onMemeBookmarked: {
            console.log("Main: Meme bookmarked:", title);
            updateBookmarkStatus(memeId, true);
        }
        
        onMemeUnbookmarked: {
            console.log("Main: Meme unbookmarked:", memeId);
            updateBookmarkStatus(memeId, false);
        }
    }

    // MemeAPI service
    MemeAPI {
        id: memeAPI
        
        onMemesLoaded: {
            console.log("Main: Memes loaded, count:", memes.length);
            if (memes.length > 0) {
                memeGrid.addMemes(memes);
                memeGrid.isLoading = false;
                memeGrid.clearError();
                refreshBookmarkStatus(); // Update bookmark status for new memes
            } else {
                memeGrid.setError("No memes found for this subreddit");
                memeGrid.isLoading = false;
            }
        }
        
        onMultiSubredditMemesLoaded: {
            console.log("Main: Multi-subreddit memes loaded, count:", memes.length);
            root.subredditSources = subredditSources;
            if (memes.length > 0) {
                memeGrid.addMemes(memes);
                memeGrid.isLoading = false;
                memeGrid.clearError();
                refreshBookmarkStatus(); // Update bookmark status for new memes
            } else {
                memeGrid.setError("No memes found from selected subreddits");
                memeGrid.isLoading = false;
            }
        }
        
        onMultiSubredditProgress: {
            console.log("Main: Multi-subreddit progress:", completed, "/", total);
            // Could show progress in UI if needed
        }
        
        onError: {
            console.log("Main: Error loading memes:", message);
            memeGrid.setError(message);
            memeGrid.isLoading = false;
        }
    }

    // Settings persistence
    Settings {
        id: settings
        property alias selectedSubreddit: root.selectedSubreddit
        property alias darkMode: root.darkMode
        property alias hasCompletedOnboarding: root.hasCompletedOnboarding
        property alias isLoggedIn: root.isLoggedIn
        property alias loggedInUsername: root.loggedInUsername
    }

    // ========== LOGIN SCREEN ==========
    LoginScreen {
        id: loginScreen
        anchors.fill: parent
        visible: root.showLoginScreen
        z: 100
        
        bgColor: root.bgColor
        cardColor: root.cardColor
        textColor: root.textColor
        subtextColor: root.subtextColor
        accentColor: root.accentColor
        dividerColor: root.dividerColor
        darkMode: root.darkMode
        
        onLoginRequested: {
            console.log("Main: Login requested for user:", username)
            loginScreen.isLoading = true
            // TODO: Implement actual Reddit OAuth login
            // For now, simulate login
            loginTimer.username = username
            loginTimer.start()
        }
        
        onSignupRequested: {
            console.log("Main: Signup requested for user:", username, "email:", email)
            loginScreen.isLoading = true
            // TODO: Implement actual Reddit OAuth signup
            // For now, show info that signup happens on Reddit
            loginScreen.showError("Please sign up on Reddit.com first, then login here")
        }
        
        onSkipRequested: {
            console.log("Main: User chose to skip login")
            completeOnboarding(false, "")
        }
    }
    
    // Simulated login timer (replace with actual OAuth later)
    Timer {
        id: loginTimer
        interval: 1500
        repeat: false
        property string username: ""
        onTriggered: {
            // Simulate successful login
            completeOnboarding(true, username)
            loginScreen.isLoading = false
        }
    }
    
    // Function to complete onboarding and show main content
    function completeOnboarding(loggedIn, username) {
        root.isLoggedIn = loggedIn
        root.loggedInUsername = username
        root.hasCompletedOnboarding = true
        root.showLoginScreen = false
        
        // Initialize app content now
        initializeAppContent()
    }
    
    // Function to logout
    function logout() {
        root.isLoggedIn = false
        root.loggedInUsername = ""
        console.log("Main: User logged out")
    }

    function unescapeHtml(safe) {
        return safe.replace(/&amp;/g, '&')
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&quot;/g, '"')
            .replace(/&#039;/g, "'");
    }

    // ========== REDDIT-STYLE THREE-COLUMN LAYOUT ==========
    // Column 1: Subreddit Sidebar (left)
    // Column 2: Posts Feed (center)  
    // Column 3: Comments/Detail Panel (right)
    
    Row {
        id: mainLayout
        anchors.fill: parent
        visible: !root.showLoginScreen
        
        // ===== COLUMN 1: SUBREDDIT SIDEBAR =====
        Rectangle {
            id: sidebarColumn
            width: root.isDesktopMode ? units.gu(28) : 0
            height: parent.height
            color: root.cardColor
            visible: root.isDesktopMode
            
            // Sidebar divider
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: root.dividerColor
            }
            
            Column {
                anchors.fill: parent
                
                // Sidebar Header
                Rectangle {
                    width: parent.width
                    height: units.gu(7)
                    color: root.accentColor
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(1)
                        
                        // App icon
                        Rectangle {
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(2)
                            color: "white"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "stock_image"
                                color: root.accentColor
                            }
                        }
                        
                        Label {
                            text: "MemesApp"
                            font.pixelSize: units.gu(2.2)
                            font.weight: Font.Bold
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                // Quick Actions
                Rectangle {
                    width: parent.width
                    height: units.gu(6)
                    color: root.bgColor
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(1.5)
                        
                        // Home/Multi-feed button
                        Rectangle {
                            width: units.gu(5)
                            height: units.gu(5)
                            radius: units.gu(1)
                            color: root.isMultiSubredditMode ? root.accentColor : root.cardColor
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "home"
                                color: root.isMultiSubredditMode ? "white" : root.textColor
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.useDefaultMultiFeed = true;
                                    loadDefaultMultiFeed();
                                }
                            }
                        }
                        
                        // Multi-Feed Selector button
                        Rectangle {
                            width: units.gu(5)
                            height: units.gu(5)
                            radius: units.gu(1)
                            color: root.cardColor
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "view-grid-symbolic"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: multiSubredditDialog.open()
                            }
                        }
                        
                        // Bookmarks button
                        Rectangle {
                            width: units.gu(5)
                            height: units.gu(5)
                            radius: units.gu(1)
                            color: root.cardColor
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "starred"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    loadBookmarks();
                                    bookmarksDialog.open();
                                }
                            }
                        }
                        
                        // Settings button
                        Rectangle {
                            width: units.gu(5)
                            height: units.gu(5)
                            radius: units.gu(1)
                            color: root.cardColor
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "settings"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: settingsDialog.open()
                            }
                        }
                    }
                }
                
                // Section header
                Rectangle {
                    width: parent.width
                    height: units.gu(4)
                    color: "transparent"
                    
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1.5)
                        anchors.verticalCenter: parent.verticalCenter
                        text: "SUBREDDITS"
                        font.pixelSize: units.gu(1.3)
                        font.weight: Font.Medium
                        color: root.subtextColor
                    }
                }
                
                // Subreddit List
                ListView {
                    id: sidebarSubredditList
                    width: parent.width
                    height: parent.height - units.gu(17)
                    clip: true
                    model: root.categoryNames
                    
                    delegate: Rectangle {
                        width: sidebarSubredditList.width
                        height: modelData.indexOf("---") === 0 ? units.gu(3) : units.gu(5)
                        color: {
                            if (modelData.indexOf("---") === 0) return "transparent";
                            var subredditName = root.extendedCategoryMap[modelData] || modelData;
                            if (subredditName === root.selectedSubreddit && !root.isMultiSubredditMode) {
                                return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2);
                            }
                            return mouseArea.containsMouse ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.05) : "transparent";
                        }
                        
                        // Separator styling
                        Label {
                            visible: modelData.indexOf("---") === 0
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(1.5)
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.replace(/---/g, "").trim()
                            font.pixelSize: units.gu(1.2)
                            font.weight: Font.Medium
                            color: root.subtextColor
                        }
                        
                        // Subreddit item
                        Row {
                            visible: modelData.indexOf("---") !== 0
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(1.5)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: units.gu(1.2)
                            
                            // Subreddit avatar
                            Rectangle {
                                width: units.gu(3.5)
                                height: units.gu(3.5)
                                radius: units.gu(1.75)
                                color: {
                                    var colors = ["#FF4500", "#0079D3", "#46D160", "#FFD700", "#9B59B6", "#00CEC9", "#E17055", "#74B9FF"];
                                    var cleanName = modelData.replace("⭐ ", "");
                                    var hash = 0;
                                    for (var i = 0; i < cleanName.length; i++) {
                                        hash = cleanName.charCodeAt(i) + ((hash << 5) - hash);
                                    }
                                    return colors[Math.abs(hash) % colors.length];
                                }
                                
                                Label {
                                    anchors.centerIn: parent
                                    text: {
                                        var cleanName = modelData.replace("⭐ ", "");
                                        return cleanName.charAt(0).toUpperCase();
                                    }
                                    font.pixelSize: units.gu(1.8)
                                    font.weight: Font.Bold
                                    color: "white"
                                }
                            }
                            
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: units.gu(0.2)
                                
                                Label {
                                    text: modelData
                                    font.pixelSize: units.gu(1.6)
                                    color: root.textColor
                                    elide: Text.ElideRight
                                    width: units.gu(18)
                                }
                                
                                Label {
                                    text: "r/" + (root.extendedCategoryMap[modelData] || modelData)
                                    font.pixelSize: units.gu(1.2)
                                    color: root.subtextColor
                                    elide: Text.ElideRight
                                    width: units.gu(18)
                                    visible: modelData !== (root.extendedCategoryMap[modelData] || modelData)
                                }
                            }
                        }
                        
                        // Selection indicator
                        Rectangle {
                            visible: {
                                if (modelData.indexOf("---") === 0) return false;
                                var subredditName = root.extendedCategoryMap[modelData] || modelData;
                                return subredditName === root.selectedSubreddit && !root.isMultiSubredditMode;
                            }
                            anchors.left: parent.left
                            width: units.gu(0.4)
                            height: parent.height
                            color: root.accentColor
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: modelData.indexOf("---") !== 0
                            onClicked: {
                                var subredditName = root.extendedCategoryMap[modelData] || modelData;
                                root.selectedSubreddit = subredditName;
                                root.isMultiSubredditMode = false;
                                root.useDefaultMultiFeed = false;
                                root.detailPanelVisible = false;
                                refreshMemes();
                            }
                        }
                    }
                }
            }
        }
        
        // ===== COLUMN 2: POSTS FEED =====
        Rectangle {
            id: feedColumn
            width: {
                if (root.isDesktopMode) {
                    return root.detailPanelVisible ? parent.width - units.gu(28) - units.gu(45) : parent.width - units.gu(28);
                } else if (root.isTabletMode) {
                    return root.detailPanelVisible ? parent.width - units.gu(40) : parent.width;
                } else {
                    return parent.width;
                }
            }
            height: parent.height
            color: root.bgColor
            
            // Feed divider (right side)
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: root.dividerColor
                visible: root.detailPanelVisible
            }
            
            Column {
                anchors.fill: parent
                
                // Feed Header
                Rectangle {
                    id: feedHeader
                    width: parent.width
                    height: units.gu(7)
                    color: root.cardColor
                    
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1.5)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(1.5)
                        
                        // Menu button (mobile only)
                        Rectangle {
                            visible: !root.isDesktopMode
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(0.5)
                            color: menuMouseArea.pressed ? root.dividerColor : "transparent"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "navigation-menu"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: menuMouseArea
                                anchors.fill: parent
                                onClicked: subredditDialog.open()
                            }
                        }
                        
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Label {
                                text: root.isMultiSubredditMode ? "Multi-Feed" : ("r/" + root.selectedSubreddit)
                                font.pixelSize: units.gu(2.2)
                                font.weight: Font.Bold
                                color: root.textColor
                            }
                            
                            Label {
                                visible: root.isMultiSubredditMode
                                text: root.selectedSubreddits.length + " subreddits combined"
                                font.pixelSize: units.gu(1.4)
                                color: root.subtextColor
                            }
                        }
                    }
                    
                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(1.5)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(1)
                        
                        // Loading indicator
                        RedditLoadingAnimation {
                            running: memeGrid.isLoading
                            visible: running
                            width: units.gu(3)
                            height: units.gu(3)
                            accentColor: "#FF4500"
                            darkMode: root.darkMode
                        }
                        
                        // Refresh button
                        Rectangle {
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(0.5)
                            color: refreshMouseArea.pressed ? root.dividerColor : "transparent"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                name: "reload"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: refreshMouseArea
                                anchors.fill: parent
                                onClicked: refreshMemes()
                            }
                        }
                        
                        // Multi-Feed Selector button (mobile only)
                        Rectangle {
                            visible: !root.isDesktopMode
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(0.5)
                            color: multiFeedMouseArea.pressed ? root.dividerColor : "transparent"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                name: "view-grid-symbolic"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: multiFeedMouseArea
                                anchors.fill: parent
                                onClicked: multiSubredditDialog.open()
                            }
                        }
                        
                        // Bookmarks button (mobile only)
                        Rectangle {
                            visible: !root.isDesktopMode
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(0.5)
                            color: bookmarkMouseArea.pressed ? root.dividerColor : "transparent"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                name: "starred"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: bookmarkMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    loadBookmarks();
                                    bookmarksDialog.open();
                                }
                            }
                        }
                        
                        // Settings button (mobile only)
                        Rectangle {
                            visible: !root.isDesktopMode
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(0.5)
                            color: settingsMouseArea.pressed ? root.dividerColor : "transparent"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                name: "settings"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: settingsMouseArea
                                anchors.fill: parent
                                onClicked: settingsDialog.open()
                            }
                        }
                    }
                    
                    // Bottom border
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: root.dividerColor
                    }
                }
                
                // Meme Grid View
                MemeGridView {
                    id: memeGrid
                    width: parent.width
                    height: parent.height - feedHeader.height
                    isMultiSubredditMode: root.isMultiSubredditMode
                    subredditSources: root.subredditSources
                    bookmarkStatus: root.bookmarkStatus
                    darkMode: root.darkMode
                    
                    onMemeClicked: {
                        console.log("Main: Opening fullscreen viewer for meme:", index);
                        root.currentMemeIndex = index;
                        root.dialogImageSource = imageUrl;
                        fullscreenViewer.imageSource = imageUrl;
                        fullscreenViewer.currentIndex = index;
                        fullscreenViewer.totalCount = memeGrid.count;
                        fullscreenViewer.open();
                    }

                    onCommentClicked: {
                        console.log("Main: Opening comments for meme index:", index);
                        var meme = memeGrid.getMemeAt(index);
                        if (meme) {
                            root.currentDetailMeme = meme;
                            
                            // On desktop/tablet, show in detail panel
                            if (root.isDesktopMode || root.isTabletMode) {
                                detailPanel.loadMeme(meme);
                                root.detailPanelVisible = true;
                                memeAPI.fetchComments(meme.subreddit, meme.id);
                            } else {
                                // On mobile, use dialog
                                postDetailView.postId = meme.id;
                                postDetailView.postTitle = meme.title;
                                postDetailView.postImage = meme.image;
                                postDetailView.postAuthor = meme.author;
                                postDetailView.postSubreddit = meme.subreddit;
                                postDetailView.postUpvotes = meme.upvotes;
                                postDetailView.postCommentCount = meme.comments;
                                postDetailView.postSelfText = meme.selftext;
                                postDetailView.postSelfTextHtml = meme.selftext_html || "";
                                postDetailView.postType = meme.postType;
                                postDetailView.postImages = meme.images || [];
                                postDetailView.postPermalink = meme.permalink;
                                
                                postDetailView.commentsModel = [];
                                postDetailView.open();
                                
                                memeAPI.fetchComments(meme.subreddit, meme.id);
                            }
                        }
                    }
                    
                    onBookmarkToggled: {
                        console.log("Main: Bookmark toggled for meme:", meme.title, "bookmark:", bookmark);
                        if (bookmark) {
                            if (databaseManager.bookmarkMeme(meme)) {
                                updateBookmarkStatus(meme.id, true);
                            }
                        } else {
                            if (databaseManager.unbookmarkMeme(meme.id)) {
                                updateBookmarkStatus(meme.id, false);
                            }
                        }
                    }
                    
                    onLoadMore: {
                        if (!isLoading) {
                            console.log("Main: Loading more memes");
                            loadMoreMemes();
                        }
                    }
                    
                    onRefreshRequested: {
                        console.log("Main: Pull to refresh triggered");
                        refreshMemes();
                    }
                }
            }
        }
        
        // ===== COLUMN 3: DETAIL/COMMENTS PANEL =====
        Rectangle {
            id: detailPanel
            width: {
                if (!root.detailPanelVisible) return 0;
                if (root.isDesktopMode) return units.gu(45);
                if (root.isTabletMode) return units.gu(40);
                return 0;
            }
            height: parent.height
            color: root.cardColor
            visible: root.detailPanelVisible && (root.isDesktopMode || root.isTabletMode)
            clip: true
            
            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            property string postId: ""
            property string postTitle: ""
            property string postImage: ""
            property string postAuthor: ""
            property string postSubreddit: ""
            property int postUpvotes: 0
            property int postCommentCount: 0
            property string postSelfText: ""
            property string postSelfTextHtml: ""
            property string postType: ""
            property string postPermalink: ""
            property var commentsModel: []
            property bool isLoadingComments: false
            
            function loadMeme(meme) {
                postId = meme.id;
                postTitle = meme.title;
                postImage = meme.image || "";
                postAuthor = meme.author || "";
                postSubreddit = meme.subreddit || "";
                postUpvotes = meme.upvotes || 0;
                postCommentCount = meme.comments || 0;
                postSelfText = meme.selftext || "";
                postSelfTextHtml = meme.selftext_html || "";
                postType = meme.postType || "";
                postPermalink = meme.permalink || "";
                commentsModel = [];
                isLoadingComments = true;
            }
            
            Column {
                anchors.fill: parent
                
                // Detail Panel Header
                Rectangle {
                    width: parent.width
                    height: units.gu(7)
                    color: root.bgColor
                    
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1.5)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(1)
                        
                        // Close button
                        Rectangle {
                            width: units.gu(4)
                            height: units.gu(4)
                            radius: units.gu(0.5)
                            color: closeMouseArea.pressed ? root.dividerColor : "transparent"
                            
                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.2)
                                height: units.gu(2.2)
                                name: "close"
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                onClicked: root.detailPanelVisible = false
                            }
                        }
                        
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Label {
                                text: "Post Details"
                                font.pixelSize: units.gu(2)
                                font.weight: Font.Bold
                                color: root.textColor
                            }
                            
                            Label {
                                text: "r/" + detailPanel.postSubreddit
                                font.pixelSize: units.gu(1.4)
                                color: root.accentColor
                            }
                        }
                    }
                    
                    // Loading indicator
                    RedditLoadingAnimation {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(1.5)
                        anchors.verticalCenter: parent.verticalCenter
                        running: detailPanel.isLoadingComments
                        visible: running
                        width: units.gu(3)
                        height: units.gu(3)
                        accentColor: "#FF4500"
                        darkMode: root.darkMode
                    }
                    
                    // Bottom border
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: root.dividerColor
                    }
                }
                
                // Scrollable content
                Flickable {
                    width: parent.width
                    height: parent.height - units.gu(7)
                    contentHeight: detailContentColumn.height
                    clip: true
                    
                    Column {
                        id: detailContentColumn
                        width: parent.width
                        spacing: units.gu(1)
                        
                        // Post image
                        Image {
                            width: parent.width
                            height: detailPanel.postImage ? Math.min(width * 0.6, units.gu(35)) : 0
                            source: detailPanel.postImage
                            fillMode: Image.PreserveAspectFit
                            visible: detailPanel.postImage !== ""
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fullscreenViewer.imageSource = detailPanel.postImage;
                                    fullscreenViewer.currentIndex = -1;
                                    fullscreenViewer.totalCount = 1;
                                    fullscreenViewer.open();
                                }
                            }
                        }
                        
                        // Post info card
                        Rectangle {
                            width: parent.width
                            height: postInfoColumn.height + units.gu(3)
                            color: root.bgColor
                            
                            Column {
                                id: postInfoColumn
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: units.gu(1.5)
                                spacing: units.gu(1)
                                
                                // Title
                                Label {
                                    width: parent.width
                                    text: detailPanel.postTitle
                                    font.pixelSize: units.gu(2)
                                    font.weight: Font.Medium
                                    color: root.textColor
                                    wrapMode: Text.WordWrap
                                }
                                
                                // Meta info row
                                Row {
                                    spacing: units.gu(1.5)
                                    
                                    // Author
                                    Rectangle {
                                        height: units.gu(3)
                                        width: authorLabel.width + units.gu(1.5)
                                        radius: units.gu(0.5)
                                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                                        
                                        Label {
                                            id: authorLabel
                                            anchors.centerIn: parent
                                            text: "u/" + detailPanel.postAuthor
                                            font.pixelSize: units.gu(1.4)
                                            color: root.accentColor
                                        }
                                    }
                                    
                                    // Upvotes
                                    Row {
                                        spacing: units.gu(0.5)
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Label {
                                            text: "↑"
                                            font.pixelSize: units.gu(1.6)
                                            color: "#FF4500"
                                        }
                                        Label {
                                            text: detailPanel.postUpvotes
                                            font.pixelSize: units.gu(1.4)
                                            color: root.subtextColor
                                        }
                                    }
                                    
                                    // Comments count
                                    Row {
                                        spacing: units.gu(0.5)
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Label {
                                            text: "💬"
                                            font.pixelSize: units.gu(1.4)
                                        }
                                        Label {
                                            text: detailPanel.postCommentCount
                                            font.pixelSize: units.gu(1.4)
                                            color: root.subtextColor
                                        }
                                    }
                                }
                                
                                // Self text
                                Label {
                                    width: parent.width
                                    text: detailPanel.postSelfTextHtml ? unescapeHtml(detailPanel.postSelfTextHtml) : detailPanel.postSelfText
                                    textFormat: detailPanel.postSelfTextHtml ? Text.RichText : Text.AutoText
                                    font.pixelSize: units.gu(1.6)
                                    color: root.textColor
                                    wrapMode: Text.WordWrap
                                    visible: detailPanel.postSelfText !== ""
                                    onLinkActivated: Qt.openUrlExternally(link)
                                }
                            }
                        }
                        
                        // Comments header
                        Rectangle {
                            width: parent.width
                            height: units.gu(5)
                            color: root.bgColor
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: units.gu(1.5)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: units.gu(1)
                                
                                Label {
                                    text: "💬 Comments"
                                    font.pixelSize: units.gu(1.8)
                                    font.weight: Font.Medium
                                    color: root.textColor
                                }
                                
                                Label {
                                    text: "(" + detailPanel.commentsModel.length + ")"
                                    font.pixelSize: units.gu(1.5)
                                    color: root.subtextColor
                                    visible: !detailPanel.isLoadingComments
                                }
                                
                                RedditLoadingAnimation {
                                    running: detailPanel.isLoadingComments
                                    visible: running
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    accentColor: "#FF4500"
                                    darkMode: root.darkMode
                                }
                            }
                        }
                        
                        // Comments list
                        Repeater {
                            model: detailPanel.commentsModel
                            
                            delegate: Rectangle {
                                width: detailContentColumn.width
                                height: commentColumn.height + units.gu(2)
                                color: index % 2 === 0 ? root.bgColor : Qt.rgba(root.cardColor.r, root.cardColor.g, root.cardColor.b, 0.5)
                                
                                // Thread indicator line
                                Rectangle {
                                    visible: (modelData.depth || 0) > 0
                                    x: units.gu(1) + ((modelData.depth || 1) - 1) * units.gu(1.5)
                                    width: units.gu(0.3)
                                    height: parent.height
                                    color: {
                                        var colors = ["#FF4500", "#0079D3", "#46D160", "#FFD700", "#9B59B6", "#00CEC9"];
                                        return colors[((modelData.depth || 1) - 1) % colors.length];
                                    }
                                }
                                
                                Column {
                                    id: commentColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: units.gu(1)
                                    anchors.leftMargin: units.gu(1.5) + (modelData.depth || 0) * units.gu(1.5)
                                    spacing: units.gu(0.5)
                                    
                                    // Comment header
                                    Row {
                                        spacing: units.gu(1)
                                        
                                        Label {
                                            text: modelData.author || "[deleted]"
                                            font.pixelSize: units.gu(1.4)
                                            font.weight: Font.Medium
                                            color: root.accentColor
                                        }
                                        
                                        Label {
                                            text: "•"
                                            font.pixelSize: units.gu(1.3)
                                            color: root.subtextColor
                                        }
                                        
                                        Label {
                                            text: (modelData.score || 0) + " pts"
                                            font.pixelSize: units.gu(1.3)
                                            color: root.subtextColor
                                        }
                                    }
                                    
                                    // Comment body
                                    Label {
                                        width: parent.width
                                        text: modelData.body || ""
                                        font.pixelSize: units.gu(1.5)
                                        color: root.textColor
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                        
                        // Empty state
                        Item {
                            visible: !detailPanel.isLoadingComments && detailPanel.commentsModel.length === 0
                            width: parent.width
                            height: units.gu(15)
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(1)
                                
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "💬"
                                    font.pixelSize: units.gu(4)
                                }
                                
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "No comments yet"
                                    font.pixelSize: units.gu(1.6)
                                    color: root.subtextColor
                                }
                            }
                        }
                        
                        // Bottom padding
                        Item { width: 1; height: units.gu(4) }
                    }
                }
            }
        }
    }

    // Dialogs
    SubredditSelectionDialog {
        id: subredditDialog
        categoryNames: root.categoryNames
        extendedCategoryMap: root.extendedCategoryMap
        darkMode: root.darkMode
        
        onSubredditSelected: {
            console.log("Main: Subreddit selected:", subreddit);
            root.selectedSubreddit = subreddit;
            root.isMultiSubredditMode = false; // Switch to single subreddit mode
            root.useDefaultMultiFeed = false; // Disable default multi-feed
            refreshMemes();
        }
        
        onAddToCollection: {
            console.log("Main: Adding custom subreddit to collection:", subredditName);
            databaseManager.addCustomSubreddit(subredditName, subredditName, false);
        }
    }

    ManageSubredditsDialog {
        id: manageDialog
        customSubreddits: root.customSubreddits
        
        onRemoveSubreddit: {
            console.log("Main: Removing subreddit:", subredditName);
            databaseManager.removeCustomSubreddit(subredditName);
        }
        
        onToggleFavorite: {
            console.log("Main: Toggling favorite for:", subredditName);
            databaseManager.toggleFavorite(subredditName, true); // Need to determine isFavorite value
        }
        
        onUseSubreddit: {
            console.log("Main: Using subreddit:", subredditName);
            root.selectedSubreddit = subredditName;
            root.isMultiSubredditMode = false; // Switch to single subreddit mode
            root.useDefaultMultiFeed = false; // Disable default multi-feed
            manageDialog.close();
            refreshMemes();
        }
    }

    MultiSubredditDialog {
        id: multiSubredditDialog
        categoryNames: root.categoryNames
        extendedCategoryMap: root.extendedCategoryMap
        customSubreddits: root.customSubreddits
        
        onMultiSubredditSelected: {
            console.log("Main: Multi-subreddit selected with:", subreddits.length, "subreddits");
            root.selectedSubreddits = subreddits;
            root.isMultiSubredditMode = true;
            loadMultiSubredditMemes();
        }
    }

    BookmarksDialog {
        id: bookmarksDialog
        darkMode: root.darkMode
        
        onMemeSelected: {
            console.log("Main: Opening meme from bookmarks:", meme.title);
            root.dialogImageSource = meme.image;
            fullscreenViewer.imageSource = meme.image;
            fullscreenViewer.currentIndex = 0;
            fullscreenViewer.totalCount = 1;
            fullscreenViewer.open();
        }
        
        onRemoveBookmark: {
            console.log("Main: Removing bookmark for meme ID:", memeId);
            databaseManager.unbookmarkMeme(memeId);
            loadBookmarks();
        }
        
        onClearAllBookmarks: {
            console.log("Main: Clearing all bookmarks");
            databaseManager.clearAllBookmarks();
            loadBookmarks();
        }
    }

    FullscreenImageViewer {
        id: fullscreenViewer
        
        onNavigateNext: {
            var nextIndex = root.currentMemeIndex + 1;
            if (nextIndex < memeGrid.count) {
                navigateToMeme(nextIndex);
            }
        }
        
        onNavigatePrevious: {
            var prevIndex = root.currentMemeIndex - 1;
            if (prevIndex >= 0) {
                navigateToMeme(prevIndex);
            }
        }
        
        onClosed: {
            root.currentMemeIndex = -1;
            root.dialogImageSource = "";
        }
    }

    // Post detail view for comments
    PostDetailView {
        id: postDetailView
        darkMode: root.darkMode
        
        onImageClicked: {
            console.log("Main: Image clicked in comments view, opening fullscreen");
            root.dialogImageSource = url;
            fullscreenViewer.imageSource = url;
            fullscreenViewer.currentIndex = -1;
            fullscreenViewer.totalCount = 1;
            fullscreenViewer.open();
        }
    }

    Connections {
        target: memeAPI
        onCommentsLoaded: {
            console.log("Main: Comments loaded, count:", comments.length);
            postDetailView.commentsModel = comments;
            detailPanel.commentsModel = comments;
            detailPanel.isLoadingComments = false;
        }
        onCommentsLoadingStarted: {
            postDetailView.isLoadingComments = true;
            detailPanel.isLoadingComments = true;
        }
        onCommentsLoadingFinished: {
            postDetailView.isLoadingComments = false;
            detailPanel.isLoadingComments = false;
        }
    }

    // Settings dialog
    SettingsDialog {
        id: settingsDialog
        darkMode: root.darkMode
        currentSubreddit: root.selectedSubreddit
        totalMemesLoaded: memeGrid.count
        
        onDarkModeToggled: {
            root.darkMode = enabled;
            theme.name = root.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance";
        }
        
        onClearBookmarksRequested: {
            console.log("Main: Clearing all bookmarks from settings");
            databaseManager.clearAllBookmarks();
            loadBookmarks();
        }
        
        onClearCacheRequested: {
            console.log("Main: Clearing cache and reloading from settings");
            refreshMemes();
            settingsDialog.close();
        }
    }

    // Functions
    function updateCategoryLists() {
        console.log("Main: Updating category lists with custom subreddits:", root.customSubreddits.length);
        
        // Create extended category map
        var extended = {};
        
        // Add default categories
        for (var key in root.categoryMap) {
            extended[key] = root.categoryMap[key];
        }
        
        // Add custom subreddits
        var names = root.categoryNames.slice(); // Copy default names
        
        if (root.customSubreddits.length > 0) {
            names.push("--- Custom Subreddits ---");
            
            for (var i = 0; i < root.customSubreddits.length; i++) {
                var custom = root.customSubreddits[i];
                var displayName = custom.displayName;
                if (custom.isFavorite) {
                    displayName = "⭐ " + displayName;
                }
                names.push(displayName);
                extended[displayName] = custom.subredditName;
            }
        }
        
        root.extendedCategoryMap = extended;
        root.categoryNames = names;
        
        console.log("Main: Category lists updated, total categories:", names.length);
    }

    function refreshMemes() {
        console.log("Main: Refreshing memes");
        memeGrid.clearMemes();
        memeGrid.clearError();
        memeGrid.isLoading = true;
        
        // Maintain multi-feed mode if active, otherwise load single subreddit
        if (root.isMultiSubredditMode && root.selectedSubreddits.length > 0) {
            console.log("Main: Refreshing multi-feed with", root.selectedSubreddits.length, "subreddits");
            memeAPI.fetchMultipleSubreddits(root.selectedSubreddits, undefined, false);
        } else {
            console.log("Main: Refreshing single subreddit:", root.selectedSubreddit);
            root.isMultiSubredditMode = false;
            memeAPI.fetchMemes(root.selectedSubreddit, undefined, false);
        }
    }

    function loadMoreMemes() {
        console.log("Main: Loading more memes");
        memeGrid.isLoading = true;
        if (root.isMultiSubredditMode) {
            memeAPI.fetchMultipleSubreddits(root.selectedSubreddits, undefined, true);
        } else {
            memeAPI.fetchMemes(root.selectedSubreddit, undefined, true);
        }
    }
    
    function loadMultiSubredditMemes() {
        console.log("Main: Loading multi-subreddit memes for:", root.selectedSubreddits);
        memeGrid.clearMemes();
        memeGrid.clearError();
        memeGrid.isLoading = true;
        memeAPI.fetchMultipleSubreddits(root.selectedSubreddits, undefined, false);
    }
    
    function loadDefaultMultiFeed() {
        console.log("Main: Loading default multi-feed from all subreddits");
        
        // Get all subreddit names from the category map
        var allSubreddits = [];
        for (var category in root.categoryMap) {
            var subreddit = root.categoryMap[category];
            if (allSubreddits.indexOf(subreddit) === -1) {
                allSubreddits.push(subreddit);
            }
        }
        
        // Add custom subreddits
        for (var i = 0; i < root.customSubreddits.length; i++) {
            var customSub = root.customSubreddits[i].subredditName;
            if (allSubreddits.indexOf(customSub) === -1) {
                allSubreddits.push(customSub);
            }
        }
        
        console.log("Main: Default multi-feed includes", allSubreddits.length, "subreddits");
        
        // Select top subreddits for better performance (limit to 10-12 popular ones)
        var popularSubreddits = [
            "memes",
            "dankmemes", 
            "wholesomememes",
            "funny",
            "ProgrammerHumor",
            "meirl",
            "AnimeMemes",
            "HistoryMemes",
            "2meirl4meirl",
            "PrequelMemes"
        ];
        
        // Add any custom subreddits
        for (var j = 0; j < root.customSubreddits.length; j++) {
            popularSubreddits.push(root.customSubreddits[j].subredditName);
        }
        
        root.selectedSubreddits = popularSubreddits;
        root.isMultiSubredditMode = true;
        loadMultiSubredditMemes();
    }

    function navigateToMeme(index) {
        console.log("Main: Navigating to meme at index:", index);
        if (index >= 0 && index < memeGrid.count) {
            root.currentMemeIndex = index;
            var meme = memeGrid.getMemeAt(index);
            if (meme && meme.image) {
                root.dialogImageSource = meme.image;
                fullscreenViewer.imageSource = meme.image;
                fullscreenViewer.currentIndex = index;
                fullscreenViewer.totalCount = memeGrid.count;
                
                console.log("Main: Updated fullscreen viewer with image:", meme.image);
                
                // Increment usage count for database tracking
                databaseManager.incrementUsageCount(root.selectedSubreddit);
            } else {
                console.log("Main: Invalid meme data at index:", index, meme);
            }
        }
    }
    
    // ===== BOOKMARK MANAGEMENT FUNCTIONS =====
    
    function loadBookmarks() {
        console.log("Main: Loading bookmarks");
        var bookmarks = databaseManager.getBookmarks();
        root.bookmarkedMemes = bookmarks;
        bookmarksDialog.loadBookmarks(bookmarks);
        
        // Update bookmark status for currently loaded memes
        refreshBookmarkStatus();
        console.log("Main: Loaded", bookmarks.length, "bookmarks");
    }
    
    function refreshBookmarkStatus() {
        console.log("Main: Refreshing bookmark status");
        var newStatus = {};
        
        // Check all currently loaded memes
        for (var i = 0; i < memeGrid.count; i++) {
            var meme = memeGrid.getMemeAt(i);
            if (meme && meme.id) {
                newStatus[meme.id] = databaseManager.isBookmarked(meme.id);
            }
        }
        
        root.bookmarkStatus = newStatus;
        console.log("Main: Updated bookmark status for", Object.keys(newStatus).length, "memes");
    }
    
    function updateBookmarkStatus(memeId, isBookmarked) {
        console.log("Main: Updating bookmark status for meme:", memeId, "to:", isBookmarked);
        var newStatus = {};
        // Copy existing status
        for (var key in root.bookmarkStatus) {
            newStatus[key] = root.bookmarkStatus[key];
        }
        // Update the specific meme
        newStatus[memeId] = isBookmarked;
        root.bookmarkStatus = newStatus;
    }
    
    // Note: bookmarkStatusChanged signal is automatically generated by QML for the bookmarkStatus property

    // Initialize app content (called after onboarding or if already completed)
    function initializeAppContent() {
        console.log("Main: Initializing app content");
        
        // Initialize database and load custom subreddits
        databaseManager.initializeDatabase();
        databaseManager.loadCustomSubreddits();
        
        // Load bookmarks
        loadBookmarks();
        
        // Load initial memes - use default multi-feed or single subreddit
        if (root.useDefaultMultiFeed) {
            console.log("Main: Loading default combined multi-feed");
            loadDefaultMultiFeed();
        } else {
            console.log("Main: Loading single subreddit:", root.selectedSubreddit);
            refreshMemes();
        }
        
        console.log("Main: App content initialization complete");
    }

    // Component initialization
    Component.onCompleted: {
        console.log("Main: Application started");
        
        // Apply saved theme
        theme.name = root.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance";
        
        // Check if user has completed onboarding
        if (root.hasCompletedOnboarding) {
            console.log("Main: User has completed onboarding, loading app content");
            root.showLoginScreen = false;
            initializeAppContent();
        } else {
            console.log("Main: Showing login screen for first-time user");
            root.showLoginScreen = true;
        }
        
        console.log("Main: Initial setup complete");
    }
}