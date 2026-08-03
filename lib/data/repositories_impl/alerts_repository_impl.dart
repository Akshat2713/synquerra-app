import 'package:dartz/dartz.dart';
import '../../domain/entities/alerts/alert_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/remote/alerts_remote_datasource.dart';
import 'repository_helper.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource _remote;
  AlertsRepositoryImpl({required AlertsRemoteDataSource remote})
    : _remote = remote;
  @override
  Future<Either<Failure, List<AlertEntity>>> getAllAlerts(
    String personId, {
    int hours = 24,
  }) => safeListCall(
    call: () => _remote.getAllAlerts(personId, hours: hours),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlerts(String imei) =>
      safeListCall(
        call: () => _remote.getAlerts(imei),
        toEntity: (m) => m.toEntity(),
      );
}
