import '../../entities/analytics/analytics_entity.dart';
import '../../repositories/analytics_repository.dart';

class SubscribeAnalyticsRealtimeUseCase {
  final AnalyticsRepository _repository;
  SubscribeAnalyticsRealtimeUseCase(this._repository);

  Stream<AnalyticsEntity> call(String imei) =>
      _repository.subscribeToTelemetry(imei);

  Stream<String> get errors => _repository.telemetryErrors;

  Future<void> stop() => _repository.unsubscribeFromTelemetry();
}
