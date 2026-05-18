import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/daily_activity_chart.dart';
import 'package:gestion_stock/features/dashboard/presentation/widgets/profit_analysis_card.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Statistics Page - Detailed analytics and charts
/// Features: month navigation, advanced charts, category breakdown, daily activity
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  DateTimeRange? _customRange;
  bool _isMonthMode = true; // true = month mode, false = custom range mode

  static const _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void initState() {
    super.initState();
    _loadMonthStats();
  }

  void _loadMonthStats() {
    context.read<DashboardBloc>().add(
          LoadStatsForMonthEvent(year: _currentYear, month: _currentMonth),
        );
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth--;
      if (_currentMonth < 1) {
        _currentMonth = 12;
        _currentYear--;
      }
    });
    _loadMonthStats();
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    if (_currentYear == now.year && _currentMonth >= now.month) return;
    setState(() {
      _currentMonth++;
      if (_currentMonth > 12) {
        _currentMonth = 1;
        _currentYear++;
      }
    });
    _loadMonthStats();
  }

  void _selectCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (range != null && mounted) {
      setState(() {
        _customRange = range;
        _isMonthMode = false;
      });
      context.read<DashboardBloc>().add(
            LoadCustomRangeStatsEvent(startDate: range.start, endDate: range.end),
          );
    }
  }

  void _switchToMonthMode() {
    setState(() => _isMonthMode = true);
    _loadMonthStats();
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
            // Header
            AppPageHeader(
              title: 'Statistiques',
              subtitle: 'Analyses détaillées et indicateurs de performance',
            ),
            SizedBox(height: 16.h),

            // Month Navigation / Period Controls
            _buildPeriodControls(),
            SizedBox(height: 20.h),

            // Content
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoadingState) {
                    return const StatisticsShimmer();
                  }
                  if (state is DashboardErrorState) {
                    return AppErrorState(
                      message: state.message,
                      onRetry: _isMonthMode ? _loadMonthStats : () {},
                    );
                  }
                  if (state is DashboardLoadedState) {
                    return _buildStatisticsContent(state.statistics);
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

  Widget _buildPeriodControls() {
    final now = DateTime.now();
    final isCurrentMonth = _currentYear == now.year && _currentMonth == now.month;

    return Row(
      children: [
        // Month Navigation
        if (_isMonthMode) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _navButton(Icons.chevron_left_rounded, _goToPreviousMonth),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Text(
                    '${_monthNames[_currentMonth - 1]} $_currentYear',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                _navButton(
                  Icons.chevron_right_rounded,
                  isCurrentMonth ? null : _goToNextMonth,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Quick month jumps
          _buildQuickMonthChips(),
        ] else ...[
          // Custom range display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded, size: 18.sp, color: AppTheme.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  _customRange != null
                      ? '${DateFormat('dd MMM yyyy').format(_customRange!.start)} – ${DateFormat('dd MMM yyyy').format(_customRange!.end)}'
                      : 'Période Personnalisée',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          TextButton.icon(
            onPressed: _switchToMonthMode,
            icon: Icon(Icons.calendar_month_rounded, size: 16.sp),
            label: const Text('Retour vue mensuelle'),
          ),
        ],

        const Spacer(),

        // Custom range button
        OutlinedButton.icon(
          onPressed: _selectCustomRange,
          icon: Icon(Icons.date_range_rounded, size: 16.sp),
          label: Text(
            'Période Personnalisée',
            style: TextStyle(fontSize: 12.sp),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            icon,
            size: 22.sp,
            color: onTap != null ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMonthChips() {
    final now = DateTime.now();
    // Show quick jumps: This Month, Last Month, 2 months ago
    final quickMonths = <_QuickMonth>[];
    for (int i = 0; i < 3; i++) {
      var m = now.month - i;
      var y = now.year;
      if (m < 1) {
        m += 12;
        y--;
      }
      final label = i == 0
          ? 'Ce Mois'
          : i == 1
              ? 'Mois Dernier'
              : _monthNames[m - 1].substring(0, 3);
      quickMonths.add(_QuickMonth(y, m, label));
    }

    return Row(
      children: quickMonths.map((qm) {
        final isActive = _currentMonth == qm.month && _currentYear == qm.year;
        return Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                setState(() {
                  _currentMonth = qm.month;
                  _currentYear = qm.year;
                  _isMonthMode = true;
                });
                _loadMonthStats();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  qm.label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatisticsContent(StatisticsEntity stats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── Summary Cards Row (staggered) ─────────────────
          Row(
            children: [
              Expanded(child: AnimatedFadeSlide(delay: staggerDelay(0), offset: const Offset(0, 40), child: _summaryCard('Chiffre d\'Affaires', appCurrencyFormat.format(stats.totalRevenue), Icons.attach_money_rounded, AppTheme.successColor, stats.revenueGrowthPercent))),
              SizedBox(width: 12.w),
              Expanded(child: AnimatedFadeSlide(delay: staggerDelay(1), offset: const Offset(0, 40), child: _summaryCard('Coût d\'Achat', appCurrencyFormat.format(stats.totalPurchaseCost), Icons.shopping_cart_outlined, AppTheme.warningColor, null))),
              SizedBox(width: 12.w),
              Expanded(child: AnimatedFadeSlide(delay: staggerDelay(2), offset: const Offset(0, 40), child: _summaryCard('Bénéfice Net', appCurrencyFormat.format(stats.netProfit), Icons.trending_up_rounded, AppTheme.secondaryColor, stats.profitGrowthPercent))),
              SizedBox(width: 12.w),
              Expanded(child: AnimatedFadeSlide(delay: staggerDelay(3), offset: const Offset(0, 40), child: _summaryCard('Commande Moy.', appCurrencyFormat.format(stats.averageOrderValue), Icons.receipt_outlined, AppTheme.accentColor, null))),
            ],
          ),
          SizedBox(height: 20.h),

          // ─── Revenue vs Cost vs Profit Bar Chart ───────────
          AnimatedFadeSlide(
            delay: staggerDelay(4),
            duration: const Duration(milliseconds: 700),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildRevenueBreakdownChart(stats),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: _buildCategoryHorizontalBars(stats),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ─── Daily Activity + Top Products ─────────────────
          AnimatedFadeSlide(
            delay: staggerDelay(5),
            duration: const Duration(milliseconds: 700),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: DailyActivityChart(salesData: stats.salesOverTime),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: _buildTopProductsList(stats),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ─── Profit Analysis Card ──────────────────────────
          AnimatedFadeSlide(
            delay: staggerDelay(6),
            duration: const Duration(milliseconds: 700),
            child: ProfitAnalysisCard(stats: stats),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color, double? growth) {
    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          AppIconBox(icon: icon, color: color),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
                    ),
                    if (growth != null) ...[
                      SizedBox(width: 6.w),
                      _growthBadge(growth),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthBadge(double growth) {
    final isPositive = growth >= 0;
    final color = growth == 0
        ? Colors.grey
        : isPositive
            ? AppTheme.successColor
            : AppTheme.dangerColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildRevenueBreakdownChart(StatisticsEntity stats) {
    final revenue = stats.totalRevenue;
    final cost = stats.totalPurchaseCost;
    final profit = stats.netProfit;

    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition du Chiffre d\'Affaires',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 220.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: revenue > 0 ? revenue * 1.2 : 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: revenue > 0 ? revenue / 4 : 25,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55.w,
                      getTitlesWidget: (value, meta) => Text(
                        formatCompactNumber(value),
                        style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36.h,
                      getTitlesWidget: (value, meta) {
                        final labels = ['CA', 'Coût', 'Bénéfice'];
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                      toY: revenue,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppTheme.successColor, Color(0xFF2ECC71)],
                      ),
                      width: 40.w,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                    ),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                      toY: cost,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppTheme.warningColor, Color(0xFFF1C40F)],
                      ),
                      width: 40.w,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                    ),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                      toY: profit > 0 ? profit : 0,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppTheme.secondaryColor, Color(0xFF5DADE2)],
                      ),
                      width: 40.w,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                    ),
                  ]),
                ],
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
            ),
          ),
          SizedBox(height: 12.h),
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _chartLegend('CA', appCurrencyFormat.format(revenue), AppTheme.successColor),
              _chartLegend('Coût', appCurrencyFormat.format(cost), AppTheme.warningColor),
              _chartLegend('Bénéfice', appCurrencyFormat.format(profit), AppTheme.secondaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary)),
            Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryHorizontalBars(StatisticsEntity stats) {
    final categories = stats.salesByCategory;
    final maxRevenue = categories.isEmpty
        ? 1.0
        : categories.first.revenue;

    const colors = [
      AppTheme.secondaryColor,
      AppTheme.successColor,
      AppTheme.accentColor,
      AppTheme.warningColor,
      AppTheme.dangerColor,
      Color(0xFF8E44AD),
      Color(0xFF16A085),
      Color(0xFF2980B9),
    ];

    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CA par Catégorie',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20.h),
          if (categories.isEmpty)
            SizedBox(
              height: 200.h,
              child: Center(
                child: Text(
                  'Aucune donnée par catégorie',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp),
                ),
              ),
            )
          else
            ...categories.take(6).toList().asMap().entries.map((entry) {
              final cat = entry.value;
              final progress = maxRevenue > 0 ? cat.revenue / maxRevenue : 0.0;
              final color = colors[entry.key % colors.length];
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cat.category,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          appCurrencyFormat.format(cat.revenue),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8.h,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${cat.quantity} units • ${appCurrencyFormat.format(cat.profit)} profit',
                      style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTopProductsList(StatisticsEntity stats) {
    final bestSellers = stats.bestSellingProducts;

    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meilleurs Produits',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${bestSellers.length} articles',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (bestSellers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Text(
                  'Aucune vente cette période',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp),
                ),
              ),
            )
          else
            ...bestSellers.take(8).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final product = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 26.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        gradient: idx < 3
                            ? LinearGradient(
                                colors: [
                                  [const Color(0xFFFFD700), const Color(0xFFFFA000)],
                                  [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
                                  [const Color(0xFFCD7F32), const Color(0xFFA0522D)],
                                ][idx],
                              )
                            : null,
                        color: idx >= 3 ? Colors.grey.shade100 : null,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: idx < 3 ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${product.totalQuantitySold} unités',
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      appCurrencyFormat.format(product.totalRevenue),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _QuickMonth {
  final int year;
  final int month;
  final String label;
  _QuickMonth(this.year, this.month, this.label);
}
