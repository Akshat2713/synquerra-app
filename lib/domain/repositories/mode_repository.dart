// domain/repositories/mode_repository.dart
import 'package:dartz/dartz.dart';

import '../entities/modes/mode_entity.dart';
import '../failures/failure.dart';

abstract class ModeRepository {
  Future<Either<Failure, List<ModeEntity>>> getModes();
  Future<Either<Failure, Unit>> switchMode({
    required String imei,
    required String modeId,
  });
}
