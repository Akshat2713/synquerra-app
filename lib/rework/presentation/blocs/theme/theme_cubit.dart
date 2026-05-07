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
    debugPrint('[ThemeCubit] init → current: $savedMode');
  }

  void toggle() {
    debugPrint('[ThemeCubit] toggle → current: $state');
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
    debugPrint('[ThemeCubit] toggled → new: $state');
  }

  bool get isDark => state == ThemeMode.dark;
}
