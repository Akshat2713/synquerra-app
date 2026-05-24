import 'package:dartz/dartz.dart';
import '../../domain/entities/geofence/geofence_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../datasources/remote/geofence_remote_datasource.dart';
import 'repository_helper.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  final GeofenceRemoteDataSource _remote;
  GeofenceRepositoryImpl({required GeofenceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<GeofenceEntity>>> getDeviceGeofences(
    String imei,
  ) => safeListCall(
    call: () => _remote.getGeofences(imei),
    toEntity: (m) => m.toEntity(),
  );
}
