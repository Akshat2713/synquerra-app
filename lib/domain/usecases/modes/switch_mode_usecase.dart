// domain/usecases/mode/switch_mode_usecase.dart
// params: SwitchModeParams { deviceId, modeId }
import 'package:dartz/dartz.dart';

import '../../failures/failure.dart';
import '../../repositories/mode_repository.dart';

class SwitchModeUseCase {
  final ModeRepository _repository;
  const SwitchModeUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String deviceId,
    required String modeId,
  }) => _repository.switchMode(deviceId: deviceId, modeId: modeId);
}
