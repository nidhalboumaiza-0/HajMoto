import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';

/// A professional pagination bar widget.
/// Shows  ◀ [1] [2] [3] … ▶  controls, item range info, and a page-size selector.
class AppPaginationBar extends StatelessWidget {
  const AppPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
    this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 15, 25, 50],
  });

  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final List<int> pageSizeOptions;

  int get _totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();
  int get _from => totalItems == 0 ? 0 : currentPage * pageSize + 1;
  int get _to => ((currentPage + 1) * pageSize).clamp(0, totalItems);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          // Items info label
          Text(
            totalItems == 0
                ? 'Aucun résultat'
                : '$_from – $_to  sur  $totalItems résultats',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),

          // Page-size selector
          if (onPageSizeChanged != null) ...[
            Text(
              'Lignes :',
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(width: 6.w),
            _PageSizeDropdown(
              value: pageSize,
              options: pageSizeOptions,
              onChanged: onPageSizeChanged!,
            ),
            SizedBox(width: 20.w),
          ],

          // ◀ Prev
          _NavButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 0,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          SizedBox(width: 4.w),

          // Page number buttons
          ...List.generate(_buildRange().length, (i) {
            final page = _buildRange()[i];
            return Padding(
              padding: EdgeInsets.only(right: i < _buildRange().length - 1 ? 4.w : 0),
              child: _PageNumberButton(
                page: page,
                isActive: page == currentPage,
                onTap: () => onPageChanged(page),
              ),
            );
          }),
          SizedBox(width: 4.w),

          // ▶ Next
          _NavButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < _totalPages - 1,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  /// Returns up to 5 page indices centred around [currentPage].
  List<int> _buildRange() {
    if (_totalPages <= 1) return [];
    final windowSize = 5.clamp(1, _totalPages);
    int start = (currentPage - windowSize ~/ 2).clamp(0, _totalPages - windowSize);
    return List.generate(windowSize, (i) => start + i);
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

class _PageSizeDropdown extends StatelessWidget {
  const _PageSizeDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      isDense: true,
      underline: const SizedBox(),
      style: TextStyle(fontSize: 12.sp, color: AppTheme.textPrimary),
      items: options
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text('$s', style: TextStyle(fontSize: 12.sp)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: BoxConstraints(minWidth: 30.w, minHeight: 30.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '${page + 1}',
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive ? Colors.white : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 30.w,
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: enabled ? AppTheme.textPrimary : Colors.grey.shade400,
        ),
      ),
    );
  }
}
