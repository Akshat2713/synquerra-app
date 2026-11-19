// presentation/blocs/sos/sos_state.dart
part of 'sos_bloc.dart';

enum SosAction { acknowledge, stop }

abstract class SosState extends BaseState {
  /// Non-null while an acknowledged SOS is still running.
  final String? activeDeviceId;
  const SosState({this.activeDeviceId});
}

class SosInitial extends SosState {
  const SosInitial({super.activeDeviceId});

  @override
  List<Object?> get props => [activeDeviceId];
}

class SosProcessing extends SosState with LoadingState {
  final SosAction action;

  const SosProcessing({required this.action, super.activeDeviceId});

  @override
  List<Object?> get props => [action, activeDeviceId];
}

class SosSuccess extends SosState {
  final SosAction action;

  const SosSuccess({required this.action, super.activeDeviceId});

  @override
  List<Object?> get props => [action, activeDeviceId];
}

class SosFailure extends SosState with ErrorState {
  final SosAction action;
  @override
  final String message;

  const SosFailure({
    required this.action,
    required this.message,
    super.activeDeviceId,
  });

  @override
  List<Object?> get props => [action, message, activeDeviceId];
}
