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

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'memesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(40)
    height: units.gu(70)
  
    Page {
        title: "MemeStream"

        ListView {
            id: memeList
            anchors.fill: parent
            model: memeModel

            delegate: Item {
                width: parent.width
                height: image.height + title.height + units.gu(2)

                Column {
                    width: parent.width

                    Image {
                        id: image
                        source: model.image
                        width: parent.width
                        height: sourceSize.height > 0 ? sourceSize.height : units.gu(30)
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        id: title
                        text: model.title
                        font.bold: true
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Rectangle {
                        height: units.gu(1)
                        width: parent.width
                        color: "#ddd"
                    }
                }
            }

            Component.onCompleted: {
                memeFetcher.fetchMemes()
            }
        }
    }

    QtObject {
        id: memeFetcher

        function fetchMemes() {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "https://www.reddit.com/r/memes/top.json?limit=25", true)
            xhr.setRequestHeader("User-Agent", "UbuntuTouchMemeApp/0.1")

            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var json = JSON.parse(xhr.responseText)
                    var posts = json.data.children

                    memeModel.clear()
                    for (var i = 0; i < posts.length; i++) {
                        var post = posts[i].data
                        if (post.post_hint === "image") {
                            memeModel.append({
                                title: post.title,
                                image: post.url
                            })
                        }
                    }
                }
            }

            xhr.send()
        }
    }

    ListModel {
        id: memeModel
    }
}
