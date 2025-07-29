/// Application constants for SCADA ConnectX
/// Contains all magic numbers, strings, and configuration values
class AppConstants {
  // Application Information
  static const String appTitle = 'SL Scada Application';
  static const String defaultStatusText = 'Status Bar';
  static const String defaultCanvasTitle = 'Canvas';
  
  // File Extensions
  static const String connectxFileExtension = '.connectx';
  static const String jsonFileExtension = '.json';
  
  // Widget Types
  static const String typeTextBox = 'TextBox';
  static const String typeDataBox = 'DataBox';
  static const String typeDataBox2 = 'DataBox2';
  static const String typeDataBox3 = 'DataBox3';
  
  // Column Names
  static const String columnSettings = 'Settings';
  static const String columnSimulation = 'Simulation';
  static const String columnAlarms = 'Alarms';
  
  // Canvas Configuration
  static const double defaultScale = 1.0;
  static const double minScale = 0.5;
  static const double maxScale = 3.0;
  
  // Theme Configuration
  static const String themeKey = 'theme_mode';
  
  // Colors
  static const int defaultShapeColorValue = 0x00A3BCC7; // Color.fromARGB(0, 163, 188, 199)
  
  // File Paths
  static const String deviceConfigFile = 'device_conf.json';
  static const String alarmConfigFile = 'alarm_conf.json';
  static const String itemsFile = 'items.json';
  
  // UI Configuration
  static const List<String> readOnlyFields = [
    'text',
    'widgetType',
    'type',
    'imagePath'
  ];
  
  static const List<String> hiddenProperties = [
    'text',
    'widgetType',
    'type',
    'imagePath'
  ];
  
  // Error Messages
  static const String errorLoadingTheme = 'Error loading theme';
  static const String errorTogglingTheme = 'Error toggling theme';
  static const String errorFileOperation = 'Error during file operation';
  static const String errorConnectionFailed = 'Connection failed';
  
  // Success Messages
  static const String successFileSaved = 'File saved successfully';
  static const String successConnectionEstablished = 'Connection established';
  
  // Default Values
  static const int defaultCanvasIndex = 0;
  static const bool defaultHasSettingsBeenOpened = false;
  static const bool defaultHasAlarmsBeenOpened = false;
}