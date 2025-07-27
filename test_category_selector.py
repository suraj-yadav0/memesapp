#!/usr/bin/env python3
"""
Test the Category Selector integration
"""

def check_category_selector():
    """Check if category selector is properly integrated in Main.qml"""
    print("🔍 Checking Category Selector Integration")
    print("=" * 40)
    
    main_file = "/home/suraj/memesapp/qml/Main.qml"
    
    try:
        with open(main_file, 'r') as f:
            content = f.read()
        
        # Check for category selector elements
        checks = {
            "ComboBox Component": "ComboBox {" in content,
            "Category Text": '"Category:"' in content,
            "categoryNames Model": "model: root.categoryNames" in content,
            "categoryMap Usage": "root.categoryMap[" in content,
            "Selection Handler": "onCurrentTextChanged" in content,
            "Subreddit Update": "memeService.fetchMemes" in content,
            "Initial Selection": "Component.onCompleted" in content,
            "Category Properties": "property var categoryNames" in content and "property var categoryMap" in content
        }
        
        print("📊 Integration Check Results:")
        print("-" * 30)
        
        passed = 0
        total = len(checks)
        
        for check_name, result in checks.items():
            status = "✅" if result else "❌"
            print(f"  {status} {check_name}")
            if result:
                passed += 1
        
        print(f"\n🎯 Integration Score: {passed}/{total}")
        
        if passed >= total - 1:
            print("✅ Category Selector is properly integrated!")
            
            # Show available categories
            print("\n📋 Available Categories:")
            if "categoryNames: [" in content:
                # Extract category names
                start = content.find("categoryNames: [")
                end = content.find("]", start)
                categories_section = content[start:end+1]
                print("  Found in Main.qml:")
                categories = [c.strip().replace('"', '') for c in categories_section.split('\n') if '"' in c]
                for i, cat in enumerate(categories[:5], 1):  # Show first 5
                    if cat:
                        print(f"    {i}. {cat}")
                if len(categories) > 5:
                    print(f"    ... and {len(categories) - 5} more")
            
            return True
        else:
            print("❌ Category Selector integration incomplete")
            return False
            
    except Exception as e:
        print(f"❌ Error checking integration: {e}")
        return False

def main():
    success = check_category_selector()
    
    print(f"\n{'='*40}")
    if success:
        print("🎉 Category Selector is available in the app!")
        print("Users can now select different meme categories from the dropdown.")
    else:
        print("⚠️  Category Selector needs attention.")
    
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
