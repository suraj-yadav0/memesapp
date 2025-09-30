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

Dialog {
    id: fullscreenViewer
    modal: true
    focus: true
    padding: 0
    x: 0
    y: 0
    width: parent.width
    height: parent.height
    
    // Properties
    property string imageSource: ""
    property int currentIndex: -1
    property int totalCount: 0
    
    // Signals
    signal navigateNext()
    signal navigatePrevious()
    signal closed()

    background: Rectangle {
        color: "transparent"
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: {
            fullscreenViewer.close();
            fullscreenViewer.closed();
        }
        Keys.onLeftPressed: fullscreenViewer.navigatePrevious()
        Keys.onRightPressed: fullscreenViewer.navigateNext()

        Rectangle {
            anchors.fill: parent
            color: "#000000CC"

            // Flickable container for zoom and pan functionality
            Flickable {
                id: imageFlickable
                anchors.fill: parent
                contentWidth: zoomableImage.width
                contentHeight: zoomableImage.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                
                // Enable interactive panning when zoomed
                interactive: zoomableImage.scale > 1.0
                
                // Zoom limits
                property real minZoom: 0.5
                property real maxZoom: 5.0
                
                Image {
                    id: zoomableImage
                    width: parent.parent.width * 0.94
                    height: parent.parent.height * 0.94
                    fillMode: Image.PreserveAspectFit
                    source: fullscreenViewer.imageSource
                    cache: true
                    smooth: true
                    transformOrigin: Item.Center
                    
                    property real initialScale: 1.0
                    
                    onStatusChanged: {
                        if (status === Image.Ready) {
                            // Reset zoom when new image loads
                            imageFlickable.resetZoom();
                        }
                    }
                }
                
                // Pinch to zoom functionality
                PinchArea {
                    id: pinchArea
                    anchors.fill: parent
                    
                    property real initialScale: 1.0
                    property point initialCenter
                    
                    onPinchStarted: {
                        initialScale = zoomableImage.scale;
                        initialCenter = pinch.center;
                        console.log("FullscreenViewer: Pinch zoom started, initial scale:", initialScale);
                    }
                    
                    onPinchUpdated: {
                        var newScale = initialScale * pinch.scale;
                        newScale = Math.max(imageFlickable.minZoom, Math.min(imageFlickable.maxZoom, newScale));
                        
                        zoomableImage.scale = newScale;
                        
                        // Update flickable content size
                        imageFlickable.contentWidth = zoomableImage.width * zoomableImage.scale;
                        imageFlickable.contentHeight = zoomableImage.height * zoomableImage.scale;
                        
                        console.log("FullscreenViewer: Pinch zoom updated, scale:", newScale);
                    }
                    
                    onPinchFinished: {
                        console.log("FullscreenViewer: Pinch zoom finished, final scale:", zoomableImage.scale);
                    }
                }
                
                // Mouse wheel zoom functionality
                MouseArea {
                    id: wheelZoomArea
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    
                    onWheel: {
                        var scaleFactor = wheel.angleDelta.y > 0 ? 1.2 : 0.8;
                        var newScale = zoomableImage.scale * scaleFactor;
                        newScale = Math.max(imageFlickable.minZoom, Math.min(imageFlickable.maxZoom, newScale));
                        
                        zoomableImage.scale = newScale;
                        
                        // Update flickable content size
                        imageFlickable.contentWidth = zoomableImage.width * zoomableImage.scale;
                        imageFlickable.contentHeight = zoomableImage.height * zoomableImage.scale;
                        
                        // Center the zoom on the mouse position
                        if (zoomableImage.scale > 1.0) {
                            imageFlickable.contentX = wheel.x * zoomableImage.scale - wheel.x;
                            imageFlickable.contentY = wheel.y * zoomableImage.scale - wheel.y;
                        } else {
                            imageFlickable.contentX = 0;
                            imageFlickable.contentY = 0;
                        }
                        
                        console.log("FullscreenViewer: Mouse wheel zoom, scale:", newScale);
                    }
                }
                
                // Function to reset zoom
                function resetZoom() {
                    zoomableImage.scale = 1.0;
                    contentX = 0;
                    contentY = 0;
                    contentWidth = zoomableImage.width;
                    contentHeight = zoomableImage.height;
                    console.log("FullscreenViewer: Zoom reset");
                }
            }

            // Touch and swipe gesture detection (only when not zoomed)
            MultiPointTouchArea {
                id: touchArea
                anchors.fill: imageFlickable
                mouseEnabled: false  // Let mouse wheel area handle mouse events
                enabled: zoomableImage.scale <= 1.0  // Only enable swipe when not zoomed
                
                property real startX: 0
                property real startY: 0
                property real currentX: 0
                property real currentY: 0
                property bool isSwipeActive: false
                property real minSwipeDistance: units.gu(8)  // Minimum distance for a swipe
                
                onPressed: {
                    if (touchPoints.length === 1) { // Only handle single touch for swipe
                        var touch = touchPoints[0];
                        startX = touch.x;
                        startY = touch.y;
                        currentX = touch.x;
                        currentY = touch.y;
                        isSwipeActive = true;
                        console.log("FullscreenViewer: Touch/swipe started at:", startX, startY);
                    }
                }
                
                onUpdated: {
                    // Track the primary touch point position continuously
                    if (isSwipeActive && touchPoints.length === 1) { // Only single touch
                        var touch = touchPoints[0];
                        currentX = touch.x;
                        currentY = touch.y;
                    }
                }
                
                onReleased: {
                    if (isSwipeActive && touchPoints.length === 0) {
                        var deltaX = currentX - startX;
                        var deltaY = currentY - startY;
                        var distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
                        
                        console.log("FullscreenViewer: Touch released - deltaX:", deltaX, "deltaY:", deltaY, "distance:", distance);
                        
                        // Check if it's a horizontal swipe (more horizontal than vertical)
                        if (distance > minSwipeDistance && Math.abs(deltaX) > Math.abs(deltaY) * 1.5) {
                            if (deltaX > 0) {
                                // Swipe right - go to previous meme
                                console.log("FullscreenViewer: Touch swipe right detected, navigating to previous meme");
                                fullscreenViewer.navigatePrevious();
                            } else {
                                // Swipe left - go to next meme
                                console.log("FullscreenViewer: Touch swipe left detected, navigating to next meme");
                                fullscreenViewer.navigateNext();
                            }
                        } else if (distance < minSwipeDistance) {
                            // Short tap - reset zoom if zoomed, otherwise ignore
                            if (zoomableImage.scale > 1.0) {
                                imageFlickable.resetZoom();
                            } else {
                                console.log("FullscreenViewer: Short tap detected, ignoring");
                            }
                        }
                        
                        isSwipeActive = false;
                    }
                }
                
                onCanceled: {
                    console.log("FullscreenViewer: Touch gesture canceled");
                    isSwipeActive = false;
                }
            }

            // Zoom control buttons
            Row {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: units.gu(1)
                spacing: units.gu(0.5)
                z: 100
                
                Button {
                    text: "🔍+"
                    width: units.gu(4)
                    height: units.gu(3)
                    enabled: zoomableImage.scale < imageFlickable.maxZoom
                    onClicked: {
                        var newScale = Math.min(imageFlickable.maxZoom, zoomableImage.scale * 1.5);
                        zoomableImage.scale = newScale;
                        imageFlickable.contentWidth = zoomableImage.width * newScale;
                        imageFlickable.contentHeight = zoomableImage.height * newScale;
                        console.log("FullscreenViewer: Zoom in, scale:", newScale);
                    }
                }
                
                Button {
                    text: "🔍-"
                    width: units.gu(4)
                    height: units.gu(3)
                    enabled: zoomableImage.scale > imageFlickable.minZoom
                    onClicked: {
                        var newScale = Math.max(imageFlickable.minZoom, zoomableImage.scale / 1.5);
                        zoomableImage.scale = newScale;
                        imageFlickable.contentWidth = zoomableImage.width * newScale;
                        imageFlickable.contentHeight = zoomableImage.height * newScale;
                        
                        if (newScale <= 1.0) {
                            imageFlickable.contentX = 0;
                            imageFlickable.contentY = 0;
                        }
                        console.log("FullscreenViewer: Zoom out, scale:", newScale);
                    }
                }
                
                Button {
                    text: "1:1"
                    width: units.gu(4)
                    height: units.gu(3)
                    onClicked: {
                        imageFlickable.resetZoom();
                    }
                }
            }

            // Close button
            Button {
                text: "\u2715"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: units.gu(1)
                width: units.gu(4)
                height: units.gu(4)
                z: 100
                onClicked: {
                    console.log("FullscreenViewer: Close button clicked");
                    fullscreenViewer.close();
                    fullscreenViewer.closed();
                }
            }

            // Navigation indicators (only show if there are multiple memes)
            Rectangle {
                id: navigationHint
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: units.gu(2)
                width: hintText.contentWidth + units.gu(2)
                height: units.gu(4)
                color: "#000000AA"
                radius: units.gu(1)
                visible: fullscreenViewer.totalCount > 1
                
                Text {
                    id: hintText
                    anchors.centerIn: parent
                    text: {
                        var navText = "Swipe ← → or arrow keys • " + (fullscreenViewer.currentIndex + 1) + " / " + fullscreenViewer.totalCount;
                        var zoomText = "Pinch/wheel to zoom";
                        var currentZoom = " • " + Math.round(zoomableImage.scale * 100) + "%";
                        return navText + " • " + zoomText + currentZoom;
                    }
                    color: "white"
                    font.pixelSize: units.gu(1.1)
                }
            }

            // Previous/Next navigation areas (only visible when not zoomed)
            Rectangle {
                id: prevArea
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * 0.15
                color: "transparent"
                visible: fullscreenViewer.currentIndex > 0 && zoomableImage.scale <= 1.0
                z: 50
                
                Rectangle {
                    anchors.centerIn: parent
                    width: units.gu(6)
                    height: units.gu(6)
                    color: "#000000AA"
                    radius: width / 2
                    visible: parent.hovered
                    
                    Text {
                        anchors.centerIn: parent
                        text: "◀"
                        color: "white"
                        font.pixelSize: units.gu(2)
                    }
                }
                
                property bool hovered: false
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: fullscreenViewer.navigatePrevious()
                }
            }
            
            Rectangle {
                id: nextArea
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * 0.15
                color: "transparent"
                visible: fullscreenViewer.currentIndex < fullscreenViewer.totalCount - 1 && zoomableImage.scale <= 1.0
                z: 50
                
                Rectangle {
                    anchors.centerIn: parent
                    width: units.gu(6)
                    height: units.gu(6)
                    color: "#000000AA"
                    radius: width / 2
                    visible: parent.hovered
                    
                    Text {
                        anchors.centerIn: parent
                        text: "▶"
                        color: "white"
                        font.pixelSize: units.gu(2)
                    }
                }
                
                property bool hovered: false
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: fullscreenViewer.navigateNext()
                }
            }

            // Background click area (excludes the image area and close button to prevent conflicts)
            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: {
                    // Only close if click is outside the image area and not on close button
                    var imageRect = zoomableImage.mapToItem(parent, 0, 0, zoomableImage.width, zoomableImage.height);
                    var closeButtonSize = units.gu(4);
                    var closeButtonMargin = units.gu(1);
                    
                    // Check if click is outside image area AND not in close button area
                    var clickOutsideImage = (mouse.x < imageRect.x || mouse.x > imageRect.x + imageRect.width || 
                                           mouse.y < imageRect.y || mouse.y > imageRect.y + imageRect.height);
                    var clickNotOnCloseButton = !(mouse.x >= parent.width - closeButtonSize - closeButtonMargin && 
                                                 mouse.y <= closeButtonSize + closeButtonMargin);
                    
                    if (clickOutsideImage && clickNotOnCloseButton) {
                        console.log("FullscreenViewer: Background clicked, closing dialog");
                        fullscreenViewer.close();
                        fullscreenViewer.closed();
                    }
                }
                hoverEnabled: true
                propagateComposedEvents: true
            }
        }
    }

    onClosed: {
        // Reset zoom when dialog closes
        if (imageFlickable) {
            imageFlickable.resetZoom();
        }
        fullscreenViewer.closed();
    }
}