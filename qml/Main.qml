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

ApplicationWindow {
    id: root
    visible: true
    title: "MemeStream"
    width: 400
    height: 600

    Rectangle {
        anchors.fill: parent
        color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : theme.palette.normal.background
        z: -1
    }

    // Application properties
    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property bool useCustomSubreddit: false
    property string dialogImageSource: ""
    property int currentMemeIndex: -1
    property bool isDesktopMode: true
    
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
                appHeader.isLoading = false;
                memeGrid.clearError();
                refreshBookmarkStatus(); // Update bookmark status for new memes
            } else {
                memeGrid.setError("No memes found for this subreddit");
                appHeader.isLoading = false;
            }
        }
        
        onMultiSubredditMemesLoaded: {
            console.log("Main: Multi-subreddit memes loaded, count:", memes.length);
            root.subredditSources = subredditSources;
            if (memes.length > 0) {
                memeGrid.addMemes(memes);
                memeGrid.isLoading = false;
                appHeader.isLoading = false;
                memeGrid.clearError();
                refreshBookmarkStatus(); // Update bookmark status for new memes
            } else {
                memeGrid.setError("No memes found from selected subreddits");
                appHeader.isLoading = false;
            }
        }
        
        onMultiSubredditProgress: {
            console.log("Main: Multi-subreddit progress:", completed, "/", total);
            // Could show progress in UI if needed
        }
        
        onError: {
            console.log("Main: Error loading memes:", message);
            memeGrid.setError(message);
            appHeader.isLoading = false;
        }
    }

    // Settings persistence
    Settings {
        id: settings
        property alias selectedSubreddit: root.selectedSubreddit
        property alias darkMode: root.darkMode
    }

    // Main layout
    Page {
        anchors.fill: parent
        
        // Application header
        header: AppHeader {
            id: appHeader
            currentSubreddit: root.selectedSubreddit
            isMultiSubredditMode: root.isMultiSubredditMode
            currentSubreddits: root.selectedSubreddits
            
            onSubredditSelectionRequested: subredditDialog.open()
            onManageSubredditsRequested: manageDialog.open()
            onSettingsRequested: settingsDialog.open()
            onRefreshRequested: refreshMemes()
            onMultiSubredditSelectionRequested: multiSubredditDialog.open()
            onBookmarksRequested: {
                loadBookmarks();
                bookmarksDialog.open();
            }
        }
        
        // Meme grid view
        MemeGridView {
            id: memeGrid
            anchors.fill: parent
            anchors.topMargin: appHeader.height
            isMultiSubredditMode: root.isMultiSubredditMode
            subredditSources: root.subredditSources
            bookmarkStatus: root.bookmarkStatus
            
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
                    postDetailView.postId = meme.id;
                    postDetailView.postTitle = meme.title;
                    postDetailView.postImage = meme.image;
                    postDetailView.postAuthor = meme.author;
                    postDetailView.postSubreddit = meme.subreddit;
                    postDetailView.postUpvotes = meme.upvotes;
                    postDetailView.postCommentCount = meme.comments;
                    postDetailView.postSelfText = meme.selftext;
                    postDetailView.postType = meme.postType;
                    postDetailView.postPermalink = meme.permalink;
                    
                    postDetailView.commentsModel = []; // Clear previous comments
                    postDetailView.open();
                    
                    memeAPI.fetchComments(meme.subreddit, meme.id);
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
                if (!isLoading && !appHeader.isLoading) {
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

    // Dialogs
    SubredditSelectionDialog {
        id: subredditDialog
        categoryNames: root.categoryNames
        extendedCategoryMap: root.extendedCategoryMap
        
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
        }
        onCommentsLoadingStarted: {
            postDetailView.isLoadingComments = true;
        }
        onCommentsLoadingFinished: {
            postDetailView.isLoadingComments = false;
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
        appHeader.isLoading = true;
        
        // Maintain multi-feed mode if active, otherwise load single subreddit
        if (root.isMultiSubredditMode && root.selectedSubreddits.length > 0) {
            console.log("Main: Refreshing multi-feed with", root.selectedSubreddits.length, "subreddits");
            memeAPI.fetchMultipleSubreddits(root.selectedSubreddits);
        } else {
            console.log("Main: Refreshing single subreddit:", root.selectedSubreddit);
            root.isMultiSubredditMode = false;
            memeAPI.fetchMemes(root.selectedSubreddit);
        }
    }

    function loadMoreMemes() {
        console.log("Main: Loading more memes");
        memeGrid.isLoading = true;
        if (root.isMultiSubredditMode) {
            memeAPI.fetchMultipleSubreddits(root.selectedSubreddits);
        } else {
            memeAPI.fetchMemes(root.selectedSubreddit); // MemeAPI handles pagination internally
        }
    }
    
    function loadMultiSubredditMemes() {
        console.log("Main: Loading multi-subreddit memes for:", root.selectedSubreddits);
        memeGrid.clearMemes();
        memeGrid.clearError();
        memeGrid.isLoading = true;
        appHeader.isLoading = true;
        memeAPI.fetchMultipleSubreddits(root.selectedSubreddits);
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

    // Component initialization
    Component.onCompleted: {
        console.log("Main: Application started");
        
        // Apply saved theme
        theme.name = root.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance";
        
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
        
        console.log("Main: Initial setup complete");
    }
}