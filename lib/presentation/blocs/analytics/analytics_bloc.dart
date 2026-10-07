// lib/presentation/blocs/analytics/analytics_bloc.dart

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/analytics/analytics_filter.dart';
import '../../../domain/usecases/analytics/get_analytics_usecase.dart';
import '../../../domain/usecases/analytics/get_live_telemetry_usecase.dart';
import '../../../domain/usecases/analytics/subscribe_analytics_realtime_usecase.dart';
import '../../../domain/utils/analytics_params_computer.dart';
import '../../../core/utils/app_logger.dart';
import '../base/base_state.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  static const _noFixMessage = 'The device could not get a GPS fix right now.';

  final GetAnalyticsUseCase _getAnalyticsUseCase;
  final SubscribeAnalyticsRealtimeUseCase _subscribeRealtimeUseCase;
  final GetLiveTelemetryUseCase _getLiveTelemetryUseCase;
  StreamSubscription<AnalyticsEntity>? _realtimeSub;
  StreamSubscription<String>? _realtimeErrorSub;
  String? _currentDeviceId;
  bool _isLiveQuerying = false;

  /// Incremented by every data fetch. A response whose id no longer matches
  /// belongs to a superseded request and is discarded, so a slow response can
  /// never overwrite the result of a newer one (e.g. rapid filter-chip taps).
  int _requestSeq = 0;

  AnalyticsBloc({
    required GetAnalyticsUseCase getAnalyticsUseCase,
    required SubscribeAnalyticsRealtimeUseCase subscribeRealtimeUseCase,
    required GetLiveTelemetryUseCase getLiveTelemetryUseCase,
  }) : _getAnalyticsUseCase = getAnalyticsUseCase,
       _subscribeRealtimeUseCase = subscribeRealtimeUseCase,
       _getLiveTelemetryUseCase = getLiveTelemetryUseCase,
       super(AnalyticsInitial()) {
    on<AnalyticsLoadDefault>(_onLoadDefault);
    on<AnalyticsFilterChanged>(_onFilterChanged);
    on<AnalyticsCustomRangeSelected>(_onCustomRange);
    on<AnalyticsSliderChanged>(_onSliderChanged);
    on<AnalyticsRealtimePointReceived>(_onRealtimePoint);
    on<AnalyticsLiveQueryRequested>(_onLiveQuery);
  }

  // ───────────────────────── Initial load + realtime ─────────────────────────

  Future<void> _onLoadDefault(
    AnalyticsLoadDefault event,
    Emitter<AnalyticsState> emit,
  ) async {
    _currentDeviceId = event.deviceId;
    emit(const AnalyticsLoading());
    await _fetch(
      emit: emit,
      deviceId: event.deviceId,
      filter: AnalyticsFilter.latest,
    );
    _startRealtime(event.imei);
  }

  void _startRealtime(String imei) {
    _realtimeSub?.cancel();
    _realtimeErrorSub?.cancel();
    _realtimeSub = _subscribeRealtimeUseCase(
      imei,
    ).listen((point) => add(AnalyticsRealtimePointReceived(point)));
    _realtimeErrorSub = _subscribeRealtimeUseCase.errors.listen((_) {
      final deviceId = _currentDeviceId;
      if (deviceId == null) return;

      // Only the "latest" view depends on the live stream. A history snapshot
      // must not be replaced because the socket hiccuped.
      final s = state;
      final isHistory =
          s is AnalyticsLoaded && s.activeFilter != AnalyticsFilter.latest;
      if (isHistory) return;

      add(
        AnalyticsFilterChanged(
          deviceId: deviceId,
          filter: AnalyticsFilter.latest,
        ),
      );
    });
  }

  /// The device channel also carries config/command traffic (null lat/lng,
  /// geoid "gps_error"). Only packets with a valid GNSS fix may update the
  /// map; anything else is ignored and the last known fix stays on screen.
  void _onRealtimePoint(
    AnalyticsRealtimePointReceived event,
    Emitter<AnalyticsState> emit,
  ) {
    final current = state;
    if (current is! AnalyticsLoaded) return;
    if (current.activeFilter != AnalyticsFilter.latest) return;

    final incoming = event.point;

    if (!incoming.hasLocation) {
      AppLogger.d(
        'AnalyticsBloc',
        'Ignored realtime packet without a fix '
            '(type: ${incoming.type}, geoid: ${incoming.geoid})',
      );
      return;
    }

    if (_isOlderThanNewestFix(current, incoming)) {
      AppLogger.d(
        'AnalyticsBloc',
        'Ignored out-of-order packet @ ${incoming.deviceTimestamp}',
      );
      return;
    }

    emit(current.copyWith(points: [incoming]));
  }

  /// True only when both timestamps are known and [incoming] is strictly older
  /// than the newest fix already held. Unknown timestamps are not rejected.
  bool _isOlderThanNewestFix(
    AnalyticsLoaded current,
    AnalyticsEntity incoming,
  ) {
    final held = current.newestFix?.deviceTimestamp;
    final next = incoming.deviceTimestamp;
    return held != null && next != null && next.isBefore(held);
  }

  // ───────────────────────────── Filters / history ───────────────────────────

  static Duration? _lookback(AnalyticsFilter filter) => switch (filter) {
    AnalyticsFilter.latest || AnalyticsFilter.custom => null,
    AnalyticsFilter.lastHour => const Duration(hours: 1),
    AnalyticsFilter.last2Hours => const Duration(hours: 2),
    AnalyticsFilter.last6Hours => const Duration(hours: 6),
    AnalyticsFilter.last12Hours => const Duration(hours: 12),
    AnalyticsFilter.last24Hours => const Duration(hours: 24),
  };

  Future<void> _onFilterChanged(
    AnalyticsFilterChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.d('AnalyticsBloc', 'FilterChanged → ${event.filter}');

    // Custom ranges need dates, so they go through AnalyticsCustomRangeSelected.
    // Bail out BEFORE emitting Loading, otherwise the UI would hang in loading.
    if (event.filter == AnalyticsFilter.custom) {
      AppLogger.d(
        'AnalyticsBloc',
        'FilterChanged(custom) ignored; use AnalyticsCustomRangeSelected',
      );
      return;
    }

    emit(const AnalyticsLoading());

    final now = DateTime.now().toUtc();
    final window = _lookback(event.filter);

    await _fetch(
      emit: emit,
      deviceId: event.deviceId,
      filter: event.filter,
      startDate: window == null ? null : now.subtract(window),
      endDate: now,
    );
  }

  Future<void> _onCustomRange(
    AnalyticsCustomRangeSelected event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.d(
      'AnalyticsBloc',
      'CustomRange → ${event.startDate} to ${event.endDate}',
    );
    emit(const AnalyticsLoading());
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
    final current = state;
    if (current is! AnalyticsLoaded) return;
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
    final requestId = ++_requestSeq;

    final fetchParams = computeAnalyticsParams(
      filter: filter,
      startDate: startDate,
      endDate: endDate,
    );

    AppLogger.d(
      'AnalyticsBloc',
      'Fetch → filter: $filter, limit: ${fetchParams.limit}, '
          'interval: ${fetchParams.dataInterval}',
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

    // A newer request started while this one was in flight; it owns the state.
    if (requestId != _requestSeq) {
      AppLogger.d('AnalyticsBloc', 'Dropped superseded fetch ($filter)');
      return;
    }

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

  // ─────────────────────────────── Live query ────────────────────────────────

  Future<void> _onLiveQuery(
    AnalyticsLiveQueryRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (_isLiveQuerying) return;
    _isLiveQuerying = true;

    // Remember which request generation we started in (see _requestSeq).
    final requestId = _requestSeq;

    try {
      AppLogger.d('AnalyticsBloc', 'LiveQuery → ${event.deviceId}');

      final before = state;
      if (before is AnalyticsLoaded) {
        emit(before.copyWith(isQuerying: true, clearLiveQueryError: true));
      }

      final result = await _getLiveTelemetryUseCase(
        LiveTelemetryParams(deviceId: event.deviceId),
      );

      // The user changed filter/view while we waited; don't clobber that.
      if (requestId != _requestSeq) return;

      result.fold(
        (failure) {
          AppLogger.d('AnalyticsBloc', 'LiveQuery failed: ${failure.message}');
          _failLiveQuery(emit, failure.userMessage);
        },
        (entity) {
          // A live response without a fix must not wipe the last known one.
          if (!entity.hasLocation) {
            AppLogger.d('AnalyticsBloc', 'LiveQuery returned no fix');
            _failLiveQuery(emit, _noFixMessage);
            return;
          }

          final now = state; // re-read; state may have changed while waiting
          if (now is AnalyticsLoaded && _isOlderThanNewestFix(now, entity)) {
            emit(now.copyWith(isQuerying: false));
            return;
          }

          AppLogger.d(
            'AnalyticsBloc',
            'LiveQuery OK @ ${entity.deviceTimestamp}',
          );
          emit(
            AnalyticsLoaded(
              points: [entity],
              activeFilter: AnalyticsFilter.latest,
              sliderIndex: 0,
            ),
          );
        },
      );
    } finally {
      _isLiveQuerying = false;
    }
  }

  void _failLiveQuery(Emitter<AnalyticsState> emit, String message) {
    final now = state;
    if (now is AnalyticsLoaded) {
      emit(now.copyWith(isQuerying: false, liveQueryError: message));
    } else {
      emit(AnalyticsError(message));
    }
  }

  // ─────────────────────────────── Lifecycle ────────────────────────────────

  @override
  Future<void> close() async {
    await _realtimeSub?.cancel();
    await _realtimeErrorSub?.cancel();
    try {
      await _subscribeRealtimeUseCase.stop();
    } finally {
      await super.close();
    }
  }

  String _toIso(DateTime dt) => '${dt.toIso8601String().split('.').first}Z';
}
