// get_device_alerts_usecase.dart
import 'package:dartz/dartz.dart';
import '../../entities/alerts/alert_error_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/alerts_errors_repository.dart';
import '../base_usecase.dart';

class GetDeviceAlertsUseCase
    implements UseCase<List<AlertErrorEntity>, String> {
  final AlertsErrorsRepository _repository;

  GetDeviceAlertsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AlertErrorEntity>>> call(String deviceId) async {
    final result = await _repository.getDeviceAlertsErrors(deviceId);
    return result.map(
      (list) => list.where((e) => e.type == AlertErrorType.alert).toList(),
    );
  }
}
