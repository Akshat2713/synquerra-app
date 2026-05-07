import 'package:dartz/dartz.dart';
import '../entities/alerts/alert_entity.dart';
import '../failures/failure.dart';

abstract class AlertsRepository {
  Future<Either<Failure, List<AlertEntity>>> getAlerts();
}
