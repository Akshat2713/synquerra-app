import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class GetScheduleByIdUseCase {
  final ScheduleRepository repository;

  GetScheduleByIdUseCase(this.repository);

  Future<Either<Failure, ScheduleEntity>> call(String scheduleId) async {
    return await repository.getScheduleById(scheduleId);
  }
}
