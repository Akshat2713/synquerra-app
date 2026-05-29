// data/repositories_impl/analytics_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/analytics/analytics_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/remote/analytics_remote_datasource.dart';
import 'repository_helper.dart'; // Added import for the shared helper

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;

  AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<AnalyticsEntity>>> getAnalytics({
    required String imei,
    int? skip,
    int? limit,
    int? dataInterval,
    String? startDate,
    String? endDate,
  }) {
    return safeListCall(
      call: () => _remote.getAnalytics(
        imei: imei,
        skip: skip,
        limit: limit,
        dataInterval: dataInterval,
        startDate: startDate,
        endDate: endDate,
      ),
      toEntity: (m) => m.toEntity(),
    );
  }
}
