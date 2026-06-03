import 'package:dartz/dartz.dart';
import '../../entities/alerts/alert_error_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/alerts_errors_repository.dart';
import '../base_usecase.dart';

class GetAlertsErrorsUseCase
    implements UseCase<List<AlertErrorEntity>, String> {
  final AlertsErrorsRepository _repository;
  GetAlertsErrorsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> call(String imei) =>
      _repository.getDeviceAlertsErrors(imei);
}
