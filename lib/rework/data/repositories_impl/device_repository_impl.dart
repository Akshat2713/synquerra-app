import 'package:dartz/dartz.dart';
import '../../domain/entities/device/device_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/device_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../datasources/remote/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remote;

  DeviceRepositoryImpl({required DeviceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDeviceList() async {
    try {
      final models = await _remote.getDeviceList();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
