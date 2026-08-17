// data/repositories_impl/analytics_repository_impl.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/analytics/analytics_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/remote/analytics_realtime_datasource.dart';
import '../datasources/remote/analytics_remote_datasource.dart';
import 'repository_helper.dart'; // Added import for the shared helper

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;
  final AnalyticsRealtimeDataSource _realtime;
  AnalyticsRepositoryImpl({
    required AnalyticsRemoteDataSource remote,
    required AnalyticsRealtimeDataSource realtime,
  }) : _remote = remote,
       _realtime = realtime;

  @override
  Stream<AnalyticsEntity> subscribeToTelemetry(String imei) {
    unawaited(_realtime.subscribeTelemetry(imei));
    return _realtime.telemetryStream.map((m) => m.toEntity());
  }

  @override
  Stream<String> get telemetryErrors => _realtime.errors;

  @override
  Future<void> unsubscribeFromTelemetry() => _realtime.unsubscribe();

  @override
  Future<Either<Failure, List<AnalyticsEntity>>> getAnalytics({
    required String deviceId,
    int? skip,
    int? limit,
    int? dataInterval,
    String? startDate,
    String? endDate,
  }) {
    return safeListCall(
      call: () => _remote.getAnalytics(
        deviceId: deviceId,
        skip: skip,
        limit: limit,
        dataInterval: dataInterval,
        startDate: startDate,
        endDate: endDate,
      ),
      toEntity: (m) => m.toEntity(),
    );
  }
}
