part of 'alerts_errors_bloc.dart';

sealed class AlertsErrorsEvent extends Equatable {
  const AlertsErrorsEvent();
  @override
  List<Object?> get props => [];
}

class AlertsErrorsLoadRequested extends AlertsErrorsEvent {
  final String imei;
  const AlertsErrorsLoadRequested(this.imei);
  @override
  List<Object?> get props => [imei];
}
