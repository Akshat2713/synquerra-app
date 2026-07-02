import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

abstract class LinkDeviceRepository {
  Future<Either<Failure, void>> linkDevice({
    required String ownerId,
    required String ownerType,
    required String deviceSerialNo,
  });
}
