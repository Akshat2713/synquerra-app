import 'package:dartz/dartz.dart';

import '../../core/error/app_exceptions.dart';
import '../../domain/entities/analytics/analytics_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/remote/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;

  AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<AnalyticsEntity>>> getAnalytics({
    required String imei,
    int? skip,
    int? limit,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final models = await _remote.getAnalytics(
        imei: imei,
        skip: skip,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
