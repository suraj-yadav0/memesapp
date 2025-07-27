#!/usr/bin/env python3
"""
Simple test to verify QML structure and navigation setup
"""
import re
import os

def check_qml_syntax(filepath):
    """Basic QML syntax checking"""
    print(f"Checking {filepath}...")
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Count braces
    open_braces = content.count('{')
    close_braces = content.count('}')
    
    print(f"  Open braces: {open_braces}")
    print(f"  Close braces: {close_braces}")
    
    if open_braces != close_braces:
        print(f"  ❌ BRACE MISMATCH in {filepath}")
        return False
    else:
        print(f"  ✅ Braces balanced in {filepath}")
    
    # Check for basic QML structure
    if 'import' in content and ('Item' in content or 'Page' in content or 'MainView' in content or 'Row' in content or 'Column' in content):
        print(f"  ✅ Basic QML structure found in {filepath}")
        return True
    else:
        print(f"  ❌ Invalid QML structure in {filepath}")
        return False

def check_navigation_setup():
    """Check if navigation setup is correct"""
    print("\nChecking navigation setup...")
    
    main_qml = '/home/suraj/memesapp/qml/Main.qml'
    settings_qml = '/home/suraj/memesapp/qml/SettingsPage.qml'
    
    with open(main_qml, 'r') as f:
        main_content = f.read()
    
    # Check for PageStack
    if 'PageStack' in main_content:
        print("  ✅ PageStack found in Main.qml")
    else:
        print("  ❌ PageStack missing in Main.qml")
        return False
    
    # Check for settings action
    if 'Settings' in main_content and 'Action' in main_content:
        print("  ✅ Settings action found in Main.qml")
    else:
        print("  ❌ Settings action missing in Main.qml")
        return False
    
    # Check for component creation
    if 'Qt.createComponent("SettingsPage.qml")' in main_content:
        print("  ✅ Settings page component creation found")
    else:
        print("  ❌ Settings page component creation missing")
        return False
    
    # Check if SettingsPage exists
    if os.path.exists(settings_qml):
        print("  ✅ SettingsPage.qml exists")
    else:
        print("  ❌ SettingsPage.qml missing")
        return False
    
    # Check for signal connections
    if 'darkModeChanged.connect' in main_content and 'selectedSubredditChanged.connect' in main_content:
        print("  ✅ Signal connections found")
    else:
        print("  ❌ Signal connections missing")
        return False
    
    return True

def main():
    print("🧪 Testing MemeApp Navigation Setup")
    print("=" * 40)
    
    qml_files = [
        '/home/suraj/memesapp/qml/Main.qml',
        '/home/suraj/memesapp/qml/SettingsPage.qml',
        '/home/suraj/memesapp/qml/components/CategorySelector.qml'
    ]
    
    all_good = True
    
    # Check syntax of all QML files
    for qml_file in qml_files:
        if os.path.exists(qml_file):
            if not check_qml_syntax(qml_file):
                all_good = False
        else:
            print(f"❌ File not found: {qml_file}")
            all_good = False
    
    # Check navigation setup
    if not check_navigation_setup():
        all_good = False
    
    print("\n" + "=" * 40)
    if all_good:
        print("🎉 All tests passed! Navigation should work.")
    else:
        print("❌ Some tests failed. Check the issues above.")

if __name__ == "__main__":
    main()
