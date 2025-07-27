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

QtObject {
    id: memeAPI

    // Signals
    signal memesLoaded(var memes)
    signal loadingStarted
    signal loadingFinished
    signal error(string message)

    // Properties
    property bool isLoading: false
    property string userAgent: "UbuntuTouchMemeApp/1.0"
    property int defaultLimit: 10

    // Private properties
    property var currentXhr: null

    function fetchMemes(subreddit, limit) {
        if (isLoading) {
            console.log("MemeAPI: Already loading, skipping fetch");
            return;
        }

        // Set default values
        subreddit = subreddit || "memes";
        limit = limit || defaultLimit;

        console.log("MemeAPI: Starting to fetch memes for subreddit:", subreddit);

        // Cancel any existing request
        if (currentXhr) {
            currentXhr.abort();
        }

        isLoading = true;
        loadingStarted();

        currentXhr = new XMLHttpRequest();
        var url = "https://www.reddit.com/r/" + subreddit + "/hot.json?limit=" + limit;

        currentXhr.open("GET", url, true);
        currentXhr.setRequestHeader("User-Agent", userAgent);

        currentXhr.onreadystatechange = function () {
            if (currentXhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;
                loadingFinished();

                if (currentXhr.status === 200) {
                    try {
                        var json = JSON.parse(currentXhr.responseText);
                        var posts = json.data.children;
                        console.log("MemeAPI: Received", posts.length, "posts from Reddit");

                        var memes = [];
                        for (var i = 0; i < posts.length; i++) {
                            var post = posts[i].data;

                            // Check for images (including imgur, i.redd.it, etc.)
                            if (isImagePost(post)) {
                                var meme = {
                                    id: post.id,
                                    title: post.title,
                                    image: post.url,
                                    upvotes: post.ups || 0,
                                    comments: post.num_comments || 0,
                                    subreddit: post.subreddit,
                                    author: post.author,
                                    created: post.created_utc,
                                    permalink: "https://reddit.com" + post.permalink,
                                    thumbnail: post.thumbnail
                                };
                                memes.push(meme);
                            }
                        }

                        console.log("MemeAPI: Processed", memes.length, "image posts");
                        memesLoaded(memes);
                    } catch (e) {
                        console.log("MemeAPI: Error parsing JSON:", e);
                        error("Failed to parse response: " + e.toString());
                    }
                } else {
                    console.log("MemeAPI: Network error:", currentXhr.status);
                    error("Network error: " + currentXhr.status);
                }

                currentXhr = null;
            }
        };

        currentXhr.onerror = function () {
            isLoading = false;
            loadingFinished();
            error("Network request failed");
            currentXhr = null;
        };

        currentXhr.send();
    }

    function isImagePost(post) {
        if (!post || !post.url) {
            return false;
        }

        // Check post hint
        if (post.post_hint === "image") {
            return true;
        }

        // Check URL patterns
        var url = post.url.toLowerCase();

        // Direct image URLs
        if (url.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
            return true;
        }

        // Known image hosts
        if (url.includes("i.redd.it") || url.includes("i.imgur.com") || url.includes("imgur.com/") || url.includes("preview.redd.it")) {
            return true;
        }

        return false;
    }

    function cancelCurrentRequest() {
        if (currentXhr) {
            currentXhr.abort();
            currentXhr = null;
            isLoading = false;
            loadingFinished();
        }
    }
}
