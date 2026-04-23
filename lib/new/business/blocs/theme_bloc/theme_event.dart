// lib/business/blocs/theme_bloc/theme_event.dart
part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeLoaded extends ThemeEvent {}

class ThemeToggled extends ThemeEvent {}
