import 'package:flutter/material.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/local/theme_local_datasource.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<ThemeMode> getSavedThemeMode() async {
    return await _localDataSource.getLastThemeMode();
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _localDataSource.cacheThemeMode(mode);
  }
}
