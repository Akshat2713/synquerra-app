import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/device_assignment_repository.dart';

class UnassignDeviceUseCase {
  final DeviceAssignmentRepository _repository;

  UnassignDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String deviceId,
    required String associationType,
  }) {
    return _repository.unassignDevice(
      deviceId: deviceId,
      associationType: associationType,
    );
  }
}
