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
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3

Rectangle {
    id: loginScreen
    
    // Theme properties (passed from parent)
    property color bgColor: "#0F0F0F"
    property color cardColor: "#1A1A1B"
    property color textColor: "#D7DADC"
    property color subtextColor: "#818384"
    property color accentColor: "#FF4500"
    property color dividerColor: "#343536"
    property bool darkMode: true
    
    // Signals
    signal loginRequested(string username, string password)
    signal signupRequested(string username, string email, string password)
    signal skipRequested()
    
    // State
    property bool isLoginMode: true
    property bool isLoading: false
    property string errorMessage: ""
    
    color: bgColor
    
    // Background gradient overlay
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1) }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.3) }
        }
    }
    
    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + units.gu(8)
        clip: true
        
        ColumnLayout {
            id: contentColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: units.gu(6)
            width: Math.min(parent.width - units.gu(4), units.gu(45))
            spacing: units.gu(3)
            
            // App Logo and Title
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: units.gu(2)
                
                // Reddit-style icon
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(12)
                    height: units.gu(12)
                    radius: units.gu(6)
                    color: accentColor
                    
                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(7)
                        height: units.gu(7)
                        name: "stock_image"
                        color: "white"
                    }
                }
                
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "MemeStream"
                    font.pixelSize: units.gu(4)
                    font.bold: true
                    color: textColor
                }
                
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Your daily dose of memes"
                    font.pixelSize: units.gu(1.8)
                    color: subtextColor
                }
            }
            
            // Tab Switcher
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(5)
                radius: units.gu(1)
                color: cardColor
                
                Row {
                    anchors.fill: parent
                    
                    // Login Tab
                    Rectangle {
                        width: parent.width / 2
                        height: parent.height
                        radius: units.gu(1)
                        color: isLoginMode ? accentColor : "transparent"
                        
                        Label {
                            anchors.centerIn: parent
                            text: "Login"
                            font.pixelSize: units.gu(2)
                            font.bold: isLoginMode
                            color: isLoginMode ? "white" : subtextColor
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                isLoginMode = true
                                errorMessage = ""
                            }
                        }
                    }
                    
                    // Signup Tab
                    Rectangle {
                        width: parent.width / 2
                        height: parent.height
                        radius: units.gu(1)
                        color: !isLoginMode ? accentColor : "transparent"
                        
                        Label {
                            anchors.centerIn: parent
                            text: "Sign Up"
                            font.pixelSize: units.gu(2)
                            font.bold: !isLoginMode
                            color: !isLoginMode ? "white" : subtextColor
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                isLoginMode = false
                                errorMessage = ""
                            }
                        }
                    }
                }
            }
            
            // Login/Signup Form Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formColumn.height + units.gu(4)
                radius: units.gu(1.5)
                color: cardColor
                
                ColumnLayout {
                    id: formColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: units.gu(2)
                    spacing: units.gu(2)
                    
                    // Username Field
                    Column {
                        Layout.fillWidth: true
                        spacing: units.gu(0.5)
                        
                        Label {
                            text: "Username"
                            font.pixelSize: units.gu(1.6)
                            color: subtextColor
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: units.gu(5)
                            radius: units.gu(0.8)
                            color: bgColor
                            border.color: usernameInput.activeFocus ? accentColor : dividerColor
                            border.width: usernameInput.activeFocus ? 2 : 1
                            
                            TextInput {
                                id: usernameInput
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                verticalAlignment: TextInput.AlignVCenter
                                color: textColor
                                font.pixelSize: units.gu(1.8)
                                clip: true
                                
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Enter your username"
                                    color: subtextColor
                                    font.pixelSize: units.gu(1.8)
                                    visible: !usernameInput.text && !usernameInput.activeFocus
                                }
                            }
                        }
                    }
                    
                    // Email Field (Signup only)
                    Column {
                        Layout.fillWidth: true
                        spacing: units.gu(0.5)
                        visible: !isLoginMode
                        
                        Label {
                            text: "Email"
                            font.pixelSize: units.gu(1.6)
                            color: subtextColor
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: units.gu(5)
                            radius: units.gu(0.8)
                            color: bgColor
                            border.color: emailInput.activeFocus ? accentColor : dividerColor
                            border.width: emailInput.activeFocus ? 2 : 1
                            
                            TextInput {
                                id: emailInput
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                verticalAlignment: TextInput.AlignVCenter
                                color: textColor
                                font.pixelSize: units.gu(1.8)
                                inputMethodHints: Qt.ImhEmailCharactersOnly
                                clip: true
                                
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Enter your email"
                                    color: subtextColor
                                    font.pixelSize: units.gu(1.8)
                                    visible: !emailInput.text && !emailInput.activeFocus
                                }
                            }
                        }
                    }
                    
                    // Password Field
                    Column {
                        Layout.fillWidth: true
                        spacing: units.gu(0.5)
                        
                        Label {
                            text: "Password"
                            font.pixelSize: units.gu(1.6)
                            color: subtextColor
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: units.gu(5)
                            radius: units.gu(0.8)
                            color: bgColor
                            border.color: passwordInput.activeFocus ? accentColor : dividerColor
                            border.width: passwordInput.activeFocus ? 2 : 1
                            
                            TextInput {
                                id: passwordInput
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                verticalAlignment: TextInput.AlignVCenter
                                color: textColor
                                font.pixelSize: units.gu(1.8)
                                echoMode: TextInput.Password
                                clip: true
                                
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Enter your password"
                                    color: subtextColor
                                    font.pixelSize: units.gu(1.8)
                                    visible: !passwordInput.text && !passwordInput.activeFocus
                                }
                            }
                        }
                    }
                    
                    // Confirm Password Field (Signup only)
                    Column {
                        Layout.fillWidth: true
                        spacing: units.gu(0.5)
                        visible: !isLoginMode
                        
                        Label {
                            text: "Confirm Password"
                            font.pixelSize: units.gu(1.6)
                            color: subtextColor
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: units.gu(5)
                            radius: units.gu(0.8)
                            color: bgColor
                            border.color: confirmPasswordInput.activeFocus ? accentColor : dividerColor
                            border.width: confirmPasswordInput.activeFocus ? 2 : 1
                            
                            TextInput {
                                id: confirmPasswordInput
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                verticalAlignment: TextInput.AlignVCenter
                                color: textColor
                                font.pixelSize: units.gu(1.8)
                                echoMode: TextInput.Password
                                clip: true
                                
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Confirm your password"
                                    color: subtextColor
                                    font.pixelSize: units.gu(1.8)
                                    visible: !confirmPasswordInput.text && !confirmPasswordInput.activeFocus
                                }
                            }
                        }
                    }
                    
                    // Error Message
                    Label {
                        Layout.fillWidth: true
                        text: errorMessage
                        color: "#FF6B6B"
                        font.pixelSize: units.gu(1.5)
                        wrapMode: Text.WordWrap
                        visible: errorMessage !== ""
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Submit Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.gu(5.5)
                        radius: units.gu(1)
                        color: submitMouseArea.pressed ? Qt.darker(accentColor, 1.2) : accentColor
                        opacity: isLoading ? 0.7 : 1
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(1)
                            
                            ActivityIndicator {
                                running: isLoading
                                visible: isLoading
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                            }
                            
                            Label {
                                text: isLoading ? "Please wait..." : (isLoginMode ? "Login" : "Create Account")
                                font.pixelSize: units.gu(2)
                                font.bold: true
                                color: "white"
                            }
                        }
                        
                        MouseArea {
                            id: submitMouseArea
                            anchors.fill: parent
                            enabled: !isLoading
                            onClicked: {
                                if (validateForm()) {
                                    if (isLoginMode) {
                                        loginRequested(usernameInput.text, passwordInput.text)
                                    } else {
                                        signupRequested(usernameInput.text, emailInput.text, passwordInput.text)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Forgot Password (Login only)
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Forgot password?"
                        font.pixelSize: units.gu(1.6)
                        color: accentColor
                        visible: isLoginMode
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // TODO: Implement forgot password
                                errorMessage = "Password reset will open Reddit in browser"
                            }
                        }
                    }
                }
            }
            
            // Divider with "or"
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: units.gu(2)
                
                Rectangle {
                    width: units.gu(8)
                    height: 1
                    color: dividerColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Label {
                    text: "or"
                    font.pixelSize: units.gu(1.6)
                    color: subtextColor
                }
                
                Rectangle {
                    width: units.gu(8)
                    height: 1
                    color: dividerColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Skip Login Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(5.5)
                radius: units.gu(1)
                color: skipMouseArea.pressed ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                border.color: dividerColor
                border.width: 1
                
                Row {
                    anchors.centerIn: parent
                    spacing: units.gu(1)
                    
                    Icon {
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        name: "go-next"
                        color: textColor
                    }
                    
                    Label {
                        text: "Continue without account"
                        font.pixelSize: units.gu(2)
                        color: textColor
                    }
                }
                
                MouseArea {
                    id: skipMouseArea
                    anchors.fill: parent
                    onClicked: skipRequested()
                }
            }
            
            // Info text
            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                text: "You can browse memes without logging in.\nLogin enables upvoting, commenting, and saving."
                font.pixelSize: units.gu(1.4)
                color: subtextColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            
            // Reddit OAuth info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: oauthInfo.height + units.gu(2)
                radius: units.gu(1)
                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1)
                border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                border.width: 1
                
                Row {
                    id: oauthInfo
                    anchors.centerIn: parent
                    anchors.margins: units.gu(1)
                    spacing: units.gu(1)
                    width: parent.width - units.gu(2)
                    
                    Icon {
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        name: "info"
                        color: accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Label {
                        text: "Login uses Reddit OAuth for secure authentication"
                        font.pixelSize: units.gu(1.4)
                        color: subtextColor
                        wrapMode: Text.WordWrap
                        width: parent.width - units.gu(4)
                    }
                }
            }
            
            // Bottom spacing
            Item {
                Layout.preferredHeight: units.gu(4)
            }
        }
    }
    
    // Form validation
    function validateForm() {
        errorMessage = ""
        
        if (usernameInput.text.trim() === "") {
            errorMessage = "Please enter your username"
            return false
        }
        
        if (usernameInput.text.length < 3) {
            errorMessage = "Username must be at least 3 characters"
            return false
        }
        
        if (!isLoginMode && emailInput.text.trim() === "") {
            errorMessage = "Please enter your email"
            return false
        }
        
        if (!isLoginMode && !isValidEmail(emailInput.text)) {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        if (passwordInput.text === "") {
            errorMessage = "Please enter your password"
            return false
        }
        
        if (passwordInput.text.length < 6) {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        if (!isLoginMode && passwordInput.text !== confirmPasswordInput.text) {
            errorMessage = "Passwords do not match"
            return false
        }
        
        return true
    }
    
    function isValidEmail(email) {
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        return emailRegex.test(email)
    }
    
    function clearForm() {
        usernameInput.text = ""
        emailInput.text = ""
        passwordInput.text = ""
        confirmPasswordInput.text = ""
        errorMessage = ""
        isLoading = false
    }
    
    function showError(message) {
        errorMessage = message
        isLoading = false
    }
}
