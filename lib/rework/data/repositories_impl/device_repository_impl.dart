import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/device/device_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/device_repository.dart';
import '../../core/error/app_exceptions.dart';
// import '../../core/error/failure_mapper.dart';
import '../datasources/remote/device_remote_datasource.dart';
import '../mappers/faulure_mapper.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remote;
  DeviceRepositoryImpl({required DeviceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDeviceList() async {
    try {
      final models = await _remote.getDeviceList();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      debugPrint('[DeviceRepository] Error: $e');
      debugPrint('[DeviceRepository] StackTrace: $stackTrace');
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
