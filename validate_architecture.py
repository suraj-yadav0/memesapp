#!/usr/bin/env python3
"""
MemeApp Architecture Validation Script
Tests the new Model-View-Service architecture
"""

import os
import sys
import json
from pathlib import Path

def validate_file_structure():
    """Validate that all required files exist"""
    print("🔍 Validating file structure...")
    
    required_files = [
        "qml/Main.qml",
        "qml/SettingsPage.qml",
        "qml/models/MemeModel.qml",
        "qml/models/MemeAPI.qml",
        "qml/models/qmldir",
        "qml/services/MemeService.qml",  
        "qml/services/qmldir",
        "qml/components/MemeDelegate.qml",
        "qml/components/qmldir",
        "qml/TestMain.qml"
    ]
    
    missing_files = []
    existing_files = []
    
    for file_path in required_files:
        if os.path.exists(file_path):
            existing_files.append(file_path)
            print(f"  ✅ {file_path}")
        else:
            missing_files.append(file_path)
            print(f"  ❌ {file_path}")
    
    print(f"\n📊 File Structure Summary:")
    print(f"  ✅ Existing files: {len(existing_files)}")
    print(f"  ❌ Missing files: {len(missing_files)}")
    
    return len(missing_files) == 0

def validate_qml_syntax():
    """Check QML files for basic syntax validation"""
    print("\n🔍 Validating QML syntax...")
    
    qml_files = [
        "qml/TestMain.qml",
        "qml/models/MemeModel.qml", 
        "qml/models/MemeAPI.qml",
        "qml/services/MemeService.qml",
        "qml/components/MemeDelegate.qml"
    ]
    
    syntax_ok = True
    
    for qml_file in qml_files:
        if os.path.exists(qml_file):
            try:
                with open(qml_file, 'r') as f:
                    content = f.read()
                    
                # Basic syntax checks
                if content.count('{') != content.count('}'):
                    print(f"  ❌ {qml_file}: Mismatched braces")
                    syntax_ok = False
                elif 'import QtQuick' not in content:
                    print(f"  ⚠️  {qml_file}: No QtQuick import")
                else:
                    print(f"  ✅ {qml_file}: Basic syntax OK")
                    
            except Exception as e:
                print(f"  ❌ {qml_file}: Error reading - {e}")
                syntax_ok = False
        else:
            print(f"  ⚠️  {qml_file}: File not found")
    
    return syntax_ok

def validate_architecture_separation():
    """Validate that the architecture layers are properly separated"""
    print("\n🔍 Validating architecture separation...")
    
    # Check Model layer
    model_files = ["qml/models/MemeModel.qml", "qml/models/MemeAPI.qml"]
    view_files = ["qml/Main.qml", "qml/components/MemeDelegate.qml"]
    service_files = ["qml/services/MemeService.qml"]
    
    architecture_ok = True
    
    # Check if Model files don't have view-specific imports
    for model_file in model_files:
        if os.path.exists(model_file):
            with open(model_file, 'r') as f:
                content = f.read()
                if 'import QtQuick.Controls' in content or 'import Ubuntu.Components' in content:
                    print(f"  ❌ {model_file}: Contains view-specific imports (should be pure data/logic)")
                    architecture_ok = False
                else:
                    print(f"  ✅ {model_file}: Clean model layer")
    
    # Check if Service layer exists and properly coordinates
    for service_file in service_files:
        if os.path.exists(service_file):
            with open(service_file, 'r') as f:
                content = f.read()
                if 'MemeAPI' in content and 'memeModel' in content:
                    print(f"  ✅ {service_file}: Properly coordinates Model and API")
                else:
                    print(f"  ⚠️  {service_file}: May not be properly coordinating layers")
    
    return architecture_ok

