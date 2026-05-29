import 'package:dartz/dartz.dart';
import '../../domain/entities/alerts/alert_error_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/alerts_errors_repository.dart';
import '../datasources/remote/alerts_errors_remote_datasource.dart';
import 'repository_helper.dart';

class AlertsErrorsRepositoryImpl implements AlertsErrorsRepository {
  final AlertErrorsRemoteDataSource _remote;

  AlertsErrorsRepositoryImpl({required AlertErrorsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> getDeviceAlertsErrors(
    String imei,
  ) => safeListCall(
    call: () => _remote.getAlertsErrors(imei),
    toEntity: (m) => m.toEntity(),
  );
}
