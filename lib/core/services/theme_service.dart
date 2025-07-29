import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'error_service.dart';

/// Service for managing application themes
/// Provides centralized theme configuration and persistence
class ThemeService with ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal() {
    _loadTheme();
  }

  final ErrorService _errorService = ErrorService();
  ThemeMode _themeMode = ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  // Color schemes
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF1976D2),
    primaryContainer: Color(0xFFE3F2FD),
    secondary: Color(0xFF424242),
    secondaryContainer: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFFAFAFA),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF212121),
    onBackground: Color(0xFF212121),
    onError: Color(0xFFFFFFFF),
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF90CAF9),
    primaryContainer: Color(0xFF1565C0),
    secondary: Color(0xFFBDBDBD),
    secondaryContainer: Color(0xFF424242),
    surface: Color(0xFF303030),
    background: Color(0xFF121212),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    onBackground: Color(0xFFFFFFFF),
    onError: Color(0xFF000000),
  );

  /// Get light theme
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  /// Get dark theme
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  /// Load theme preference from storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(AppConstants.themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (error) {
      _errorService.logError(AppConstants.errorLoadingTheme, error: error);
      // Keep default light theme if there's an error
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    try {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, isDarkMode);
      notifyListeners();
    } catch (error) {
      _errorService.logError(AppConstants.errorTogglingTheme, error: error);
    }
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, isDarkMode);
      notifyListeners();
    } catch (error) {
      _errorService.logError('Error setting theme mode', error: error);
    }
  }

  /// Get canvas background color based on current theme
  Color get canvasBackgroundColor => isDarkMode 
      ? _darkColorScheme.surface 
      : _lightColorScheme.surface;

  /// Get text color based on current theme
  Color get textColor => isDarkMode 
      ? _darkColorScheme.onSurface 
      : _lightColorScheme.onSurface;

  /// Get primary color based on current theme
  Color get primaryColor => isDarkMode 
      ? _darkColorScheme.primary 
      : _lightColorScheme.primary;

  /// Get secondary color based on current theme
  Color get secondaryColor => isDarkMode 
      ? _darkColorScheme.secondary 
      : _lightColorScheme.secondary;

  /// Get error color based on current theme
  Color get errorColor => isDarkMode 
      ? _darkColorScheme.error 
      : _lightColorScheme.error;

  /// Get success color (not in ColorScheme by default)
  Color get successColor => isDarkMode 
      ? const Color(0xFF4CAF50) 
      : const Color(0xFF2E7D32);

  /// Get warning color (not in ColorScheme by default)
  Color get warningColor => isDarkMode 
      ? const Color(0xFFFF9800) 
      : const Color(0xFFE65100);
}