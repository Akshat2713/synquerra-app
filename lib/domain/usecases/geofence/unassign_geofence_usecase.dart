import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';

class UnassignGeofenceUseCase {
  final GeofenceRepository _repository;
  const UnassignGeofenceUseCase(this._repository);

  Future<Either<Failure, Unit>> call({required String geofenceNumber}) =>
      _repository.unassignGeofence(geofenceNumber: geofenceNumber);
}
