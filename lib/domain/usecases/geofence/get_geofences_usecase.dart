import 'package:dartz/dartz.dart';
// import '../../entities/geofence/geofence_entity.dart';
import '../../entities/geofence/geofence_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/geofence_repository.dart';
import '../base_usecase.dart';

class GetGeofencesUseCase implements UseCase<List<GeofenceEntity>, String> {
  final GeofenceRepository _repository;

  GetGeofencesUseCase(this._repository);

  @override
  Future<Either<Failure, List<GeofenceEntity>>> call(String imei) =>
      _repository.getDeviceGeofences(imei);
}
