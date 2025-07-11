# Logo Matic

A modern Flutter application for adding logos to your images with precise positioning and easy batch processing.

## Features

- **Multi-Image Processing**: Select and process multiple images at once
- **Logo Positioning**: Choose from 5 position options (center, top-left, top-right, bottom-left, bottom-right)
- **Live Preview**: Real-time preview of how your logo will appear on images
- **Batch Save**: Save all processed images to your device gallery at once
- **File Picker Integration**: Direct file picker access without additional dialogs
- **Cross-Platform Support**: Works on Android, iOS, Windows, macOS, and Linux
- **Modern UI**: Clean Material Design 3 interface with intuitive workflow

## Technologies

- **Flutter/Dart** for cross-platform development
- **Provider** package for efficient state management
- **Material Design 3** for modern UI implementation
- **Image Processing** with native Dart image library
- **File Picker** for seamless file selection
- **Gallery Saver** for saving processed images
- **Path Provider** for cross-platform file management
- **Responsive Design** optimized for multiple screen sizes

## How to Use

1. **Select Images**: Choose one or more images you want to add your logo to
2. **Choose Logo**: Select your logo image (PNG with transparency recommended)
3. **Position Logo**: Pick where you want the logo to appear on your images
4. **Preview**: See a live preview of the result
5. **Process & Save**: Process all images and save them to your gallery

## Supported Formats

- **Input Images**: JPEG, PNG, BMP
- **Logo Files**: PNG (recommended for transparency), JPEG, BMP
- **Output**: High-quality processed images saved to device gallery

## Getting Started

### Prerequisites

- Flutter SDK (3.16.0 or later)
- Dart SDK (3.4.3 or later)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/xMaan1/Logo-Matic.git
   ```

2. Navigate to the project directory:
   ```bash
   cd Logo-Matic
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── components/          # Reusable UI components
│   ├── action_buttons.dart
│   ├── image_selection_card.dart
│   ├── live_preview_card.dart
│   ├── logo_position_card.dart
│   ├── logo_selection_card.dart
│   └── quick_preview.dart
├── models/             # Data models and business logic
│   └── logo_matic_model.dart
├── screens/            # App screens
│   ├── full_screen_image.dart
│   ├── home_screen.dart
│   └── preview_screen.dart
├── utils/              # Utility functions
│   ├── file_utils.dart
│   └── logo_position_helper.dart
└── main.dart           # App entry point
```

## Key Dependencies

- `file_picker: ^6.1.1` - File selection functionality
- `image: ^4.1.7` - Image processing and manipulation
- `provider: ^6.1.1` - State management
- `gallery_saver: ^2.3.2` - Save images to device gallery
- `path_provider: ^2.1.2` - Cross-platform file paths

## Recent Updates

- **Simplified File Selection**: Removed intermediate dialog popup for direct file picker access
- **Improved Performance**: Optimized image processing and preview generation
- **Enhanced Error Handling**: Better user feedback for file operations
- **Code Cleanup**: Streamlined codebase for better maintainability

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines

1. Follow Flutter/Dart style guidelines
2. Ensure cross-platform compatibility
3. Test on multiple devices/platforms
4. Update documentation for new features

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

- GitHub: [xMaan1](https://github.com/xMaan1)
- Issues: [Report bugs or request features](https://github.com/xMaan1/Logo-Matic/issues)
