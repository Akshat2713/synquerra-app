import 'package:dartz/dartz.dart';
import '../../entities/geofence/geofence_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';

class CreateGeofenceUseCase {
  final GeofenceRepository _repository;
  const CreateGeofenceUseCase(this._repository);

  Future<Either<Failure, GeofenceEntity>> call({
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
  }) => _repository.createGeofence(
    deviceId: deviceId,
    name: name,
    isActive: isActive,
    coordinates: coordinates,
    color: color,
    locality: locality,
    block: block,
    district: district,
    state: state,
    postcode: postcode,
    country: country,
    landmark: landmark,
    address: address,
  );
}
