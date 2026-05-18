import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Monthly Revenue Chart - Grouped bar chart showing revenue & profit by month
class MonthlyRevenueChart extends StatelessWidget {
  final List<MonthlySalesData> data;

  const MonthlyRevenueChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CA & Bénéfice Mensuels',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _legendItem('CA', AppTheme.secondaryColor),
              SizedBox(width: 16.w),
              _legendItem('Bénéfice', AppTheme.successColor),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 250.h,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'Aucune donnée mensuelle',
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

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  BarChartData _buildChartData() {
    final maxRevenue = data.isEmpty
        ? 100.0
        : data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    final barWidth = data.length <= 6 ? 16.0.w : 10.0.w;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxRevenue * 1.2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxRevenue > 0 ? maxRevenue / 4 : 25,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 55.w,
            getTitlesWidget: (value, meta) => Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Text(
                formatCompactNumber(value),
                style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < data.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    data[idx].shortLabel,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
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
      barGroups: data.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.revenue,
              color: AppTheme.secondaryColor,
              width: barWidth,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            ),
            BarChartRodData(
              toY: entry.value.profit > 0 ? entry.value.profit : 0,
              color: AppTheme.successColor,
              width: barWidth,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            ),
          ],
          barsSpace: 3.w,
        );
      }).toList(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final month = data[groupIndex].label;
            final label = rodIndex == 0 ? 'CA' : 'Bénéfice';
            return BarTooltipItem(
              '$month\n$label: ${appCurrencyFormat.format(rod.toY)}',
              TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
    );
  }
}
