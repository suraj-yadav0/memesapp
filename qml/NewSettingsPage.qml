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

    // Properties
    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property var categoryNames: []
    property var categoryMap: ({})
    property var memeService: null

    // Signals for dark mode and subreddit changes are automatically generated

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

    ScrollView {
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(2)
        }

        Column {
            width: parent.width
            spacing: units.gu(3)

            // Header
            Column {
                width: parent.width
                spacing: units.gu(1)

                Label {
                    text: "Settings"
                    font.bold: true
                    fontSize: "x-large"
                    color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                }

                Label {
                    text: "Customize your meme browsing experience"
                    fontSize: "medium"
                    color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            // Theme Settings Section
            UbuntuShape {
                width: parent.width
                height: themeColumn.height + units.gu(2)
                backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"

                Column {
                    id: themeColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: units.gu(1)
                    }
                    spacing: units.gu(1)

                    Label {
                        text: "Appearance"
                        font.bold: true
                        color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                    }

                    Row {
                        width: parent.width
                        spacing: units.gu(2)

                        Label {
                            text: "Dark Mode"
                            anchors.verticalCenter: parent.verticalCenter
                            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                            width: parent.width - darkModeSwitch.width - units.gu(2)
                        }

                        Switch {
                            id: darkModeSwitch
                            checked: settingsPage.darkMode
                            onCheckedChanged: {
                                console.log("SettingsPage: Dark mode changed to:", checked);
                                settingsPage.darkMode = checked;
                            }
                        }
                    }

                    Label {
                        text: "Enable dark mode for a more comfortable viewing experience in low light conditions"
                        fontSize: "small"
                        color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // Category Settings Section
            UbuntuShape {
                width: parent.width
                height: categoryColumn.height + units.gu(2)
                backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"

                Column {
                    id: categoryColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: units.gu(1)
                    }
                    spacing: units.gu(1)

                    Label {
                        text: "Default Category"
                        font.bold: true
                        color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                    }

                    Label {
                        text: "Current: r/" + settingsPage.selectedSubreddit
                        fontSize: "medium"
                        color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                    }

                    CategorySelector {
                        id: categorySelector
                        width: parent.width
                        categoryNames: settingsPage.categoryNames
                        categoryMap: settingsPage.categoryMap
                        selectedSubreddit: settingsPage.selectedSubreddit
                        memeService: settingsPage.memeService

                        onSelectedSubredditChanged: {
                            console.log("SettingsPage: Category selector subreddit changed to:", selectedSubreddit);
                            settingsPage.selectedSubreddit = selectedSubreddit;
                        }
                    }

                    Label {
                        text: "Choose your default meme category. This will be loaded when the app starts."
                        fontSize: "small"
                        color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // Statistics Section (if service provides stats)
            UbuntuShape {
                width: parent.width
                height: statisticsColumn.height + units.gu(2)
                backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"
                visible: settingsPage.memeService && !settingsPage.memeService.isModelEmpty()

                Column {
                    id: statisticsColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: units.gu(1)
                    }
                    spacing: units.gu(1)

                    Label {
                        text: "Current Session Stats"
                        font.bold: true
                        color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                    }

                    Grid {
                        columns: 2
                        spacing: units.gu(1)
                        width: parent.width

                        Label {
                            text: "Memes Loaded:"
                            color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                        }

                        Label {
                            text: settingsPage.memeService ? settingsPage.memeService.getMemeCount().toString() : "0"
                            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                        }

                        Label {
                            text: "Current Subreddit:"
                            color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                        }

                        Label {
                            text: "r/" + (settingsPage.memeService ? settingsPage.memeService.currentSubreddit : "unknown")
                            color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                        }
                    }
                }
            }

            // Actions Section
            UbuntuShape {
                width: parent.width
                height: actionsColumn.height + units.gu(2)
                backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"

                Column {
                    id: actionsColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: units.gu(1)
                    }
                    spacing: units.gu(2)

                    Label {
                        text: "Actions"
                        font.bold: true
                        color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                    }

                    Button {
                        text: "Refresh Memes"
                        width: parent.width
                        enabled: settingsPage.memeService && !settingsPage.memeService.isLoading
                        onClicked: {
                            console.log("SettingsPage: Refresh memes requested");
                            if (settingsPage.memeService) {
                                settingsPage.memeService.refreshMemes();
                            }
                        }
                    }

                    Button {
                        text: "Clear Cache"
                        width: parent.width
                        enabled: settingsPage.memeService && !settingsPage.memeService.isModelEmpty()
                        onClicked: {
                            console.log("SettingsPage: Clear cache requested");
                            if (settingsPage.memeService) {
                                settingsPage.memeService.clearMemes();
                            }
                        }
                    }
                }
            }

            // About Section
            UbuntuShape {
                width: parent.width
                height: aboutColumn.height + units.gu(2)
                backgroundColor: settingsPage.darkMode ? "#2D2D2D" : "#F0F0F0"

                Column {
                    id: aboutColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: units.gu(1)
                    }
                    spacing: units.gu(1)

                    Label {
                        text: "About"
                        font.bold: true
                        color: settingsPage.darkMode ? "#FFFFFF" : "#000000"
                    }

                    Label {
                        text: "MemeStream v1.0.0"
                        color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                    }

                    Label {
                        text: "A Reddit meme viewer for Ubuntu Touch"
                        fontSize: "small"
                        color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Label {
                        text: "© 2025 Suraj Yadav"
                        fontSize: "small"
                        color: settingsPage.darkMode ? "#CCCCCC" : "#666666"
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("SettingsPage: Component completed");
        console.log("SettingsPage: darkMode:", settingsPage.darkMode);
        console.log("SettingsPage: selectedSubreddit:", settingsPage.selectedSubreddit);
        console.log("SettingsPage: categoryNames length:", settingsPage.categoryNames.length);
        console.log("SettingsPage: memeService attached:", settingsPage.memeService !== null);

        // Set initial selection in the CategorySelector
        if (categorySelector && settingsPage.categoryNames.length > 0) {
            categorySelector.setInitialSelection(settingsPage.selectedSubreddit);
        }
    }
}
