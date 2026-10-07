import 'package:dartz/dartz.dart';
import '../../entities/geofence_mode/mode_condition_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/mode_conditions_repository.dart';
import '../base_usecase.dart';

class GetModeConditionsParams {
  final String deviceId;
  final String conditionType;
  final bool enabled;
  final String scope;

  const GetModeConditionsParams({
    required this.deviceId,
    required this.conditionType,
    this.enabled = true,
    this.scope = 'device',
  });
}

class GetModeConditionsUseCase
    implements UseCase<List<ModeConditionEntity>, GetModeConditionsParams> {
  final ModeConditionsRepository _repository;
  GetModeConditionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ModeConditionEntity>>> call(
    GetModeConditionsParams p,
  ) => _repository.getModeConditions(
    deviceId: p.deviceId,
    conditionType: p.conditionType,
    enabled: p.enabled,
    scope: p.scope,
  );
}
