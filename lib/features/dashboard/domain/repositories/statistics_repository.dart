import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Statistics Repository Interface - Domain Layer
/// Provides aggregated business intelligence data
abstract class StatisticsRepository {
  /// Get overall statistics (all time)
  Future<Either<Failure, StatisticsEntity>> getOverallStatistics();

  /// Get statistics for a specific date range
  Future<Either<Failure, StatisticsEntity>> getStatisticsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get daily statistics for current day
  Future<Either<Failure, StatisticsEntity>> getDailyStatistics();

  /// Get monthly statistics for current month
  Future<Either<Failure, StatisticsEntity>> getMonthlyStatistics();

  /// Get yearly statistics for current year
  Future<Either<Failure, StatisticsEntity>> getYearlyStatistics();

  /// Get statistics for a specific month
  Future<Either<Failure, StatisticsEntity>> getStatisticsForMonth({
    required int year,
    required int month,
  });

  /// Get statistics for last N days
  Future<Either<Failure, StatisticsEntity>> getStatsForLastNDays(int days);
}
