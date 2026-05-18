import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';

/// Snack bar type
enum SnackType { success, error, warning, info }

/// AppSnackBar – beautiful, consistent snack bars across the whole app.
///
/// Usage:
/// ```dart
/// AppSnackBar.success(context, 'Produit ajouté !');
/// AppSnackBar.error(context, 'Une erreur est survenue.');
/// AppSnackBar.warning(context, 'Stock faible !');
/// AppSnackBar.info(context, 'Chargement en cours…');
/// ```
class AppSnackBar {
  AppSnackBar._();

  // ─────────────────────────── Public shortcuts ──────────────────────────

  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(context, message: message, title: title, type: SnackType.success, duration: duration);

  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(context, message: message, title: title, type: SnackType.error, duration: duration);

  static void warning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(context, message: message, title: title, type: SnackType.warning, duration: duration);

  static void info(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(context, message: message, title: title, type: SnackType.info, duration: duration);

  // ─────────────────────────── Core implementation ───────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    String? title,
    required SnackType type,
    required Duration duration,
  }) {
    if (!context.mounted) return;

    final cfg = _config(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          width: 420.w.clamp(280.0, 500.0),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          content: _SnackBarBody(
            message: message,
            title: title,
            config: cfg,
          ),
        ),
      );
  }

  static _SnackBarConfig _config(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackBarConfig(
          background: AppTheme.successColor,
          accent: const Color(0xFF1E8449),
          icon: Icons.check_circle_rounded,
          label: 'Succès',
        );
      case SnackType.error:
        return _SnackBarConfig(
          background: AppTheme.dangerColor,
          accent: const Color(0xFFC0392B),
          icon: Icons.error_rounded,
          label: 'Erreur',
        );
      case SnackType.warning:
        return _SnackBarConfig(
          background: AppTheme.warningColor,
          accent: const Color(0xFFD68910),
          icon: Icons.warning_amber_rounded,
          label: 'Attention',
        );
      case SnackType.info:
        return _SnackBarConfig(
          background: AppTheme.secondaryColor,
          accent: const Color(0xFF2E86C1),
          icon: Icons.info_rounded,
          label: 'Info',
        );
    }
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────

class _SnackBarConfig {
  final Color background;
  final Color accent;
  final IconData icon;
  final String label;

  const _SnackBarConfig({
    required this.background,
    required this.accent,
    required this.icon,
    required this.label,
  });
}

class _SnackBarBody extends StatelessWidget {
  const _SnackBarBody({
    required this.message,
    required this.config,
    this.title,
  });

  final String message;
  final String? title;
  final _SnackBarConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: config.background.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(width: 5, color: config.accent),

            // Icon area
            Container(
              color: config.accent.withValues(alpha: 0.25),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Center(
                child: Icon(config.icon, color: Colors.white, size: 22.sp),
              ),
            ),

            // Text area
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? config.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
