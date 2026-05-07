import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

/// Every use case implements this.
/// [Type] is the return type on success.
/// [Params] is the input parameter object.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when a use case needs no parameters.
class NoParams {}
