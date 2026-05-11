import 'package:dartz/dartz.dart';
// import '../../domain/entities/alerts/alert_error_entity.dart';
import '../../domain/entities/alerts/alert_error_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../datasources/remote/alerts_remote_datasource.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource _remote;

  AlertsRepositoryImpl({required AlertsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> getAllAlerts() async {
    try {
      final models = await _remote.getAlerts(null);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> getDeviceAlerts(
    String imei,
  ) async {
    try {
      final models = await _remote.getAlerts(imei);
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
