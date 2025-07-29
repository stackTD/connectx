# SCADA ConnectX API Documentation

## Core Services API

### ErrorService

The ErrorService provides centralized error handling throughout the application.

#### Methods

##### `logError(String message, {Object? error, StackTrace? stackTrace, String? context})`
Logs an error with optional context and details.

**Parameters:**
- `message` (String): Error description
- `error` (Object?, optional): The exception object
- `stackTrace` (StackTrace?, optional): Stack trace for debugging
- `context` (String?, optional): Context where error occurred

**Example:**
```dart
final errorService = ErrorService();
try {
  await riskyOperation();
} catch (error, stackTrace) {
  errorService.logError(
    'Failed to perform operation',
    error: error,
    stackTrace: stackTrace,
    context: 'FileOperation',
  );
}
```

##### `showErrorDialog(BuildContext context, String title, String message)`
Shows an error dialog to the user.

##### `showErrorSnackbar(BuildContext context, String message)`
Shows an error snackbar with red background.

##### `showSuccessSnackbar(BuildContext context, String message)`
Shows a success snackbar with green background.

##### `handleAsyncFutureError<T>(String operation, Future<T> Function() action, {BuildContext? context, String? contextName})`
Generic error handler for async Future operations.

**Returns:** `Future<T?>` - The result of the operation or null if error occurred.

---

### FileService

The FileService handles all file operations with proper error handling and validation.

#### Methods

##### `saveJsonFile(String fileName, Map<String, dynamic> data)`
Saves data to a JSON file in the application directory.

**Returns:** `Future<bool>` - true if successful, false otherwise.

##### `loadJsonFile(String fileName)`
Loads data from a JSON file.

**Returns:** `Future<Map<String, dynamic>?>` - The loaded data or null if error/not found.

##### `saveConnectXProject(String projectName, Map<String, dynamic> projectData)`
Saves project data as a .connectx file with metadata.

**Parameters:**
- `projectName` (String): Name of the project (extension optional)
- `projectData` (Map<String, dynamic>): Project data to save

**Returns:** `Future<bool>` - true if successful.

##### `loadConnectXProject(String projectName)`
Loads project data from a .connectx file with validation.

**Returns:** `Future<Map<String, dynamic>?>` - The project data or null if error.

##### `getAvailableProjects()`
Gets list of available .connectx project files.

**Returns:** `Future<List<String>>` - List of project file names.

##### `createBackup(String fileName)`
Creates a timestamped backup of a file.

**Returns:** `Future<bool>` - true if backup was created successfully.

---

### ThemeService

The ThemeService manages application themes with Material 3 design system.

#### Properties

##### `themeMode` (ThemeMode)
Current theme mode (light, dark, or system).

##### `isDarkMode` (bool)
Whether dark mode is currently active.

##### `lightTheme` (ThemeData)
Material 3 light theme configuration.

##### `darkTheme` (ThemeData)
Material 3 dark theme configuration.

#### Methods

##### `toggleTheme()`
Toggles between light and dark theme.

**Returns:** `Future<void>`

##### `setThemeMode(ThemeMode mode)`
Sets a specific theme mode.

**Parameters:**
- `mode` (ThemeMode): The theme mode to set

---

### PerformanceService

The PerformanceService monitors and tracks application performance.

#### Methods

##### `startOperation(String operationName)`
Starts tracking an operation's performance.

##### `endOperation(String operationName)`
Ends tracking and logs the operation duration.

##### `timeOperation<T>(String operationName, T Function() operation)`
Times a synchronous operation.

**Returns:** `T` - The result of the operation.

##### `timeAsyncOperation<T>(String operationName, Future<T> Function() operation)`
Times an asynchronous operation.

**Returns:** `Future<T>` - The result of the operation.

##### `getPerformanceReport()`
Gets a comprehensive performance report.

**Returns:** `Map<String, dynamic>` - Performance statistics by operation.

##### `getSlowOperations(Duration threshold)`
Gets operations that exceed the threshold duration.

