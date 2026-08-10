import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/theme_repository.dart';
import '../../../core/utils/app_logger.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeRepository _themeRepository;

  ThemeCubit(this._themeRepository) : super(ThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    final savedThemeMode = await _themeRepository.getSavedThemeMode();
    emit(savedThemeMode);
    AppLogger.d('ThemeCubit', 'init → Start: $savedThemeMode');
  }

  void toggle() async {
    AppLogger.d('ThemeCubit', 'toggle → current: $state');
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    emit(newMode);

    await _themeRepository.saveThemeMode(newMode);
    AppLogger.d('ThemeCubit', 'toggled → new: $state');
  }

  bool get isDark => state == ThemeMode.dark;
}
