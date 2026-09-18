import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class UpdateScheduleUseCase {
  final ScheduleRepository repository;

  UpdateScheduleUseCase(this.repository);

  Future<Either<Failure, ScheduleEntity>> call({
    required String scheduleId,
    required Map<String, dynamic> updateBody,
  }) async {
    return await repository.updateSchedule(scheduleId, updateBody);
  }
}
