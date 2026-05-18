import 'package:equatable/equatable.dart';

/// Base failure class for error handling
/// Uses Equatable for value comparison in testing
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server-side failures (Supabase errors)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Local cache failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Validation failures (form input, business rules)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Stock-related failures
class StockFailure extends Failure {
  const StockFailure({required super.message});
}

/// CSV Import failures
class ImportFailure extends Failure {
  const ImportFailure({required super.message});
}

/// Generic unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}
