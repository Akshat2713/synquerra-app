// presentation/blocs/mode/mode_state.dart
part of 'mode_bloc.dart';

abstract class ModeState extends Equatable {
  const ModeState();
  @override
  List<Object?> get props => [];
}

class ModeInitial extends ModeState {
  const ModeInitial();
}

class ModeLoading extends ModeState {
  const ModeLoading();
}

class ModeLoaded extends ModeState {
  final List<ModeEntity> modes;
  final String? selectedModeId; // locally selected, not yet saved
  const ModeLoaded({required this.modes, this.selectedModeId});
  @override
  List<Object?> get props => [modes, selectedModeId];
}

class ModeError extends ModeState {
  final String message;
  const ModeError(this.message);
  @override
  List<Object?> get props => [message];
}

class ModeSwitching extends ModeState {
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

class ModeSwitchFailure extends ModeState {
  final List<ModeEntity> modes;
  final String selectedModeId;
  final String message;
  const ModeSwitchFailure({
    required this.modes,
    required this.selectedModeId,
    required this.message,
  });
  @override
  List<Object?> get props => [modes, selectedModeId, message];
}
