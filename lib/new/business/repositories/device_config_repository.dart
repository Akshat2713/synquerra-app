// lib/business/repositories/device_config_repository.dart
import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

abstract class DeviceConfigRepository {
  /// Get all device configuration settings
  Future<Either<Failure, Map<String, String>>> getAllSettings();

  /// Save a single setting
  Future<Either<Failure, void>> saveSetting(String key, String value);

  /// Get a specific setting
  Future<Either<Failure, String>> getSetting(String key);
}
