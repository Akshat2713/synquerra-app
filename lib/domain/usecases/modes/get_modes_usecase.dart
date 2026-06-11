// domain/usecases/mode/get_modes_usecase.dart
import 'package:dartz/dartz.dart';

import '../../entities/modes/mode_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/mode_repository.dart';

class GetModesUseCase {
  final ModeRepository _repository;
  const GetModesUseCase(this._repository);

  Future<Either<Failure, List<ModeEntity>>> call() => _repository.getModes();
}
