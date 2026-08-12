import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/app_exceptions.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/device_assignment_repository.dart';
import '../datasources/remote/device_assignment_remote_datasource.dart';
import '../mappers/failure_mapper.dart';

class DeviceAssignmentRepositoryImpl implements DeviceAssignmentRepository {
  final DeviceAssignmentRemoteDataSource _remote;

  DeviceAssignmentRepositoryImpl({
    required DeviceAssignmentRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, void>> assignDevice({
    required String personId,
    required String deviceId,
    required String associationType,
  }) async {
    try {
      await _remote.assignDevice(
        personId: personId,
        deviceId: deviceId,
        associationType: associationType,
      );
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> unassignDevice({
    required String deviceId,
    required String associationType,
  }) async {
    try {
      await _remote.unassignDevice(
        deviceId: deviceId,
        associationType: associationType,
      );
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
