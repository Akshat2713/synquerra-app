import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/settings/send_query_command_entity.dart';
import '../../domain/entities/settings/settings_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/remote/settings_remote_datasource.dart';
import 'repository_helper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remote;

  SettingsRepositoryImpl({required SettingsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, SettingsEntity>> getSettings({
    required String deviceId,
  }) => safeCall(
    call: () => _remote.getSettings(deviceId: deviceId),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, SettingsEntity>> updatePhoneNumbers({
    required String deviceId,
    String? phoneNum1,
    String? phoneNum2,
    String? controlRoomNum,
  }) => safeCall(
    call: () => _remote.updatePhoneNumbers(
      deviceId: deviceId,
      phoneNum1: phoneNum1,
      phoneNum2: phoneNum2,
      controlRoomNum: controlRoomNum,
    ),
    toEntity: (m) => m.toEntity(),
  );
  @override
  Future<Either<Failure, SendQueryCommandEntity>> sendQueryCommand({
    required String deviceId,
  }) => safeCall(
    call: () => _remote.sendQueryCommand(deviceId: deviceId),
    toEntity: (m) => m.toEntity(),
  );
}
