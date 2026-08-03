import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/usecases/alerts/get_alerts_usecase.dart';
import '../../../domain/usecases/analytics/get_analytics_usecase.dart';
import '../../../domain/utils/analytics_params_computer.dart';
import '../analytics/analytics_bloc.dart' show AnalyticsFilter;

part 'landing_event.dart';
part 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final GetAnalyticsUseCase _getAnalyticsUseCase;
  final GetAlertsUseCase _getAlertsUseCase;

  LandingBloc({
    required GetAnalyticsUseCase getAnalyticsUseCase,
    required GetAlertsUseCase getAlertsUseCase,
  }) : _getAnalyticsUseCase = getAnalyticsUseCase,
       _getAlertsUseCase = getAlertsUseCase,
       super(const LandingInitial()) {
    on<LandingLoadRequested>(_onLoad);
    on<LandingRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(LandingEvent event, Emitter<LandingState> emit) async {
    final device = event is LandingLoadRequested
        ? event.device
        : (event as LandingRefreshRequested).device;

    emit(const LandingLoading());

    final personId = sl<UserHolder>().user?.personId;
    if (personId == null) {
      debugPrint('[LandingBloc] No logged-in user found');
      emit(const LandingError('User not found. Please log in again.'));
      return;
    }

    debugPrint('[LandingBloc] Loading for device ${device.id}');

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
      debugPrint('[LandingBloc] Analytics fetch failed: ${failure.message}');
      return null;
    }, (points) => points.isNotEmpty ? points.first : null);

    final alerts = alertsResult.fold((failure) {
      debugPrint('[LandingBloc] Alerts fetch failed: ${failure.message}');
      return <AlertEntity>[];
    }, (a) => a);

    emit(LandingLoaded(latest: latest, alerts: alerts));
  }
}
