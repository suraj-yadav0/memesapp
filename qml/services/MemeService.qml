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
import "../models"

QtObject {
    id: memeService

    // Properties
    property var memeModel: null
    property string currentSubreddit: "memes"
    property bool isLoading: false
    property string lastError: ""

    // Private properties
    property var memeAPI: MemeAPI {
        id: api

        onMemesLoaded: {
            console.log("MemeService: Received", memes.length, "memes from API");
            if (memeService.memeModel) {
                memeService.memeModel.clearModel();
                var addedCount = memeService.memeModel.addMemes(memes);
                console.log("MemeService: Added", addedCount, "memes to model");
                memeService.memesRefreshed(addedCount);
            } else {
                console.log("MemeService: No model attached");
            }
        }

        onLoadingStarted: {
            memeService.isLoading = true;
            memeService.loadingChanged(true);
        }

        onLoadingFinished: {
            memeService.isLoading = false;
            memeService.loadingChanged(false);
        }

        onError: {
            console.log("MemeService: API Error:", message);
            memeService.lastError = message;
            memeService.errorOccurred(message);
        }
    }

    // Signals
    signal memesRefreshed(int count)
    signal loadingChanged(bool loading)
    signal errorOccurred(string message)
    signal subredditChanged(string subreddit)

    // Public methods
    function setModel(model) {
        if (model && typeof model === 'object') {
            memeModel = model;
            console.log("MemeService: Model attached successfully");
            return true;
        } else {
            console.log("MemeService: Invalid model provided");
            return false;
        }
    }

    function fetchMemes(subreddit, limit) {
        subreddit = subreddit || currentSubreddit;
        limit = limit || 10;

        if (subreddit !== currentSubreddit) {
            currentSubreddit = subreddit;
            subredditChanged(subreddit);
        }

        console.log("MemeService: Fetching memes for subreddit:", subreddit);

        if (!memeModel) {
            console.log("MemeService: No model attached, cannot fetch memes");
            errorOccurred("No model attached");
            return false;
        }

        api.fetchMemes(subreddit, limit);
        return true;
    }

    function refreshMemes() {
        return fetchMemes(currentSubreddit);
    }

    function cancelRequest() {
        api.cancelCurrentRequest();
    }

    function clearMemes() {
        if (memeModel) {
            memeModel.clearModel();
            console.log("MemeService: Memes cleared");
        }
    }

    function getMemeCount() {
        return memeModel ? memeModel.count : 0;
    }

    function getMeme(index) {
        return memeModel ? memeModel.getMeme(index) : null;
    }

    function getMemeById(id) {
        return memeModel ? memeModel.getMemeById(id) : null;
    }

    function getStatistics() {
        return memeModel ? memeModel.getStatistics() : null;
    }

    function isModelEmpty() {
        return memeModel ? memeModel.isEmpty() : true;
    }

    // Initialization
    Component.onCompleted: {
        console.log("MemeService: Service initialized");
    }

    Component.onDestruction: {
        cancelRequest();
        console.log("MemeService: Service destroyed");
    }
}
