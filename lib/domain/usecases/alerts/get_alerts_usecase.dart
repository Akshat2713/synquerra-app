import 'package:dartz/dartz.dart';
import '../../entities/alerts/alert_error_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/alerts_repository.dart';
import '../base_usecase.dart';

class GetAlertsUseCase implements UseCase<List<AlertErrorEntity>, NoParams> {
  final AlertsRepository _repository;
  GetAlertsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> call(NoParams params) =>
      _repository.getAllAlerts();
}
