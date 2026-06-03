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

  @override
  Future<Either<Failure, GeofenceEntity>> createGeofence({
    required String imei,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
  }) => safeCall(
    call: () => _remote.createGeofence(
      imei: imei,
      name: name,
      isActive: isActive,
      coordinates: coordinates,
    ),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, Unit>> deleteGeofence({
    required String imei,
    required String geofenceId,
  }) => safeCall(
    call: () => _remote.deleteGeofence(imei: imei, geofenceId: geofenceId),
    toEntity: (_) => unit,
  );
}
