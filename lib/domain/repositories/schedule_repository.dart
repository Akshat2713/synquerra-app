import 'package:dartz/dartz.dart';

import '../entities/schedule/effective_schedule_entity.dart';
import '../entities/schedule/schedule_entity.dart';
import '../entities/schedule/schedule_override_entity.dart';
import '../failures/failure.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, ScheduleEntity>> createSchedule(
    Map<String, dynamic> requestBody,
  );

  Future<Either<Failure, List<ScheduleEntity>>> getMySchedules({
    bool? isActive,
  });

  Future<Either<Failure, List<ScheduleEntity>>> getTargetUserSchedules(
    String targetUserId, {
    bool? isActive,
  });

  Future<Either<Failure, ScheduleEntity>> getScheduleById(String scheduleId);

  Future<Either<Failure, ScheduleEntity>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> updateBody,
  );

  Future<Either<Failure, void>> toggleScheduleStatus(
    String scheduleId,
    bool isActive,
  );

  Future<Either<Failure, void>> deleteSchedule(String scheduleId);

  Future<Either<Failure, ScheduleOverrideEntity>> createScheduleOverride(
    String scheduleId,
    Map<String, dynamic> overrideBody,
  );

  Future<Either<Failure, List<ScheduleOverrideEntity>>> getScheduleOverrides(
    String scheduleId, {
    String? startDate,
    String? endDate,
  });

  Future<Either<Failure, ScheduleOverrideEntity>> getScheduleOverrideById(
    String scheduleId,
    String overrideId,
  );

  Future<Either<Failure, ScheduleOverrideEntity>> updateScheduleOverride(
    String scheduleId,
    String overrideId,
    Map<String, dynamic> updateBody,
  );

  Future<Either<Failure, void>> deleteScheduleOverride(
    String scheduleId,
    String overrideId,
  );

  Future<Either<Failure, EffectiveScheduleEntity>> getEffectiveSchedule(
    String scheduleId,
    String date,
  );
}
