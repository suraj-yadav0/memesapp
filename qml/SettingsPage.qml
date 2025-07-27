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

import Lomiri.Components 1.3
import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import "components"

Page {
    id: settingsPage
    title: "Settings"

    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property var categoryNames: []
    property var categoryMap: ({})
    property var memeFetcher: null

    signal darkModeChanged(bool darkMode)
    signal selectedSubredditChanged(string subreddit)

    header: PageHeader {
        id: pageHeader
        title: "Settings"
        subtitle: "Customize your meme experience"

        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"
                    text: "Back"
                    onTriggered: pageStack.pop()
                }
            ]
        }
    }

    // Simple test content first
    Column {
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(2)
        }
        spacing: units.gu(2)

        Label {
            text: "Settings Page"
            font.bold: true
            fontSize: "x-large"
            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
        }

        Label {
            text: "Dark Mode: " + settingsPage.darkMode
            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
        }

        Label {
            text: "Selected Subreddit: " + settingsPage.selectedSubreddit
            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
        }

        Label {
            text: "Category Names Count: " + settingsPage.categoryNames.length
            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
        }

        // Theme Settings Section
        UbuntuShape {
            width: parent.width
            height: units.gu(8)
            backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"

            Row {
                anchors.centerIn: parent
                spacing: units.gu(2)

                Label {
                    text: "Dark Mode"
                    anchors.verticalCenter: parent.verticalCenter
                    color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                }

                Switch {
                    id: darkModeSwitch
                    checked: settingsPage.darkMode
                    onCheckedChanged: {
                        console.log("Dark mode changed to:", checked);
                        settingsPage.darkMode = checked;
                        settingsPage.darkModeChanged(checked);
                    }
                }
            }
        }

        // Category Settings Section
        UbuntuShape {
            width: parent.width
            height: units.gu(12)
            backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"

            Column {
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }
                spacing: units.gu(1)

                Label {
                    text: "Default Category"
                    font.bold: true
                    color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                }

                OptionSelector {
                    id: categorySelector
                    width: parent.width
                    categoryNames: settingsPage.categoryNames
                    categoryMap: settingsPage.categoryMap
                    selectedSubreddit: settingsPage.selectedSubreddit
                    memeFetcher: settingsPage.memeFetcher

                    onSelectedSubredditChanged: {
                        console.log("Selected subreddit changed to:", selectedSubreddit);
                        settingsPage.selectedSubreddit = selectedSubreddit;
                        settingsPage.selectedSubredditChanged(selectedSubreddit);
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("SettingsPage Component.onCompleted called");
        console.log("SettingsPage darkMode:", settingsPage.darkMode);
        console.log("SettingsPage selectedSubreddit:", settingsPage.selectedSubreddit);
        console.log("SettingsPage categoryNames length:", settingsPage.categoryNames.length);
        
        // Set initial selection in the OptionSelector
        if (categorySelector && settingsPage.categoryNames.length > 0) {
            categorySelector.setInitialSelection(settingsPage.selectedSubreddit);
        }
    }
}
