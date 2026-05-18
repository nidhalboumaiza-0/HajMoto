import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_stock/features/dashboard/domain/usecases/statistics_usecases.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_state.dart';

/// Dashboard BLoC - Presentation Layer
/// Manages dashboard statistics, filters, and chart data
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetOverallStatisticsUseCase getOverallStatisticsUseCase;
  final GetDailyStatisticsUseCase getDailyStatisticsUseCase;
  final GetMonthlyStatisticsUseCase getMonthlyStatisticsUseCase;
  final GetYearlyStatisticsUseCase getYearlyStatisticsUseCase;
  final GetStatisticsByDateRangeUseCase getStatisticsByDateRangeUseCase;
  final GetStatsForMonthUseCase getStatsForMonthUseCase;
  final GetStatsForLastNDaysUseCase getStatsForLastNDaysUseCase;

  DashboardBloc({
    required this.getOverallStatisticsUseCase,
    required this.getDailyStatisticsUseCase,
    required this.getMonthlyStatisticsUseCase,
    required this.getYearlyStatisticsUseCase,
    required this.getStatisticsByDateRangeUseCase,
    required this.getStatsForMonthUseCase,
    required this.getStatsForLastNDaysUseCase,
  }) : super(const DashboardInitialState()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<LoadDailyStatsEvent>(_onLoadDaily);
    on<LoadMonthlyStatsEvent>(_onLoadMonthly);
    on<LoadYearlyStatsEvent>(_onLoadYearly);
    on<LoadCustomRangeStatsEvent>(_onLoadCustomRange);
    on<LoadStatsForMonthEvent>(_onLoadForMonth);
    on<LoadLastNDaysStatsEvent>(_onLoadLastNDays);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getOverallStatisticsUseCase();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(statistics: stats, period: 'overall')),
    );
  }

  Future<void> _onLoadDaily(
    LoadDailyStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getDailyStatisticsUseCase();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(statistics: stats, period: 'daily')),
    );
  }

  Future<void> _onLoadMonthly(
    LoadMonthlyStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getMonthlyStatisticsUseCase();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(statistics: stats, period: 'monthly')),
    );
  }

  Future<void> _onLoadYearly(
    LoadYearlyStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getYearlyStatisticsUseCase();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(statistics: stats, period: 'yearly')),
    );
  }

  Future<void> _onLoadCustomRange(
    LoadCustomRangeStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getStatisticsByDateRangeUseCase(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(statistics: stats, period: 'custom')),
    );
  }

  Future<void> _onLoadForMonth(
    LoadStatsForMonthEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getStatsForMonthUseCase(
      year: event.year,
      month: event.month,
    );
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final label = '${months[event.month - 1]} ${event.year}';
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(statistics: stats, period: label)),
    );
  }

  Future<void> _onLoadLastNDays(
    LoadLastNDaysStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await getStatsForLastNDaysUseCase(event.days);
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats) => emit(DashboardLoadedState(
        statistics: stats,
        period: 'Last ${event.days} days',
      )),
    );
  }
}
