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
- **Custom Subreddit Support** - Explore any meme subreddit
- **Fullscreen Image Viewer** - Immersive meme viewing experience
- **Share & Download** - Easy sharing and external access to memes
- **Responsive Design** - Optimized for mobile screens

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
│   ├── Main.qml                 # Main application window
│   ├── components/              # Reusable UI components
│   │   ├── CategorySelector.qml # Subreddit category picker
│   │   ├── MemeDelegate.qml     # Individual meme display
│   │   └── OptionSelector.qml   # Generic option selector
│   ├── models/                  # Data models
│   │   ├── MemeModel.qml        # Meme data structure
│   │   └── MemeAPI.qml          # Reddit API interface
│   └── services/                # Business logic
│       └── MemeService.qml      # Meme fetching service
├── assets/                      # Static resources
├── po/                          # Internationalization files
├── CMakeLists.txt              # Build configuration
├── clickable.yaml              # Clickable configuration
└── manifest.json               # App metadata
```

### Key Components

- **MemeService**: Handles Reddit API communication and data processing
- **MemeModel**: Manages meme data and state
- **CategorySelector**: Provides predefined subreddit categories
- **Custom Input**: Allows users to enter any subreddit name
- **Download Manager**: Handles meme sharing and external access

## Usage 📖

### Getting Started
1. Launch MemeStream from your app drawer
2. Browse memes from the default "r/memes" subreddit
3. Tap the settings icon to choose different categories or enter custom subreddits
4. Toggle between light and dark modes using the theme button

### Navigation
- **Scroll** through the meme feed vertically
- **Tap images** to view in fullscreen mode
- **Tap share icon** (📤) to open memes externally
- **Tap download icon** (💾) to access the image URL
- Use the **back button** or **swipe** to exit fullscreen view

### Customization
- **Theme Toggle**: Switch between light and dark modes
- **Category Selection**: Choose from 10+ predefined meme categories
- **Custom Subreddits**: Enter any subreddit name (e.g., "wholesomememes", "programmerhumor")
- **Settings Persistence**: Your preferences are saved between sessions

## Development 🛠️

### Technology Stack
- **QML/Qt**: User interface framework
- **Ubuntu Touch SDK**: Native platform integration
- **Lomiri Components**: Ubuntu Touch UI toolkit
- **CMake**: Build system
- **Clickable**: Ubuntu Touch development tool

### Building Components

The app follows a modular architecture:

```qml
// Example: Adding a new meme category
var newCategory = {
    "Your Category": "your_subreddit_name"
};
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
To enable verbose logging:
```bash
clickable desktop --verbose
```

## Roadmap 🗺️

### Upcoming Features
- [ ] **Offline Mode**: Cache memes for offline viewing
- [ ] **Search Functionality**: Search within loaded memes
- [ ] **User Preferences**: Customize feed order and filtering
- [ ] **Multiple Feeds**: View multiple subreddits simultaneously
- [ ] **Comment Viewing**: Read Reddit comments
- [ ] **Favorites System**: Save favorite memes locally
- [ ] **Improved Sharing**: Direct integration with system sharing

### Performance Improvements
- [ ] **Image Caching**: Faster loading of previously viewed memes
- [ ] **Lazy Loading**: Load images on demand
- [ ] **Memory Optimization**: Better resource management

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
- 🎉 Initial release
- ✨ 10+ predefined meme categories
- 🎨 Dark/Light theme support
- 📱 Custom subreddit input
- 🖼️ Fullscreen image viewer
- 📤 Share and download functionality
- 💾 Settings persistence
- 🔄 Responsive mobile design

---

## License 📄

Copyright (C) 2025 Suraj Yadav

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3, as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

---

**Made with ❤️ for Ubuntu Touch**

*MemeStream - Bringing Reddit's best memes to your Ubuntu Touch device*
