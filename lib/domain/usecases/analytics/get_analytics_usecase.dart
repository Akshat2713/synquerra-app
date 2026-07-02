import 'package:dartz/dartz.dart';
import '../../entities/analytics/analytics_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/analytics_repository.dart';
import '../base_usecase.dart';

class AnalyticsParams {
  final String deviceId;
  final int? skip;
  final int? limit;
  final int? dataInterval;
  final String? startDate;
  final String? endDate;

  const AnalyticsParams({
    required this.deviceId,
    this.skip,
    this.limit,
    this.dataInterval,
    this.startDate,
    this.endDate,
  });
}

class GetAnalyticsUseCase
    implements UseCase<List<AnalyticsEntity>, AnalyticsParams> {
  final AnalyticsRepository _repository;

  GetAnalyticsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AnalyticsEntity>>> call(AnalyticsParams params) {
    return _repository.getAnalytics(
      deviceId: params.deviceId,
      skip: params.skip,
      limit: params.limit,
      dataInterval: params.dataInterval,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
