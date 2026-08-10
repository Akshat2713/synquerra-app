import 'package:flutter/material.dart';

abstract class ThemeRepository {
  Future<ThemeMode> getSavedThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
