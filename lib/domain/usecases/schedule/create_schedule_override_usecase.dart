import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_override_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class CreateScheduleOverrideParams {
  final String scheduleId;
  final Map<String, dynamic> overrideBody;

  const CreateScheduleOverrideParams({
    required this.scheduleId,
    required this.overrideBody,
  });
}

class CreateScheduleOverrideUseCase {
  final ScheduleRepository _repository;

  CreateScheduleOverrideUseCase(this._repository);

  Future<Either<Failure, ScheduleOverrideEntity>> call(
    CreateScheduleOverrideParams params,
  ) {
    return _repository.createScheduleOverride(
      params.scheduleId,
      params.overrideBody,
    );
  }
}
