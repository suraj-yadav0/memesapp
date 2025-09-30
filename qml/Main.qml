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
import Qt.labs.settings 1.0
import "components"
import "models"
import "services"

ApplicationWindow {
    id: root
    visible: true
    title: "MemeStream"
    width: 400
    height: 600

    Rectangle {
        anchors.fill: parent
        color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : theme.palette.normal.background
        z: -1  // Ensure it stays behind other content
    }

    // Application properties
    property bool darkMode: false
    property string selectedSubreddit: "memes"
    property bool useCustomSubreddit: false
    // Fullscreen image viewer source
    property string dialogImageSource: ""
    property int currentMemeIndex: -1  // Track current meme index in fullscreen view
    property bool isDesktopMode: true  // Reactive to window size

    // Category mapping for better user experience
    property var categoryMap: ({
            "General Memes": "memes",
            "Dank Memes": "dankmemes",
            "Wholesome Memes": "wholesomememes",
            "Funny": "funny",
            "Programming Humor": "ProgrammerHumor",
            "Me IRL": "meirl",
            "Star Wars Memes": "PrequelMemes",
            "History Memes": "HistoryMemes",
            "Gaming Memes": "gaming",
            "Anime Memes": "AnimeMemes",
            "Cursed Comments": "cursedcomments",
            "Surreal Memes": "surrealmemes",
            "Memes of the Dank": "memesofthedank",
            "Meme Economy": "MemeEconomy",
            "2meirl4meirl": "2meirl4meirl",
            "teenagers": "teenagers",
            "Advice Animals": "AdviceAnimals",
            "Prequel Memes": "PrequelMemes",
            "Sequel Memes": "SequelMemes",
            "OT Memes": "OTMemes",
            "High Quality Memes": "HighQualityGifs",
            "Low Effort Memes": "loweffortmemes",
            "Political Memes": "PoliticalHumor",
            "Animal Memes": "AnimalsBeingDerps",
            "Cat Memes": "catmemes",
            "Dog Memes": "dogmemes",
            "Wholesome Animemes": "wholesomeanimemes",
            "Meme Art": "MemeArt"
        })

    // Array of category names for the OptionSelector (will be updated with custom subreddits)
    property var categoryNames: ["General Memes", "Dank Memes", "Wholesome Memes", "Funny", "Programming Humor", "Me IRL", "Star Wars Memes", "History Memes", "Gaming Memes", "Anime Memes", "Cursed Comments", "Surreal Memes", "Memes of the Dank", "Meme Economy", "2meirl4meirl", "teenagers", "Advice Animals", "Prequel Memes", "Sequel Memes", "OT Memes", "High Quality Memes", "Low Effort Memes", "Political Memes", "Animal Memes", "Cat Memes", "Dog Memes", "Wholesome Animemes", "Meme Art"]
    
    // Extended category map including custom subreddits
    property var extendedCategoryMap: categoryMap
    property var customSubreddits: []

    // Database Manager
    DatabaseManager {
        id: databaseManager
        
        onCustomSubredditsLoaded: {
            console.log("Main: Custom subreddits loaded:", subreddits.length);
            root.customSubreddits = subreddits;
            updateCategoryLists();
        }
        
        onSubredditAdded: {
            console.log("Main: Subreddit added to database:", displayName);
            updateCategoryLists();
        }
        
        onSubredditRemoved: {
            console.log("Main: Subreddit removed from database:", displayName);
            updateCategoryLists();
        }
        
        onErrorOccurred: {
            console.log("Main: Database error:", message);
            // Could show error notification to user here
        }
    }

    // Model
    MemeModel {
        id: memeModel

        onModelUpdated: {
            console.log("Main: Model updated with", count, "memes");
        }

        onModelCleared: {
            console.log("Main: Model cleared");
        }
    }

    // Service
    MemeService {
        id: memeService

        Component.onCompleted: {
            console.log("Main: Setting model for service");
            setModel(memeModel);
        }

        onMemesRefreshed: {
            console.log("Main: Memes refreshed, count:", count);
        }

        onLoadingChanged: {
            console.log("Main: Loading state changed:", loading);
        }

        onErrorOccurred: {
            console.log("Main: Service error:", message);
        }

        onSubredditChanged: {
            console.log("Main: Subreddit changed to:", subreddit);
            root.selectedSubreddit = subreddit;
        }
    }

    // Download Manager
    QtObject {
        id: downloadManager

        function downloadMeme(imageUrl, title) {
            console.log("DownloadManager: Starting download for:", imageUrl);
            try {
                Qt.openUrlExternally(imageUrl);
                console.log("DownloadManager: Opened image URL externally:", imageUrl);
            } catch (e) {
                console.log("DownloadManager: Failed to open URL externally:", e);
            }
        }

        function shareMeme(url, title) {
            console.log("DownloadManager: Sharing meme:", title, "URL:", url);
            try {
                Qt.openUrlExternally(url);
                console.log("DownloadManager: Opened share URL externally:", url);
            } catch (e) {
                console.log("DownloadManager: Failed to open share URL externally:", e);
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPageComponent
    }

    Component {
        id: mainPageComponent

        Page {
            title: "MemeStream"
            Rectangle {
                anchors.fill: parent
                color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : theme.palette.normal.background
                z: -1
            }

            header: PageHeader {
                title: i18n.tr("M E M E S T R E A M")
                subtitle: i18n.tr("r/" + root.selectedSubreddit)
                StyleHints {
                    backgroundColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "black" : "#081831"
                    foregroundColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#9b4f22" : "white"
                }

                trailingActionBar.actions: [
                    Action {
                        iconName: "settings"
                        text: i18n.tr("Select Subreddit")
                        onTriggered: {
                            subredditSelectionDialog.open();
                        }
                    },
                    Action {
                        iconName: "bookmark-new"
                        text: i18n.tr("Manage Collection")
                        onTriggered: {
                            manageSubredditsDialog.open();
                        }
                    },
                    Action {
                        iconName: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "weather-clear-night-symbolic" : "weather-clear-symbolic"
                        text: theme.name === "Ubuntu.Components.Themes.SuruDark" ? i18n.tr("Light Mode") : i18n.tr("Dark Mode")
                        onTriggered: {
                            Theme.name = theme.name === "Ubuntu.Components.Themes.SuruDark" ? "Ubuntu.Components.Themes.Ambiance" : "Ubuntu.Components.Themes.SuruDark";
                        }
                    },
                    Action {
                        iconName: root.isDesktopMode ? "view-list-symbolic" : "view-grid-symbolic"
                        text: i18n.tr(root.isDesktopMode ? "List View" : "Grid View")
                        onTriggered: {
                            root.isDesktopMode = !root.isDesktopMode;
                        }
                    }
                ]
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.gu(2)
                anchors.topMargin: units.gu(4)
                spacing: units.gu(1.5)

                // Loading indicator
                BusyIndicator {
                    visible: memeService.isLoading
                    running: memeService.isLoading
                    Layout.alignment: Qt.AlignHCenter
                }

                // Current subreddit info
                Text {
                    text: "r/" + root.selectedSubreddit
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    color: theme.palette.normal.backgroundText
                    visible: !memeService.isLoading && !memeService.isModelEmpty()
                    Layout.alignment: Qt.AlignHCenter
                }

                GridView {
                    id: memeGridView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: memeModel
                    visible: !memeService.isLoading
                    clip: true

                    // 🚫 Never let cellWidth exceed GridView width
                    cellWidth: root.isDesktopMode ? Math.min(width / 2, units.gu(35)) : width
                    cellHeight: root.isDesktopMode ? units.gu(45) : delegate.implicitHeight + units.gu(2)

                    // ⬇️ Flow vertically in list mode, horizontally in grid mode
                    flow: root.isDesktopMode ? GridView.LeftToRight : GridView.TopToBottom
                    // 🚫 Use constants, not string enums (Qt 5.12+)

                    // 🔄 Snap to rows in list mode for better UX
                    snapMode: GridView.SnapToRow

                    // 🚫 Disable horizontal scrolling in list mode
                    flickableDirection: root.isDesktopMode ? Flickable.AutoFlickDirection : Flickable.VerticalFlick

                    delegate: Rectangle {
                        id: delegate
                        width: memeGridView.cellWidth - (root.isDesktopMode ? units.gu(1) : 0)
                        height: root.isDesktopMode ? memeGridView.cellHeight - units.gu(1) : delegateColumn.implicitHeight + units.gu(3)  // 👈 Use implicitHeight!

                        color: theme.palette.normal.background
                        border.color: theme.palette.normal.base
                        border.width: 1
                        radius: 8

                        Column {
                            id: delegateColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: units.gu(1)
                            spacing: units.gu(0.5)

                            Text {
                                text: model.title || "Untitled"
                                font.bold: true
                                wrapMode: Text.WordWrap
                                width: parent.width
                                color: theme.palette.normal.backgroundText
                                maximumLineCount: root.isDesktopMode ? 2 : 5
                                elide: Text.ElideRight
                            }

                            Image {
                                source: model.image || ""
                                width: parent.width - units.gu(2)
                                height: root.isDesktopMode ? Math.min(parent.width * 0.8, units.gu(25)) : units.gu(30)
                                fillMode: Image.PreserveAspectFit
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: source != ""

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("Failed to load image:", model.image);
                                        visible = false;
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (model.image) {
                                            root.currentMemeIndex = index;
                                            root.dialogImageSource = model.image;
                                            attachmentDialog.open();
                                        }
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Flow {
                                width: parent.width
                                spacing: root.isDesktopMode ? units.gu(1) : units.gu(2)

                                Text {
                                    text: "👍 " + (model.upvotes || 0)
                                    color: theme.palette.normal.backgroundText
                                    font.pixelSize: root.isDesktopMode ? units.gu(1.2) : units.gu(1.4)
                                }

                                Text {
                                    text: "💬 " + (model.comments || 0)
                                    color: theme.palette.normal.backgroundText
                                    font.pixelSize: root.isDesktopMode ? units.gu(1.2) : units.gu(1.4)
                                }

                                Text {
                                    text: "r/" + (model.subreddit || "")
                                    color: theme.palette.normal.backgroundText
                                    font.pixelSize: root.isDesktopMode ? units.gu(1.2) : units.gu(1.4)
                                    elide: Text.ElideMiddle
                                    maximumLineCount: 1
                                }

                                Text {
                                    text: "📤"
                                    font.pixelSize: units.gu(1.5)
                                    color: theme.palette.normal.backgroundText

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: downloadManager.shareMeme(model.permalink || model.image, model.title)
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                Text {
                                    text: "💾"
                                    font.pixelSize: units.gu(1.5)
                                    color: theme.palette.normal.backgroundText

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: downloadManager.downloadMeme(model.image, model.title)
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }

                        // Hover effect for desktop mode
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: theme.palette.normal.selection
                            border.width: parent.hovered ? 2 : 0
                            radius: 8
                            visible: root.isDesktopMode

                            property bool hovered: false

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                propagateComposedEvents: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                            }
                        }
                    }

                    // ✅ ScrollBar — only in desktop mode
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        visible: root.isDesktopMode
                        policy: ScrollBar.AsNeeded
                    }

                    // 🚫 Prevent horizontal scrolling in list mode
                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AlwaysOff
                    }
                }

                // Empty state
                Column {
                    Layout.alignment: Qt.AlignCenter
                    visible: memeService.isModelEmpty() && !memeService.isLoading
                    spacing: units.gu(1.5)

                    Text {
                        text: "No memes found"
                        font.pixelSize: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.backgroundText
                    }

                    Text {
                        text: root.useCustomSubreddit ? "Try a different subreddit or check the spelling" : "Try selecting a different category or refresh"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.backgroundSecondaryText
                    }

                    Button {
                        text: "Refresh"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: memeService.refreshMemes()
                    }
                }

                // Error state
                Column {
                    Layout.alignment: Qt.AlignCenter
                    visible: memeService.lastError !== "" && !memeService.isLoading
                    spacing: units.gu(1.5)

                    Text {
                        text: "Error loading memes"
                        font.pixelSize: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.negative
                    }

                    Text {
                        text: memeService.lastError
                        font.pixelSize: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.palette.normal.backgroundSecondaryText
                        wrapMode: Text.WordWrap
                        width: units.gu(40)
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        text: "Try Again"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: memeService.refreshMemes()
                    }
                }
            }
        }
    }

    // Settings persistence
    Settings {
        id: settings
        property alias darkMode: root.darkMode
        property alias selectedSubreddit: root.selectedSubreddit
        property alias useCustomSubreddit: root.useCustomSubreddit
    }

    // Subreddit Selection Dialog
    Dialog {
        id: subredditSelectionDialog
        modal: true
        focus: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        width: Math.min(root.width * 0.9, units.gu(50))
        x: (root.width - width) / 2
        y: (root.height - height) / 2

        background: Rectangle {
            color: theme.palette.normal.background
            radius: units.gu(1)
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: units.gu(2)

            // Mode selector (Category vs Custom)
            GroupBox {
                title: "Selection Mode"
                Layout.fillWidth: true
                anchors.margins: units.gu(1)

                background: Rectangle {
                    color: theme.palette.normal.background
                    radius: units.gu(.5)
                }

                label: Text {
                    text: "Selection Mode"
                    color: theme.palette.normal.backgroundText
                    anchors.margins: units.gu(1)
                    font.bold: true
                }

                Column {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    RadioButton {
                        id: dialogCategoryModeRadio
                        text: "Predefined Categories"
                        checked: !root.useCustomSubreddit

                        contentItem: Text {
                            text: dialogCategoryModeRadio.text
                            color: theme.palette.normal.backgroundText
                            leftPadding: dialogCategoryModeRadio.indicator.width + dialogCategoryModeRadio.spacing
                        }
                    }

                    RadioButton {
                        id: dialogCustomModeRadio
                        text: "Custom Subreddit"
                        checked: root.useCustomSubreddit

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
                        model: root.categoryNames
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
                            if (!root.useCustomSubreddit) {
                                for (var i = 0; i < root.categoryNames.length; i++) {
                                    if (root.extendedCategoryMap[root.categoryNames[i]] === root.selectedSubreddit) {
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
                        text: "Enter the name of any subreddit:"
                        Layout.fillWidth: true
                        color: theme.palette.normal.backgroundText
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(1)

                        Text {
                            text: "r/"
                            font.bold: true
                            color: theme.palette.normal.backgroundText
                        }

                        TextField {
                            id: dialogCustomSubredditField
                            Layout.fillWidth: true
                            placeholderText: "e.g., memes, funny, programming"
                            text: root.useCustomSubreddit ? root.selectedSubreddit : ""

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
                                        var success = root.addCustomSubredditToDatabase(subredditName);
                                        if (success) {
                                            console.log("Main: Successfully added subreddit to collection");
                                            // Don't close dialog, let user decide if they want to use it now
                                        }
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
                    newSubreddit = root.extendedCategoryMap[categoryName];
                }
            }

            if (newSubreddit && (newSubreddit !== root.selectedSubreddit || newUseCustom !== root.useCustomSubreddit)) {
                console.log("Dialog: Applying new subreddit:", newSubreddit, "Custom:", newUseCustom);
                root.useCustomSubreddit = newUseCustom;
                root.selectedSubreddit = newSubreddit;
                memeService.fetchMemes(newSubreddit);
            }
        }

        onOpened: {
            dialogCategoryModeRadio.checked = !root.useCustomSubreddit;
            dialogCustomModeRadio.checked = root.useCustomSubreddit;

            if (root.useCustomSubreddit) {
                dialogCustomSubredditField.text = root.selectedSubreddit;
                dialogCustomSubredditField.forceActiveFocus();
            } else {
                for (var i = 0; i < root.categoryNames.length; i++) {
                    if (root.extendedCategoryMap[root.categoryNames[i]] === root.selectedSubreddit) {
                        dialogCategoryCombo.currentIndex = i;
                        break;
                    }
                }
            }
        }
    }

    // Custom Subreddits Management Dialog
    Dialog {
        id: manageSubredditsDialog
        modal: true
        focus: true
        standardButtons: Dialog.Close
        
        width: Math.min(root.width * 0.9, units.gu(60))
        height: Math.min(root.height * 0.8, units.gu(50))
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        
        title: "Manage My Subreddit Collection"
        
        background: Rectangle {
            color: theme.palette.normal.background
            radius: units.gu(1)
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: units.gu(1)
            
            Text {
                text: "Your Custom Subreddits (" + root.customSubreddits.length + ")"
                font.bold: true
                color: theme.palette.normal.backgroundText
                Layout.fillWidth: true
            }
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ListView {
                    id: customSubredditsListView
                    model: root.customSubreddits
                    spacing: units.gu(0.5)
                    
                    delegate: Rectangle {
                        width: customSubredditsListView.width
                        height: units.gu(6)
                        color: theme.palette.normal.background
                        border.color: theme.palette.normal.base
                        border.width: 1
                        radius: 4
                        
                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: units.gu(1)
                            spacing: units.gu(1)
                            
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - buttonRow.width - parent.spacing
                                
                                Text {
                                    text: modelData.displayName + (modelData.isFavorite ? " ⭐" : "")
                                    font.bold: true
                                    color: theme.palette.normal.backgroundText
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                
                                Text {
                                    text: "r/" + modelData.subredditName + " • Used " + modelData.usageCount + " times"
                                    font.pixelSize: units.gu(1.2)
                                    color: theme.palette.normal.backgroundSecondaryText
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }
                            
                            Row {
                                id: buttonRow
                                spacing: units.gu(0.5)
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Button {
                                    text: modelData.isFavorite ? "★" : "☆"
                                    width: units.gu(4)
                                    height: units.gu(4)
                                    onClicked: {
                                        console.log("Main: Toggling favorite for:", modelData.subredditName);
                                        databaseManager.toggleFavorite(modelData.subredditName);
                                    }
                                }
                                
                                Button {
                                    text: "Use"
                                    width: units.gu(6)
                                    height: units.gu(4)
                                    onClicked: {
                                        console.log("Main: Using custom subreddit:", modelData.subredditName);
                                        root.useCustomSubreddit = true;
                                        root.selectedSubreddit = modelData.subredditName;
                                        memeService.fetchMemes(modelData.subredditName);
                                        manageSubredditsDialog.close();
                                    }
                                }
                                
                                Button {
                                    text: "✕"
                                    width: units.gu(4)
                                    height: units.gu(4)
                                    onClicked: {
                                        console.log("Main: Removing custom subreddit:", modelData.subredditName);
                                        databaseManager.removeCustomSubreddit(modelData.subredditName);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Text {
                text: root.customSubreddits.length === 0 ? 
                      "No custom subreddits saved yet. Use 'Select Subreddit' → 'Custom Subreddit' → 'Add to My Collection' to save subreddits." :
                      "Tip: ⭐ Mark favorites to show them at the top of the list."
                font.pixelSize: units.gu(1.2)
                color: theme.palette.normal.backgroundSecondaryText
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignCenter
            }
        }
    }

    // Fullscreen image viewer dialog
    Dialog {
        id: attachmentDialog
        modal: true
        focus: true
        padding: 0
        x: 0
        y: 0
        width: root.width
        height: root.height
        background: Rectangle {
            color: "transparent"
        }

        FocusScope {
            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: attachmentDialog.close()
            Keys.onLeftPressed: root.navigateToPrevMeme()
            Keys.onRightPressed: root.navigateToNextMeme()

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
                    source: root.dialogImageSource
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
                        console.log("Main: Pinch zoom started, initial scale:", initialScale);
                    }
                    
                    onPinchUpdated: {
                        var newScale = initialScale * pinch.scale;
                        newScale = Math.max(imageFlickable.minZoom, Math.min(imageFlickable.maxZoom, newScale));
                        
                        // Calculate new position to keep zoom centered on pinch center
                        var centerX = initialCenter.x;
                        var centerY = initialCenter.y;
                        
                        zoomableImage.scale = newScale;
                        
                        // Update flickable content size
                        imageFlickable.contentWidth = zoomableImage.width * zoomableImage.scale;
                        imageFlickable.contentHeight = zoomableImage.height * zoomableImage.scale;
                        
                        console.log("Main: Pinch zoom updated, scale:", newScale);
                    }
                    
                    onPinchFinished: {
                        console.log("Main: Pinch zoom finished, final scale:", zoomableImage.scale);
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
                        
                        // Zoom towards mouse position
                        var mouseX = wheel.x;
                        var mouseY = wheel.y;
                        
                        // Calculate the point in the image coordinate system
                        var imageX = mouseX - zoomableImage.x;
                        var imageY = mouseY - zoomableImage.y;
                        
                        // Apply zoom
                        zoomableImage.scale = newScale;
                        
                        // Update flickable content size
                        imageFlickable.contentWidth = zoomableImage.width * zoomableImage.scale;
                        imageFlickable.contentHeight = zoomableImage.height * zoomableImage.scale;
                        
                        // Center the zoom on the mouse position
                        if (zoomableImage.scale > 1.0) {
                            imageFlickable.contentX = imageX * zoomableImage.scale - mouseX;
                            imageFlickable.contentY = imageY * zoomableImage.scale - mouseY;
                        } else {
                            // Reset position when zoomed out
                            imageFlickable.contentX = 0;
                            imageFlickable.contentY = 0;
                        }
                        
                        console.log("Main: Mouse wheel zoom, scale:", newScale);
                    }
                }
                
                // Function to reset zoom
                function resetZoom() {
                    zoomableImage.scale = 1.0;
                    contentX = 0;
                    contentY = 0;
                    contentWidth = zoomableImage.width;
                    contentHeight = zoomableImage.height;
                    console.log("Main: Zoom reset");
                }
                
                // Function to zoom to fit
                function zoomToFit() {
                    resetZoom();
                }
                
                // Function to zoom to actual size
                function zoomToActual() {
                    if (zoomableImage.sourceSize.width > 0 && zoomableImage.sourceSize.height > 0) {
                        var scaleX = parent.width / zoomableImage.sourceSize.width;
                        var scaleY = parent.height / zoomableImage.sourceSize.height;
                        zoomableImage.scale = Math.min(scaleX, scaleY);
                        
                        contentWidth = zoomableImage.width * zoomableImage.scale;
                        contentHeight = zoomableImage.height * zoomableImage.scale;
                        
                        // Center the image
                        contentX = Math.max(0, (contentWidth - width) / 2);
                        contentY = Math.max(0, (contentHeight - height) / 2);
                        
                        console.log("Main: Zoom to actual size, scale:", zoomableImage.scale);
                    }
                }
            }            // Touch and swipe gesture detection (only when not zoomed)
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
                        console.log("Main: Touch/swipe started at:", startX, startY);
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
                        
                        console.log("Main: Touch released - deltaX:", deltaX, "deltaY:", deltaY, "distance:", distance);
                        
                        // Check if it's a horizontal swipe (more horizontal than vertical)
                        if (distance > minSwipeDistance && Math.abs(deltaX) > Math.abs(deltaY) * 1.5) {
                            if (deltaX > 0) {
                                // Swipe right - go to previous meme
                                console.log("Main: Touch swipe right detected, navigating to previous meme");
                                root.navigateToPrevMeme();
                            } else {
                                // Swipe left - go to next meme
                                console.log("Main: Touch swipe left detected, navigating to next meme");
                                root.navigateToNextMeme();
                            }
                        } else if (distance < minSwipeDistance) {
                            // Short tap - reset zoom if zoomed, otherwise ignore
                            if (zoomableImage.scale > 1.0) {
                                imageFlickable.resetZoom();
                            } else {
                                console.log("Main: Short tap detected, ignoring");
                            }
                        }
                        
                        isSwipeActive = false;
                    }
                }
                
                onCanceled: {
                    console.log("Main: Touch gesture canceled");
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
                        console.log("Main: Zoom in, scale:", newScale);
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
                        console.log("Main: Zoom out, scale:", newScale);
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

            // Close button (placed after touch areas to ensure it's on top)
            Button {
                text: "\u2715"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: units.gu(1)
                width: units.gu(4)
                height: units.gu(4)
                z: 100  // Ensure button is always on top
                onClicked: {
                    console.log("Main: Close button clicked");
                    attachmentDialog.close();
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
                    visible: memeModel.count > 1

                    Text {
                        id: hintText
                        anchors.centerIn: parent
                        text: {
                            var navText = "Swipe ← → or arrow keys • " + (root.currentMemeIndex + 1) + " / " + memeModel.count;
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
                    visible: root.currentMemeIndex > 0 && zoomableImage.scale <= 1.0
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
                        onClicked: root.navigateToPrevMeme()
                    }
                }
                
                Rectangle {
                    id: nextArea
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * 0.15
                    color: "transparent"
                    visible: root.currentMemeIndex < memeModel.count - 1 && zoomableImage.scale <= 1.0
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
                        onClicked: root.navigateToNextMeme()
                    }
                }                // Background click area (excludes the image area to prevent conflicts with swipe)
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Only close if click is outside the image area
                        var imageRect = zoomableImage.mapToItem(parent, 0, 0, zoomableImage.width, zoomableImage.height);
                        if (mouse.x < imageRect.x || mouse.x > imageRect.x + imageRect.width || mouse.y < imageRect.y || mouse.y > imageRect.y + imageRect.height) {
                            console.log("Main: Background clicked, closing dialog");
                            attachmentDialog.close();
                        }
                    }
                    hoverEnabled: true
                    propagateComposedEvents: false
                }
            }
        } // Close FocusScope

        onClosed: {
            root.dialogImageSource = "";
            root.currentMemeIndex = -1;
            // Reset zoom when dialog closes
            if (imageFlickable) {
                imageFlickable.resetZoom();
            }
        }
    }

    function handleSelectedSubredditChanged(subreddit) {
        console.log("Main: Selected subreddit changed to:", subreddit);
        root.selectedSubreddit = subreddit;
        memeService.fetchMemes(subreddit);
        
        // Increment usage count if it's a custom subreddit
        databaseManager.incrementUsageCount(subreddit);
    }
    
    function updateCategoryLists() {
        console.log("Main: Updating category lists with custom subreddits");
        
        // Create new extended category map
        var newCategoryMap = {};
        var newCategoryNames = [];
        
        // Add built-in categories first
        for (var key in categoryMap) {
            newCategoryMap[key] = categoryMap[key];
            newCategoryNames.push(key);
        }
        
        // Add custom subreddits
        for (var i = 0; i < customSubreddits.length; i++) {
            var custom = customSubreddits[i];
            var displayName = custom.displayName + (custom.isFavorite ? " ⭐" : "");
            newCategoryMap[displayName] = custom.subredditName;
            newCategoryNames.push(displayName);
        }
        
        // Update properties
        extendedCategoryMap = newCategoryMap;
        categoryNames = newCategoryNames;
        
        console.log("Main: Updated category lists - total categories:", newCategoryNames.length);
    }
    
    function addCustomSubredditToDatabase(subredditName) {
        // Create a nice display name from subreddit name
        var displayName = subredditName.charAt(0).toUpperCase() + subredditName.slice(1);
        displayName = displayName.replace(/([A-Z])/g, ' $1').trim(); // Add spaces before capitals
        
        console.log("Main: Adding custom subreddit to database:", displayName, "->", subredditName);
        return databaseManager.addCustomSubreddit(displayName, subredditName);
    }

    // Navigation functions for fullscreen image viewer
    function navigateToNextMeme() {
        if (currentMemeIndex < memeModel.count - 1) {
            currentMemeIndex++;
            var nextMeme = memeModel.get(currentMemeIndex);
            if (nextMeme && nextMeme.image) {
                dialogImageSource = nextMeme.image;
                console.log("Main: Navigated to next meme:", currentMemeIndex, nextMeme.title);
            }
        } else {
            console.log("Main: Already at last meme");
        }
    }

    function navigateToPrevMeme() {
        if (currentMemeIndex > 0) {
            currentMemeIndex--;
            var prevMeme = memeModel.get(currentMemeIndex);
            if (prevMeme && prevMeme.image) {
                dialogImageSource = prevMeme.image;
                console.log("Main: Navigated to previous meme:", currentMemeIndex, prevMeme.title);
            }
        } else {
            console.log("Main: Already at first meme");
        }
    }

    // Initialization
    Component.onCompleted: {
        console.log("Main: App starting up");
        console.log("Main: Selected subreddit:", root.selectedSubreddit);
        console.log("Main: Dark mode:", root.darkMode);
        console.log("Main: Use custom subreddit:", root.useCustomSubreddit);

        Qt.callLater(function () {
            memeService.fetchMemes(root.selectedSubreddit);
        });
    }
}
