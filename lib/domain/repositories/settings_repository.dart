import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/settings/send_query_command_entity.dart';
import '../entities/settings/settings_entity.dart';
import '../failures/failure.dart';

abstract class SettingsRepository {
  /// Fetches device settings by device ID
  Future<Either<Failure, SettingsEntity>> getSettings({
    required String deviceId,
  });

  /// Updates phone numbers for the specified device
  Future<Either<Failure, SettingsEntity>> updatePhoneNumbers({
    required String deviceId,
    String? phoneNum1,
    String? phoneNum2,
  });

  /// Sends a query command to the device
  Future<Either<Failure, SendQueryCommandEntity>> sendQueryCommand({
    required String deviceId,
  });
}
