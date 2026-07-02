import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:synquerra/data/datasources/remote/link_device_remote_datasource.dart';
import 'package:synquerra/domain/repositories/link_device_repository.dart';

import '../../core/error/app_exceptions.dart';
import '../../domain/failures/failure.dart';
import '../mappers/failure_mapper.dart';

class LinkDeviceRepositoryImpl implements LinkDeviceRepository {
  final LinkDeviceRemoteDataSource _remote;
  LinkDeviceRepositoryImpl({required LinkDeviceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, void>> linkDevice({
    required String ownerId,
    required String ownerType,
    required String deviceSerialNo,
  }) async {
    try {
      await _remote.linkDevice(
        ownerId: ownerId,
        ownerType: ownerType,
        deviceSerialNo: deviceSerialNo,
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
