#!/usr/bin/env python3
"""
Test QML property and signal behavior
"""
import re

def test_signal_declarations():
    print("🧪 Testing QML Signal Declarations")
    print("=" * 50)
    
    files_to_check = [
        ('/home/suraj/memesapp/qml/SettingsPage.qml', 'SettingsPage'),
        ('/home/suraj/memesapp/qml/components/CategorySelector.qml', 'CategorySelector')
    ]
    
    all_good = True
    
    for file_path, file_name in files_to_check:
        print(f"\nChecking {file_name}...")
        
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Check for property declarations
            properties = re.findall(r'property\s+\w+\s+(\w+):', content)
            manual_signals = re.findall(r'signal\s+(\w+)\s*\(', content)
            
            print(f"  Properties found: {properties}")
            print(f"  Manual signals found: {manual_signals}")
            
            # Check for duplicate signals (property + manual signal)
            conflicts = []
            for prop in properties:
                expected_signal = prop + 'Changed'
                if expected_signal in manual_signals:
                    conflicts.append((prop, expected_signal))
            
            if conflicts:
                print(f"  ❌ Signal conflicts found: {conflicts}")
                all_good = False
            else:
                print(f"  ✅ No signal conflicts in {file_name}")
                
            # Check for manual signal emissions
            manual_emissions = re.findall(r'(\w+)\.(\w+Changed)\s*\(', content)
            if manual_emissions:
                print(f"  ⚠️  Manual signal emissions found: {manual_emissions}")
                print(f"      These should be removed if properties auto-emit signals")
            else:
                print(f"  ✅ No manual signal emissions in {file_name}")
                
        except FileNotFoundError:
            print(f"  ❌ File not found: {file_path}")
            all_good = False
        except Exception as e:
            print(f"  ❌ Error reading {file_path}: {e}")
            all_good = False
    
    print("\n" + "=" * 50)
    if all_good:
        print("🎉 All signal declarations look good!")
        print("Navigation should work without duplicate signal errors.")
    else:
        print("❌ Some issues found. Check the details above.")
    
    return all_good

if __name__ == "__main__":
    test_signal_declarations()
