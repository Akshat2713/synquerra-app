import 'package:dartz/dartz.dart';

import '../../domain/failures/failure.dart';
import '../../domain/repositories/sos_repository.dart';
import '../datasources/remote/sos_remote_datasource.dart';
import 'repository_helper.dart';

class SosRepositoryImpl implements SosRepository {
  final SosRemoteDataSource _remote;

  SosRepositoryImpl({required SosRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, Unit>> acknowledgeSos({required String alertId}) =>
      safeCall(
        call: () => _remote.acknowledgeSos(alertId: alertId),
        toEntity: (_) => unit,
      );

  @override
  Future<Either<Failure, Unit>> stopSos({required String deviceId}) => safeCall(
    call: () => _remote.stopSos(deviceId: deviceId),
    toEntity: (_) => unit,
  );
}