def validate_data_flow():
    """Validate that data flows properly through the architecture"""
    print("\n🔍 Validating data flow...")
    
    expected_patterns = {
        "qml/models/MemeAPI.qml": ["signal memesLoaded", "XMLHttpRequest", "fetchMemes"],
        "qml/models/MemeModel.qml": ["ListModel", "addMeme", "clearModel"],
        "qml/services/MemeService.qml": ["MemeAPI", "memeModel", "memesRefreshed"],
        "qml/Main.qml": ["MemeService", "MemeModel", "memeService.fetchMemes"]
    }
    
    data_flow_ok = True
    
    for file_path, patterns in expected_patterns.items():
        if os.path.exists(file_path):
            with open(file_path, 'r') as f:
                content = f.read()
                
            missing_patterns = []
            for pattern in patterns:
                if pattern not in content:
                    missing_patterns.append(pattern)
            
            if missing_patterns:
                print(f"  ⚠️  {file_path}: Missing patterns - {missing_patterns}")
                data_flow_ok = False
            else:
                print(f"  ✅ {file_path}: All expected patterns found")
        else:
            print(f"  ❌ {file_path}: File not found")
            data_flow_ok = False
    
    return data_flow_ok

def validate_qmldir_files():
    """Validate qmldir files for proper module registration"""
    print("\n🔍 Validating qmldir files...")
    
    qmldir_files = {
        "qml/models/qmldir": ["MemeModel", "MemeAPI"],
        "qml/services/qmldir": ["MemeService"],
        "qml/components/qmldir": ["MemeDelegate", "CategorySelector"]
    }
    
    qmldir_ok = True
    
    for qmldir_path, expected_components in qmldir_files.items():
        if os.path.exists(qmldir_path):
            with open(qmldir_path, 'r') as f:
                content = f.read()
            
            missing_components = []
            for component in expected_components:
                if component not in content:
                    missing_components.append(component)
            
            if missing_components:
                print(f"  ⚠️  {qmldir_path}: Missing components - {missing_components}")
            else:
                print(f"  ✅ {qmldir_path}: All components registered")
        else:
            print(f"  ❌ {qmldir_path}: File not found")
            qmldir_ok = False
    
    return qmldir_ok

def generate_architecture_summary():
    """Generate a summary of the new architecture"""
    print("\n📋 Architecture Summary:")
    print("=" * 50)
    
    print("\n🏗️  Model-View-Service Architecture:")
    print("  📊 Model Layer:")
    print("    • MemeModel.qml - Data storage and management")
    print("    • MemeAPI.qml - Backend API calls to Reddit")
    print("  ")
    print("  🔧 Service Layer:")
    print("    • MemeService.qml - Business logic coordination")
    print("    • Coordinates between API and Model")
    print("    • Handles state management")
    print("  ")
    print("  🎨 View Layer:")
    print("    • Main.qml - Main application view")
    print("    • MemeDelegate.qml - Individual meme display")
    print("    • SettingsPage.qml - Settings interface")
    
    print("\n🔄 Data Flow:")
    print("  1. User Action → Service Layer")
    print("  2. Service → API Layer (fetch data)")
    print("  3. API → Service (return data)")
    print("  4. Service → Model (store data)")
    print("  5. Model → View (display data)")
    
    print("\n✅ Architecture Benefits:")
    print("  • Separation of concerns")
    print("  • Testable components")
    print("  • Maintainable code structure")
    print("  • Reusable components")
    print("  • Clear data flow")

def main():
    """Main validation function"""
    print("🧪 MemeApp Architecture Validation")
    print("=" * 50)
    
    # Change to the project directory
    os.chdir('/home/suraj/memesapp')
    
    # Run all validations
    validations = [
        ("File Structure", validate_file_structure),
        ("QML Syntax", validate_qml_syntax),
        ("Architecture Separation", validate_architecture_separation),
        ("Data Flow", validate_data_flow),
        ("QML Module Registration", validate_qmldir_files)
    ]
    
    results = {}
    
    for validation_name, validation_func in validations:
        try:
            results[validation_name] = validation_func()
        except Exception as e:
            print(f"❌ Error in {validation_name}: {e}")
            results[validation_name] = False
    
    # Generate summary
    generate_architecture_summary()
    
    # Overall results
    print("\n📊 Validation Results:")
    print("=" * 30)
    
    passed = 0
    total = len(results)
    
    for validation_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {status} {validation_name}")
        if result:
            passed += 1
    
    print(f"\n🎯 Overall Score: {passed}/{total} validations passed")
    
    if passed == total:
        print("🎉 All validations passed! Architecture is properly implemented.")
        return 0
    else:
        print("⚠️  Some validations failed. Please review the issues above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
