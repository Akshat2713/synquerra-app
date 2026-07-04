part of 'alerts_errors_bloc.dart';

sealed class AlertsErrorsEvent extends Equatable {
  const AlertsErrorsEvent();
  @override
  List<Object?> get props => [];
}

class AlertsErrorsLoadRequested extends AlertsErrorsEvent {
  final String deviceId;
  const AlertsErrorsLoadRequested(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}
