// presentation/blocs/mode/mode_event.dart
part of 'mode_bloc.dart';

abstract class ModeEvent extends Equatable {
  const ModeEvent();
  @override
  List<Object?> get props => [];
}

class ModeLoad extends ModeEvent {
  const ModeLoad();
}

class ModeSelect extends ModeEvent {
  final String modeId;
  const ModeSelect(this.modeId);
  @override
  List<Object?> get props => [modeId];
}

class ModeSwitchSubmit extends ModeEvent {
  final String imei;
  final String modeId;
  const ModeSwitchSubmit({required this.imei, required this.modeId});
  @override
  List<Object?> get props => [imei, modeId];
}
