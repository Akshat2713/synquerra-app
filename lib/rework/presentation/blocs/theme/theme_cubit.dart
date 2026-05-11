import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/theme_local_datasource.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeLocalDataSource _localDataSource;
  ThemeCubit(this._localDataSource) : super(ThemeMode.system) {
    _init();
  }
  Future<void> _init() async {
    final savedMode = await _localDataSource.getLastThemeMode();
    emit(savedMode);
    debugPrint('[ThemeCubit] init → Start: $savedMode');
  }

  void toggle() async {
    debugPrint('[ThemeCubit] toggle → current: $state');
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    // UI update
    emit(newMode);

    // Persistence through the DataSource
    await _localDataSource.cacheThemeMode(newMode);
    debugPrint('[ThemeCubit] toggled → new: $state');
  }

  bool get isDark => state == ThemeMode.dark;
}
