part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;
  final bool isUpdating;
  final String? updateError;

  const SettingsLoaded({
    required this.settings,
    this.isUpdating = false,
    this.updateError,
  });

  SettingsLoaded copyWith({
    SettingsEntity? settings,
    bool? isUpdating,
    String? updateError,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isUpdating: isUpdating ?? this.isUpdating,
      updateError: updateError,
    );
  }

  @override
  List<Object?> get props => [settings, isUpdating, updateError];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
