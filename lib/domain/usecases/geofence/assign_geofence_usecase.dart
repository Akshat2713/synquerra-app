import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';

class AssignGeofenceUseCase {
  final GeofenceRepository _repository;
  const AssignGeofenceUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String geofenceId,
    required String geofenceNumber,
  }) => _repository.assignGeofence(
    geofenceId: geofenceId,
    geofenceNumber: geofenceNumber,
  );
}
