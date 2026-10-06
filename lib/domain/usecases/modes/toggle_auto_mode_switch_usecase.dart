// domain/usecases/mode/toggle_auto_mode_switch_usecase.dart
// params: ToggleAutoModeSwitchParams { deviceId }
import 'package:dartz/dartz.dart';

import '../../failures/failure.dart';
import '../../repositories/mode_repository.dart';

class ToggleAutoModeSwitchUseCase {
  final ModeRepository _repository;
  const ToggleAutoModeSwitchUseCase(this._repository);

  Future<Either<Failure, Unit>> call({required String deviceId}) =>
      _repository.toggleAutoModeSwitch(deviceId: deviceId);
}
