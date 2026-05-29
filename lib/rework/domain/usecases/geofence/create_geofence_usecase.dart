import 'package:dartz/dartz.dart';
import '../../entities/geofence/geofence_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';

class CreateGeofenceUseCase {
  final GeofenceRepository _repository;
  const CreateGeofenceUseCase(this._repository);

  Future<Either<Failure, GeofenceEntity>> call({
    required String imei,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
  }) => _repository.createGeofence(
    imei: imei,
    name: name,
    isActive: isActive,
    coordinates: coordinates,
  );
}
