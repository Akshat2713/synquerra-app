import 'package:dartz/dartz.dart';
import '../../entities/alerts/alert_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/alerts_repository.dart';
import '../base_usecase.dart';

class GetAlertsParams {
  final String personId;
  final int hours;
  const GetAlertsParams(this.personId, {this.hours = 24});
}

class GetAlertsUseCase implements UseCase<List<AlertEntity>, GetAlertsParams> {
  final AlertsRepository _repository;
  GetAlertsUseCase(this._repository);
  @override
  Future<Either<Failure, List<AlertEntity>>> call(GetAlertsParams params) =>
      _repository.getAllAlerts(params.personId, hours: params.hours);
}
