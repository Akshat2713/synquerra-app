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
  // Nested helper for interval computation
  int? computeInterval(int durationSeconds) {
    final totalPackets = durationSeconds ~/ assumedPingIntervalSeconds;
    if (totalPackets <= targetPointCount) return null; // no skipping needed

    final interval = (totalPackets / targetPointCount).floor();
    return interval < 2 ? null : interval; // interval=1 is same as no interval
  }

  switch (filter) {
    case AnalyticsFilter.latest:
      return const AnalyticsFetchParams(limit: 1);

    case AnalyticsFilter.lastHour:
      return const AnalyticsFetchParams(limit: 120);

    case AnalyticsFilter.last24Hours:
      return AnalyticsFetchParams(dataInterval: computeInterval(24 * 60 * 60));

    case AnalyticsFilter.lastWeek:
      return AnalyticsFetchParams(
        dataInterval: computeInterval(7 * 24 * 60 * 60),
      );

    case AnalyticsFilter.custom:
      if (startDate == null || endDate == null) {
        return const AnalyticsFetchParams();
      }
      final durationSeconds = endDate.difference(startDate).inSeconds.abs();
      return AnalyticsFetchParams(
        dataInterval: computeInterval(durationSeconds),
      );
  }
}
