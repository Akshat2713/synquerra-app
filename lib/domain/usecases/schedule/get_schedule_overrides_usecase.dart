import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_override_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class GetScheduleOverridesUseCase {
  final ScheduleRepository repository;

  GetScheduleOverridesUseCase(this.repository);

  Future<Either<Failure, List<ScheduleOverrideEntity>>> call({
    required String scheduleId,
    String? startDate,
    String? endDate,
  }) async {
    return await repository.getScheduleOverrides(
      scheduleId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
