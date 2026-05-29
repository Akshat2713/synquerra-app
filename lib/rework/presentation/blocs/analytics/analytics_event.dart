part of 'analytics_bloc.dart';

// 1. Extend Equatable on the base class
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsLoadDefault extends AnalyticsEvent {
  final String imei;
  const AnalyticsLoadDefault(this.imei); // Added const

  // 2. Override props
  @override
  List<Object?> get props => [imei];
}

class AnalyticsFilterChanged extends AnalyticsEvent {
  final String imei;
  final AnalyticsFilter filter;
  const AnalyticsFilterChanged({
    required this.imei,
    required this.filter,
  }); // Added const

  // 2. Override props
  @override
  List<Object?> get props => [imei, filter];
}

class AnalyticsCustomRangeSelected extends AnalyticsEvent {
  final String imei;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsCustomRangeSelected({
    // Added const
    required this.imei,
    required this.startDate,
    required this.endDate,
  });

  // 2. Override props
  @override
  List<Object?> get props => [imei, startDate, endDate];
}

class AnalyticsSliderChanged extends AnalyticsEvent {
  final int index;
  const AnalyticsSliderChanged(this.index); // Added const

  // 2. Override props
  @override
  List<Object?> get props => [index];
}
