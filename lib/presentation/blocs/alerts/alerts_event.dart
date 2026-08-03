part of 'alerts_bloc.dart';

abstract class AlertsEvent extends Equatable {
  const AlertsEvent();
  @override
  List<Object?> get props => [];
}

class AlertsLoadRequested extends AlertsEvent {
  final int hours;
  const AlertsLoadRequested({this.hours = 24});
  @override
  List<Object?> get props => [hours];
}

class AlertsRefreshRequested extends AlertsEvent {
  const AlertsRefreshRequested();
}

// When you move to websocket: add AlertsPushed(AlertEntity alert) here,
// handled by inserting/updating into the current AlertsLoaded list.
