// lib/providers/theme_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:synquerra/core/preferences/theme_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final ThemePreferences _prefs = ThemePreferences();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Constructor: Load the saved theme immediately
  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await _prefs.getTheme();
    notifyListeners(); // Update the UI once data is moved from Disk to RAM
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setTheme(_isDarkMode); // Save to Disk
    notifyListeners(); // Update RAM for all active widgets
  }
}
