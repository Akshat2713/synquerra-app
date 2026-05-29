import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/app_exceptions.dart';
import '../../domain/failures/failure.dart';
import '../mappers/failure_mapper.dart';

/// Wraps any remote call that returns a list of models, maps them to
/// entities, and converts exceptions to Failure — one place, not four.
Future<Either<Failure, List<E>>> safeListCall<M, E>({
  required Future<List<M>> Function() call,
  required E Function(M) toEntity,
}) async {
  try {
    final models = await call();
    return Right(models.map(toEntity).toList());
  } catch (e) {
    final cause = (e is DioException && e.error is AppException)
        ? e.error as AppException
        : e;
    return Left(mapExceptionToFailure(cause));
  }
}

Future<Either<Failure, E>> safeCall<M, E>({
  required Future<M> Function() call,
  required E Function(M) toEntity,
}) async {
  try {
    final model = await call();
    return Right(toEntity(model));
  } catch (e) {
    final cause = (e is DioException && e.error is AppException)
        ? e.error as AppException
        : e;
    return Left(mapExceptionToFailure(cause));
  }
}
