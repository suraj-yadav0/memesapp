import QtQuick 2.12
import Ubuntu.Components 1.3

Row {
    id: root

    // Properties to connect with parent
    property var categoryNames: []
    property var categoryMap: ({})
    property string selectedSubreddit: "memes"
   // property bool darkMode: false
    property var memeFetcher: null
    property bool isExpanded: false

    spacing: units.gu(2)
    height: isExpanded ? units.gu(12) : units.gu(5)

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
        height: root.isExpanded ? units.gu(12) : units.gu(5)

        anchors.verticalCenter: parent.verticalCenter

        onDelegateClicked: {
            console.log("OptionSelector clicked, current isExpanded:", root.isExpanded);
            root.isExpanded = !root.isExpanded;
            console.log("OptionSelector new isExpanded:", root.isExpanded);
        }

        onSelectedIndexChanged: {
            if (root.categoryNames.length > 0 && selectedIndex >= 0) {
                var categoryName = root.categoryNames[selectedIndex];
                var subredditName = root.categoryMap[categoryName];
                console.log("Category changed to:", categoryName, "-> subreddit:", subredditName);
                root.selectedSubreddit = subredditName;
                if (root.memeFetcher) {
                    root.memeFetcher.fetchMemes();
                }
                // Collapse after selection
                root.isExpanded = false;
            }
        }
    }

  

    // Switch {
    //     id: darkSwitch
    //     checked: root.darkMode
    //     anchors.verticalCenter: parent.verticalCenter
    //     onCheckedChanged: {
    //         root.darkMode = checked;
    //     }
    // }

    // Label {
    //     text: "Dark"
    //     anchors.verticalCenter: parent.verticalCenter
    // }

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
