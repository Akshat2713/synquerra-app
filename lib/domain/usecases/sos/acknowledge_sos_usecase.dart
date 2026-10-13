import 'package:dartz/dartz.dart';

import '../../failures/failure.dart';
import '../../repositories/sos_repository.dart';

class AcknowledgeSosUseCase {
  final SosRepository _repository;
  const AcknowledgeSosUseCase(this._repository);

  Future<Either<Failure, Unit>> call({required String alertId}) =>
      _repository.acknowledgeSos(alertId: alertId);
}
