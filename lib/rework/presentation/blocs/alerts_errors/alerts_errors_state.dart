part of 'alerts_errors_bloc.dart';

sealed class AlertsErrorsState extends Equatable {
  const AlertsErrorsState();
  @override
  List<Object?> get props => [];
}

class AlertsErrorsInitial extends AlertsErrorsState {}

class AlertsErrorsLoading extends AlertsErrorsState {}

class AlertsErrorsLoaded extends AlertsErrorsState {
  final List<AlertErrorEntity> alerts; // type == alert
  final List<AlertErrorEntity> errors; // type == error
  const AlertsErrorsLoaded({required this.alerts, required this.errors});
  @override
  List<Object?> get props => [alerts, errors];
}

class AlertsErrorsFailure extends AlertsErrorsState {
  final String message;
  const AlertsErrorsFailure(this.message);
  @override
  List<Object?> get props => [message];
}
