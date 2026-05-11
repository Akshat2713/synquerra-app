// presentation/blocs/errors/errors_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/alerts/alert_error_entity.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/alerts_errors/get_device_errors_usecase.dart';

part 'errors_event.dart';
part 'errors_state.dart';

class ErrorsBloc extends Bloc<ErrorsEvent, ErrorsState> {
  final GetDeviceErrorsUseCase _getDeviceErrorsUseCase;

  ErrorsBloc({required GetDeviceErrorsUseCase getDeviceErrorsUseCase})
    : _getDeviceErrorsUseCase = getDeviceErrorsUseCase,
      super(ErrorsInitial()) {
    on<ErrorsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    ErrorsLoadRequested event,
    Emitter<ErrorsState> emit,
  ) async {
    emit(ErrorsLoading());
    debugPrint('[ErrorsBloc] Fetching errors for imei: ${event.imei}');
    final result = await _getDeviceErrorsUseCase(event.imei);
    result.fold(
      (failure) {
        debugPrint('[ErrorsBloc] Failed: ${failure.message}');
        emit(ErrorsFailure(message: _mapFailure(failure)));
      },
      (errors) {
        debugPrint('[ErrorsBloc] Loaded ${errors.length} errors');
        emit(ErrorsLoaded(errors: errors));
      },
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection.';
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty ? failure.message : 'Server error.';
    }
    return 'Something went wrong.';
  }
}
