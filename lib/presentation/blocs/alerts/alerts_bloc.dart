import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/usecases/alerts/get_alerts_usecase.dart';
import '../../../core/utils/app_logger.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GetAlertsUseCase _getAlertsUseCase;

  AlertsBloc({required GetAlertsUseCase getAlertsUseCase})
    : _getAlertsUseCase = getAlertsUseCase,
      super(const AlertsInitial()) {
    on<AlertsLoadRequested>(_onLoad);
    on<AlertsRefreshRequested>(
      _onLoad,
    ); // same handler, refresh = reload for now
  }

  Future<void> _onLoad(AlertsEvent event, Emitter<AlertsState> emit) async {
    final personId = sl<UserHolder>().user?.personId;
    if (personId == null) {
      AppLogger.d('AlertsBloc', 'No logged-in user found');
      emit(const AlertsError('User not found. Please log in again.'));
      return;
    }
    emit(const AlertsLoading());
    final hours = event is AlertsLoadRequested ? event.hours : 24;
    final result = await _getAlertsUseCase(
      GetAlertsParams(personId, hours: hours),
    );
    result.fold(
      (failure) {
        AppLogger.d('AlertsBloc', 'Fetch failed: ${failure.message}');
        emit(AlertsError(failure.userMessage));
      },
      (alerts) {
        AppLogger.d('AlertsBloc', 'Loaded ${alerts.length} alerts');
        emit(AlertsLoaded(alerts));
      },
    );
  }
}
