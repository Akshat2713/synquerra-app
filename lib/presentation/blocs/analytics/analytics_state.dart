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

  const AnalyticsLoaded({
    required this.points,
    required this.activeFilter,
    this.startDate,
    this.endDate,
    this.sliderIndex = 0,
  });

  List<AnalyticsEntity> get mappablePoints =>
      points.where((p) => p.hasLocation).toList();

  AnalyticsEntity? get currentPoint => mappablePoints.isEmpty
      ? null
      : mappablePoints[sliderIndex.clamp(0, mappablePoints.length - 1)];

  AnalyticsLoaded copyWith({
    List<AnalyticsEntity>? points,
    AnalyticsFilter? activeFilter,
    DateTime? startDate,
    DateTime? endDate,
    int? sliderIndex,
  }) {
    return AnalyticsLoaded(
      points: points ?? this.points,
      activeFilter: activeFilter ?? this.activeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sliderIndex: sliderIndex ?? this.sliderIndex,
    );
  }

  @override
  List<Object?> get props => [
    points,
    activeFilter,
    startDate,
    endDate,
    sliderIndex,
  ];
}

class AnalyticsError extends AnalyticsState with ErrorState {
  @override
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
