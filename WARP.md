# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

MemeStream is a Ubuntu Touch app built with QML/Qt that displays memes from Reddit's public API. It's designed for mobile touch interfaces using the Lomiri UI framework and follows Ubuntu Touch development patterns.

## Common Commands

### Development & Building
```bash
# Install Clickable (Ubuntu Touch development tool)
pip3 install --user clickable-ut

# Build and run on desktop (for testing)
clickable desktop

# Build and deploy to connected Ubuntu Touch device
clickable

# Build with verbose output for debugging
clickable desktop --verbose

# Clean build artifacts
clickable clean

# Only build without running
clickable build
```

### Testing & Development
```bash
# Run on desktop with debug logging
QML_IMPORT_TRACE=1 clickable desktop

# Check for QML syntax errors
qmlscene --check-syntax qml/Main.qml

# View application logs (when running on device)
clickable logs
```

### Packaging & Distribution
```bash
# Create click package
clickable click-build

# Install package on device
clickable install

# Review package contents
clickable review
```

## Architecture Overview

### Core Architecture Pattern
The app follows a **Service-Model-View** architecture pattern with QML:

- **Services Layer**: Business logic and external API communication
- **Models Layer**: Data management and state handling  
- **Views/Components Layer**: UI presentation and user interaction

### Key Components

#### MemeAPI (`qml/models/MemeAPI.qml`)
- Handles Reddit API communication via XMLHttpRequest
- Fetches from `https://www.reddit.com/r/{subreddit}/hot.json`
- Filters posts to only include image content
- Manages loading states and error handling
- Uses respectful API practices with proper User-Agent

#### MemeModel (`qml/models/MemeModel.qml`)
- Extends QML ListModel for meme data storage
- Manages duplicate detection and data integrity
- Provides statistics and search functionality
- Handles model updates and change notifications

#### MemeService (`qml/services/MemeService.qml`)
- Orchestrates communication between MemeAPI and MemeModel
- Provides high-level business logic methods
- Manages service lifecycle and state
- Acts as the main interface for UI components

#### Main Application (`qml/Main.qml`)
- Application entry point with StackView navigation
- Manages global app state (theme, subreddit selection)
- Coordinates between services and UI components
- Handles download/sharing functionality via Qt.openUrlExternally

### Component Structure
```
qml/
├── Main.qml                    # Application root & navigation
├── SettingsPage.qml           # Settings and subreddit selection
├── components/                # Reusable UI components
│   ├── CategorySelector.qml   # Predefined subreddit categories
│   ├── MemeDelegate.qml       # Individual meme display item
│   └── OptionSelector.qml     # Generic selection component
├── models/                    # Data layer
│   ├── MemeAPI.qml           # Reddit API interface
│   └── MemeModel.qml         # Meme data management
└── services/                  # Business logic layer
    └── MemeService.qml        # Service orchestration
```

### Data Flow
1. User selects subreddit → MemeService.fetchMemes()
2. MemeService → MemeAPI.fetchMemes() 
3. MemeAPI fetches from Reddit → parses JSON → filters images
4. MemeAPI.memesLoaded signal → MemeService updates MemeModel
5. MemeModel updates → ListView automatically refreshes UI

### Ubuntu Touch Integration
- Uses **Lomiri Components** for native UI elements (PageHeader, BusyIndicator)
- Implements **adaptive theming** (SuruDark/Ambiance)
- Touch-optimized navigation with proper gesture handling
- System integration via Qt.openUrlExternally for sharing
- Follows **Clickable** build system conventions
- Internationalization support with i18n.tr()

### State Management
- **Global state**: Stored in Main.qml root properties
- **Settings persistence**: Uses Qt.labs.settings for user preferences
- **Model state**: Managed by MemeModel with proper signals
- **Loading states**: Coordinated through service layer

### Key Design Patterns
- **Signal-Slot Communication**: All inter-component communication uses QML signals
- **Dependency Injection**: MemeService receives MemeModel via setModel()
- **Error Propagation**: Errors bubble up through signal chains
- **Resource Management**: Proper cleanup in Component.onDestruction handlers

## Development Notes

### QML Best Practices Used
- Consistent signal naming and error handling patterns
- Proper resource cleanup and memory management  
- Modular component architecture with clear boundaries
- Defensive programming with input validation

### API Considerations
- Reddit API has informal rate limits - app includes appropriate delays
- Only accesses public subreddits, no authentication required
- Respects robots.txt and uses identifying User-Agent header
- Gracefully handles network failures and malformed responses

### Mobile Optimization
- Touch-first interface design with appropriate touch targets
- Efficient image loading and memory management
- Responsive layout adapting to different screen sizes
- Battery-conscious network usage patterns
