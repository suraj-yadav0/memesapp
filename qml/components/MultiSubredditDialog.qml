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
    id: multiDialog
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: Math.min(parent.width * 0.9, units.gu(50))
    height: Math.min(parent.height * 0.85, units.gu(60))
    modal: true
    focus: true
    

    // Properties
    property var categoryNames: []
    property var extendedCategoryMap: ({})
    property var customSubreddits: []
    property var selectedSubreddits: []

    // Signals
    signal multiSubredditSelected(var subreddits)

    background: Rectangle {
        color: theme.palette.normal.background
        radius: units.gu(1)
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(2)

        Label {
            text: "Create Combined Feed"
            font.weight: Font.Bold
            font.pixelSize: units.gu(2)
            Layout.fillWidth: true
        }

        

        Rectangle {
            Layout.fillWidth: true
            height: units.dp(1)
            color: theme.palette.normal.base
        }

        // Selected subreddits display
        RowLayout {
            Layout.fillWidth: true

spacing: units.gu(5)
            Label {
                text: "Selected (" + selectedSubreddits.length + "):"
                font.weight: Font.Medium
            }

            CustomButton {
                text: "Clear All"
                anchors.right: parent.right
              
                visible: selectedSubreddits.length > 0
                onClicked: {
                    selectedSubreddits = [];
                    updateSelectionDisplay();
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(8)
            visible: selectedSubreddits.length > 0

            Flow {
                id: selectedFlow
                width: parent.width
                spacing: units.gu(0.5)

                Repeater {
                    model: selectedSubreddits
                    delegate: Rectangle {
                        width: subredditChip.width + units.gu(1)
                        height: units.gu(3)
                        color: "#3498db"
                        radius: height / 2

                        RowLayout {
                            id: subredditChip
                            anchors.centerIn: parent
                            spacing: units.gu(0.5)

                            Label {
                                text: "r/" + modelData
                                color: "white"
                                font.pixelSize: units.gu(1.2)
                            }

                            Icon {
                                name: "close"
                                width: units.gu(1.5)
                                height: units.gu(1.5)
                                color: "white"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: removeSubreddit(modelData)
                        }
                    }
                }
            }
        }

        // Available subreddits list
        Label {
            text: "Available Subreddits:"
            font.weight: Font.Medium
            Layout.fillWidth: true
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: subredditListView
                width: parent.width
                
                model: ListModel {
                    id: availableSubredditsModel
                }

                section.property: "category"
                section.criteria: ViewSection.FullString
                section.delegate: Rectangle {
                    width: subredditListView.width
                    height: units.gu(4)
                    color: theme.palette.normal.base

                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1)
                        anchors.verticalCenter: parent.verticalCenter
                        text: section
                        font.weight: Font.Bold
                        color: theme.palette.normal.backgroundText
                    }
                }

                delegate: ListItem {
                    id: subredditItem
                    width: subredditListView.width
                    height: units.gu(6)

                    property bool isSelected: selectedSubreddits.indexOf(model.subreddit) >= 0

                    Rectangle {
                        anchors.fill: parent
                        color: subredditItem.isSelected ? "#E0E0E0" : "transparent"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.gu(1)

                            Column {
                                Layout.fillWidth: true
                                
                                Label {
                                    text: model.displayName
                                    font.weight: Font.Medium
                                }
                                
                                Label {
                                    text: "r/" + model.subreddit
                                    font.pixelSize: units.gu(1.1)
                                    color: theme.palette.normal.backgroundSecondaryText
                                }
                            }

                            Icon {
                                name: subredditItem.isSelected ? "tick" : "add"
                                width: units.gu(2)
                                height: units.gu(2)
                                color: subredditItem.isSelected ? "#4CAF50" : theme.palette.normal.backgroundText
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: toggleSubreddit(model.subreddit)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: units.dp(1)
            color: theme.palette.normal.base
        }

        // Action Buttons
        RowLayout {
            Layout.fillWidth: true

            CustomButton {
                text: "Cancel"
                Layout.fillWidth: true
                onClicked: multiDialog.close()
            }

            CustomButton {
                text: "Create Feed (" + selectedSubreddits.length + ")"
                Layout.fillWidth: true
               // color: "#FF4500"
                enabled: selectedSubreddits.length >= 2
                onClicked: {
                    if (selectedSubreddits.length >= 2) {
                        console.log("MultiSubredditDialog: Creating feed with subreddits:", selectedSubreddits);
                        multiSubredditSelected(selectedSubreddits.slice()); // Create a copy
                        multiDialog.close();
                    }
                }
            }
        }
    }

    // Functions
    function populateSubreddits() {
        console.log("MultiSubredditDialog: Populating subreddits");
        availableSubredditsModel.clear();

        // Add predefined categories
        for (var i = 0; i < categoryNames.length; i++) {
            var categoryName = categoryNames[i];
            if (categoryName === "--- Custom Subreddits ---") {
                continue; // Skip this separator
            }
            
            var subreddit = extendedCategoryMap[categoryName];
            if (subreddit) {
                availableSubredditsModel.append({
                    displayName: categoryName,
                    subreddit: subreddit,
                    category: "Popular Categories"
                });
            }
        }

        // Add custom subreddits
        if (customSubreddits.length > 0) {
            for (var j = 0; j < customSubreddits.length; j++) {
                var custom = customSubreddits[j];
                var displayName = custom.displayName;
                if (custom.isFavorite) {
                    displayName = "⭐ " + displayName;
                }
                availableSubredditsModel.append({
                    displayName: displayName,
                    subreddit: custom.subredditName,
                    category: "Your Subreddits"
                });
            }
        }

        console.log("MultiSubredditDialog: Added", availableSubredditsModel.count, "subreddits");
    }

    function toggleSubreddit(subreddit) {
        var index = selectedSubreddits.indexOf(subreddit);
        if (index >= 0) {
            // Remove from selection
            selectedSubreddits.splice(index, 1);
        } else {
            // Add to selection
            selectedSubreddits.push(subreddit);
        }
        updateSelectionDisplay();
        console.log("MultiSubredditDialog: Selected subreddits:", selectedSubreddits);
    }

    function removeSubreddit(subreddit) {
        var index = selectedSubreddits.indexOf(subreddit);
        if (index >= 0) {
            selectedSubreddits.splice(index, 1);
            updateSelectionDisplay();
        }
    }

    function updateSelectionDisplay() {
        // Force UI update by reassigning the array
        var temp = selectedSubreddits.slice();
        selectedSubreddits = temp;
    }

    onOpened: {
        populateSubreddits();
        selectedSubreddits = [];
    }
}