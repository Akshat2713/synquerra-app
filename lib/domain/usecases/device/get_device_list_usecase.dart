import 'package:dartz/dartz.dart';
import '../../entities/device/device_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/device_repository.dart';
import '../base_usecase.dart';

class GetDeviceListUseCase implements UseCase<List<DeviceEntity>, NoParams> {
  final DeviceRepository _repository;
  GetDeviceListUseCase(this._repository);

  @override
  Future<Either<Failure, List<DeviceEntity>>> call(NoParams params) =>
      _repository.getDeviceList();
}
