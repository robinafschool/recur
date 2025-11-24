import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable tag chip widget
class TagChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const TagChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: textColor ?? AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

