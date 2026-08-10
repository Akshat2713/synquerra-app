part of 'manage_bloc.dart';

abstract class ManageState extends Equatable {
  const ManageState();

  @override
  List<Object?> get props => [];
}

class ManageInitial extends ManageState {}

class ManageLoading extends ManageState {}

class ManageLoaded extends ManageState {
  final SettingsEntity settings;
  final List<ModeEntity> modes;
  final String? activeModeId;

  // Specific action flags & errors
  final bool isSwitchingMode;
  final String? modeSwitchError;
  final bool isUpdatingSettings;
  final String? settingsUpdateError;

  const ManageLoaded({
    required this.settings,
    required this.modes,
    this.activeModeId,
    this.isSwitchingMode = false,
    this.modeSwitchError,
    this.isUpdatingSettings = false,
    this.settingsUpdateError,
  });

  ManageLoaded copyWith({
    SettingsEntity? settings,
    List<ModeEntity>? modes,
    String? activeModeId,
    bool? isSwitchingMode,
    String? modeSwitchError,
    bool? isUpdatingSettings,
    String? settingsUpdateError,
  }) {
    return ManageLoaded(
      settings: settings ?? this.settings,
      modes: modes ?? this.modes,
      activeModeId: activeModeId ?? this.activeModeId,
      isSwitchingMode: isSwitchingMode ?? this.isSwitchingMode,
      modeSwitchError: modeSwitchError,
      isUpdatingSettings: isUpdatingSettings ?? this.isUpdatingSettings,
      settingsUpdateError: settingsUpdateError,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    modes,
    activeModeId,
    isSwitchingMode,
    modeSwitchError,
    isUpdatingSettings,
    settingsUpdateError,
  ];
}

class ManageError extends ManageState {
  final String message;

  const ManageError(this.message);

  @override
  List<Object?> get props => [message];
}
