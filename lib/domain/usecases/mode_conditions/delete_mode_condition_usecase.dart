import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/mode_conditions_repository.dart';
import '../base_usecase.dart';

class DeleteModeConditionUseCase implements UseCase<void, String> {
  final ModeConditionsRepository _repository;
  DeleteModeConditionUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String conditionId) =>
      _repository.deleteModeCondition(conditionId);
}
