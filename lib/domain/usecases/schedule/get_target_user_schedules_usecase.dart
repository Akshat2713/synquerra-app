import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class GetTargetUserSchedulesUseCase {
  final ScheduleRepository _repository;

  GetTargetUserSchedulesUseCase(this._repository);

  Future<Either<Failure, List<ScheduleEntity>>> call({
    required String userId,
    required String deviceId,
  }) {
    return _repository.getTargetUserSchedules(userId, deviceId);
  }
}
