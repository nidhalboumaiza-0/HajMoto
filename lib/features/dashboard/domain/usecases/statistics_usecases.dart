import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';
import 'package:gestion_stock/features/dashboard/domain/repositories/statistics_repository.dart';

/// Get Overall Statistics Use Case
class GetOverallStatisticsUseCase {
  final StatisticsRepository repository;

  GetOverallStatisticsUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call() {
    return repository.getOverallStatistics();
  }
}

/// Get Daily Statistics Use Case
class GetDailyStatisticsUseCase {
  final StatisticsRepository repository;

  GetDailyStatisticsUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call() {
    return repository.getDailyStatistics();
  }
}

/// Get Monthly Statistics Use Case
class GetMonthlyStatisticsUseCase {
  final StatisticsRepository repository;

  GetMonthlyStatisticsUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call() {
    return repository.getMonthlyStatistics();
  }
}

/// Get Yearly Statistics Use Case
class GetYearlyStatisticsUseCase {
  final StatisticsRepository repository;

  GetYearlyStatisticsUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call() {
    return repository.getYearlyStatistics();
  }
}

/// Get Statistics By Date Range Use Case
class GetStatisticsByDateRangeUseCase {
  final StatisticsRepository repository;

  GetStatisticsByDateRangeUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getStatisticsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Get Statistics for a Specific Month Use Case
class GetStatsForMonthUseCase {
  final StatisticsRepository repository;

  GetStatsForMonthUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call({
    required int year,
    required int month,
  }) {
    return repository.getStatisticsForMonth(year: year, month: month);
  }
}

/// Get Statistics for Last N Days Use Case
class GetStatsForLastNDaysUseCase {
  final StatisticsRepository repository;

  GetStatsForLastNDaysUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call(int days) {
    return repository.getStatsForLastNDays(days);
  }
}
