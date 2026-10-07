import 'package:dartz/dartz.dart';

import '../../domain/entities/geofence_mode/geofence_mode_entity.dart';
import '../../domain/entities/geofence_mode/mode_condition_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/mode_conditions_repository.dart';
import '../datasources/remote/mode_conditions_remote_data_source.dart';
import 'repository_helper.dart';

class ModeConditionsRepositoryImpl implements ModeConditionsRepository {
  final ModeConditionsRemoteDataSource _remote;

  ModeConditionsRepositoryImpl({required ModeConditionsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<GeofenceModeEntity>>> getModes({
    String category = 'geofence',
    bool isActive = true,
  }) {
    return safeListCall(
      call: () => _remote.getModes(category: category, isActive: isActive),
      toEntity: (model) => model.toEntity(),
    );
  }

  // ───────────── Mode Conditions ─────────────

  @override
  Future<Either<Failure, List<ModeConditionEntity>>> getModeConditions({
    required String deviceId,
    required String conditionType,
    bool enabled = true,
    String scope = 'device',
  }) {
    return safeListCall(
      call: () => _remote.getModeConditions(
        deviceId: deviceId,
        conditionType: conditionType,
        enabled: enabled,
        scope: scope,
      ),
      toEntity: (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> createModeCondition({
    required String modeId,
    required String deviceId,
    required String conditionType,
    required bool enabled,
    required Map<String, dynamic> config,
  }) {
    return safeVoidCall(
      call: () => _remote.createModeCondition(
        modeId: modeId,
        deviceId: deviceId,
        conditionType: conditionType,
        enabled: enabled,
        config: config,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> updateModeCondition({
    required String conditionId,
    required String modeId,
    required String deviceId,
    required String conditionType,
    required bool enabled,
    required Map<String, dynamic> config,
  }) {
    return safeVoidCall(
      call: () => _remote.updateModeCondition(
        conditionId: conditionId,
        modeId: modeId,
        deviceId: deviceId,
        conditionType: conditionType,
        enabled: enabled,
        config: config,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteModeCondition(String conditionId) {
    return safeVoidCall(call: () => _remote.deleteModeCondition(conditionId));
  }
}
