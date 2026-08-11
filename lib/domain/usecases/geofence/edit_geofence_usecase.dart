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
    String? locality,
    String? block,
    String? district,
    String? state,
    String? postcode,
    String? country,
    String? landmark,
    String? address,
  }) => _repository.editGeofence(
    deviceId: deviceId,
    name: name,
    isActive: isActive,
    coordinates: coordinates,
    color: color,
    geofenceId: geofenceId,
    geofenceNumber: geofenceNumber,
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
