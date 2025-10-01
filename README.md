# MemeStream 🎭

A fun and intuitive memes app for Ubuntu Touch that brings the best of Reddit's meme communities to your mobile device.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20Touch-orange)
![License](https://img.shields.io/badge/license-GPL%20v3-green)

## Features ✨

### 🎯 **Curated Categories**
- **General Memes** (r/memes) - Classic internet humor
- **Dank Memes** (r/dankmemes) - Cutting-edge meme culture
- **Wholesome Memes** (r/wholesomememes) - Feel-good content
- **Programming Humor** (r/ProgrammerHumor) - Developer jokes
- **Gaming Memes** (r/gaming) - Video game humor
- **Anime Memes** (r/AnimeMemes) - Anime and manga jokes
- And more specialized categories!

### 🔧 **Smart Interface**
- **Dark/Light Mode** - Adaptive theming for comfortable viewing
- **Custom Subreddit Support** - Explore and save any meme subreddit
- **Fullscreen Image Viewer** - Immersive viewing with zoom and swipe navigation
- **Touch Gestures** - Swipe left/right to navigate between memes
- **Zoom Functionality** - Pinch to zoom, mouse wheel, and zoom controls
- **Local Database** - Save custom subreddits with favorites and usage tracking
- **Pull-to-Refresh** - Easy content updates with gesture support
- **Responsive Design** - Optimized for mobile and desktop screens

### 📱 **Ubuntu Touch Integration**
- Native Lomiri UI components
- Touch-optimized navigation
- Adaptive layout for different screen sizes
- System theme integration


## Installation 🚀

### Prerequisites
- Ubuntu Touch device or emulator
- Clickable development environment (for building from source)

### Building from Source

1. **Clone the repository:**
   ```bash
   git clone <https://github.com/suraj-yadav0/memesapp.git>
   cd memesapp
   ```

2. **Install Clickable:**
   ```bash
   pip3 install --user clickable-ut
   ```

3. **Build and run:**
   ```bash
   clickable desktop  # For desktop testing
   clickable          # For device deployment
   ```

### From OpenStore
*Coming soon - Will be available on the Ubuntu Touch OpenStore*

## Architecture 🏗️

### Project Structure
```
memesapp/
├── qml/
│   ├── Main.qml                          # Main application (391 lines, refactored!)
│   ├── components/                       # Modular UI components
│   │   ├── AppHeader.qml                # Application header with actions
│   │   ├── FullscreenImageViewer.qml    # Image viewer with zoom/swipe
│   │   ├── ManageSubredditsDialog.qml   # Custom subreddit management
│   │   ├── MemeDelegate.qml             # Individual meme display
│   │   ├── MemeGridView.qml             # Grid layout with pull-to-refresh
│   │   └── SubredditSelectionDialog.qml # Subreddit selection interface
│   ├── models/                          # Data layer
│   │   ├── MemeModel.qml                # Meme data structure
│   │   └── MemeAPI.qml                  # Reddit API interface
│   └── services/                        # Service layer
│       └── DatabaseManager.qml          # SQLite database operations
├── assets/                              # Static resources
├── po/                                  # Internationalization files
├── CMakeLists.txt                      # Build configuration
├── clickable.yaml                      # Clickable configuration
└── manifest.json                       # App metadata
```

### Key Components

- **MemeAPI**: Handles Reddit API communication and data processing
- **MemeModel**: Manages meme data and state with ListModel
- **DatabaseManager**: SQLite integration for custom subreddit storage
- **FullscreenImageViewer**: Advanced image viewer with zoom, pan, and swipe navigation
- **MemeGridView**: Responsive grid layout with pull-to-refresh and infinite scroll
- **SubredditSelectionDialog**: Unified interface for subreddit selection and custom input
- **ManageSubredditsDialog**: Complete CRUD interface for saved subreddits
- **AppHeader**: Centralized navigation with settings and refresh actions

## Usage 📖

### Getting Started
1. Launch MemeStream from your app drawer
2. Browse memes from the default "r/memes" subreddit
3. Tap the settings icon to choose different categories or enter custom subreddits
4. Toggle between light and dark modes using the theme button

### Navigation
- **Scroll** through the meme feed vertically or use pull-to-refresh
- **Tap images** to view in fullscreen mode with zoom capabilities
- **Swipe left/right** or use arrow keys to navigate between memes in fullscreen
- **Pinch to zoom** or use mouse wheel for image scaling
- **Pan** around zoomed images with touch or mouse
- **Tap close button** (✕) or press Escape to exit fullscreen view

### Customization
- **Theme Toggle**: Switch between light and dark modes in settings
- **Category Selection**: Choose from 25+ predefined meme categories
- **Custom Subreddits**: Enter and save any subreddit name to your collection
- **Subreddit Management**: Add favorites, track usage, and organize saved subreddits
- **Database Storage**: Custom subreddits persist locally with SQLite
- **Settings Persistence**: All preferences saved between app sessions

## Development 🛠️

### Technology Stack
- **QML/Qt 2.12**: Modern user interface framework
- **Ubuntu Touch SDK**: Native platform integration
- **Lomiri Components 1.3**: Ubuntu Touch UI toolkit
- **Qt LocalStorage/SQLite**: Local database for custom subreddits
- **CMake**: Build system and deployment
- **Clickable**: Ubuntu Touch development and testing tool

### Modular Architecture

The app follows a clean component-based architecture:

```qml
// Example: Using a reusable component
MemeGridView {
    onMemeClicked: fullscreenViewer.open()
    onLoadMore: api.fetchMoreMemes()
}

// Example: Database integration
DatabaseManager {
    onCustomSubredditsLoaded: updateUI(subreddits)
}
```

### API Integration
MemeStream fetches content from Reddit's public JSON API:
- **Endpoint**: `https://www.reddit.com/r/{subreddit}.json`
- **Rate Limiting**: Respectful API usage with appropriate delays
- **Error Handling**: Graceful fallbacks for network issues

## Contributing 🤝

Contributions are welcome! Here's how you can help:

### Ways to Contribute
- 🐛 **Bug Reports**: Found an issue? Open a GitHub issue
- 💡 **Feature Requests**: Have ideas? Share them with us
- 🔧 **Code Contributions**: Submit pull requests
- 📝 **Documentation**: Help improve our docs
- 🌍 **Translations**: Help localize the app

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### Code Style
- Follow QML best practices
- Use meaningful component and property names
- Add comments for complex logic
- Test on both desktop and device

## Troubleshooting 🔍

### Common Issues

**App won't load memes:**
- Check your internet connection
- Try switching to a different subreddit
- Ensure the subreddit name is spelled correctly

**Images not displaying:**
- Some subreddits may have text-only posts
- Try categories known for images like "memes" or "funny"

**Custom subreddit not working:**
- Verify the subreddit exists and is public
- Check that it contains image posts
- Remove any "r/" prefix from the input

### Debug Mode
To enable verbose logging and component debugging:
```bash
clickable desktop --verbose
# OR set QML debugging
QT_LOGGING_RULES="*.debug=true" clickable desktop
```

### Component Architecture
The modular design makes debugging easier:
- **Main.qml**: Check application state and component orchestration  
- **MemeGridView**: Verify grid layout and refresh functionality
- **FullscreenImageViewer**: Debug zoom, swipe, and navigation issues
- **DatabaseManager**: Monitor SQLite operations and custom subreddit storage

## Roadmap 🗺️

### ✅ **Completed in v1.0.0**
- [x] **Modular Architecture**: Refactored from monolithic to component-based design
- [x] **Touch Gestures**: Swipe navigation and pinch-to-zoom functionality
- [x] **Local Database**: SQLite integration for custom subreddit management
- [x] **Advanced Image Viewer**: Zoom, pan, and swipe navigation
- [x] **Pull-to-Refresh**: Gesture-based content updates
- [x] **Custom Subreddit Storage**: Persistent favorites and usage tracking

### 🚀 **Upcoming Features**
- [ ] **Offline Mode**: Cache memes for offline viewing
- [ ] **Search Functionality**: Search within loaded memes by title/content
- [ ] **Multiple Feeds**: View multiple subreddits simultaneously in tabs
- [ ] **Comment Viewing**: Read Reddit comments for memes
- [ ] **Enhanced Favorites**: Local meme bookmarking with tags
- [ ] **Improved Sharing**: Direct integration with system sharing
- [ ] **Export/Import**: Backup and sync custom subreddit collections

### ⚡ **Performance & UX Improvements**
- [ ] **Image Caching**: Faster loading of previously viewed memes
- [ ] **Lazy Loading**: Load images on demand for better memory usage
- [ ] **Memory Optimization**: Better resource management and cleanup
- [ ] **Keyboard Shortcuts**: Desktop-friendly navigation
- [ ] **Accessibility**: Screen reader support and improved contrast

## Privacy & Data 🔒

- **No User Data Collection**: MemeStream doesn't collect personal information
- **Reddit Public API**: Only accesses publicly available content
- **No Authentication**: No need to log into Reddit
- **Local Storage**: Preferences stored locally on your device
- **Network Usage**: Only for fetching meme content

## Support 💬

### Getting Help
- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs on GitHub Issues
- **Community**: Join Ubuntu Touch community forums
- **Email**: Contact the maintainer at surajyadav200701@gmail.com

### Feedback
We love hearing from users! Share your thoughts on:
- App features and usability
- New subreddit categories to add
- Performance on different devices
- Ideas for future improvements

## Acknowledgments 🙏

- **Ubuntu Touch Community**: For the amazing mobile platform
- **Reddit**: For providing public API access
- **Qt/QML**: For the excellent development framework
- **Clickable Team**: For the fantastic development tools
- **Lomiri Project**: For native UI components

## Changelog 📋

### v1.0.0 (2025)
- 🎉 Initial release with modular architecture
- ✨ 25+ predefined meme categories
- 🎨 Dark/Light theme support
- 📱 Custom subreddit input with database storage
- 🖼️ Advanced fullscreen viewer with zoom and swipe navigation
- � Pull-to-refresh and infinite scroll
- 💾 SQLite database for persistent custom subreddit management
- 🎯 Touch gesture support (swipe, pinch, pan)
- � Responsive design optimized for mobile and desktop
- 🏗️ Clean component-based architecture (Main.qml: 1420→391 lines!)

---

## License 📄

Copyright (C) 2025 Suraj Yadav

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3, as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

---

**Made with ❤️ for Ubuntu Touch**

*MemeStream - Bringing Reddit's best memes to your Ubuntu Touch device*