**Returns:** `List<PerformanceMetric>` - List of slow operations.

---

### MemoryService

The MemoryService manages memory usage and caching.

#### Methods

##### `cacheObject(String key, Object object, {Duration? expiry})`
Caches an object with optional expiry time.

##### `getCachedObject<T>(String key)`
Retrieves a cached object.

**Returns:** `T?` - The cached object or null if not found/expired.

##### `clearCache()`
Clears all cached objects.

##### `optimizeMemory()`
Optimizes memory usage by removing old/expired cache entries.

##### `getCacheStatistics()`
Gets current cache statistics.

**Returns:** `Map<String, dynamic>` - Cache usage statistics.

---

## State Management API

### AppStateManager

The AppStateManager handles all application-level state using MobX.

#### Observable Properties

##### `showSecondColumn1` (bool)
Whether the settings column is visible.

##### `showAddDeviceForm` (bool)
Whether the add device form is visible.

##### `showGroupForm` (bool)
Whether the group form is visible.

##### `showAlarms` (bool)
Whether the alarms panel is visible.

##### `selectedDeviceName` (String?)
Currently selected device name.

##### `hasSettingsBeenOpened` (bool)
Whether settings have been opened at least once.

##### `hasAlarmsBeenOpened` (bool)
Whether alarms have been opened at least once.

##### `statusText` (String)
Current status text.

#### Actions

##### `toggleColumn(String column)`
Toggles visibility of main application columns.

**Parameters:**
- `column` (String): Column name (use AppConstants.columnSettings, etc.)

##### `showAddForm()`
Shows the add device form.

##### `closeForm()`
Closes the add device form and returns to settings.

##### `showAddGroupForm(String deviceName)`
Shows the add group form for a specific device.

##### `closeGroupForm()`
Closes the group form and returns to settings.

##### `updateStatus(String newStatus)`
Updates the application status text.

##### `resetState()`
Resets all state to default values.

---

## Widget API

### ErrorBoundary

Catches and handles errors in child widgets gracefully.

#### Constructor Parameters

##### `child` (Widget, required)
The child widget to wrap with error handling.

##### `errorTitle` (String?, optional)
Custom error title for the fallback UI.

##### `errorMessage` (String?, optional)
Custom error message for the fallback UI.

##### `fallbackWidget` (Widget?, optional)
Custom fallback widget to show on error.

##### `onError` (void Function(FlutterErrorDetails)?, optional)
Callback when an error occurs.

**Example:**
```dart
ErrorBoundary(
  errorTitle: 'Canvas Error',
  errorMessage: 'There was an error loading the canvas area.',
  child: UICanvasArea(...),
)
```

### LoadingWidget

Displays a consistent loading indicator.

#### Constructor Parameters

##### `message` (String?, optional)
Loading message to display.

##### `color` (Color?, optional)
Color of the loading indicator.

### EmptyStateWidget

Displays a consistent empty state.

#### Constructor Parameters

##### `title` (String, required)
Title text for the empty state.

##### `subtitle` (String?, optional)
Subtitle text providing more context.

##### `icon` (IconData?, optional)
Icon to display (defaults to inbox icon).

##### `action` (Widget?, optional)
Action button or widget to display.

### AppCard

Reusable card widget with consistent styling.

#### Constructor Parameters

##### `child` (Widget, required)
Content to display in the card.

##### `title` (String?, optional)
Optional title for the card.

##### `padding` (EdgeInsetsGeometry?, optional)
Custom padding (defaults to 16.0).

##### `margin` (EdgeInsetsGeometry?, optional)
Custom margin (defaults to 8.0).

##### `onTap` (VoidCallback?, optional)
Tap callback to make card interactive.

### SafeAsyncBuilder<T>

Builder widget that safely handles async operations with loading and error states.

#### Constructor Parameters

##### `future` (Future<T> Function(), required)
Function that returns the future to build with.

##### `builder` (Widget Function(BuildContext context, T data), required)
Builder for when data is available.

