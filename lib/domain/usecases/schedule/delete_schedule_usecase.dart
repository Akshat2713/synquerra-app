import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/schedule_repository.dart';

class DeleteScheduleUseCase {
  final ScheduleRepository repository;

  DeleteScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(String scheduleId) async {
    return await repository.deleteSchedule(scheduleId);
  }
}
