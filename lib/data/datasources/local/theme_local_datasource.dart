// lib/data/datasources/local/theme_local_datasource.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeLocalDataSource {
  final FlutterSecureStorage _storage;

  // Same key as before: an old saved 'dark' still resolves to the Dark theme.
  static const _keyTheme = 'theme_mode';
  ThemeLocalDataSource(this._storage);

  Future<void> cacheTheme(String name) =>
      _storage.write(key: _keyTheme, value: name);

  Future<String?> getLastTheme() => _storage.read(key: _keyTheme);
}
