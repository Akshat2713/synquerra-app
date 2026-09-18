import 'package:dartz/dartz.dart';

import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class ToggleScheduleStatusParams {
  final String scheduleId;
  final bool isActive;

  const ToggleScheduleStatusParams({
    required this.scheduleId,
    required this.isActive,
  });
}

class ToggleScheduleStatusUseCase {
  final ScheduleRepository _repository;

  ToggleScheduleStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(ToggleScheduleStatusParams params) {
    return _repository.toggleScheduleStatus(params.scheduleId, params.isActive);
  }
}
