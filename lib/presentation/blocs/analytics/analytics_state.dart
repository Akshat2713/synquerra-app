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

  // Not `const`: [mappablePoints] is a `late final` cache, and a class with a
  // const constructor cannot have late fields. If any other file calls
  // `const AnalyticsLoaded(...)`, just remove the `const` there.
  AnalyticsLoaded({
    required this.points,
    required this.activeFilter,
    this.startDate,
    this.endDate,
    this.sliderIndex = 0,
    this.isQuerying = false,
    this.liveQueryError,
  });

  /// Points with a valid GNSS fix, ordered oldest → newest.
  ///
  /// Computed once per state instance (states are immutable). Previously this
  /// filtered and sorted on every access, and [currentPoint] accessed it up to
  /// three times per call, which adds up while scrubbing the timeline slider.
  late final List<AnalyticsEntity> mappablePoints = _sortedFixes(points);

  /// Most recent point that has a valid fix, or null when there is none.
  AnalyticsEntity? get newestFix =>
      mappablePoints.isEmpty ? null : mappablePoints.last;

  AnalyticsEntity? get currentPoint {
    final fixes = mappablePoints;
    if (fixes.isEmpty) return null;
    return fixes[sliderIndex.clamp(0, fixes.length - 1)];
  }

  static List<AnalyticsEntity> _sortedFixes(List<AnalyticsEntity> source) {
    return source.where((p) => p.hasLocation).toList()..sort(_byTimestamp);
  }

  /// Valid comparator: unknown timestamps sort first and compare equal to
  /// each other (the old one returned -1 for two nulls, which breaks the
  /// sort contract).
  static int _byTimestamp(AnalyticsEntity a, AnalyticsEntity b) {
    final at = a.deviceTimestamp;
    final bt = b.deviceTimestamp;
    if (at == null && bt == null) return 0;
    if (at == null) return -1;
    if (bt == null) return 1;
    return at.compareTo(bt);
  }

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
