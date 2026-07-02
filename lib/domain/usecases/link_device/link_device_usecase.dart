import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/repositories/link_device_repository.dart';
import '../../failures/failure.dart';
import '../base_usecase.dart';

class LinkDeviceParams {
  final String ownerId;
  final String ownerType;
  final String deviceSerialNo;

  const LinkDeviceParams({
    required this.ownerId,
    required this.ownerType,
    required this.deviceSerialNo,
  });
}

class LinkDeviceUseCase implements UseCase<void, LinkDeviceParams> {
  final LinkDeviceRepository _repository;

  LinkDeviceUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(LinkDeviceParams params) {
    return _repository.linkDevice(
      ownerId: params.ownerId,
      ownerType: params.ownerType,
      deviceSerialNo: params.deviceSerialNo,
    );
  }
}
