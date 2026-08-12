import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

abstract class DeviceAssignmentRepository {
  Future<Either<Failure, void>> assignDevice({
    required String personId,
    required String deviceId,
    required String associationType,
  });

  Future<Either<Failure, void>> unassignDevice({
    required String deviceId,
    required String associationType,
  });
}
