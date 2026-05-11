// presentation/blocs/alerts/alerts_state.dart
part of 'alerts_bloc.dart';

sealed class AlertsState extends Equatable {
  const AlertsState();
  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<AlertErrorEntity> alerts;
  const AlertsLoaded({required this.alerts});
  @override
  List<Object?> get props => [alerts];
}

class AlertsFailure extends AlertsState {
  final String message;
  const AlertsFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
