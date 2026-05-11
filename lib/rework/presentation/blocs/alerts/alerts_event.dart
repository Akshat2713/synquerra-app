// presentation/blocs/alerts/alerts_event.dart
part of 'alerts_bloc.dart';

sealed class AlertsEvent extends Equatable {
  const AlertsEvent();
  @override
  List<Object?> get props => [];
}

class AlertsLoadRequested extends AlertsEvent {
  final String imei;
  const AlertsLoadRequested(this.imei);
  @override
  List<Object?> get props => [imei];
}
