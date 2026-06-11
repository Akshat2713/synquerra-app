import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/alerts/alert_error_entity.dart';
import '../../../domain/usecases/alerts_errors/get_alerts_errors_usecase.dart';

part 'alerts_errors_event.dart';
part 'alerts_errors_state.dart';

class AlertsErrorsBloc extends Bloc<AlertsErrorsEvent, AlertsErrorsState> {
  final GetAlertsErrorsUseCase _getAlertsErrors;

  AlertsErrorsBloc({required GetAlertsErrorsUseCase getAlertsErrors})
    : _getAlertsErrors = getAlertsErrors,
      super(AlertsErrorsInitial()) {
    on<AlertsErrorsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    AlertsErrorsLoadRequested event,
    Emitter<AlertsErrorsState> emit,
  ) async {
    emit(AlertsErrorsLoading());
    final result = await _getAlertsErrors(event.imei);
    result.fold(
      (failure) => emit(AlertsErrorsFailure(failure.userMessage)),
      (all) => emit(
        AlertsErrorsLoaded(
          alerts: all.where((e) => e.type == AlertErrorType.alert).toList(),
          errors: all.where((e) => e.type == AlertErrorType.error).toList(),
        ),
      ),
    );
  }
}
