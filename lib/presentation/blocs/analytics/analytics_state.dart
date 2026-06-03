part of 'analytics_bloc.dart';

enum AnalyticsFilter { latest, lastHour, last24Hours, lastWeek, custom }

// 1. Extend Equatable on the base class
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final List<AnalyticsEntity> points;
  final AnalyticsFilter activeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final int sliderIndex;

  const AnalyticsLoaded({
    // Added const
    required this.points,
    required this.activeFilter,
    this.startDate,
    this.endDate,
    this.sliderIndex = 0,
  });

  // Points that have valid location for map rendering
  List<AnalyticsEntity> get mappablePoints =>
      points.where((p) => p.hasLocation).toList();

  // Currently selected point via slider
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

  // 2. Override props with all fields that determine state equality
  @override
  List<Object?> get props => [
    points,
    activeFilter,
    startDate,
    endDate,
    sliderIndex,
  ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message); // Added const

  // 3. Override props for the error message
  @override
  List<Object?> get props => [message];
}
