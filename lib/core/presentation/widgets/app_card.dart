import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A themed card with elevation 0, a thin grey border, and consistent radius.
/// Supports an optional hover lift effect for interactive cards.
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hoverEffect;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.hoverEffect = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: widget.hoverEffect && _isHovered
          ? const EdgeInsets.only(bottom: 2)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isHovered ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
        boxShadow: _isHovered && widget.hoverEffect
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: widget.padding != null
            ? Padding(padding: widget.padding!, child: widget.child)
            : widget.child,
      ),
    );

    if (!widget.hoverEffect) return card;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: card,
    );
  }
}
