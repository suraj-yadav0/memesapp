/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 */

import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    id: root
    width: units.gu(10)
    height: units.gu(10)
    property color accentColor: "#FF4500" // Reddit Orange
    property bool running: true
    property bool darkMode: false

    visible: running

    // Container for the animation
    Item {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        opacity: root.running ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        // 1. Outer Orbit Ring (Static or slow spin)
        Rectangle {
            id: orbit
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: width
            radius: width / 2
            color: "transparent"
            border.color: root.accentColor
            border.width: units.dp(2)
            opacity: 0.2
        }

        // 2. Orbiting Planet (The "Electron")
        Item {
            anchors.fill: orbit
            
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1500
                loops: Animation.Infinite
                running: root.running
                easing.type: Easing.InOutCubic
            }

            Rectangle {
                width: units.gu(1.5)
                height: width
                radius: width / 2
                color: root.accentColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -height / 2
                
                // Trail effect
                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: parent.radius
                    color: parent.color
                    opacity: 0.5
                    x: -width * 0.5
                    y: width * 0.2
                    scale: 0.8
                }
            }
        }
        
        // 3. Central Pulsing Core (The "Sun" / Snoo Head abstract)
        Rectangle {
            id: core
            anchors.centerIn: parent
            width: parent.width * 0.35
            height: width
            radius: width / 2
            color: root.accentColor
            
            // Antenna (Abstract)
            Rectangle {
                width: units.dp(3)
                height: units.gu(1.5)
                color: root.accentColor
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: -units.dp(2)
                rotation: 15
                transformOrigin: Item.Bottom
            }
            
            Rectangle {
                width: units.gu(0.8)
                height: width
                radius: width / 2
                color: root.accentColor
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: units.gu(1.2)
                anchors.horizontalCenterOffset: units.gu(0.2)
            }

            SequentialAnimation {
                running: root.running
                loops: Animation.Infinite
                
                ParallelAnimation {
                    NumberAnimation {
                        target: core
                        property: "scale"
                        from: 0.85
                        to: 1.15
                        duration: 800
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: core
                        property: "opacity"
                        from: 0.8
                        to: 1.0
                        duration: 800
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: core
                        property: "scale"
                        from: 1.15
                        to: 0.85
                        duration: 800
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: core
                        property: "opacity"
                        from: 1.0
                        to: 0.8
                        duration: 800
                    }
                }
            }
        }
    }
}
