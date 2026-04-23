// lib/data/repositories_impl/device_config_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../business/repositories/device_config_repository.dart';
import '../../business/failures/failure.dart';
import '../datasources/local/device_config_local_datasource.dart';
import '../mappers/device_config_mapper.dart';

class DeviceConfigRepositoryImpl implements DeviceConfigRepository {
  final DeviceConfigLocalDataSource _localDataSource;
  // final DeviceConfigMapper _mapper;

  DeviceConfigRepositoryImpl({
    required DeviceConfigLocalDataSource localDataSource,
    required DeviceConfigMapper mapper,
  }) : _localDataSource = localDataSource;
  //  _mapper = mapper;

  @override
  Future<Either<Failure, Map<String, String>>> getAllSettings() async {
    try {
      final settings = await _localDataSource.getAllIntervals();
      return Right(settings);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveSetting(String key, String value) async {
    try {
      await _localDataSource.saveInterval(key, value);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to save setting: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> getSetting(String key) async {
    try {
      final value = await _localDataSource.getSetting(key);
      return Right(value);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get setting: ${e.toString()}'),
      );
    }
  }
}
