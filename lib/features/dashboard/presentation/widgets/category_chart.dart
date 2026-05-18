import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Category Breakdown Chart - Donut chart showing revenue by category
class CategoryBreakdownChart extends StatelessWidget {
  final List<CategorySalesData> data;

  const CategoryBreakdownChart({super.key, required this.data});

  static const _colors = [
    AppTheme.secondaryColor,
    AppTheme.successColor,
    AppTheme.accentColor,
    AppTheme.warningColor,
    AppTheme.dangerColor,
    Color(0xFF8E44AD),
    Color(0xFF16A085),
    Color(0xFF2980B9),
  ];

  @override
  Widget build(BuildContext context) {
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
          if (data.isEmpty)
            SizedBox(
              height: 200.h,
              child: Center(
                child: Text(
                  'Aucune donnée par catégorie',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sections: data.take(8).toList().asMap().entries.map((entry) {
                    final totalRevenue = data.fold<double>(0, (sum, c) => sum + c.revenue);
                    final pct = totalRevenue > 0
                        ? (entry.value.revenue / totalRevenue) * 100
                        : 0.0;
                    return PieChartSectionData(
                      value: entry.value.revenue,
                      color: _colors[entry.key % _colors.length],
                      radius: 45.r,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 35.r,
                  sectionsSpace: 2,
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
              ),
            ),
            SizedBox(height: 16.h),
            // Legend
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: data.take(8).toList().asMap().entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: _colors[entry.key % _colors.length],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      entry.value.category,
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      appCurrencyFormat.format(entry.value.revenue),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
