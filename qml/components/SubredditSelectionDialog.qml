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
    id: subredditSelectionDialog
    modal: true
    focus: true
    standardButtons: Dialog.Ok | Dialog.Cancel

    width: Math.min(parent.width * 0.9, units.gu(50))
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // Properties
    property var categoryNames: []
    property var extendedCategoryMap: ({})
    property bool useCustomSubreddit: false
    property string selectedSubreddit: ""
    
    // Signals
    signal subredditSelected(string subreddit, bool isCustom)
    signal addToCollection(string subredditName)

    background: Rectangle {
        color: theme.palette.normal.background
        radius: units.gu(1)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(2)

        // Mode Selection
        GroupBox {
            title: "Selection Mode"
            Layout.fillWidth: true

            background: Rectangle {
                color: theme.palette.normal.background
                radius: 4
            }

            label: Text {
                text: "Selection Mode"
                color: theme.palette.normal.backgroundText
                font.bold: true
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: units.gu(1)

                RadioButton {
                    id: dialogCategoryModeRadio
                    text: "Popular Categories"
                    checked: !subredditSelectionDialog.useCustomSubreddit

                    contentItem: Text {
                        text: dialogCategoryModeRadio.text
                        color: theme.palette.normal.backgroundText
                        leftPadding: dialogCategoryModeRadio.indicator.width + dialogCategoryModeRadio.spacing
                    }
                }

                RadioButton {
                    id: dialogCustomModeRadio
                    text: "Custom Subreddit"
                    checked: subredditSelectionDialog.useCustomSubreddit

                    contentItem: Text {
                        text: dialogCustomModeRadio.text
                        color: theme.palette.normal.backgroundText
                        leftPadding: dialogCustomModeRadio.indicator.width + dialogCustomModeRadio.spacing
                    }
                }
            }
        }

        // Category Selector
        GroupBox {
            title: "Choose Category"
            Layout.fillWidth: true
            visible: dialogCategoryModeRadio.checked

            background: Rectangle {
                color: theme.palette.normal.background
                radius: 4
            }

            label: Text {
                text: "Choose Category"
                color: theme.palette.normal.backgroundText
                font.bold: true
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: units.gu(1)

                Text {
                    text: "Select a meme category:"
                    Layout.fillWidth: true
                    color: theme.palette.normal.backgroundText
                }

                ComboBox {
                    id: dialogCategoryCombo
                    model: subredditSelectionDialog.categoryNames
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: theme.palette.normal.background
                        border.color: theme.palette.normal.base
                        border.width: 1
                        radius: 4
                    }

                    contentItem: Text {
                        text: dialogCategoryCombo.displayText
                        color: theme.palette.normal.fieldText
                        leftPadding: units.gu(1)
                        rightPadding: units.gu(3)
                        verticalAlignment: Text.AlignVCenter
                    }

                    Component.onCompleted: {
                        if (!subredditSelectionDialog.useCustomSubreddit) {
                            for (var i = 0; i < subredditSelectionDialog.categoryNames.length; i++) {
                                if (subredditSelectionDialog.extendedCategoryMap[subredditSelectionDialog.categoryNames[i]] === subredditSelectionDialog.selectedSubreddit) {
                                    currentIndex = i;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }

        // Custom subreddit input
        GroupBox {
            title: "Enter Custom Subreddit"
            Layout.fillWidth: true
            visible: dialogCustomModeRadio.checked

            background: Rectangle {
                color: theme.palette.normal.background
                radius: 4
            }

            label: Text {
                text: "Enter Custom Subreddit"
                color: theme.palette.normal.backgroundText
                font.bold: true
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: units.gu(1)

                Text {
                    text: "Enter subreddit name (without 'r/'):"
                    Layout.fillWidth: true
                    color: theme.palette.normal.backgroundText
                }

                TextField {
                    id: dialogCustomSubredditField
                    Layout.fillWidth: true
                    placeholderText: "e.g., memes, funny, programming"
                    text: subredditSelectionDialog.useCustomSubreddit ? subredditSelectionDialog.selectedSubreddit : ""

                    Rectangle {
                        color: theme.palette.normal.background
                        border.color: theme.palette.normal.base
                        border.width: 1
                        radius: 4
                    }

                    color: theme.palette.normal.fieldText

                    onTextChanged: {
                        if (text.toLowerCase().startsWith("r/")) {
                            text = text.substring(2);
                        }
                        var cleanText = text.replace(/[^a-zA-Z0-9_]/g, '');
                        if (cleanText !== text) {
                            text = cleanText;
                        }
                    }

                    Keys.onReturnPressed: subredditSelectionDialog.accept()
                    Keys.onEnterPressed: subredditSelectionDialog.accept()
                }
                
                // Add to Collection button
                Row {
                    Layout.fillWidth: true
                    spacing: units.gu(1)
                    
                    Button {
                        text: "Add to My Collection"
                        enabled: dialogCustomSubredditField.text.trim() !== ""
                        
                        onClicked: {
                            var subredditName = dialogCustomSubredditField.text.trim().toLowerCase();
                            if (subredditName !== "") {
                                subredditSelectionDialog.addToCollection(subredditName);
                            }
                        }
                    }
                    
                    Text {
                        text: "Save for future use"
                        font.pixelSize: units.gu(1.1)
                        color: theme.palette.normal.backgroundSecondaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: "Note: Make sure the subreddit exists and contains images"
                    font.pixelSize: units.gu(1.2)
                    color: theme.palette.normal.backgroundSecondaryText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    onAccepted: {
        var newSubreddit = "";
        var newUseCustom = dialogCustomModeRadio.checked;

        if (newUseCustom) {
            var customText = dialogCustomSubredditField.text.trim().toLowerCase();
            if (customText !== "") {
                newSubreddit = customText;
            } else {
                return; // Don't close if invalid
            }
        } else {
            if (dialogCategoryCombo.currentIndex >= 0 && dialogCategoryCombo.currentText) {
                var categoryName = dialogCategoryCombo.currentText;
                newSubreddit = subredditSelectionDialog.extendedCategoryMap[categoryName];
            }
        }

        if (newSubreddit) {
            console.log("SubredditSelectionDialog: Selected subreddit:", newSubreddit, "Custom:", newUseCustom);
            subredditSelectionDialog.subredditSelected(newSubreddit, newUseCustom);
        }
    }

    onOpened: {
        dialogCategoryModeRadio.checked = !subredditSelectionDialog.useCustomSubreddit;
        dialogCustomModeRadio.checked = subredditSelectionDialog.useCustomSubreddit;

        if (subredditSelectionDialog.useCustomSubreddit) {
            dialogCustomSubredditField.text = subredditSelectionDialog.selectedSubreddit;
            dialogCustomSubredditField.forceActiveFocus();
        } else {
            for (var i = 0; i < subredditSelectionDialog.categoryNames.length; i++) {
                if (subredditSelectionDialog.extendedCategoryMap[subredditSelectionDialog.categoryNames[i]] === subredditSelectionDialog.selectedSubreddit) {
                    dialogCategoryCombo.currentIndex = i;
                    break;
                }
            }
        }
    }
}