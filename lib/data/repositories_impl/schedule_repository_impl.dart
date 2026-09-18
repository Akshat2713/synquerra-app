import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/app_exceptions.dart';
import '../../domain/entities/schedule/effective_schedule_entity.dart';
import '../../domain/entities/schedule/schedule_entity.dart';
import '../../domain/entities/schedule/schedule_override_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/remote/schedule_remote_datasource.dart';
import '../mappers/failure_mapper.dart';
import 'repository_helper.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remote;

  ScheduleRepositoryImpl({required ScheduleRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, ScheduleEntity>> createSchedule(
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final model = await _remote.createSchedule(requestBody);
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getMySchedules({
    bool? isActive,
  }) async {
    return await safeListCall(
      call: () => _remote.getMySchedules(isActive: isActive),
      toEntity: (m) => m.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getTargetUserSchedules(
    String targetUserId, {
    bool? isActive,
  }) async {
    return await safeListCall(
      call: () =>
          _remote.getTargetUserSchedules(targetUserId, isActive: isActive),
      toEntity: (m) => m.toEntity(),
    );
  }

  @override
  Future<Either<Failure, ScheduleEntity>> getScheduleById(
    String scheduleId,
  ) async {
    try {
      final model = await _remote.getScheduleById(scheduleId);
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> updateBody,
  ) async {
    try {
      final model = await _remote.updateSchedule(scheduleId, updateBody);
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> toggleScheduleStatus(
    String scheduleId,
    bool isActive,
  ) async {
    try {
      await _remote.toggleScheduleStatus(scheduleId, isActive);
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String scheduleId) async {
    try {
      await _remote.deleteSchedule(scheduleId);
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, ScheduleOverrideEntity>> createScheduleOverride(
    String scheduleId,
    Map<String, dynamic> overrideBody,
  ) async {
    try {
      final model = await _remote.createScheduleOverride(
        scheduleId,
        overrideBody,
      );
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleOverrideEntity>>> getScheduleOverrides(
    String scheduleId, {
    String? startDate,
    String? endDate,
  }) async {
    return await safeListCall(
      call: () => _remote.getScheduleOverrides(
        scheduleId,
        startDate: startDate,
        endDate: endDate,
      ),
      toEntity: (m) => m.toEntity(),
    );
  }

  @override
  Future<Either<Failure, ScheduleOverrideEntity>> getScheduleOverrideById(
    String scheduleId,
    String overrideId,
  ) async {
    try {
      final model = await _remote.getScheduleOverrideById(
        scheduleId,
        overrideId,
      );
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, ScheduleOverrideEntity>> updateScheduleOverride(
    String scheduleId,
    String overrideId,
    Map<String, dynamic> updateBody,
  ) async {
    try {
      final model = await _remote.updateScheduleOverride(
        scheduleId,
        overrideId,
        updateBody,
      );
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScheduleOverride(
    String scheduleId,
    String overrideId,
  ) async {
    try {
      await _remote.deleteScheduleOverride(scheduleId, overrideId);
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, EffectiveScheduleEntity>> getEffectiveSchedule(
    String scheduleId,
    String date,
  ) async {
    try {
      final model = await _remote.getEffectiveSchedule(scheduleId, date);
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
