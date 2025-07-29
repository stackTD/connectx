# SCADA ConnectX

A modern, industrial SCADA (Supervisory Control and Data Acquisition) application built with Flutter. This tool allows users to create factory plans, save them as .connectx files, set alarms, connect with PLCs, and display data through interactive widgets.

## 🏗️ Architecture

The application has been completely refactored to follow clean architecture principles with modern Flutter best practices:

- **Clean Architecture**: Clear separation between presentation, business logic, and data layers
- **Service-Oriented Design**: Centralized services for error handling, file operations, theme management, and performance monitoring
- **Reactive State Management**: MobX-based state management with automatic UI updates
- **Comprehensive Error Handling**: Error boundaries and centralized error service throughout the application
- **Performance Optimized**: Memory management, performance tracking, and optimized widget rebuilds

## ✨ Features

### Core Functionality
- **Visual Factory Planning**: Drag-and-drop interface for creating factory layouts
- **Project Management**: Save/load projects as .connectx files with metadata and validation
- **PLC Integration**: Connect and communicate with industrial PLCs (Modbus TCP and more)
- **Real-time Data Display**: Live data widgets including gauges, thermometers, and fans
- **Alarm System**: Configurable alarms and monitoring with notifications
- **Multi-Canvas Support**: Multiple drawing canvases for complex projects

### Technical Features
- **Modern UI**: Material 3 design system with light/dark theme support
- **Error Recovery**: Graceful error handling with user-friendly fallback interfaces
- **Performance Monitoring**: Built-in performance tracking and memory management
- **File Validation**: Robust file format validation with backup/recovery mechanisms
- **Responsive Design**: Optimized for various screen sizes and resolutions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.4.4)
- Dart SDK (>=3.4.4)
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/stackTD/connectx.git
cd connectx
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate MobX files**
```bash
flutter packages pub run build_runner build
```

4. **Run the application**
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── core/                           # Core framework
│   ├── constants/                  # Application constants
│   │   └── app_constants.dart
│   ├── services/                   # Business services
│   │   ├── error_service.dart      # Error handling
│   │   ├── file_service.dart       # File operations
│   │   ├── theme_service.dart      # Theme management
│   │   ├── performance_service.dart # Performance monitoring
│   │   └── memory_service.dart     # Memory management
│   ├── state/                      # State management
│   │   └── app_state_manager.dart  # Application state
│   └── widgets/                    # Reusable widgets
│       ├── error_boundary.dart     # Error boundaries
│       └── app_widgets.dart        # Common widgets
├── ui_components/                  # UI layer
│   ├── UIHeaderBar.dart
│   ├── UICanvasArea.dart
│   ├── UIPropertiesMenu.dart
│   └── ...
├── components/                     # Business logic
│   ├── drawing_area/               # Canvas management
│   ├── toolbar/                    # Widget components
│   ├── settings/                   # Configuration
│   └── connector_store.dart        # PLC communication
├── Alarm/                          # Alarm system
├── SmartWidgets/                   # SCADA widgets
└── main.dart                       # Application entry point
```

## 🛠️ Development

### Code Quality
The project follows strict coding standards and best practices:

- **Consistent Naming**: PascalCase for classes, camelCase for variables/methods
- **Documentation**: Comprehensive inline documentation and API docs
- **Error Handling**: All operations use centralized error service
- **Performance**: Built-in performance tracking and memory optimization
- **Testing**: Error boundary testing and service validation

### Key Services

#### ErrorService
Centralized error handling with logging and user notifications:
```dart
final errorService = ErrorService();
errorService.logError('Operation failed', error: e, context: 'FileOperation');
```

#### FileService
Robust file operations with validation and backup:
```dart
final fileService = FileService();
await fileService.saveConnectXProject('MyProject', projectData);
```

#### ThemeService
Modern Material 3 theme management:
```dart
final themeService = ThemeService();
await themeService.toggleTheme();
```

### Architecture Patterns
- **Service Locator**: Singleton services for global functionality
- **Observer Pattern**: MobX reactive state management
- **Error Boundary**: Graceful error handling with fallback UI
- **Mixin Pattern**: Reusable functionality (PerformanceTrackingMixin, MemoryManagementMixin)

## 📖 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md) - Detailed architecture overview
- [Coding Standards](docs/CODING_STANDARDS.md) - Development guidelines
- [API Documentation](docs/API_DOCUMENTATION.md) - Complete API reference

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/error_service_test.dart
```

### Test Coverage
The application includes:
- Unit tests for all services
- Widget tests for UI components
- Integration tests for file operations
- Error boundary testing

## 🔧 Configuration

### Environment Setup
Create configuration files for different environments:

- `device_conf.json` - PLC device configurations
- `alarm_conf.json` - Alarm system settings
- `items.json` - Available widget items

### Theme Customization
Themes can be customized through the ThemeService:
```dart
// Custom color schemes available
final themeService = ThemeService();
final customTheme = themeService.lightTheme.copyWith(
  colorScheme: customColorScheme,
);
```

## 🚀 Performance

### Optimization Features
- **Memory Management**: Automatic cache cleanup and memory monitoring
- **Performance Tracking**: Built-in operation timing and metrics
- **Lazy Loading**: On-demand widget and data loading
- **Efficient Rebuilds**: MobX reactive updates minimize unnecessary rebuilds

### Monitoring
Enable debug widgets for development:
```dart
// Add to main.dart for debugging
PerformanceDebugWidget(),
MemoryDebugWidget(),
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow coding standards and add tests
4. Commit changes (`git commit -m 'feat: add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Development Guidelines
- Follow the established architecture patterns
- Use the ErrorService for all error handling
- Add comprehensive documentation
- Include unit tests for new functionality
- Ensure UI components use error boundaries

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔧 Troubleshooting

### Common Issues

**Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Performance Issues**
- Use the PerformanceService to identify slow operations
- Monitor memory usage with MemoryService
- Check for memory leaks in debug widgets

**File Operation Errors**
- Verify file permissions
- Check FileService error logs
- Use backup/recovery mechanisms

## 📞 Support

For issues, questions, or contributions:
- Create an issue on GitHub
- Check the documentation in the `docs/` folder
- Review the coding standards for contribution guidelines

---

**Built with ❤️ using Flutter for industrial automation and SCADA applications.**
