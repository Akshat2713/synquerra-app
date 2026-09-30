import 'package:dartz/dartz.dart';
import '../../entities/analytics/analytics_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/analytics_repository.dart';
import '../base_usecase.dart';

class LiveTelemetryParams {
  final String deviceId;

  const LiveTelemetryParams({required this.deviceId});
}

class GetLiveTelemetryUseCase
    implements UseCase<AnalyticsEntity, LiveTelemetryParams> {
  final AnalyticsRepository _repository;

  GetLiveTelemetryUseCase(this._repository);

  @override
  Future<Either<Failure, AnalyticsEntity>> call(LiveTelemetryParams params) {
    return _repository.getLiveTelemetry(deviceId: params.deviceId);
  }
}
