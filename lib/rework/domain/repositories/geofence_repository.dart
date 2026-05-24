import 'package:dartz/dartz.dart';
// import '../entities/geofence/geofence_entity.dart';
import '../entities/geofence/geofence_entity.dart';
import '../failures/failure.dart';

abstract class GeofenceRepository {
  Future<Either<Failure, List<GeofenceEntity>>> getDeviceGeofences(String imei);
}
