import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/settings/send_query_command_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/settings_repository.dart';

class SendQueryCommandUseCase {
  final SettingsRepository _repository;

  const SendQueryCommandUseCase(this._repository);

  Future<Either<Failure, SendQueryCommandEntity>> call({
    required String deviceId,
  }) => _repository.sendQueryCommand(deviceId: deviceId);
}
