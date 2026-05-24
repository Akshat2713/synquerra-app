import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/app_exceptions.dart';
// import '../../core/error/failure_mapper.dart';
import '../../domain/entities/analytics/analytics_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/remote/analytics_remote_datasource.dart';
import '../mappers/faulure_mapper.dart';

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
  }) async {
    try {
      final models = await _remote.getAnalytics(
        imei: imei,
        skip: skip,
        limit: limit,
        dataInterval: dataInterval,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
