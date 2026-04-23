// lib/business/usecases/device/get_device_telemetry_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/device_repository.dart';
import '../../entities/analytics_entity.dart';
import '../../failures/failure.dart';

class GetDeviceTelemetryUseCase {
  final DeviceRepository _repository;

  GetDeviceTelemetryUseCase(this._repository);

  Future<Either<Failure, List<AnalyticsDataEntity>>> call(String imei) async {
    if (imei.isEmpty) {
      return Left(ValidationFailure(message: 'IMEI cannot be empty'));
    }

    return await _repository.getAnalyticsByImei(imei);
  }
}
