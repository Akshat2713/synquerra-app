part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class AnalyticsLoadDefault extends AnalyticsEvent {
  final String deviceId; // ~ renamed from imei
  const AnalyticsLoadDefault(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class AnalyticsFilterChanged extends AnalyticsEvent {
  final String deviceId; // ~ renamed from imei
  final AnalyticsFilter filter;
  const AnalyticsFilterChanged({required this.deviceId, required this.filter});
  @override
  List<Object?> get props => [deviceId, filter];
}

class AnalyticsCustomRangeSelected extends AnalyticsEvent {
  final String deviceId; // ~ renamed from imei
  final DateTime startDate;
  final DateTime endDate;
  const AnalyticsCustomRangeSelected({
    required this.deviceId,
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [deviceId, startDate, endDate];
}

class AnalyticsSliderChanged extends AnalyticsEvent {
  final int index;
  const AnalyticsSliderChanged(this.index);
  @override
  List<Object?> get props => [index];
}
