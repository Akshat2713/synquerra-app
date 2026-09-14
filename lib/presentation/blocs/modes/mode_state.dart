// lib/presentation/blocs/modes/mode_state.dart

part of 'mode_bloc.dart';

abstract class ModeState extends BaseState {
  const ModeState();
}

class ModeInitial extends ModeState {
  const ModeInitial();
}

class ModeLoading extends ModeState with LoadingState {
  const ModeLoading();
}

class ModeLoaded extends ModeState {
  final List<ModeEntity> modes;
  final String? selectedModeId;

  const ModeLoaded({required this.modes, this.selectedModeId});

  @override
  List<Object?> get props => [modes, selectedModeId];
}

class ModeError extends ModeState with ErrorState {
  @override
  final String message;

  const ModeError(this.message);

  @override
  List<Object?> get props => [message];
}

class ModeSwitching extends ModeState with LoadingState {
  final List<ModeEntity> modes;
  final String selectedModeId;

  const ModeSwitching({required this.modes, required this.selectedModeId});

  @override
  List<Object?> get props => [modes, selectedModeId];
}

class ModeSwitchSuccess extends ModeState {
  final List<ModeEntity> modes;
  final String activeModeId;

  const ModeSwitchSuccess({required this.modes, required this.activeModeId});

  @override
  List<Object?> get props => [modes, activeModeId];
}

class ModeSwitchFailure extends ModeState with ErrorState {
  final List<ModeEntity> modes;
  final String selectedModeId;
  @override
  final String message;

  const ModeSwitchFailure({
    required this.modes,
    required this.selectedModeId,
    required this.message,
  });

  @override
  List<Object?> get props => [modes, selectedModeId, message];
}
