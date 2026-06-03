import 'package:dartz/dartz.dart';
import '../entities/alerts/alert_error_entity.dart';
import '../failures/failure.dart';

abstract class AlertsErrorsRepository {
  Future<Either<Failure, List<AlertErrorEntity>>> getDeviceAlertsErrors(
    String imei,
  );
}
