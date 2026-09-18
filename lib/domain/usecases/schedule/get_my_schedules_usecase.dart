import 'package:dartz/dartz.dart';

import '../../entities/schedule/schedule_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class GetMySchedulesUseCase {
  final ScheduleRepository _repository;

  GetMySchedulesUseCase(this._repository);

  Future<Either<Failure, List<ScheduleEntity>>> call({bool? isActive}) {
    return _repository.getMySchedules(isActive: isActive);
  }
}