##### `errorBuilder` (Widget Function(BuildContext context, Object error)?, optional)
Custom error widget builder.

##### `loadingBuilder` (Widget Function(BuildContext context)?, optional)
Custom loading widget builder.

**Example:**
```dart
SafeAsyncBuilder<List<Project>>(
  future: () => fileService.getAvailableProjects(),
  builder: (context, projects) => ProjectList(projects: projects),
  loadingBuilder: (context) => LoadingWidget(message: 'Loading projects...'),
)
```

---

## Mixins API

### PerformanceTrackingMixin

Adds performance tracking capabilities to widgets.

#### Methods

##### `trackBuildPerformance(String widgetName, VoidCallback buildFunction)`
Tracks the performance of a widget build.

##### `trackAsyncPerformance<T>(String operationName, Future<T> Function() operation)`
Tracks the performance of an async operation.

### MemoryManagementMixin

Adds memory management capabilities to widgets.

#### Methods

##### `cacheWidgetData(String key, Object data)`
Caches data specific to this widget.

##### `getCachedWidgetData<T>(String key)`
Retrieves cached data for this widget.

##### `clearWidgetCache()`
Clears all cached data for this widget.

---

## Constants API

### AppConstants

Centralized constants for the application.

#### Application Information
- `appTitle`: 'SL Scada Application'
- `defaultStatusText`: 'Status Bar'
- `defaultCanvasTitle`: 'Canvas'

#### File Extensions
- `connectxFileExtension`: '.connectx'
- `jsonFileExtension`: '.json'

#### Widget Types
- `typeTextBox`: 'TextBox'
- `typeDataBox`: 'DataBox'
- `typeDataBox2`: 'DataBox2'
- `typeDataBox3`: 'DataBox3'

#### Column Names
- `columnSettings`: 'Settings'
- `columnSimulation`: 'Simulation'
- `columnAlarms`: 'Alarms'

#### Canvas Configuration
- `defaultScale`: 1.0
- `minScale`: 0.5
- `maxScale`: 3.0

#### Error Messages
- `errorLoadingTheme`: 'Error loading theme'
- `errorTogglingTheme`: 'Error toggling theme'
- `errorFileOperation`: 'Error during file operation'
- `errorConnectionFailed`: 'Connection failed'

#### Success Messages
- `successFileSaved`: 'File saved successfully'
- `successConnectionEstablished`: 'Connection established'

---

## Usage Examples

### Basic Error Handling
```dart
final errorService = ErrorService();

try {
  final result = await someRiskyOperation();
  errorService.showSuccessSnackbar(context, 'Operation completed');
} catch (error) {
  errorService.logError('Operation failed', error: error);
  errorService.showErrorSnackbar(context, 'Operation failed');
}
```

### File Operations
```dart
final fileService = FileService();

// Save a project
final success = await fileService.saveConnectXProject('MyProject', projectData);
if (success) {
  print('Project saved successfully');
}

// Load a project
final projectData = await fileService.loadConnectXProject('MyProject');
if (projectData != null) {
  // Use project data
}
```

### State Management
```dart
final appStateManager = AppStateManager();

// Toggle to settings
appStateManager.toggleColumn(AppConstants.columnSettings);

// Show device form
appStateManager.showAddForm();
```

### Performance Tracking
```dart
class MyWidget extends StatefulWidget with PerformanceTrackingMixin {
  @override
  Widget build(BuildContext context) {
    return trackBuildPerformance('MyWidget', () {
      return ExpensiveWidget();
    });
  }
}
```

### Memory Management
```dart
class DataWidget extends StatefulWidget with MemoryManagementMixin {
  void loadData() {
    final cached = getCachedWidgetData<List<Item>>('items');
    if (cached != null) {
      displayItems(cached);
    } else {
      // Load and cache data
      fetchItems().then((items) {
        cacheWidgetData('items', items);
        displayItems(items);
      });
    }
  }
}
```

This API documentation provides comprehensive information for developers working with the refactored SCADA ConnectX application, ensuring consistent usage of the new architecture and services.