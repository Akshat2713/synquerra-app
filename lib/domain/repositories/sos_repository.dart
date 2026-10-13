// domain/repositories/sos_repository.dart
import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

abstract class SosRepository {
  Future<Either<Failure, Unit>> acknowledgeSos({required String alertId});
  Future<Either<Failure, Unit>> stopSos({required String deviceId});
}
