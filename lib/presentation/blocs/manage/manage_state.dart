// lib/presentation/blocs/manage/manage_state.dart

part of 'manage_bloc.dart';

abstract class ManageState extends BaseState {
  const ManageState();
}

class ManageInitial extends ManageState {
  const ManageInitial();
}

class ManageLoading extends ManageState with LoadingState {
  const ManageLoading();
}

class ManageLoaded extends ManageState {
  final SettingsEntity settings;
  final List<ModeEntity> modes;
  final String? activeModeId;
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

class ManageError extends ManageState with ErrorState {
  @override
  final String message;

  const ManageError(this.message);

  @override
  List<Object?> get props => [message];
}
