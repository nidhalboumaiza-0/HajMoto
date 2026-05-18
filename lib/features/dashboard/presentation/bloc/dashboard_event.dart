import 'package:equatable/equatable.dart';

/// Dashboard BLoC Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load overall statistics for dashboard
class LoadDashboardEvent extends DashboardEvent {
  const LoadDashboardEvent();
}

/// Load daily statistics
class LoadDailyStatsEvent extends DashboardEvent {
  const LoadDailyStatsEvent();
}

/// Load monthly statistics (current month)
class LoadMonthlyStatsEvent extends DashboardEvent {
  const LoadMonthlyStatsEvent();
}

/// Load yearly statistics
class LoadYearlyStatsEvent extends DashboardEvent {
  const LoadYearlyStatsEvent();
}

/// Load statistics for custom date range
class LoadCustomRangeStatsEvent extends DashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadCustomRangeStatsEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load statistics for a specific month (e.g. January 2025)
class LoadStatsForMonthEvent extends DashboardEvent {
  final int year;
  final int month;

  const LoadStatsForMonthEvent({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

/// Load statistics for last N days (e.g. 7, 30, 90)
class LoadLastNDaysStatsEvent extends DashboardEvent {
  final int days;

  const LoadLastNDaysStatsEvent(this.days);

  @override
  List<Object?> get props => [days];
}
