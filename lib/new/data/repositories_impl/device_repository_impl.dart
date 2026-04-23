// lib/data/repositories_impl/device_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../business/repositories/device_repository.dart';
import '../../business/entities/analytics_entity.dart';
import '../../business/failures/failure.dart';
import '../datasources/remote/device_remote_datasource.dart';
import '../mappers/analytics_mapper.dart';
import '../network/error_handler.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remoteDataSource;
  final AnalyticsMapper _mapper;

  DeviceRepositoryImpl({
    required DeviceRemoteDataSource remoteDataSource,
    required AnalyticsMapper mapper,
  }) : _remoteDataSource = remoteDataSource,
       _mapper = mapper;

  @override
  Future<Either<Failure, List<AnalyticsDataEntity>>> getAnalyticsByImei(
    String imei,
  ) async {
    try {
      final models = await _remoteDataSource.getAnalyticsByImei(imei);
      final entities = models.map((model) => _mapper.toEntity(model)).toList();
      return Right(entities);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnalyticsDistanceEntity>>> getDistance24(
    String imei,
  ) async {
    try {
      final models = await _remoteDataSource.getDistance24(imei);
      final entities = models
          .map((model) => _mapper.distanceToEntity(model))
          .toList();
      return Right(entities);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsHealthEntity?>> getHealth(String imei) async {
    try {
      final model = await _remoteDataSource.getHealth(imei);
      if (model == null) return const Right(null);
      return Right(_mapper.healthToEntity(model));
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsUptimeEntity?>> getUptime(String imei) async {
    try {
      final model = await _remoteDataSource.getUptime(imei);
      if (model == null) return const Right(null);
      return Right(_mapper.uptimeToEntity(model));
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDeviceImeis() async {
    try {
      final imeis = await _remoteDataSource.getDeviceImeis();
      return Right(imeis);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnalyticsDataEntity>>> refreshDevice(
    String imei,
  ) async {
    // Refresh is the same as getAnalyticsByImei with force flag
    // The remote datasource doesn't have a separate refresh endpoint
    return getAnalyticsByImei(imei);
  }
}
