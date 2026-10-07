import 'package:dartz/dartz.dart';

import '../entities/geofence_mode/geofence_mode_entity.dart';
import '../entities/geofence_mode/mode_condition_entity.dart';
import '../failures/failure.dart';

abstract class ModeConditionsRepository {
  Future<Either<Failure, List<GeofenceModeEntity>>> getModes({
    String category = 'geofence',
    bool isActive = true,
  });

  // ───────────── Mode Conditions ─────────────

  Future<Either<Failure, List<ModeConditionEntity>>> getModeConditions({
    required String deviceId,
    required String conditionType,
    bool enabled = true,
    String scope = 'device',
  });

  Future<Either<Failure, void>> createModeCondition({
    required String modeId,
    required String deviceId,
    required String conditionType,
    required bool enabled,
    required Map<String, dynamic> config,
  });

  Future<Either<Failure, void>> updateModeCondition({
    required String conditionId,
    required String modeId,
    required String deviceId,
    required String conditionType,
    required bool enabled,
    required Map<String, dynamic> config,
  });

  Future<Either<Failure, void>> deleteModeCondition(String conditionId);
}
