import 'package:dartz/dartz.dart';
import '../../entities/settings/settings_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/settings_repository.dart';

class UpdatePhoneNumbersUseCase {
  final SettingsRepository _repository;

  const UpdatePhoneNumbersUseCase(this._repository);

  Future<Either<Failure, SettingsEntity>> call({
    required String deviceId,
    String? phoneNum1,
    String? phoneNum2,
    String? controlRoomNum,
  }) => _repository.updatePhoneNumbers(
    deviceId: deviceId,
    phoneNum1: phoneNum1,
    phoneNum2: phoneNum2,
    controlRoomNum: controlRoomNum,
  );
}
