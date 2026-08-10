import 'package:dartz/dartz.dart';
import '../../entities/settings/settings_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  const GetSettingsUseCase(this._repository);

  Future<Either<Failure, SettingsEntity>> call(String deviceId) =>
      _repository.getSettings(deviceId: deviceId);
}
