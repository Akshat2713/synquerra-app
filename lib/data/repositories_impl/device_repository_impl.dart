import 'package:dartz/dartz.dart';
import '../../domain/entities/device/device_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/remote/device_remote_datasource.dart';
import 'repository_helper.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remote;
  List<DeviceEntity>? _cache;

  DeviceRepositoryImpl({required DeviceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDeviceList() async {
    if (_cache != null) return Right(_cache!);
    final result = await safeListCall(
      call: _remote.getDeviceList,
      toEntity: (m) => m.toEntity(),
    );
    result.fold((_) {}, (devices) => _cache = devices);
    return result;
  }

  void invalidateCache() => _cache = null;
}
