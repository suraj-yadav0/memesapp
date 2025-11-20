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
import QtQuick.LocalStorage 2.12

QtObject {
    id: dbManager
    
    // Signals
    signal subredditAdded(string displayName, string subredditName)
    signal subredditRemoved(string displayName, string subredditName)
    signal customSubredditsLoaded(var subreddits)
    signal errorOccurred(string message)
    
    // Bookmark signals
    signal memeBookmarked(string memeId, string title)
    signal memeUnbookmarked(string memeId)
    signal bookmarksLoaded(var bookmarks)
    
    // Properties
    property var db: null
    property bool initialized: false
    
    // Database name and version
    readonly property string dbName: "MemesAppDB"
    readonly property string dbVersion: "1.0"
    readonly property string dbDescription: "MemeStream App Local Database"
    
    Component.onCompleted: {
        initializeDatabase();
    }
    
    function initializeDatabase() {
        try {
            console.log("DatabaseManager: Initializing database");
            db = LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, 1000000);
            
            db.transaction(function(tx) {
                // Create custom_subreddits table
                tx.executeSql(
                    'CREATE TABLE IF NOT EXISTS custom_subreddits (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'display_name TEXT UNIQUE NOT NULL, ' +
                    'subreddit_name TEXT UNIQUE NOT NULL, ' +
                    'date_added DATETIME DEFAULT CURRENT_TIMESTAMP, ' +
                    'usage_count INTEGER DEFAULT 0, ' +
                    'is_favorite BOOLEAN DEFAULT 0' +
                    ')'
                );
                
                // Create bookmarks table for favorite memes
                tx.executeSql(
                    'CREATE TABLE IF NOT EXISTS bookmarks (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'meme_id TEXT UNIQUE NOT NULL, ' +
                    'title TEXT NOT NULL, ' +
                    'image_url TEXT NOT NULL, ' +
                    'subreddit TEXT NOT NULL, ' +
                    'author TEXT, ' +
                    'permalink TEXT, ' +
                    'upvotes INTEGER DEFAULT 0, ' +
                    'comments INTEGER DEFAULT 0, ' +
                    'date_bookmarked DATETIME DEFAULT CURRENT_TIMESTAMP, ' +
                    'thumbnail_data BLOB' +  // Store thumbnail for offline viewing
                    ')'
                );
                
                // Create hidden_subreddits table for default subreddits user wants to hide
                tx.executeSql(
                    'CREATE TABLE IF NOT EXISTS hidden_subreddits (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'subreddit_name TEXT UNIQUE NOT NULL, ' +
                    'date_hidden DATETIME DEFAULT CURRENT_TIMESTAMP' +
                    ')'
                );
                
                console.log("DatabaseManager: Database tables created successfully");
            });
            
            initialized = true;
            loadCustomSubreddits();
            
        } catch (error) {
            console.log("DatabaseManager: Error initializing database:", error);
            errorOccurred("Failed to initialize local database: " + error);
        }
    }
    
    function addCustomSubreddit(displayName, subredditName) {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            errorOccurred("Database not initialized");
            return false;
        }
        
        try {
            var success = false;
            db.transaction(function(tx) {
                // Check if subreddit already exists
                var result = tx.executeSql(
                    'SELECT id FROM custom_subreddits WHERE subreddit_name = ? OR display_name = ?',
                    [subredditName, displayName]
                );
                
                if (result.rows.length > 0) {
                    console.log("DatabaseManager: Subreddit already exists:", subredditName);
                    errorOccurred("Subreddit '" + displayName + "' already exists in your collection");
                    return;
                }
                
                // Add new subreddit
                tx.executeSql(
                    'INSERT INTO custom_subreddits (display_name, subreddit_name) VALUES (?, ?)',
                    [displayName, subredditName]
                );
                
                console.log("DatabaseManager: Added custom subreddit:", displayName, "->", subredditName);
                success = true;
            });
            
            if (success) {
                subredditAdded(displayName, subredditName);
                loadCustomSubreddits(); // Refresh the list
                return true;
            }
            
        } catch (error) {
            console.log("DatabaseManager: Error adding subreddit:", error);
            errorOccurred("Failed to add subreddit: " + error);
        }
        
        return false;
    }
    
    function removeCustomSubreddit(subredditName) {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            return false;
        }
        
        try {
            var removedDisplayName = "";
            var success = false;
            
            db.transaction(function(tx) {
                // Get display name before deletion
                var result = tx.executeSql(
                    'SELECT display_name FROM custom_subreddits WHERE subreddit_name = ?',
                    [subredditName]
                );
                
                if (result.rows.length === 0) {
                    console.log("DatabaseManager: Subreddit not found for removal:", subredditName);
                    return;
                }
                
                removedDisplayName = result.rows.item(0).display_name;
                
                // Remove subreddit
                tx.executeSql(
                    'DELETE FROM custom_subreddits WHERE subreddit_name = ?',
                    [subredditName]
                );
                
                console.log("DatabaseManager: Removed custom subreddit:", removedDisplayName);
                success = true;
            });
            
            if (success) {
                subredditRemoved(removedDisplayName, subredditName);
                loadCustomSubreddits(); // Refresh the list
                return true;
            }
            
        } catch (error) {
            console.log("DatabaseManager: Error removing subreddit:", error);
            errorOccurred("Failed to remove subreddit: " + error);
        }
        
        return false;
    }
    
    function loadCustomSubreddits() {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            return;
        }
        
        try {
            var subreddits = [];
            
            db.readTransaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT display_name, subreddit_name, usage_count, is_favorite FROM custom_subreddits ORDER BY is_favorite DESC, usage_count DESC, display_name ASC'
                );
                
                for (var i = 0; i < result.rows.length; i++) {
                    var row = result.rows.item(i);
                    subreddits.push({
                        displayName: row.display_name,
                        subredditName: row.subreddit_name,
                        usageCount: row.usage_count,
                        isFavorite: row.is_favorite === 1
                    });
                }
                
                console.log("DatabaseManager: Loaded", subreddits.length, "custom subreddits");
            });
            
            customSubredditsLoaded(subreddits);
            
        } catch (error) {
            console.log("DatabaseManager: Error loading subreddits:", error);
            errorOccurred("Failed to load custom subreddits: " + error);
        }
    }
    
    function incrementUsageCount(subredditName) {
        if (!initialized) return;
        
        try {
            db.transaction(function(tx) {
                tx.executeSql(
                    'UPDATE custom_subreddits SET usage_count = usage_count + 1 WHERE subreddit_name = ?',
                    [subredditName]
                );
            });
            console.log("DatabaseManager: Incremented usage count for:", subredditName);
        } catch (error) {
            console.log("DatabaseManager: Error incrementing usage count:", error);
        }
    }
    
    function toggleFavorite(subredditName) {
        if (!initialized) return false;
        
        try {
            var newFavoriteStatus = false;
            
            db.transaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT is_favorite FROM custom_subreddits WHERE subreddit_name = ?',
                    [subredditName]
                );
                
                if (result.rows.length > 0) {
                    var currentStatus = result.rows.item(0).is_favorite === 1;
                    newFavoriteStatus = !currentStatus;
                    
                    tx.executeSql(
                        'UPDATE custom_subreddits SET is_favorite = ? WHERE subreddit_name = ?',
                        [newFavoriteStatus ? 1 : 0, subredditName]
                    );
                }
            });
            
            console.log("DatabaseManager: Toggled favorite status for:", subredditName, "to", newFavoriteStatus);
            loadCustomSubreddits(); // Refresh list
            return newFavoriteStatus;
            
        } catch (error) {
            console.log("DatabaseManager: Error toggling favorite:", error);
            return false;
        }
    }
    
    function getAllSubreddits() {
        if (!initialized) return [];
        
        var allSubreddits = [];
        
        try {
            db.readTransaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT display_name, subreddit_name FROM custom_subreddits ORDER BY is_favorite DESC, usage_count DESC, display_name ASC'
                );
                
                for (var i = 0; i < result.rows.length; i++) {
                    var row = result.rows.item(i);
                    allSubreddits.push({
                        displayName: row.display_name,
                        subredditName: row.subreddit_name
                    });
                }
            });
        } catch (error) {
            console.log("DatabaseManager: Error getting all subreddits:", error);
        }
        
        return allSubreddits;
    }
    
    // ===== BOOKMARK MANAGEMENT FUNCTIONS =====
    
    function bookmarkMeme(meme) {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            errorOccurred("Database not initialized");
            return false;
        }
        
        try {
            var success = false;
            db.transaction(function(tx) {
                // Check if already bookmarked
                var existing = tx.executeSql(
                    'SELECT id FROM bookmarks WHERE meme_id = ?',
                    [meme.id]
                );
                
                if (existing.rows.length === 0) {
                    // Add new bookmark
                    tx.executeSql(
                        'INSERT INTO bookmarks (meme_id, title, image_url, subreddit, author, permalink, upvotes, comments) ' +
                        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                        [
                            meme.id || "",
                            meme.title || "",
                            meme.image || meme.url || "",
                            meme.subreddit || "",
                            meme.author || "",
                            meme.permalink || "",
                            meme.upvotes || 0,
                            meme.comments || 0
                        ]
                    );
                    success = true;
                    console.log("DatabaseManager: Bookmarked meme:", meme.title);
                } else {
                    console.log("DatabaseManager: Meme already bookmarked:", meme.title);
                    success = false;
                }
            });
            
            if (success) {
                memeBookmarked(meme.id, meme.title);
            }
            return success;
            
        } catch (error) {
            console.log("DatabaseManager: Error bookmarking meme:", error);
            errorOccurred("Failed to bookmark meme: " + error);
            return false;
        }
    }
    
    function unbookmarkMeme(memeId) {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            errorOccurred("Database not initialized");
            return false;
        }
        
        try {
            var success = false;
            db.transaction(function(tx) {
                var result = tx.executeSql(
                    'DELETE FROM bookmarks WHERE meme_id = ?',
                    [memeId]
                );
                success = result.rowsAffected > 0;
            });
            
            if (success) {
                console.log("DatabaseManager: Removed bookmark for meme ID:", memeId);
                memeUnbookmarked(memeId);
            }
            return success;
            
        } catch (error) {
            console.log("DatabaseManager: Error removing bookmark:", error);
            errorOccurred("Failed to remove bookmark: " + error);
            return false;
        }
    }
    
    function isBookmarked(memeId) {
        if (!initialized) return false;
        
        var isBookmarked = false;
        try {
            db.readTransaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT id FROM bookmarks WHERE meme_id = ?',
                    [memeId]
                );
                isBookmarked = result.rows.length > 0;
            });
        } catch (error) {
            console.log("DatabaseManager: Error checking bookmark status:", error);
        }
        
        return isBookmarked;
    }
    
    function getBookmarks() {
        if (!initialized) return [];
        
        var bookmarks = [];
        try {
            db.readTransaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT * FROM bookmarks ORDER BY date_bookmarked DESC'
                );
                
                for (var i = 0; i < result.rows.length; i++) {
                    var row = result.rows.item(i);
                    bookmarks.push({
                        id: row.meme_id,
                        title: row.title,
                        image: row.image_url,
                        url: row.image_url,  // For compatibility
                        subreddit: row.subreddit,
                        author: row.author,
                        permalink: row.permalink,
                        upvotes: row.upvotes,
                        comments: row.comments,
                        dateBookmarked: row.date_bookmarked
                    });
                }
            });
        } catch (error) {
            console.log("DatabaseManager: Error loading bookmarks:", error);
        }
        
        return bookmarks;
    }
    
    function getBookmarkCount() {
        if (!initialized) return 0;
        
        var count = 0;
        try {
            db.readTransaction(function(tx) {
                var result = tx.executeSql('SELECT COUNT(*) as count FROM bookmarks');
                if (result.rows.length > 0) {
                    count = result.rows.item(0).count;
                }
            });
        } catch (error) {
            console.log("DatabaseManager: Error getting bookmark count:", error);
        }
        
        return count;
    }
    
    function clearAllBookmarks() {
        if (!initialized) return false;
        
        try {
            var success = false;
            db.transaction(function(tx) {
                tx.executeSql('DELETE FROM bookmarks');
                success = true;
            });
            
            console.log("DatabaseManager: Cleared all bookmarks");
            return success;
            
        } catch (error) {
            console.log("DatabaseManager: Error clearing bookmarks:", error);
            errorOccurred("Failed to clear bookmarks: " + error);
            return false;
        }
    }
    
    // ===== HIDDEN SUBREDDITS MANAGEMENT =====
    
    function hideDefaultSubreddit(subredditName) {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            errorOccurred("Database not initialized");
            return false;
        }
        
        try {
            var success = false;
            db.transaction(function(tx) {
                // Check if already hidden
                var existing = tx.executeSql(
                    'SELECT id FROM hidden_subreddits WHERE subreddit_name = ?',
                    [subredditName]
                );
                
                if (existing.rows.length === 0) {
                    tx.executeSql(
                        'INSERT INTO hidden_subreddits (subreddit_name) VALUES (?)',
                        [subredditName]
                    );
                    success = true;
                    console.log("DatabaseManager: Hidden default subreddit:", subredditName);
                }
            });
            
            return success;
            
        } catch (error) {
            console.log("DatabaseManager: Error hiding subreddit:", error);
            errorOccurred("Failed to hide subreddit: " + error);
            return false;
        }
    }
    
    function unhideDefaultSubreddit(subredditName) {
        if (!initialized) {
            console.log("DatabaseManager: Database not initialized");
            errorOccurred("Database not initialized");
            return false;
        }
        
        try {
            var success = false;
            db.transaction(function(tx) {
                var result = tx.executeSql(
                    'DELETE FROM hidden_subreddits WHERE subreddit_name = ?',
                    [subredditName]
                );
                success = result.rowsAffected > 0;
            });
            
            if (success) {
                console.log("DatabaseManager: Unhidden default subreddit:", subredditName);
            }
            return success;
            
        } catch (error) {
            console.log("DatabaseManager: Error unhiding subreddit:", error);
            errorOccurred("Failed to unhide subreddit: " + error);
            return false;
        }
    }
    
    function isSubredditHidden(subredditName) {
        if (!initialized) return false;
        
        var isHidden = false;
        try {
            db.readTransaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT id FROM hidden_subreddits WHERE subreddit_name = ?',
                    [subredditName]
                );
                isHidden = result.rows.length > 0;
            });
        } catch (error) {
            console.log("DatabaseManager: Error checking if subreddit is hidden:", error);
        }
        
        return isHidden;
    }
    
    function getHiddenSubreddits() {
        if (!initialized) return [];
        
        var hiddenList = [];
        try {
            db.readTransaction(function(tx) {
                var result = tx.executeSql(
                    'SELECT subreddit_name FROM hidden_subreddits ORDER BY date_hidden DESC'
                );
                
                for (var i = 0; i < result.rows.length; i++) {
                    hiddenList.push(result.rows.item(i).subreddit_name);
                }
            });
        } catch (error) {
            console.log("DatabaseManager: Error loading hidden subreddits:", error);
        }
        
        return hiddenList;
    }
}