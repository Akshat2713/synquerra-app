// lib/data/datasources/local/theme_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  static const String _themeKey = 'isDarkMode';

  /// Save theme preference
  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Get theme preference (default: false = light mode)
  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
