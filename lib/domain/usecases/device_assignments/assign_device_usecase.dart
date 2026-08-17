import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/device_assignment_repository.dart';

class AssignDeviceUseCase {
  final DeviceAssignmentRepository _repository;

  AssignDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String personId,
    required String deviceId,
    required String associationType,
  }) {
    return _repository.assignDevice(
      personId: personId,
      deviceId: deviceId,
      associationType: associationType,
    );
  }
}
