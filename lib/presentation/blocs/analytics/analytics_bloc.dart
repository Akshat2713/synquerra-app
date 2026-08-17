import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/analytics/analytics_filter.dart';
import '../../../domain/usecases/analytics/get_analytics_usecase.dart';
import '../../../domain/usecases/analytics/subscribe_analytics_realtime_usecase.dart';
import '../../../domain/utils/analytics_params_computer.dart';
import '../../../core/utils/app_logger.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsUseCase _getAnalyticsUseCase;
  final SubscribeAnalyticsRealtimeUseCase _subscribeRealtimeUseCase;
  StreamSubscription<AnalyticsEntity>? _realtimeSub;
  StreamSubscription<String>? _realtimeErrorSub;
  String? _currentDeviceId;

  AnalyticsBloc({
    required GetAnalyticsUseCase getAnalyticsUseCase,
    required SubscribeAnalyticsRealtimeUseCase subscribeRealtimeUseCase,
  }) : _getAnalyticsUseCase = getAnalyticsUseCase,
       _subscribeRealtimeUseCase = subscribeRealtimeUseCase,
       super(AnalyticsInitial()) {
    on<AnalyticsLoadDefault>(_onLoadDefault);
    on<AnalyticsFilterChanged>(_onFilterChanged);
    on<AnalyticsCustomRangeSelected>(_onCustomRange);
    on<AnalyticsSliderChanged>(_onSliderChanged);
    on<AnalyticsRealtimePointReceived>(_onRealtimePoint);
  }

  Future<void> _onLoadDefault(
    AnalyticsLoadDefault event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    await _fetch(
      emit: emit,
      deviceId: event.deviceId,
      filter: AnalyticsFilter.latest,
    );
    _currentDeviceId = event.deviceId;
    _startRealtime(event.imei);
  }

  void _startRealtime(String imei) {
    _realtimeSub?.cancel();
    _realtimeErrorSub?.cancel();
    _realtimeSub = _subscribeRealtimeUseCase(
      imei,
    ).listen((point) => add(AnalyticsRealtimePointReceived(point)));
    _realtimeErrorSub = _subscribeRealtimeUseCase.errors.listen((_) {
      if (_currentDeviceId != null) {
        add(
          AnalyticsFilterChanged(
            deviceId: _currentDeviceId!,
            filter: AnalyticsFilter.latest,
          ),
        );
      }
    });
  }

  void _onRealtimePoint(
    AnalyticsRealtimePointReceived event,
    Emitter<AnalyticsState> emit,
  ) {
    if (state is! AnalyticsLoaded) return;
    final current = state as AnalyticsLoaded;
    if (current.activeFilter != AnalyticsFilter.latest)
      return; // don't disturb history browsing
    emit(current.copyWith(points: [event.point, ...current.points]));
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    _realtimeErrorSub?.cancel();
    _subscribeRealtimeUseCase.stop();
    return super.close();
  }

  Future<void> _onFilterChanged(
    AnalyticsFilterChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.d('AnalyticsBloc', 'FilterChanged → ${event.filter}');
    emit(AnalyticsLoading());

    final now = DateTime.now().toUtc();
    DateTime? startDate;

    switch (event.filter) {
      case AnalyticsFilter.latest:
        break;
      case AnalyticsFilter.lastHour:
        startDate = now.subtract(const Duration(hours: 1));
        break;
      case AnalyticsFilter.last2Hours:
        startDate = now.subtract(const Duration(hours: 2));
        break;
      case AnalyticsFilter.last6Hours:
        startDate = now.subtract(const Duration(hours: 6));
        break;
      case AnalyticsFilter.last12Hours:
        startDate = now.subtract(const Duration(hours: 12));
        break;
      case AnalyticsFilter.last24Hours:
        startDate = now.subtract(const Duration(hours: 24));
        break;
      case AnalyticsFilter.custom:
        return;
    }

    await _fetch(
      emit: emit,
      deviceId: event.deviceId,
      filter: event.filter,
      startDate: startDate,
      endDate: now,
    );
  }

  Future<void> _onCustomRange(
    AnalyticsCustomRangeSelected event,
    Emitter<AnalyticsState> emit,
  ) async {
    debugPrint(
      '[AnalyticsBloc] CustomRange → '
      '${event.startDate} to ${event.endDate}',
    );
    emit(AnalyticsLoading());
    await _fetch(
      emit: emit,
      deviceId: event.deviceId,
      filter: AnalyticsFilter.custom,
      startDate: event.startDate.toUtc(),
      endDate: event.endDate.toUtc(),
      startDateDt: event.startDate,
      endDateDt: event.endDate,
    );
  }

  void _onSliderChanged(
    AnalyticsSliderChanged event,
    Emitter<AnalyticsState> emit,
  ) {
    if (state is! AnalyticsLoaded) return;
    final current = state as AnalyticsLoaded;
    AppLogger.d('AnalyticsBloc', 'Slider → index: ${event.index}');
    emit(current.copyWith(sliderIndex: event.index));
  }

  Future<void> _fetch({
    required Emitter<AnalyticsState> emit,
    required String deviceId,
    required AnalyticsFilter filter,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? startDateDt,
    DateTime? endDateDt,
  }) async {
    final fetchParams = computeAnalyticsParams(
      filter: filter,
      startDate: startDate,
      endDate: endDate,
    );

    debugPrint(
      '[AnalyticsBloc] Fetch → filter: $filter'
      ', limit: ${fetchParams.limit}'
      ', interval: ${fetchParams.dataInterval}',
    );

    final result = await _getAnalyticsUseCase(
      AnalyticsParams(
        deviceId: deviceId,
        startDate: startDate != null ? _toIso(startDate) : null,
        endDate: endDate != null ? _toIso(endDate) : null,
        limit: fetchParams.limit,
        dataInterval: fetchParams.dataInterval,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.d('AnalyticsBloc', 'Fetch failed: ${failure.message}');
        emit(AnalyticsError(failure.userMessage));
      },
      (points) {
        AppLogger.d('AnalyticsBloc', 'Fetched ${points.length} points');
        emit(
          AnalyticsLoaded(
            points: points,
            activeFilter: filter,
            startDate: startDateDt,
            endDate: endDateDt,
            sliderIndex: 0,
          ),
        );
      },
    );
  }

  String _toIso(DateTime dt) => '${dt.toIso8601String().split('.').first}Z';
}
