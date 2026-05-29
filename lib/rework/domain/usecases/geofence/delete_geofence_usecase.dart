import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';

class DeleteGeofenceUseCase {
  final GeofenceRepository _repository;
  const DeleteGeofenceUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String imei,
    required String geofenceId,
  }) => _repository.deleteGeofence(imei: imei, geofenceId: geofenceId);
}
