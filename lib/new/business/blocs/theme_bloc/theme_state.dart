// lib/business/blocs/theme_bloc/theme_state.dart
part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeReady extends ThemeState {
  final bool isDarkMode;

  const ThemeReady({required this.isDarkMode});

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  List<Object?> get props => [isDarkMode];
}
