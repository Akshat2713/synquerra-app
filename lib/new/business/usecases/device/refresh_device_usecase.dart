// lib/business/usecases/device/refresh_device_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/device_repository.dart';
import '../../entities/analytics_entity.dart';
import '../../failures/failure.dart';

class RefreshDeviceUseCase {
  final DeviceRepository _repository;

  RefreshDeviceUseCase(this._repository);

  Future<Either<Failure, List<AnalyticsDataEntity>>> call(String imei) async {
    if (imei.isEmpty) {
      return Left(ValidationFailure(message: 'IMEI cannot be empty'));
    }

    return await _repository.refreshDevice(imei);
  }
}

class RefreshDeviceWithRetryUseCase {
  final DeviceRepository _repository;

  RefreshDeviceWithRetryUseCase(this._repository);

  Future<Either<Failure, List<AnalyticsDataEntity>>> call(
    String imei, {
    int maxAttempts = 5,
    Duration baseDelay = const Duration(seconds: 2),
  }) async {
    if (imei.isEmpty) {
      return Left(ValidationFailure(message: 'IMEI cannot be empty'));
    }

    int attempts = 0;
    List<AnalyticsDataEntity>? lastResult;

    while (attempts < maxAttempts) {
      final result = await _repository.refreshDevice(imei);

      if (result.isRight()) {
        final newData = result.getOrElse(() => []);

        // Check if we got new data
        if (lastResult != null && newData.length > lastResult!.length) {
          return Right(newData);
        }

        lastResult = newData;
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(baseDelay * attempts);
      }
    }

    return lastResult != null
        ? Right(lastResult!)
        : Left(
            ServerFailure(
              message: 'Device did not respond after $maxAttempts attempts',
            ),
          );
  }
}
