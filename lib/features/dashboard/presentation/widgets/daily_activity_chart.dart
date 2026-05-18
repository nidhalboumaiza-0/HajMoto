import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Daily Activity Bar Chart - Shows daily sales as vertical bars
class DailyActivityChart extends StatelessWidget {
  final List<SalesDataPoint> salesData;

  const DailyActivityChart({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité de Vente Quotidienne',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: salesData.isEmpty
                ? Center(
                    child: Text(
                      'Aucune donnée quotidienne',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp),
                    ),
                  )
                : BarChart(
                    _buildChartData(),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildChartData() {
    final maxVal = salesData.isEmpty
        ? 100.0
        : salesData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final barWidth = salesData.length <= 10
        ? 20.0.w
        : salesData.length <= 20
            ? 12.0.w
            : 6.0.w;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxVal * 1.2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxVal > 0 ? maxVal / 4 : 25,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50.w,
            getTitlesWidget: (value, meta) => Text(
              formatCompactNumber(value),
              style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _bottomInterval(),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < salesData.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    '${salesData[idx].date.day}/${salesData[idx].date.month}',
                    style: TextStyle(fontSize: 9.sp, color: AppTheme.textSecondary),
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
      barGroups: salesData.asMap().entries.map((entry) {
        final ratio = maxVal > 0 ? entry.value.value / maxVal : 0.0;
        final color = ratio > 0.7
            ? AppTheme.successColor
            : ratio > 0.35
                ? AppTheme.secondaryColor
                : AppTheme.secondaryColor.withValues(alpha: 0.6);
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.value,
              color: color,
              width: barWidth,
              borderRadius: BorderRadius.vertical(top: Radius.circular(3.r)),
            ),
          ],
        );
      }).toList(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIdx, rod, rodIdx) {
            final point = salesData[groupIdx];
            return BarTooltipItem(
              '${appShortDateFormat.format(point.date)}\n${appCurrencyFormat.format(point.value)}',
              TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w500),
            );
          },
        ),
      ),
    );
  }

  double _bottomInterval() {
    if (salesData.length <= 10) return 1;
    return (salesData.length / 10).ceilToDouble();
  }
}
