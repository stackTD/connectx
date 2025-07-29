import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ThemeManager with ChangeNotifier {
  // Initialize _themeMode with a default value
  ThemeMode _themeMode = ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(AppConstants.themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      print(AppConstants.errorLoadingTheme + ': $e');
      // Keep default light theme if there's an error
    }
  }

  Future<void> toggleTheme() async {
    try {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, isDarkMode);
      notifyListeners();
    } catch (e) {
      print(AppConstants.errorTogglingTheme + ': $e');
    }
  }

  ThemeMode get themeMode => _themeMode;
}
