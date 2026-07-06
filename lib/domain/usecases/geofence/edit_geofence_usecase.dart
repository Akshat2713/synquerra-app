import 'package:dartz/dartz.dart';
import '../../entities/geofence/geofence_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';

class EditGeofenceUseCase {
  final GeofenceRepository _repository;
  const EditGeofenceUseCase(this._repository);

  Future<Either<Failure, GeofenceEntity>> call({
    required String deviceId,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
    required String geofenceId,
    required String geofenceNumber,
    required int entryAlertDelay,
    required int exitAlertDelay,
  }) => _repository.editGeofence(
    deviceId: deviceId,
    name: name,
    isActive: isActive,
    coordinates: coordinates,
    color: color,
    geofenceId: geofenceId,
    geofenceNumber: geofenceNumber,
    entryAlertDelay: entryAlertDelay,
    exitAlertDelay: exitAlertDelay,
  );
}
