import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/geofence/geofence_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../../core/error/app_exceptions.dart';
// import '../../core/error/failure_mapper.dart';
import '../datasources/remote/geofence_remote_datasource.dart';
import '../mappers/faulure_mapper.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  final GeofenceRemoteDataSource _remote;
  GeofenceRepositoryImpl({required GeofenceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<GeofenceEntity>>> getDeviceGeofences(
    String imei,
  ) async {
    try {
      final models = await _remote.getGeofences(imei);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
