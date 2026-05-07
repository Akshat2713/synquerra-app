import 'package:dartz/dartz.dart';
import '../../entities/analytics/analytics_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/analytics_repository.dart';
import '../base_usecase.dart';

class AnalyticsParams {
  final String imei;
  final int? skip;
  final int? limit;
  final String? startDate;
  final String? endDate;

  const AnalyticsParams({
    required this.imei,
    this.skip,
    this.limit,
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
      imei: params.imei,
      skip: params.skip,
      limit: params.limit,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
