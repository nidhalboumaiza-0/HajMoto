import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';

/// Base use case interface following Clean Architecture
/// Every use case must implement this contract
/// [Type] is the return type, [Params] is the input parameters type
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use when no parameters are needed
class NoParams {
  const NoParams();
}
