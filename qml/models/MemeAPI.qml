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
    signal multiSubredditMemesLoaded(var memes, var subredditSources)
    signal commentsLoaded(var comments)
    signal loadingStarted
    signal loadingFinished
    signal commentsLoadingStarted
    signal commentsLoadingFinished
    signal multiSubredditProgress(int completed, int total)
    signal error(string message)

    // Properties
    property bool isLoading: false
    property string userAgent: "UbuntuTouchMemeApp/1.0"
    property int defaultLimit: 50
    property string afterToken: ""
    property var subredditAfterTokens: ({})

    // Private properties
    property var currentXhr: null
    property var activeRequests: []  // Track multiple concurrent requests
    property int completedRequests: 0
    property int totalRequests: 0

    function fetchMemes(subreddit, limit, loadMore) {
        if (isLoading) {
            console.log("MemeAPI: Already loading, skipping fetch");
            return;
        }

        // Set default values
        subreddit = subreddit || "memes";
        limit = limit || defaultLimit;
        loadMore = loadMore || false;

        if (!loadMore) {
            afterToken = "";
        }

        console.log("MemeAPI: Starting to fetch memes for subreddit:", subreddit, "LoadMore:", loadMore);

        // Cancel any existing request
        if (currentXhr) {
            currentXhr.abort();
        }

        isLoading = true;
        loadingStarted();

        currentXhr = new XMLHttpRequest();
        var url = "https://www.reddit.com/r/" + subreddit + "/hot.json?limit=" + limit;
        
        if (loadMore && afterToken !== "") {
            url += "&after=" + afterToken;
        }

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
                        
                        // Update after token for next page
                        if (json.data && json.data.after) {
                            afterToken = json.data.after;
                            console.log("MemeAPI: Updated after token:", afterToken);
                        } else {
                            afterToken = "";
                        }

                        console.log("MemeAPI: Received", posts.length, "posts from Reddit");

                        var memes = [];
                        for (var i = 0; i < posts.length; i++) {
                            var post = posts[i].data;

                            // Include both image and text posts
                            var isImage = isImagePost(post);
                            var isText = isTextPost(post);
                            var isGallery = isGalleryPost(post);
                            
                            if (isImage || isText || isGallery) {
                                var galleryImages = isGallery ? getGalleryImages(post) : [];
                                var meme = {
                                    id: post.id,
                                    title: post.title,
                                    image: isImage ? post.url : (isGallery && galleryImages.length > 0 ? galleryImages[0] : ""),
                                    images: galleryImages,
                                    postType: isGallery ? "gallery" : (isImage ? "image" : "text"),
                                    selftext: isText ? post.selftext : "",
                                    selftext_html: isText ? (post.selftext_html || "") : "",
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

                        console.log("MemeAPI: Processed", memes.length, "posts (image and text)");
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

    function isTextPost(post) {
        if (!post) {
            return false;
        }

        // Check if post is a self post (text post)
        if (post.is_self === true) {
            return true;
        }

        // Additional check for post_hint
        if (post.post_hint === "self") {
            return true;
        }

        return false;
    }

    function isGalleryPost(post) {
        if (!post) return false;
        return post.is_gallery === true || (post.gallery_data && post.media_metadata);
    }

    function getGalleryImages(post) {
        var images = [];
        if (post.gallery_data && post.gallery_data.items && post.media_metadata) {
            var items = post.gallery_data.items;
            for (var i = 0; i < items.length; i++) {
                var mediaId = items[i].media_id;
                var media = post.media_metadata[mediaId];
                if (media && media.s) {
                    var url = "";
                    if (media.s.u) {
                        url = media.s.u.replace(/&amp;/g, "&");
                    } else if (media.s.gif) {
                        url = media.s.gif.replace(/&amp;/g, "&");
                    }
                    
                    if (url !== "") {
                        images.push(url);
                    }
                }
            }
        }
        return images;
    }

    function cancelCurrentRequest() {
        if (currentXhr) {
            currentXhr.abort();
            currentXhr = null;
            isLoading = false;
            loadingFinished();
        }
        
        // Cancel all active multi-subreddit requests
        for (var i = 0; i < activeRequests.length; i++) {
            if (activeRequests[i]) {
                activeRequests[i].abort();
            }
        }
        activeRequests = [];
        completedRequests = 0;
        memeAPI.totalRequests = 0;
    }

    function fetchMultipleSubreddits(subreddits, limitPerSubreddit, loadMore) {
        if (isLoading) {
            console.log("MemeAPI: Already loading, skipping multi-subreddit fetch");
            return;
        }

        if (!subreddits || subreddits.length === 0) {
            console.log("MemeAPI: No subreddits provided for multi-fetch");
            error("No subreddits selected");
            return;
        }
        
        loadMore = loadMore || false;
        if (!loadMore) {
            subredditAfterTokens = {};
        }

        console.log("MemeAPI: Starting multi-subreddit fetch for:", subreddits.length, "subreddits", "LoadMore:", loadMore);

        isLoading = true;
        loadingStarted();

        // Reset tracking variables
        memeAPI.activeRequests = [];
        memeAPI.completedRequests = 0;
        memeAPI.totalRequests = subreddits.length;
        
        var allMemes = [];
        var subredditSources = {}; // Track which subreddit each meme came from
        var limit = limitPerSubreddit || Math.floor(defaultLimit / subreddits.length);

        // Fetch from each subreddit
        for (var i = 0; i < subreddits.length; i++) {
            fetchSingleSubredditForMulti(subreddits[i], limit, allMemes, subredditSources, loadMore);
        }
    }

    function fetchSingleSubredditForMulti(subreddit, limit, allMemes, subredditSources, loadMore) {
        var xhr = new XMLHttpRequest();
        memeAPI.activeRequests.push(xhr);

        var url = "https://www.reddit.com/r/" + subreddit + ".json?limit=" + limit;
        
        // Use stored after token if loading more
        if (loadMore && subredditAfterTokens[subreddit]) {
            url += "&after=" + subredditAfterTokens[subreddit];
        }
        
        console.log("MemeAPI: Fetching from subreddit:", subreddit, "URL:", url);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                memeAPI.completedRequests++;
                console.log("MemeAPI: Multi-fetch progress:", memeAPI.completedRequests, "/", memeAPI.totalRequests);
                
                multiSubredditProgress(memeAPI.completedRequests, memeAPI.totalRequests);

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var posts = response.data.children;
                        
                        // Store after token for this subreddit
                        if (response.data && response.data.after) {
                            subredditAfterTokens[subreddit] = response.data.after;
                        } else {
                            delete subredditAfterTokens[subreddit];
                        }
                        
                        console.log("MemeAPI: Processing", posts.length, "posts from r/" + subreddit);

                        // Process posts from this subreddit
                        var subredditMemes = [];
                        for (var j = 0; j < posts.length; j++) {
                            var post = posts[j].data;
                            
                            var isImage = isImagePost(post);
                            var isText = isTextPost(post);
                            var isGallery = isGalleryPost(post);
                            
                            if (isImage || isText || isGallery) {
                                var galleryImages = isGallery ? getGalleryImages(post) : [];
                                var meme = {
                                    id: post.id,
                                    title: post.title,
                                    image: isImage ? post.url : (isGallery && galleryImages.length > 0 ? galleryImages[0] : ""),
                                    images: galleryImages,
                                    postType: isGallery ? "gallery" : (isImage ? "image" : "text"),
                                    selftext: isText ? post.selftext : "",
                                    upvotes: post.ups,
                                    comments: post.num_comments,
                                    subreddit: post.subreddit,
                                    author: post.author,
                                    created: post.created_utc,
                                    permalink: "https://reddit.com" + post.permalink,
                                    sourceSubreddit: subreddit // Track original subreddit
                                };
                                subredditMemes.push(meme);
                                allMemes.push(meme);
                                subredditSources[meme.id] = subreddit;
                            }
                        }
                        
                        console.log("MemeAPI: Added", subredditMemes.length, "memes from r/" + subreddit);
                    } catch (e) {
                        console.log("MemeAPI: Error parsing response from r/" + subreddit + ":", e);
                    }
                } else {
                    console.log("MemeAPI: Error loading from r/" + subreddit + ":", xhr.status, xhr.statusText);
                }

                // Check if all requests are complete
                if (memeAPI.completedRequests >= memeAPI.totalRequests) {
                    console.log("MemeAPI: Multi-subreddit fetch complete. Total memes:", allMemes.length);
                    
                    // Sort combined memes by upvotes or created time for better mixing
                    allMemes.sort(function(a, b) {
                        return b.upvotes - a.upvotes; // Sort by upvotes (highest first)
                    });
                    
                    isLoading = false;
                    loadingFinished();
                    multiSubredditMemesLoaded(allMemes, subredditSources);
                }
            }
        };

        xhr.onerror = function () {
            memeAPI.completedRequests++;
            console.log("MemeAPI: Network error for r/" + subreddit);
            
            multiSubredditProgress(completedRequests, totalRequests);
            
            if (completedRequests >= totalRequests) {
                isLoading = false;
                loadingFinished();
                if (allMemes.length > 0) {
                    multiSubredditMemesLoaded(allMemes, subredditSources);
                } else {
                    error("Failed to load memes from any subreddit");
                }
            }
        };

        xhr.open("GET", url, true);
        xhr.setRequestHeader("User-Agent", userAgent);
        xhr.send();
    }

    function fetchComments(subreddit, articleId) {
        console.log("MemeAPI: Fetching comments for", subreddit, articleId);
        
        commentsLoadingStarted();

        var xhr = new XMLHttpRequest();
        var url = "https://www.reddit.com/r/" + subreddit + "/comments/" + articleId + ".json";

        xhr.open("GET", url, true);
        xhr.setRequestHeader("User-Agent", userAgent);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                commentsLoadingFinished();

                if (xhr.status === 200) {
                    try {
                        var json = JSON.parse(xhr.responseText);
                        // json[0] is the post, json[1] is the comments
                        if (json.length > 1 && json[1].data && json[1].data.children) {
                            var comments = [];
                            flattenComments(json[1].data.children, 0, comments);
                            console.log("MemeAPI: Processed", comments.length, "comments");
                            commentsLoaded(comments);
                        } else {
                            console.log("MemeAPI: No comments found or invalid format");
                            commentsLoaded([]);
                        }
                    } catch (e) {
                        console.log("MemeAPI: Error parsing comments JSON:", e);
                        error("Failed to parse comments: " + e.toString());
                    }
                } else {
                    console.log("MemeAPI: Network error fetching comments:", xhr.status);
                    error("Network error: " + xhr.status);
                }
            }
        };

        xhr.onerror = function () {
            commentsLoadingFinished();
            error("Network request failed");
        };

        xhr.send();
    }

    function flattenComments(children, depth, result) {
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            if (child.kind === 't1') { // t1 is comment
                var data = child.data;
                var comment = {
                    id: data.id,
                    author: data.author,
                    body: data.body,
                    body_html: unescapeHtml(data.body_html || ""),
                    score: data.ups,
                    created_utc: data.created_utc,
                    depth: depth,
                    kind: 'comment'
                };
                result.push(comment);
                
                if (data.replies && data.replies.data && data.replies.data.children) {
                    flattenComments(data.replies.data.children, depth + 1, result);
                }
            }
        }
    }

    function unescapeHtml(safe) {
        if (!safe) return "";
        return safe
            .replace(/&amp;/g, "&")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&quot;/g, "\"")
            .replace(/&#039;/g, "'");
    }
}
