# SCADA ConnectX Coding Standards

## Overview

This document outlines the coding standards and best practices for the SCADA ConnectX Flutter application to ensure consistent, maintainable, and high-quality code.

## Dart/Flutter Conventions

### 1. Naming Conventions

#### Classes and Types
```dart
// Good: PascalCase for classes
class AppStateManager extends _AppStateManager with _$AppStateManager;
class ErrorService { }
class UICanvasArea extends StatefulWidget { }

// Bad
class appStateManager { }
class error_service { }
```

#### Variables and Methods
```dart
// Good: camelCase for variables and methods
bool showSecondColumn1 = false;
String selectedDeviceName = '';
void toggleColumn(String column) { }

// Bad
bool show_second_column_1 = false;
String SelectedDeviceName = '';
void ToggleColumn(String column) { }
```

#### Constants
```dart
// Good: Use static const with descriptive names
static const String appTitle = 'SL Scada Application';
static const double defaultScale = 1.0;
static const Duration defaultCacheExpiry = Duration(minutes: 30);

// Bad
final APP_TITLE = 'SL Scada Application';
const double scale = 1.0;
```

#### Files and Directories
```dart
// Good: snake_case for file names
app_state_manager.dart
error_service.dart
ui_canvas_area.dart

// Bad
AppStateManager.dart
ErrorService.dart
UICanvasArea.dart
```

### 2. Code Organization

#### Import Ordering
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:provider/provider.dart';
import 'package:mobx/mobx.dart';

// 4. Local imports (relative)
import '../core/services/error_service.dart';
import '../components/connector_store.dart';
import 'ui_header_bar.dart';
```

#### Class Structure
```dart
class ExampleWidget extends StatefulWidget {
  // 1. Static members
  static const String title = 'Example';
  
  // 2. Instance variables (final first)
  final String requiredProperty;
  final VoidCallback? optionalCallback;
  
  // 3. Constructor
  const ExampleWidget({
    Key? key,
    required this.requiredProperty,
    this.optionalCallback,
  }) : super(key: key);
  
  // 4. Factory constructors
  factory ExampleWidget.fromJson(Map<String, dynamic> json) {
    return ExampleWidget(requiredProperty: json['property']);
  }
  
  // 5. Methods
  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}
```

### 3. Documentation Standards

#### Class Documentation
```dart
/// Service for handling errors throughout the application
/// 
/// Provides consistent error logging, reporting, and user notification.
/// Use this service instead of direct print statements or manual error handling.
/// 
/// Example:
/// ```dart
/// final errorService = ErrorService();
/// errorService.logError('Operation failed', error: e, context: 'FileOperation');
/// ```
class ErrorService {
  // Implementation
}
```

#### Method Documentation
```dart
/// Saves project data as a .connectx file
/// 
/// Automatically adds metadata including version, creation date, and application info.
/// Creates backup if file already exists.
/// 
/// [projectName] - Name of the project (extension optional)
/// [projectData] - Project data to save
/// 
/// Returns `true` if save was successful, `false` otherwise.
/// 
/// Throws [FileSystemException] if directory is not accessible.
Future<bool> saveConnectXProject(String projectName, Map<String, dynamic> projectData) async {
  // Implementation
}
```

## Architecture Patterns

### 1. Service Pattern
```dart
// Good: Singleton service with clear responsibilities
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();
  
  void logError(String message, {Object? error, String? context}) {
    // Implementation
  }
}

// Usage
final errorService = ErrorService();
errorService.logError('Failed to load file');
```

### 2. State Management with MobX
```dart
// Good: Clear observable state with actions
abstract class _AppStateManager with Store {
  @observable
  bool showSecondColumn1 = false;
  
  @action
  void toggleColumn(String column) {
    switch (column) {
      case AppConstants.columnSettings:
        showSecondColumn1 = true;
        break;
      // Other cases
    }
  }
}
```

### 3. Error Boundary Pattern
```dart
// Good: Wrap components in error boundaries
ErrorBoundary(
  errorTitle: 'Canvas Error',
  errorMessage: 'There was an error loading the canvas area.',
  child: UICanvasArea(...),
)
```

## Error Handling Standards

### 1. Use ErrorService for All Errors
```dart
// Good
try {
  await riskyOperation();
} catch (error) {
  errorService.logError(
    'Operation failed',
    error: error,
    context: 'OperationName',
  );
  if (context.mounted) {
    errorService.showErrorSnackbar(context, 'Operation failed');
  }
}

// Bad
try {
  await riskyOperation();
} catch (error) {
  print('Error: $error'); // Don't use print directly
  // No user feedback
}
```

### 2. Provide User-Friendly Messages
```dart
// Good
errorService.handleFileError(context, 'save project', error);

// Bad
throw Exception('File operation failed: ${error.toString()}');
```

### 3. Context-Aware Error Handling
```dart
// Good
final result = await errorService.handleAsyncFutureError(
  'load configuration',
  () => fileService.loadConfig('app_settings'),
  context: context,
  contextName: 'AppInitialization',
);
```

## Performance Guidelines

### 1. Use Const Constructors
```dart
// Good
const AppCard(
  title: 'Settings',
  child: SettingsContent(),
)

