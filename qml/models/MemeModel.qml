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

ListModel {
    id: memeModel

    // Signals
    signal modelUpdated(int count)
    signal memeAdded(var meme)
    signal modelCleared

    function addMeme(meme) {
        if (!meme || !meme.id) {
            console.log("MemeModel: Invalid meme data provided");
            return false;
        }

        // Check for duplicates
        for (var i = 0; i < count; i++) {
            if (get(i).id === meme.id) {
                console.log("MemeModel: Duplicate meme found, skipping:", meme.id);
                return false;
            }
        }

        append({
            id: meme.id || "",
            title: meme.title || "Untitled",
            image: meme.image || "",
            images: meme.images || [],
            postType: meme.postType || "image",
            selftext: meme.selftext || "",
            upvotes: meme.upvotes || 0,
            comments: meme.comments || 0,
            subreddit: meme.subreddit || "",
            author: meme.author || "",
            created: meme.created || 0,
            permalink: meme.permalink || "",
            thumbnail: meme.thumbnail || ""
        });

        memeAdded(meme);
        modelUpdated(count);
        return true;
    }

    function addMemes(memes) {
        if (!memes || !Array.isArray(memes)) {
            console.log("MemeModel: Invalid memes array provided");
            return 0;
        }

        var addedCount = 0;
        for (var i = 0; i < memes.length; i++) {
            if (addMeme(memes[i])) {
                addedCount++;
            }
        }

        console.log("MemeModel: Added", addedCount, "memes out of", memes.length);
        return addedCount;
    }

    function clearModel() {
        clear();
        modelCleared();
        modelUpdated(0);
        console.log("MemeModel: Model cleared");
    }

    function getMeme(index) {
        if (index < 0 || index >= count) {
            console.log("MemeModel: Invalid index:", index);
            return null;
        }
        return get(index);
    }

    function getMemeById(id) {
        for (var i = 0; i < count; i++) {
            var meme = get(i);
            if (meme.id === id) {
                return meme;
            }
        }
        return null;
    }

    function updateMeme(index, updates) {
        if (index < 0 || index >= count) {
            console.log("MemeModel: Invalid index for update:", index);
            return false;
        }

        if (!updates || typeof updates !== 'object') {
            console.log("MemeModel: Invalid updates object");
            return false;
        }

        var meme = get(index);
        for (var key in updates) {
            if (updates.hasOwnProperty(key) && meme.hasOwnProperty(key)) {
                setProperty(index, key, updates[key]);
            }
        }

        modelUpdated(count);
        return true;
    }

    function isEmpty() {
        return count === 0;
    }

    function getStatistics() {
        if (isEmpty()) {
            return {
                totalMemes: 0,
                totalUpvotes: 0,
                totalComments: 0,
                averageUpvotes: 0,
                averageComments: 0
            };
        }

        var totalUpvotes = 0;
        var totalComments = 0;

        for (var i = 0; i < count; i++) {
            var meme = get(i);
            totalUpvotes += meme.upvotes || 0;
            totalComments += meme.comments || 0;
        }

        return {
            totalMemes: count,
            totalUpvotes: totalUpvotes,
            totalComments: totalComments,
            averageUpvotes: Math.round(totalUpvotes / count),
            averageComments: Math.round(totalComments / count)
        };
    }
}
