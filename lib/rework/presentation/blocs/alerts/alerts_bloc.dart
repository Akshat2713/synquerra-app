// presentation/blocs/alerts/alerts_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/alerts/alert_error_entity.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/alerts_errors/get_device_alerts_usecase.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GetDeviceAlertsUseCase _getDeviceAlertsUseCase;

  AlertsBloc({required GetDeviceAlertsUseCase getDeviceAlertsUseCase})
    : _getDeviceAlertsUseCase = getDeviceAlertsUseCase,
      super(AlertsInitial()) {
    on<AlertsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    AlertsLoadRequested event,
    Emitter<AlertsState> emit,
  ) async {
    emit(AlertsLoading());
    debugPrint('[AlertsBloc] Fetching alerts for imei: ${event.imei}');
    final result = await _getDeviceAlertsUseCase(event.imei);
    result.fold(
      (failure) {
        debugPrint('[AlertsBloc] Failed: ${failure.message}');
        emit(AlertsFailure(message: _mapFailure(failure)));
      },
      (alerts) {
        debugPrint('[AlertsBloc] Loaded ${alerts.length} alerts');
        emit(AlertsLoaded(alerts: alerts));
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
