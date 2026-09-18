import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class CreateScheduleUseCase {
  final ScheduleRepository _repository;

  CreateScheduleUseCase(this._repository);

  Future<Either<Failure, ScheduleEntity>> call(
    Map<String, dynamic> requestBody,
  ) {
    return _repository.createSchedule(requestBody);
  }
}
