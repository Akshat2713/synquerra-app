import 'package:dartz/dartz.dart';
import '../../domain/entities/device/device_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/remote/device_remote_datasource.dart';
import 'repository_helper.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remote;
  final Map<String, List<DeviceEntity>> _cache = {};

  DeviceRepositoryImpl({required DeviceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDeviceList(
    String personId,
  ) async {
    if (_cache.containsKey(personId)) return Right(_cache[personId]!);
    final result = await safeListCall(
      call: () => _remote.getDeviceList(personId),
      toEntity: (m) => m.toEntity(),
    );
    result.fold((_) {}, (devices) => _cache[personId] = devices);
    return result;
  }

  @override
  void invalidateCache() => _cache.clear();
}
