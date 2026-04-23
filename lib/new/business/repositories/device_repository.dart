// lib/business/repositories/device_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/analytics_entity.dart';
import '../failures/failure.dart';

abstract class DeviceRepository {
  /// Get all device IMEIs
  Future<Either<Failure, List<String>>> getDeviceImeis();

  /// Get analytics data by IMEI
  Future<Either<Failure, List<AnalyticsDataEntity>>> getAnalyticsByImei(
    String imei,
  );

  /// Get 24-hour distance data
  Future<Either<Failure, List<AnalyticsDistanceEntity>>> getDistance24(
    String imei,
  );

  /// Get device health data (can be null if not available)
  Future<Either<Failure, AnalyticsHealthEntity?>> getHealth(String imei);

  /// Get device uptime data (can be null if not available)
  Future<Either<Failure, AnalyticsUptimeEntity?>> getUptime(String imei);

  /// Force refresh device data
  Future<Either<Failure, List<AnalyticsDataEntity>>> refreshDevice(String imei);
}
