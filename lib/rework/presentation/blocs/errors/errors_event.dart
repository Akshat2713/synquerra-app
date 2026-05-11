// presentation/blocs/errors/errors_event.dart
part of 'errors_bloc.dart';

sealed class ErrorsEvent extends Equatable {
  const ErrorsEvent();
  @override
  List<Object?> get props => [];
}

class ErrorsLoadRequested extends ErrorsEvent {
  final String imei;
  const ErrorsLoadRequested(this.imei);
  @override
  List<Object?> get props => [imei];
}
