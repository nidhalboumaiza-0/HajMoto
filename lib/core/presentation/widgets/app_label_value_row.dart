import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';

/// A label–value row used in totals sections, metric summaries, etc.
///
/// Supports an optional [isBold] / [isLarge] style for emphasis (e.g. grand totals).
class AppLabelValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isLarge;
  final Color? valueColor;

  const AppLabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.isLarge = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16.sp : 13.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 18.sp : 13.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? (isBold ? AppTheme.primaryColor : AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