// Bad
AppCard(
  title: 'Settings',
  child: SettingsContent(),
)
```

### 2. Performance Tracking
```dart
// Good: Track expensive operations
class CanvasWidget extends StatefulWidget with PerformanceTrackingMixin {
  @override
  Widget build(BuildContext context) {
    return trackBuildPerformance('CanvasWidget', () {
      return ExpensiveWidget();
    });
  }
}
```

### 3. Memory Management
```dart
// Good: Use memory service for caching
class DataWidget extends StatefulWidget with MemoryManagementMixin {
  void loadData() {
    final cached = getCachedWidgetData<List<Item>>('items');
    if (cached != null) {
      displayItems(cached);
    } else {
      fetchAndCacheItems();
    }
  }
}
```

## UI/UX Guidelines

### 1. Consistent Theming
```dart
// Good: Use theme service
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Content',
    style: Theme.of(context).textTheme.bodyMedium,
  ),
)

// Bad: Hardcoded colors
Container(
  color: Colors.white,
  child: Text(
    'Content',
    style: TextStyle(color: Colors.black),
  ),
)
```

### 2. Loading States
```dart
// Good: Consistent loading indicators
SafeAsyncBuilder<ProjectData>(
  future: () => fileService.loadProject(projectName),
  builder: (context, data) => ProjectView(data: data),
  loadingBuilder: (context) => LoadingWidget(message: 'Loading project...'),
)
```

### 3. Empty States
```dart
// Good: Informative empty states
EmptyStateWidget(
  title: 'No Projects Found',
  subtitle: 'Create your first project to get started',
  icon: Icons.folder_open,
  action: ElevatedButton(
    onPressed: () => createNewProject(),
    child: Text('Create Project'),
  ),
)
```

## Testing Standards

### 1. Unit Tests
```dart
// Test naming convention
void main() {
  group('ErrorService', () {
    test('should log error with context', () {
      // Arrange
      final errorService = ErrorService();
      
      // Act
      errorService.logError('Test error', context: 'TestContext');
      
      // Assert
      // Verify logging behavior
    });
  });
}
```

### 2. Widget Tests
```dart
testWidgets('AppCard should display title and content', (WidgetTester tester) async {
  // Arrange
  const testTitle = 'Test Title';
  const testContent = Text('Test Content');
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: AppCard(
        title: testTitle,
        child: testContent,
      ),
    ),
  );
  
  // Assert
  expect(find.text(testTitle), findsOneWidget);
  expect(find.text('Test Content'), findsOneWidget);
});
```

## Code Quality Tools

### 1. Linting Configuration
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_final_locals: true
    avoid_print: true
    prefer_single_quotes: true
```

### 2. Formatting
- Use `dart format` for consistent formatting
- Line length: 80 characters (configurable)
- Use trailing commas for better diffs

### 3. Static Analysis
```bash
# Run analysis
dart analyze

# Check for unused code
dart run dependency_validator

# Security analysis
dart run pana
```

## Git Conventions

### 1. Commit Messages
```
feat: add error boundary for canvas area
fix: resolve memory leak in cache service  
docs: update architecture documentation
refactor: extract state management from main.dart
test: add unit tests for file service
perf: optimize widget rebuilds in canvas
```

### 2. Branch Naming
```
feature/error-handling-service
bugfix/memory-leak-canvas
hotfix/critical-crash-main
refactor/extract-state-management
```

## Code Review Checklist

### Before Submitting PR
- [ ] Code follows naming conventions
- [ ] All new classes and methods are documented
- [ ] Error handling is implemented using ErrorService
- [ ] Performance considerations are addressed
- [ ] UI follows theme guidelines
- [ ] Tests are included for new functionality
- [ ] No hardcoded strings or magic numbers
- [ ] Memory management is considered
- [ ] Code is formatted and analyzed

### During Review
- [ ] Architecture patterns are followed
- [ ] Error handling is comprehensive
- [ ] Performance implications are considered
- [ ] Documentation is clear and helpful
- [ ] Tests cover edge cases
- [ ] Code is maintainable and readable

## Common Anti-Patterns to Avoid

### 1. Direct State Mutation
```dart
// Bad
setState(() {
  showDialog = true;
  selectedDevice = 'Device1';
  // Multiple state changes
});

// Good
appStateManager.showDeviceDialog('Device1');
```

### 2. Mixed Concerns
```dart
// Bad
class CanvasArea extends StatefulWidget {
  void saveFile() { } // File operation in UI
  void connectToPlc() { } // PLC logic in UI
  Widget build() { } // UI logic
}

// Good: Separate concerns using services
final fileService = FileService();
final plcService = PlcService();
```

### 3. Hardcoded Values
```dart
// Bad
if (type == 'TextBox') { }
const padding = 16.0;

// Good
if (type == AppConstants.typeTextBox) { }
const padding = AppSpacing.medium;
```

## Conclusion

Following these coding standards ensures:
- **Consistency**: Uniform code style across the project
- **Maintainability**: Easy to understand and modify code
- **Reliability**: Proper error handling and testing
- **Performance**: Optimized code with monitoring
- **Collaboration**: Clear patterns for team development

All team members should familiarize themselves with these standards and apply them consistently in their contributions to the SCADA ConnectX project.