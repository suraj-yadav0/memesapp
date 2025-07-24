import QtQuick 2.12
import Ubuntu.Components 1.3

Row {
    id: root

    // Properties to connect with parent
    property var categoryNames: []
    property var categoryMap: ({})
    property string selectedSubreddit: "memes"
    property bool darkMode: false
    property var memeFetcher: null

    spacing: units.gu(1)
    height: units.gu(5)

    Label {
        text: "Category:"
        anchors.verticalCenter: parent.verticalCenter
        font.bold: true
    }

    OptionSelector {
        id: subredditSelector
        model: root.categoryNames
        selectedIndex: 0
        width: units.gu(30)
        anchors.verticalCenter: parent.verticalCenter

        onSelectedIndexChanged: {
            if (root.categoryNames.length > 0 && selectedIndex >= 0) {
                var categoryName = root.categoryNames[selectedIndex];
                var subredditName = root.categoryMap[categoryName];
                console.log("Category changed to:", categoryName, "-> subreddit:", subredditName);
                root.selectedSubreddit = subredditName;
                if (root.memeFetcher) {
                    root.memeFetcher.fetchMemes();
                }
            }
        }
    }

    Item {
        width: units.gu(2)
        height: 1
    }

    Switch {
        id: darkSwitch
        checked: root.darkMode
        anchors.verticalCenter: parent.verticalCenter
        onCheckedChanged: {
            root.darkMode = checked;
        }
    }

    Label {
        text: "Dark"
        anchors.verticalCenter: parent.verticalCenter
    }

    // Function to set initial selection
    function setInitialSelection(subreddit) {
        for (var i = 0; i < root.categoryNames.length; i++) {
            if (root.categoryMap[root.categoryNames[i]] === subreddit) {
                subredditSelector.selectedIndex = i;
                break;
            }
        }
    }
}
