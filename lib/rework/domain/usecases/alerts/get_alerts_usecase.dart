import 'package:dartz/dartz.dart';
import '../../entities/alerts/alert_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/alerts_repository.dart';
import '../base_usecase.dart';

class GetAlertsUseCase implements UseCase<List<AlertEntity>, NoParams> {
  final AlertsRepository _repository;
  GetAlertsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AlertEntity>>> call(NoParams params) =>
      _repository.getAlerts();
}
