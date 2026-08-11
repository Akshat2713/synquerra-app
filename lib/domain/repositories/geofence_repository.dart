import 'package:dartz/dartz.dart';
import '../entities/geofence/geofence_entity.dart';
import '../failures/failure.dart';

abstract class GeofenceRepository {
  Future<Either<Failure, List<GeofenceEntity>>> getDeviceGeofences(
    String deviceId,
  );

  Future<Either<Failure, GeofenceEntity>> createGeofence({
    required String deviceId,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
    String? locality,
    String? block,
    String? district,
    String? state,
    String? postcode,
    String? country,
    String? landmark,
    String? address,
  });

  Future<Either<Failure, GeofenceEntity>> editGeofence({
    required String deviceId,
    required String geofenceId,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
    required String geofenceNumber,
    String? locality,
    String? block,
    String? district,
    String? state,
    String? postcode,
    String? country,
    String? landmark,
    String? address,
  });

  Future<Either<Failure, Unit>> deleteGeofence({
    required String deviceId,
    required String geofenceId,
  });
}
