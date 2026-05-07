import 'package:dartz/dartz.dart';
import '../entities/analytics/analytics_entity.dart';
import '../failures/failure.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, List<AnalyticsEntity>>> getAnalytics({
    required String imei,
    int? skip,
    int? limit,
    String? startDate,
    String? endDate,
  });
}
