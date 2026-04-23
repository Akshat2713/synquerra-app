// lib/business/blocs/theme_bloc/theme_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../repositories/theme_repository.dart';
import '../../failures/failure.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc({required ThemeRepository themeRepository})
    : _themeRepository = themeRepository,
      super(ThemeInitial()) {
    on<ThemeLoaded>(_onThemeLoaded);
    on<ThemeToggled>(_onThemeToggled);
  }

  Future<void> _onThemeLoaded(
    ThemeLoaded event,
    Emitter<ThemeState> emit,
  ) async {
    final result = await _themeRepository.getThemeMode();

    result.fold(
      (failure) => emit(const ThemeReady(isDarkMode: false)),
      (isDarkMode) => emit(ThemeReady(isDarkMode: isDarkMode)),
    );
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ThemeReady) return;

    final newIsDarkMode = !currentState.isDarkMode;
    final result = await _themeRepository.saveThemeMode(newIsDarkMode);

    result.fold(
      (failure) => null,
      (_) => emit(ThemeReady(isDarkMode: newIsDarkMode)),
    );
  }
}
