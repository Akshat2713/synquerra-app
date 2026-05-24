import '../../../presentation/blocs/analytics/analytics_bloc.dart';
import '../base_usecase.dart';
import '../../entities/analytics/analytics_entity.dart';
import 'get_analytics_usecase.dart';

/// Represents the optimal fetch parameters for a given time range.
class AnalyticsFetchParams {
  final int? limit;
  final int? dataInterval;

  const AnalyticsFetchParams({this.limit, this.dataInterval});
}

class ComputeAnalyticsParamsUseCase {
  final int assumedPingIntervalSeconds;

  final int targetPointCount;

  const ComputeAnalyticsParamsUseCase({
    this.assumedPingIntervalSeconds = 1000,
    this.targetPointCount = 300,
  });

  AnalyticsFetchParams call({
    required AnalyticsFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    switch (filter) {
      case AnalyticsFilter.latest:
        return const AnalyticsFetchParams(limit: 1);

      case AnalyticsFilter.lastHour:
        return const AnalyticsFetchParams(limit: 120);

      case AnalyticsFilter.last24Hours:
        return AnalyticsFetchParams(
          dataInterval: _computeInterval(durationSeconds: 24 * 60 * 60),
        );

      case AnalyticsFilter.lastWeek:
        return AnalyticsFetchParams(
          dataInterval: _computeInterval(durationSeconds: 7 * 24 * 60 * 60),
        );

      case AnalyticsFilter.custom:
        if (startDate == null || endDate == null) {
          return const AnalyticsFetchParams();
        }
        final durationSeconds = endDate.difference(startDate).inSeconds.abs();
        return AnalyticsFetchParams(
          dataInterval: _computeInterval(durationSeconds: durationSeconds),
        );
    }
  }

  int? _computeInterval({required int durationSeconds}) {
    final totalPackets = durationSeconds ~/ assumedPingIntervalSeconds;
    if (totalPackets <= targetPointCount) return null; // no skipping needed
    final interval = (totalPackets / targetPointCount).floor();
    return interval < 2 ? null : interval; // interval=1 is same as no interval
  }
}
