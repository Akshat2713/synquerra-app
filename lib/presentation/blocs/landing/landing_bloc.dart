import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/usecases/alerts/get_alerts_usecase.dart';
import '../../../domain/usecases/analytics/get_analytics_usecase.dart';
import '../../../domain/entities/analytics/analytics_filter.dart';
import '../../../domain/utils/analytics_params_computer.dart';
import '../../../core/utils/app_logger.dart';

part 'landing_event.dart';
part 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final UserHolder _userHolder;
  LandingBloc({
    required GetAlertsUseCase getAlertsUseCase,
    required UserHolder userHolder,
  }) : _getAlertsUseCase = getAlertsUseCase,
       _userHolder = userHolder,
       super(const LandingInitial()) {
    on<LandingLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    LandingLoadRequested event,
    Emitter<LandingState> emit,
  ) async {
    emit(const LandingLoading());
    final personId = _userHolder.user?.personId;
    if (personId == null) {
      emit(const LandingError('User not found. Please log in again.'));
      return;
    }
    final alertsResult = await _getAlertsUseCase(
      GetAlertsParams(personId, hours: 24),
    );
    final alerts = alertsResult.fold((_) => <AlertEntity>[], (a) => a);
    emit(LandingLoaded(alerts: alerts));
  }
}
