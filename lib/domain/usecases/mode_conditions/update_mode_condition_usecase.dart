import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/mode_conditions_repository.dart';
import '../base_usecase.dart';

class UpdateModeConditionParams {
  final String conditionId;
  final String modeId;
  final String deviceId;
  final String conditionType;
  final bool enabled;
  final Map<String, dynamic> config;

  const UpdateModeConditionParams({
    required this.conditionId,
    required this.modeId,
    required this.deviceId,
    required this.conditionType,
    this.enabled = true,
    required this.config,
  });
}

class UpdateModeConditionUseCase
    implements UseCase<void, UpdateModeConditionParams> {
  final ModeConditionsRepository _repository;
  UpdateModeConditionUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateModeConditionParams p) =>
      _repository.updateModeCondition(
        conditionId: p.conditionId,
        modeId: p.modeId,
        deviceId: p.deviceId,
        conditionType: p.conditionType,
        enabled: p.enabled,
        config: p.config,
      );
}
