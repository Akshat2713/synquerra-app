import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_override_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class GetScheduleOverrideByIdUseCase {
  final ScheduleRepository repository;

  GetScheduleOverrideByIdUseCase(this.repository);

  Future<Either<Failure, ScheduleOverrideEntity>> call({
    required String scheduleId,
    required String overrideId,
  }) async {
    return await repository.getScheduleOverrideById(scheduleId, overrideId);
  }
}
