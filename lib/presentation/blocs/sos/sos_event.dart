// presentation/blocs/sos/sos_event.dart
part of 'sos_bloc.dart';

abstract class SosEvent extends Equatable {
  const SosEvent();
  @override
  List<Object?> get props => [];
}

class SosAcknowledgeSubmit extends SosEvent {
  final String alertId;
  final String deviceId;
  const SosAcknowledgeSubmit({required this.alertId, required this.deviceId});
  @override
  List<Object?> get props => [alertId, deviceId];
}

class SosStopSubmit extends SosEvent {
  final String deviceId;
  const SosStopSubmit({required this.deviceId});
  @override
  List<Object?> get props => [deviceId];
}

/// Clears one-shot results (success/failure) but keeps the active SOS.
class SosReset extends SosEvent {
  const SosReset();
}

/// Drops everything, including the active SOS (call on logout).
class SosClear extends SosEvent {
  const SosClear();
}
