import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// An icon inside a tinted rounded-rectangle background.
///
/// Used in stat cards and other places where an icon needs a subtle colour accent.
class AppIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double? size;

  const AppIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 20.sp;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
