// lib/presentation/blocs/analytics/analytics_state.dart

part of 'analytics_bloc.dart';

abstract class AnalyticsState extends BaseState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState with LoadingState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final List<AnalyticsEntity> points;
  final AnalyticsFilter activeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final int sliderIndex;
  final bool isQuerying;
  final String? liveQueryError;

  const AnalyticsLoaded({
    required this.points,
    required this.activeFilter,
    this.startDate,
    this.endDate,
    this.sliderIndex = 0,
    this.isQuerying = false,
    this.liveQueryError,
  });

  List<AnalyticsEntity> get mappablePoints {
    final filtered = points.where((p) => p.hasLocation).toList();
    filtered.sort((a, b) {
      final aTime = a.deviceTimestamp;
      final bTime = b.deviceTimestamp;
      if (aTime == null) return -1;
      if (bTime == null) return 1;
      return aTime.compareTo(bTime);
    });
    return filtered;
  }

  AnalyticsEntity? get currentPoint => mappablePoints.isEmpty
      ? null
      : mappablePoints[sliderIndex.clamp(0, mappablePoints.length - 1)];

  AnalyticsLoaded copyWith({
    List<AnalyticsEntity>? points,
    AnalyticsFilter? activeFilter,
    DateTime? startDate,
    DateTime? endDate,
    int? sliderIndex,
    bool? isQuerying,
    String? liveQueryError,
    bool clearLiveQueryError = false,
  }) {
    return AnalyticsLoaded(
      points: points ?? this.points,
      activeFilter: activeFilter ?? this.activeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sliderIndex: sliderIndex ?? this.sliderIndex,
      isQuerying: isQuerying ?? this.isQuerying,
      liveQueryError: clearLiveQueryError
          ? null
          : (liveQueryError ?? this.liveQueryError),
    );
  }

  @override
  List<Object?> get props => [
    points,
    activeFilter,
    startDate,
    endDate,
    sliderIndex,
    isQuerying,
    liveQueryError,
  ];
}

class AnalyticsError extends AnalyticsState with ErrorState {
  @override
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
