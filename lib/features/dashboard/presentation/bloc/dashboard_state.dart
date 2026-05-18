import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Dashboard BLoC States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {
  const DashboardInitialState();
}

class DashboardLoadingState extends DashboardState {
  const DashboardLoadingState();
}

class DashboardLoadedState extends DashboardState {
  final StatisticsEntity statistics;
  final String period; // 'overall', 'daily', 'monthly', 'yearly', 'custom'

  const DashboardLoadedState({required this.statistics, required this.period});

  @override
  List<Object?> get props => [statistics, period];
}

class DashboardErrorState extends DashboardState {
  final String message;

  const DashboardErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
