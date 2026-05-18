import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/revenue_trend_chart.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/monthly_revenue_chart.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/category_chart.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/best_sellers_table.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/period_selector.dart';

/// Dashboard Page - Main overview page
/// Shows KPIs with growth, revenue trends, monthly bars, category breakdown, best sellers
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = 'overall';
  int? _selectedMonth;
  int? _selectedYear;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardEvent());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _onEventSelected(DashboardEvent event) {
    context.read<DashboardBloc>().add(event);
    setState(() {
      _selectedMonth = null;
      _selectedYear = null;
      if (event is LoadDashboardEvent) {
        _selectedPeriod = 'overall';
      } else if (event is LoadDailyStatsEvent) {
        _selectedPeriod = 'daily';
      } else if (event is LoadMonthlyStatsEvent) {
        _selectedPeriod = 'monthly';
      } else if (event is LoadYearlyStatsEvent) {
        _selectedPeriod = 'yearly';
      } else if (event is LoadLastNDaysStatsEvent) {
        _selectedPeriod = 'Last ${event.days} days';
      } else if (event is LoadStatsForMonthEvent) {
        _selectedMonth = event.month;
        _selectedYear = event.year;
        _selectedPeriod = 'month_pick';
      }
    });
  }

  void _selectCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null && mounted) {
      setState(() {
        _selectedPeriod = 'custom';
        _selectedMonth = null;
        _selectedYear = null;
      });
      context.read<DashboardBloc>().add(
            LoadCustomRangeStatsEvent(startDate: range.start, endDate: range.end),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: AppPageHeader(
                    title: 'Tableau de Bord',
                    subtitle: 'Aperçu des performances de votre boutique',
                  ),
                ),
                // Live clock
                _buildClock(),
              ],
            ),
            SizedBox(height: 16.h),

            // Period Controls Row
            Row(
              children: [
                Expanded(
                  child: PeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    selectedMonth: _selectedMonth,
                    selectedYear: _selectedYear,
                    onEventSelected: _onEventSelected,
                  ),
                ),
                SizedBox(width: 12.w),
                // Custom date range button
                OutlinedButton.icon(
                  onPressed: _selectCustomRange,
                  icon: Icon(Icons.date_range_rounded, size: 16.sp),
                  label: Text(
                    'Période Personnalisée',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    side: BorderSide(
                      color: _selectedPeriod == 'custom'
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Main Content
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoadingState) {
                    return const DashboardShimmer();
                  }
                  if (state is DashboardErrorState) {
                    return AppErrorState(
                      message: state.message,
                      onRetry: () => _onEventSelected(const LoadDashboardEvent()),
                    );
                  }
                  if (state is DashboardLoadedState) {
                    return _buildDashboardContent(state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClock() {
    const dayNames = [
      'Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
    ];
    const monthNames = [
      '', 'Janvier', 'F\u00e9vrier', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Ao\u00fbt', 'Septembre', 'Octobre', 'Novembre', 'D\u00e9cembre'
    ];
    final day = dayNames[_now.weekday % 7];
    final date = '${_now.day} ${monthNames[_now.month]} ${_now.year}';
    final time = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.access_time_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '$day, $date',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardLoadedState state) {
    final stats = state.statistics;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── KPI Cards with Growth Indicators (staggered fade-slide) ──────
          Row(
            children: [
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(0),
                  offset: const Offset(0, 40),
                  child: StatCard(
                    title: 'Chiffre d\'Affaires',
                    value: appCurrencyFormat.format(stats.totalRevenue),
                    icon: Icons.attach_money_rounded,
                    color: AppTheme.successColor,
                    growthPercent: stats.revenueGrowthPercent,
                    subtitle: 'vs période précédente',
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(1),
                  offset: const Offset(0, 40),
                  child: StatCard(
                    title: 'Bénéfice Net',
                    value: appCurrencyFormat.format(stats.netProfit),
                    icon: Icons.trending_up_rounded,
                    color: AppTheme.secondaryColor,
                    growthPercent: stats.profitGrowthPercent,
                    subtitle: '${stats.profitMarginPercent.toStringAsFixed(1)}% marge',
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(2),
                  offset: const Offset(0, 40),
                  child: StatCard(
                    title: 'Total Ventes',
                    value: stats.totalSales.toString(),
                    icon: Icons.receipt_rounded,
                    color: AppTheme.accentColor,
                    growthPercent: stats.salesGrowthPercent,
                    subtitle: 'Moy : ${appCurrencyFormat.format(stats.averageOrderValue)}',
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(3),
                  offset: const Offset(0, 40),
                  child: StatCard(
                    title: 'Stock Faible',
                    value: stats.lowStockCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.warningColor,
                    subtitle: '${stats.outOfStockCount} en rupture',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ─── Revenue Trend Area Chart (fade in after cards) ────────
          AnimatedFadeSlide(
            delay: staggerDelay(4),
            duration: const Duration(milliseconds: 700),
            child: RevenueTrendChart(
              salesData: stats.salesOverTime,
              profitData: stats.profitOverTime,
            ),
          ),
          SizedBox(height: 20.h),

          // ─── Monthly Revenue + Category Breakdown Row ──────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AnimatedFadeSlide(
                  delay: staggerDelay(5),
                  duration: const Duration(milliseconds: 700),
                  child: MonthlyRevenueChart(data: stats.monthlySalesData),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: AnimatedFadeSlide(
                  delay: staggerDelay(6),
                  duration: const Duration(milliseconds: 700),
                  child: CategoryBreakdownChart(data: stats.salesByCategory),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ─── Best Sellers Table ────────────────────────────
          AnimatedFadeSlide(
            delay: staggerDelay(7),
            duration: const Duration(milliseconds: 700),
            child: BestSellersTable(bestSellers: stats.bestSellingProducts),
          ),
        ],
      ),
    );
  }
}
