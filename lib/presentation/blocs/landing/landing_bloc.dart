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
  final GetAnalyticsUseCase _getAnalyticsUseCase;
  final GetAlertsUseCase _getAlertsUseCase;
  final UserHolder _userHolder;

  LandingBloc({
    required GetAnalyticsUseCase getAnalyticsUseCase,
    required GetAlertsUseCase getAlertsUseCase,
    required UserHolder userHolder,
  }) : _getAnalyticsUseCase = getAnalyticsUseCase,
       _getAlertsUseCase = getAlertsUseCase,
       _userHolder = userHolder,
       super(const LandingInitial()) {
    on<LandingLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    LandingLoadRequested event,
    Emitter<LandingState> emit,
  ) async {
    final device = event.device;

    emit(const LandingLoading());

    final personId = _userHolder.user?.personId;
    if (personId == null) {
      AppLogger.d('LandingBloc', 'No logged-in user found');
      emit(const LandingError('User not found. Please log in again.'));
      return;
    }

    AppLogger.d('LandingBloc', 'Loading for device ${device.id}');

    final fetchParams = computeAnalyticsParams(filter: AnalyticsFilter.latest);

    // Fire both requests in parallel, await sequentially.
    final analyticsFuture = _getAnalyticsUseCase(
      AnalyticsParams(
        deviceId: device.id,
        limit: fetchParams.limit,
        dataInterval: fetchParams.dataInterval,
      ),
    );
    final alertsFuture = _getAlertsUseCase(
      GetAlertsParams(personId, hours: 24),
    );

    final analyticsResult = await analyticsFuture;
    final alertsResult = await alertsFuture;

    final latest = analyticsResult.fold((failure) {
      AppLogger.d('LandingBloc', 'Analytics fetch failed: ${failure.message}');
      return null;
    }, (points) => points.isNotEmpty ? points.first : null);

    final alerts = alertsResult.fold((failure) {
      AppLogger.d('LandingBloc', 'Alerts fetch failed: ${failure.message}');
      return <AlertEntity>[];
    }, (a) => a);

    emit(LandingLoaded(latest: latest, alerts: alerts));
  }
}
