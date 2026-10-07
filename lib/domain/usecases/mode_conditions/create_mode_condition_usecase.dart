import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/mode_conditions_repository.dart';
import '../base_usecase.dart';

class CreateModeConditionParams {
  final String modeId;
  final String deviceId;
  final String conditionType;
  final bool enabled;
  final Map<String, dynamic> config;

  const CreateModeConditionParams({
    required this.modeId,
    required this.deviceId,
    required this.conditionType,
    this.enabled = true,
    required this.config,
  });
}

class CreateModeConditionUseCase
    implements UseCase<void, CreateModeConditionParams> {
  final ModeConditionsRepository _repository;
  CreateModeConditionUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CreateModeConditionParams p) =>
      _repository.createModeCondition(
        modeId: p.modeId,
        deviceId: p.deviceId,
        conditionType: p.conditionType,
        enabled: p.enabled,
        config: p.config,
      );
}
