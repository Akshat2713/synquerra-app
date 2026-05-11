import 'package:dartz/dartz.dart';
import '../../domain/entities/alerts/alert_error_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/alerts_errors_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../datasources/remote/alerts_errors_remote_datasource.dart';

class AlertsErrorsRepositoryImpl implements AlertsErrorsRepository {
  final AlertErrorsRemoteDataSource _remote;

  AlertsErrorsRepositoryImpl({required AlertErrorsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> getDeviceAlertsErrors(
    String imei,
  ) async {
    try {
      final models = await _remote.getAlertsErrors(imei);
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
