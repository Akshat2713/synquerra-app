import 'package:dartz/dartz.dart';
import '../entities/geofence/geofence_entity.dart';
import '../failures/failure.dart';

abstract class GeofenceRepository {
  Future<Either<Failure, List<GeofenceEntity>>> getDeviceGeofences(String imei);

  Future<Either<Failure, GeofenceEntity>> createGeofence({
    required String imei,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
  });

  Future<Either<Failure, Unit>> deleteGeofence({
    required String imei,
    required String geofenceId,
  });
}
