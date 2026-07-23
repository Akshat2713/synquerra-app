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
    String deviceId,
  ) => safeListCall(
    call: () => _remote.getGeofences(deviceId),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, GeofenceEntity>> createGeofence({
    required String deviceId,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
  }) => safeCall(
    call: () => _remote.createGeofence(
      deviceId: deviceId,
      name: name,
      isActive: isActive,
      coordinates: coordinates,
      color: color,
    ),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, GeofenceEntity>> editGeofence({
    required String deviceId,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
    required String geofenceNumber,
    required int entryAlertDelay,
    required int exitAlertDelay,
    required String geofenceId,
  }) => safeCall(
    call: () => _remote.editGeofence(
      deviceId: deviceId,
      name: name,
      isActive: isActive,
      coordinates: coordinates,
      color: color,
      geofenceNumber: geofenceNumber,
      entryAlertDelay: entryAlertDelay,
      exitAlertDelay: exitAlertDelay,
      geofenceId: geofenceId,
    ),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, Unit>> deleteGeofence({
    required String deviceId,
    required String geofenceId,
  }) => safeCall(
    call: () =>
        _remote.deleteGeofence(deviceId: deviceId, geofenceId: geofenceId),
    toEntity: (_) => unit,
  );
}
