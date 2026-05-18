import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/features/dashboard/presentation/bloc/dashboard_event.dart';

/// Enhanced Period Selector Widget
/// Provides quick presets, month picker, and custom date range selection
class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final int? selectedMonth;
  final int? selectedYear;
  final ValueChanged<DashboardEvent> onEventSelected;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onEventSelected,
    this.selectedMonth,
    this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildQuickPresets(),
        SizedBox(width: 12.w),
        _buildMonthPicker(context),
      ],
    );
  }

  Widget _buildQuickPresets() {
    final presets = <String, DashboardEvent>{
      'Global': const LoadDashboardEvent(),
      'Aujourd\'hui': const LoadDailyStatsEvent(),
      '7 Jours': const LoadLastNDaysStatsEvent(7),
      '30 Jours': const LoadLastNDaysStatsEvent(30),
      'Mois': const LoadMonthlyStatsEvent(),
      'Année': const LoadYearlyStatsEvent(),
    };

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: presets.entries.map((entry) {
          final isSelected = _isPresetSelected(entry.key);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(6.r),
                onTap: () => onEventSelected(entry.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
                        : null,
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    final now = DateTime.now();
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                     'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];

    return PopupMenuButton<_MonthYear>(
      offset: Offset(0, 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selectedMonth != null ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selectedMonth != null ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16.sp,
              color: selectedMonth != null ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              selectedMonth != null
                  ? '${months[selectedMonth! - 1]} ${selectedYear ?? now.year}'
                  : 'Choisir Mois',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: selectedMonth != null ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18.sp,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_MonthYear>>[];
        // Current year and previous year
        for (final year in [now.year, now.year - 1]) {
          items.add(PopupMenuItem(
            enabled: false,
            height: 32.h,
            child: Text(
              year.toString(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ));
          final maxMonth = year == now.year ? now.month : 12;
          for (int m = maxMonth; m >= 1; m--) {
            final isSelected = selectedMonth == m && selectedYear == year;
            items.add(PopupMenuItem(
              value: _MonthYear(year, m),
              height: 36.h,
              child: Row(
                children: [
                  if (isSelected)
                    Icon(Icons.check_rounded, size: 16.sp, color: AppTheme.primaryColor)
                  else
                    SizedBox(width: 16.w),
                  SizedBox(width: 8.w),
                  Text(
                    months[m - 1],
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ));
          }
          if (year != now.year - 1) {
            items.add(const PopupMenuDivider());
          }
        }
        return items;
      },
      onSelected: (monthYear) {
        onEventSelected(LoadStatsForMonthEvent(
          year: monthYear.year,
          month: monthYear.month,
        ));
      },
    );
  }

  bool _isPresetSelected(String key) {
    switch (key) {
      case 'Global':
        return selectedPeriod == 'overall';
      case 'Aujourd\'hui':
        return selectedPeriod == 'daily';
      case '7 Jours':
        return selectedPeriod == 'Last 7 days';
      case '30 Jours':
        return selectedPeriod == 'Last 30 days';
      case 'Mois':
        return selectedPeriod == 'monthly';
      case 'Année':
        return selectedPeriod == 'yearly';
      default:
        return false;
    }
  }
}

class _MonthYear {
  final int year;
  final int month;
  _MonthYear(this.year, this.month);
}
