import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Revenue Trend Area Chart - Smooth gradient area chart for revenue curves
class RevenueTrendChart extends StatefulWidget {
  final List<SalesDataPoint> salesData;
  final List<SalesDataPoint> profitData;

  const RevenueTrendChart({
    super.key,
    required this.salesData,
    required this.profitData,
  });

  @override
  State<RevenueTrendChart> createState() => _RevenueTrendChartState();
}

class _RevenueTrendChartState extends State<RevenueTrendChart> {
  bool _showSales = true;
  bool _showProfit = true;

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
                'Tendance CA & Bénéfice',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _toggleChip('Ventes', AppTheme.secondaryColor, _showSales, (v) {
                setState(() => _showSales = v);
              }),
              SizedBox(width: 8.w),
              _toggleChip('Bénéfice', AppTheme.successColor, _showProfit, (v) {
                setState(() => _showProfit = v);
              }),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 280.h,
            child: widget.salesData.isEmpty
                ? Center(
                    child: Text(
                      'Aucune donnée disponible',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp),
                    ),
                  )
                : LineChart(
                    _buildChartData(),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, Color color, bool active, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: active ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: active ? color : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: active ? color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    final salesSpots = widget.salesData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final profitSpots = widget.profitData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateInterval(),
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
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.h,
            interval: _calculateBottomInterval(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.salesData.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    appShortDateFormat.format(widget.salesData[index].date),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
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
      lineBarsData: [
        if (_showSales)
          LineChartBarData(
            spots: salesSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppTheme.secondaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: salesSpots.length <= 15,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.r,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.secondaryColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.secondaryColor.withValues(alpha: 0.25),
                  AppTheme.secondaryColor.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        if (_showProfit && profitSpots.isNotEmpty)
          LineChartBarData(
            spots: profitSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppTheme.successColor,
            barWidth: 3,
            dotData: FlDotData(
              show: profitSpots.length <= 15,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.r,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.successColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.successColor.withValues(alpha: 0.20),
                  AppTheme.successColor.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isSales = spot.barIndex == 0 && _showSales;
              final color = isSales ? AppTheme.secondaryColor : AppTheme.successColor;
              final label = isSales ? 'Ventes' : 'Bénéfice';
              return LineTooltipItem(
                '$label: ${appCurrencyFormat.format(spot.y)}',
                TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  double _calculateInterval() {
    if (widget.salesData.isEmpty) return 100;
    final maxVal = widget.salesData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return 100;
    return (maxVal / 5).ceilToDouble();
  }

  double _calculateBottomInterval() {
    if (widget.salesData.length <= 7) return 1;
    return (widget.salesData.length / 7).ceilToDouble();
  }
}
