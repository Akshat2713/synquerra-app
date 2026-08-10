import '../../repositories/device_repository.dart';

class InvalidateDeviceCacheUseCase {
  final DeviceRepository _repository;
  InvalidateDeviceCacheUseCase(this._repository);
  void call() => _repository.invalidateCache();
}
