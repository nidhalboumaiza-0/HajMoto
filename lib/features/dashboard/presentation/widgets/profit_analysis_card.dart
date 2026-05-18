import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';

/// Profit Analysis Card - Comprehensive profit metrics with visual indicators
class ProfitAnalysisCard extends StatelessWidget {
  final StatisticsEntity stats;

  const ProfitAnalysisCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final marginPct = stats.profitMarginPercent;
    final marginColor = marginPct >= 20
        ? AppTheme.successColor
        : marginPct >= 10
            ? AppTheme.warningColor
            : AppTheme.dangerColor;

    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyse des Bénéfices',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              // Profit Margin Gauge
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120.w,
                          height: 120.h,
                          child: CircularProgressIndicator(
                            value: (marginPct.clamp(0, 100)) / 100,
                            strokeWidth: 10.w,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(marginColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${marginPct.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: marginColor,
                              ),
                            ),
                            Text(
                              'Marge',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      marginPct >= 20
                          ? 'Marge Saine'
                          : marginPct >= 10
                              ? 'Marge Modérée'
                              : 'Marge Faible',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: marginColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              // Metrics
              Expanded(
                child: Column(
                  children: [
                    _metricRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Chiffre d\'Affaires',
                      value: appCurrencyFormat.format(stats.totalRevenue),
                      color: AppTheme.successColor,
                    ),
                    SizedBox(height: 12.h),
                    _metricRow(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Coût',
                      value: appCurrencyFormat.format(stats.totalPurchaseCost),
                      color: AppTheme.warningColor,
                    ),
                    SizedBox(height: 12.h),
                    _metricRow(
                      icon: Icons.trending_up_rounded,
                      label: 'Bénéfice Net',
                      value: appCurrencyFormat.format(stats.netProfit),
                      color: AppTheme.secondaryColor,
                    ),
                    SizedBox(height: 12.h),
                    _metricRow(
                      icon: Icons.receipt_outlined,
                      label: 'Commande Moy.',
                      value: appCurrencyFormat.format(stats.averageOrderValue),
                      color: AppTheme.accentColor,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              // Stock Summary
              Expanded(
                child: Column(
                  children: [
                    _metricRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Produits',
                      value: stats.totalProducts.toString(),
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 12.h),
                    _metricRow(
                      icon: Icons.receipt_long_rounded,
                      label: 'Nombre de Ventes',
                      value: stats.totalSales.toString(),
                      color: AppTheme.secondaryColor,
                    ),
                    SizedBox(height: 12.h),
                    _metricRow(
                      icon: Icons.warning_amber_rounded,
                      label: 'Stock Faible',
                      value: stats.lowStockCount.toString(),
                      color: AppTheme.warningColor,
                    ),
                    SizedBox(height: 12.h),
                    _metricRow(
                      icon: Icons.remove_shopping_cart_outlined,
                      label: 'Rupture de Stock',
                      value: stats.outOfStockCount.toString(),
                      color: AppTheme.dangerColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
