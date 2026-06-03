import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _keyThemeMode = 'theme_mode';
  ThemeLocalDataSource(this._storage);

  Future<void> cacheThemeMode(ThemeMode mode) async {
    await _storage.write(key: _keyThemeMode, value: mode.name);
  }

  Future<ThemeMode> getLastThemeMode() async {
    final raw = await _storage.read(key: _keyThemeMode);
    if (raw == 'dark') return ThemeMode.dark;
    if (raw == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }
}
