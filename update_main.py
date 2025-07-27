#!/usr/bin/env python3

# Read the original file
with open('qml/Main.qml', 'r') as f:
    content = f.read()

# Replace the header actions section
content = content.replace(
    "            // Header actions\n\n            \n\n        }",
    """            trailingActionBar {
                actions: [
                    Action {
                        iconName: "settings"
                        text: "Settings"
                        onTriggered: {
                            pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), {
                                darkMode: root.darkMode,
                                selectedSubreddit: root.selectedSubreddit,
                                categoryNames: root.categoryNames,
                                categoryMap: root.categoryMap,
                                memeFetcher: memeFetcher
                            })
                        }
                    }
                ]
            }

        }"""
)

# Add PageStack wrapper
content = content.replace(
    "    Page {",
    """    PageStack {
        id: pageStack

        Component.onCompleted: {
            pageStack.push(mainPage)
        }

        Page {
            id: mainPage"""
)

# Remove the OptionSelector section
lines = content.split('\n')
new_lines = []
skip_lines = False
for i, line in enumerate(lines):
    if "// Category selection using custom component" in line:
        skip_lines = True
        continue
    elif skip_lines and "// Loading indicator" in line:
        skip_lines = False
        new_lines.append(line)
        continue
    elif not skip_lines:
        new_lines.append(line)

content = '\n'.join(new_lines)

# Find the end of the main page and add PageStack closing
lines = content.split('\n')
new_lines = []
for i, line in enumerate(lines):
    new_lines.append(line)
    # Add PageStack closing before the last Component.onCompleted
    if i < len(lines) - 10 and "Settings {" in line and "Component.onCompleted:" in lines[i+8:i+12]:
        # Find the next closing brace after Settings
        for j in range(i+1, len(lines)):
            new_lines.append(lines[j])
            if lines[j].strip() == "}":
                new_lines.append("")
                new_lines.append("    }")  # Close PageStack
                # Add connections handling
                new_lines.append("")
                new_lines.append("    // Handle settings changes from SettingsPage")
                new_lines.append("    Connections {")
                new_lines.append("        target: pageStack.currentPage")
                new_lines.append("        ")
                new_lines.append("        onDarkModeChanged: {")
                new_lines.append("            if (darkMode !== undefined) {")
                new_lines.append("                root.darkMode = darkMode;")
                new_lines.append("            }")
                new_lines.append("        }")
                new_lines.append("        ")
                new_lines.append("        onSelectedSubredditChanged: {")
                new_lines.append("            if (subreddit !== undefined) {")
                new_lines.append("                root.selectedSubreddit = subreddit;")
                new_lines.append("                memeFetcher.fetchMemes();")
                new_lines.append("            }")
                new_lines.append("        }")
                new_lines.append("    }")
                break
        break

# Remove the line that sets initial selection
content = '\n'.join(new_lines)
content = content.replace("        categorySelector.setInitialSelection(root.selectedSubreddit);", "")

# Write the modified content
with open('qml/Main.qml', 'w') as f:
    f.write(content)

print("Main.qml updated successfully")
