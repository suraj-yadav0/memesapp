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
}