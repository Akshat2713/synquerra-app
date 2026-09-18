import 'package:dartz/dartz.dart';

import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class DeleteScheduleOverrideUseCase {
  final ScheduleRepository repository;

  DeleteScheduleOverrideUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String scheduleId,
    required String overrideId,
  }) async {
    return await repository.deleteScheduleOverride(scheduleId, overrideId);
  }
}
