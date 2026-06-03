import 'package:dartz/dartz.dart';

import '../../domain/entities/modes/mode_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/mode_repository.dart';
import '../datasources/remote/mode_remote_datasource.dart';
import 'repository_helper.dart';

class ModeRepositoryImpl implements ModeRepository {
  final ModeRemoteDataSource _remote;
  ModeRepositoryImpl({required ModeRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, List<ModeEntity>>> getModes() => safeListCall(
    call: () => _remote.getModes(),
    toEntity: (m) => m.toEntity(),
  );

  @override
  Future<Either<Failure, Unit>> switchMode({
    required String imei,
    required String modeId,
  }) => safeCall(
    call: () => _remote.switchMode(imei: imei, modeId: modeId),
    toEntity: (_) => unit,
  );
}
