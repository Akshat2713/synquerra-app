import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/alerts/alert_error_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../datasources/remote/alerts_remote_datasource.dart';
import '../mappers/faulure_mapper.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource _remote;
  AlertsRepositoryImpl({required AlertsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> getAllAlerts() async {
    try {
      final models = await _remote.getAlerts(null);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> getDeviceAlerts(
    String imei,
  ) async {
    try {
      final models = await _remote.getAlerts(imei);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
