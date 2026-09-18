import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_override_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class UpdateScheduleOverrideUseCase {
  final ScheduleRepository repository;

  UpdateScheduleOverrideUseCase(this.repository);

  Future<Either<Failure, ScheduleOverrideEntity>> call({
    required String scheduleId,
    required String overrideId,
    required Map<String, dynamic> updateBody,
  }) async {
    return await repository.updateScheduleOverride(
      scheduleId,
      overrideId,
      updateBody,
    );
  }
}
