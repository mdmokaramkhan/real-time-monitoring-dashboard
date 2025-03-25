import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);
      
      if (savedTheme != null) {
        _themeMode = _getThemeModeFromString(savedTheme);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Save theme preference
  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemePreference(mode);
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, check the current brightness and toggle to the opposite
      final isDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
      await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
