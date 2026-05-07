part of 'analytics_bloc.dart';

abstract class AnalyticsEvent {}

class AnalyticsLoadDefault extends AnalyticsEvent {
  final String imei;
  AnalyticsLoadDefault(this.imei);
}

class AnalyticsFilterChanged extends AnalyticsEvent {
  final String imei;
  final AnalyticsFilter filter;
  AnalyticsFilterChanged({required this.imei, required this.filter});
}

class AnalyticsCustomRangeSelected extends AnalyticsEvent {
  final String imei;
  final DateTime startDate;
  final DateTime endDate;
  AnalyticsCustomRangeSelected({
    required this.imei,
    required this.startDate,
    required this.endDate,
  });
}

class AnalyticsSliderChanged extends AnalyticsEvent {
  final int index;
  AnalyticsSliderChanged(this.index);
}
