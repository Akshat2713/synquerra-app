import 'package:dartz/dartz.dart';
import '../entities/alerts/alert_error_entity.dart';
import '../failures/failure.dart';

abstract class AlertsRepository {
  Future<Either<Failure, List<AlertErrorEntity>>> getAllAlerts();
  Future<Either<Failure, List<AlertErrorEntity>>> getDeviceAlerts(String imei);
}
