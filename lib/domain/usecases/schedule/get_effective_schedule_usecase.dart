import 'package:dartz/dartz.dart';

import '../../entities/schedule/effective_schedule_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class GetEffectiveScheduleParams {
  final String scheduleId;
  final String date;

  const GetEffectiveScheduleParams({
    required this.scheduleId,
    required this.date,
  });
}

class GetEffectiveScheduleUseCase {
  final ScheduleRepository _repository;

  GetEffectiveScheduleUseCase(this._repository);

  Future<Either<Failure, EffectiveScheduleEntity>> call(
    GetEffectiveScheduleParams params,
  ) {
    return _repository.getEffectiveSchedule(params.scheduleId, params.date);
  }
}
