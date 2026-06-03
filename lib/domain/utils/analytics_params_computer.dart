// domain/utils/analytics_params_computer.dart

import '../../presentation/blocs/analytics/analytics_bloc.dart';

/// Represents the optimal fetch parameters for a given time range.
class AnalyticsFetchParams {
  final int? limit;
  final int? dataInterval;

  const AnalyticsFetchParams({this.limit, this.dataInterval});
}

/// Computes the optimal fetch parameters for a given time range.
///
/// [assumedPingIntervalSeconds] defaults to 1000.
/// [targetPointCount] defaults to 300.
AnalyticsFetchParams computeAnalyticsParams({
  required AnalyticsFilter filter,
  DateTime? startDate,
  DateTime? endDate,
  int assumedPingIntervalSeconds = 1000,
  int targetPointCount = 300,
}) {
  int? computeInterval(int durationSeconds) {
    final totalPackets = durationSeconds ~/ assumedPingIntervalSeconds;
    if (totalPackets <= targetPointCount) return null;
    final interval = (totalPackets / targetPointCount).floor();
    return interval < 2 ? null : interval;
  }

  switch (filter) {
    case AnalyticsFilter.latest:
      return const AnalyticsFetchParams(limit: 1);

    case AnalyticsFilter.lastHour:
      // Hour is short — fetch all, no interval needed
      return const AnalyticsFetchParams(limit: 0);

    case AnalyticsFilter.last24Hours:
      return AnalyticsFetchParams(
        limit: 0,
        dataInterval: computeInterval(24 * 60 * 60),
      );

    case AnalyticsFilter.lastWeek:
      return AnalyticsFetchParams(
        limit: 0,
        dataInterval: computeInterval(7 * 24 * 60 * 60),
      );

    case AnalyticsFilter.custom:
      if (startDate == null || endDate == null) {
        return const AnalyticsFetchParams(limit: 0);
      }
      final durationSeconds = endDate.difference(startDate).inSeconds.abs();
      return AnalyticsFetchParams(
        limit: 0,
        dataInterval: computeInterval(durationSeconds),
      );
  }
}
