// lib/presentation/blocs/profile/profile_state.dart

part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitchingMode;
  final String? modeSwitchError;

  const ProfileLoaded({
    required this.profile,
    this.modes = const [],
    this.activeModeId,
    this.isSwitchingMode = false,
    this.modeSwitchError,
  });

  // Use a private sentinel so we can explicitly pass null to clear error
  static const _keep = Object();

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    List<ModeEntity>? modes,
    String? activeModeId,
    bool? isSwitchingMode,
    Object? modeSwitchError = _keep,
  }) => ProfileLoaded(
    profile: profile ?? this.profile,
    modes: modes ?? this.modes,
    activeModeId: activeModeId ?? this.activeModeId,
    isSwitchingMode: isSwitchingMode ?? this.isSwitchingMode,
    modeSwitchError: modeSwitchError == _keep
        ? this.modeSwitchError
        : modeSwitchError as String?,
  );

  @override
  List<Object?> get props => [
    profile,
    modes,
    activeModeId,
    isSwitchingMode,
    modeSwitchError,
  ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
