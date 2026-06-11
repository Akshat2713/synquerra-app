import 'package:dartz/dartz.dart';
import '../entities/device/device_entity.dart';
import '../failures/failure.dart';

abstract class DeviceRepository {
  Future<Either<Failure, List<DeviceEntity>>> getDeviceList();
}
