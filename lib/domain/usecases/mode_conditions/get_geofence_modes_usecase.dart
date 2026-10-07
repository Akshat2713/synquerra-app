import 'package:dartz/dartz.dart';
import '../../entities/geofence_mode/geofence_mode_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/mode_conditions_repository.dart';
import '../base_usecase.dart';

class GetGeofenceModesParams {
  final String category;
  final bool isActive;

  const GetGeofenceModesParams({
    this.category = 'geofence',
    this.isActive = true,
  });
}

class GetGeofenceModesUseCase
    implements UseCase<List<GeofenceModeEntity>, GetGeofenceModesParams> {
  final ModeConditionsRepository _repository;
  GetGeofenceModesUseCase(this._repository);

  @override
  Future<Either<Failure, List<GeofenceModeEntity>>> call(
    GetGeofenceModesParams params,
  ) => _repository.getModes(
    category: params.category,
    isActive: params.isActive,
  );
}
