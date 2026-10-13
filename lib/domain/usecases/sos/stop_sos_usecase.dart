// domain/usecases/sos/stop_sos_usecase.dart
import 'package:dartz/dartz.dart';

import '../../failures/failure.dart';
import '../../repositories/sos_repository.dart';

class StopSosUseCase {
  final SosRepository _repository;
  const StopSosUseCase(this._repository);

  Future<Either<Failure, Unit>> call({required String deviceId}) =>
      _repository.stopSos(deviceId: deviceId);
}
