// presentation/blocs/errors/errors_state.dart
part of 'errors_bloc.dart';

sealed class ErrorsState extends Equatable {
  const ErrorsState();
  @override
  List<Object?> get props => [];
}

class ErrorsInitial extends ErrorsState {}

class ErrorsLoading extends ErrorsState {}

class ErrorsLoaded extends ErrorsState {
  final List<AlertErrorEntity> errors;
  const ErrorsLoaded({required this.errors});
  @override
  List<Object?> get props => [errors];
}

class ErrorsFailure extends ErrorsState {
  final String message;
  const ErrorsFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
