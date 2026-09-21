import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class SyncFcmTokenUseCase implements UseCase<void, String> {
  final AuthRepository _repository;
  SyncFcmTokenUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String fcmToken) =>
      _repository.syncFcmToken(fcmToken);
}
